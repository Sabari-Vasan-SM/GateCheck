require 'selenium-webdriver'
require 'uri'

# ======================================
# CONFIG
# ======================================
BASE_URL = "https://yourwebsite.com"  # 🔁 change this to your site URL
WAIT_TIME = 2  # seconds to wait after opening each link

# ======================================
# SETUP
# ======================================
options = Selenium::WebDriver::Chrome::Options.new
options.add_argument('--start-maximized')
driver = Selenium::WebDriver.for :chrome, options: options

driver.navigate.to(BASE_URL)
sleep WAIT_TIME

# ======================================
# SCRAPE LINKS
# ======================================
links = driver.find_elements(tag_name: 'a').map { |a| a.attribute('href') }.compact.uniq

puts "🔗 Found #{links.size} links on #{BASE_URL}\n\n"

# ======================================
# CHECK EACH LINK
# ======================================
links.each_with_index do |link, i|
  begin
    # Skip if link is invalid or not http/https
    next if link.nil? || !link.start_with?("http")

    puts "👉 [#{i + 1}/#{links.size}] Checking: #{link}"

    driver.navigate.to(link)
    sleep WAIT_TIME

    # Check if page loaded correctly (no 404 in title or error text)
    if driver.title.downcase.include?("404") || driver.page_source.downcase.include?("not found")
      puts "❌ Page seems broken → #{link}\n\n"
    else
      puts "✅ Page loaded fine → #{driver.title}\n\n"
    end

  rescue => e
    puts "💥 Error visiting #{link}: #{e.message}\n\n"
  end
end

puts "🎯 Done! Checked #{links.size} links total."

driver.quit
