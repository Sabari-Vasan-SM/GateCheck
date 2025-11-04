require 'selenium-webdriver'
require 'uri'
require 'net/http'
require 'optparse'

# Default configuration (can be overridden via CLI)
options = {
  base_url: ENV['BASE_URL'] || 'https://yourwebsite.com',
  wait_time: (ENV['WAIT_TIME'] || 2).to_f,
  headless: (ENV['HEADLESS'] || 'true') == 'true',
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby site_checker.rb [options]"

  opts.on('-u', '--url URL', 'Base URL to crawl (overrides BASE_URL)') do |v|
    options[:base_url] = v
  end

  opts.on('-w', '--wait N', Float, 'Seconds to wait after opening each link') do |v|
    options[:wait_time] = v
  end

  opts.on('--[no-]headless', 'Run Chrome in headless mode (default: true)') do |v|
    options[:headless] = v
  end

  opts.on('-h', '--help', 'Show this help') do
    puts opts
    exit
  end
end.parse!

BASE_URL = options[:base_url]
WAIT_TIME = options[:wait_time]
HEADLESS = options[:headless]

def http_status_for(url, limit = 5)
  return nil if url.nil? || url.empty?
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = (uri.scheme == 'https')
  http.open_timeout = 5
  http.read_timeout = 5

  req = Net::HTTP::Head.new(uri.request_uri)
  begin
    resp = http.request(req)
    # Follow simple redirects
    if resp.is_a?(Net::HTTPRedirection) && resp['location'] && limit > 0
      return http_status_for(URI.join(url, resp['location']).to_s, limit - 1)
    end
    return resp.code.to_i
  rescue => _e
    # Some servers reject HEAD; try GET as fallback
    begin
      resp = http.get(uri.request_uri)
      return resp.code.to_i
    rescue => e2
      return nil
    end
  end
end

puts "🔎 Starting site check for: #{BASE_URL} (wait #{WAIT_TIME}s, headless=#{HEADLESS})\n\n"

# Setup Selenium WebDriver with Chrome options
chrome_opts = Selenium::WebDriver::Chrome::Options.new
chrome_opts.add_argument('--start-maximized')
if HEADLESS
  # Use both forms to maximize compatibility
  chrome_opts.add_argument('--headless')
  chrome_opts.add_argument('--disable-gpu')
end

driver = Selenium::WebDriver.for :chrome, options: chrome_opts

begin
  driver.navigate.to(BASE_URL)
  sleep WAIT_TIME

  # Get unique hrefs, normalize relative links
  anchors = driver.find_elements(tag_name: 'a')
  raw_links = anchors.map { |a| a.attribute('href') }
  links = raw_links.compact.uniq

  puts "🔗 Found #{links.size} links on #{BASE_URL}\n\n"

  links.each_with_index do |link, i|
    begin
      # Skip invalid or non-http(s) links
      next if link.nil? || link.strip == ''
      next if link.start_with?('mailto:') || link.start_with?('tel:') || link.start_with?('javascript:')

      # Normalize relative links
      if !(link.start_with?('http://') || link.start_with?('https://'))
        link = URI.join(BASE_URL, link).to_s rescue link
      end

      puts "👉 [#{i + 1}/#{links.size}] Checking: #{link}"

      status = http_status_for(link)
      if status.nil?
        puts "⚠️  Could not determine HTTP status for #{link} — will try to open in browser"
      else
        puts "ℹ️  HTTP status: #{status}"
        if status >= 400
          puts "❌ Broken link (HTTP #{status}) → #{link}\n\n"
          next
        end
      end

      # Use Selenium to load and do a shallow content check
      driver.navigate.to(link)
      sleep WAIT_TIME

      page_title = driver.title.to_s
      page_src = driver.page_source.to_s.downcase

      if page_title.downcase.include?('404') || page_src.include?('not found')
        puts "❌ Page seems broken → #{link}\n\n"
      else
        puts "✅ Page loaded fine → #{page_title}\n\n"
      end

    rescue => e
      puts "💥 Error visiting #{link}: #{e.class}: #{e.message}\n\n"
    end
  end

  puts "🎯 Done! Checked #{links.size} links total."
ensure
  driver.quit if driver
end
