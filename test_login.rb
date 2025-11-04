require 'selenium-webdriver'
require 'webrick'

# Simple helper to start a static file server serving this repo's directory
def start_static_server(port = 4567)
  root = File.expand_path(File.dirname(__FILE__))
  server = WEBrick::HTTPServer.new(:Port => port, :DocumentRoot => root, :AccessLog => [], :Logger => WEBrick::Log.new(File::NULL))
  Thread.new { server.start }
  server
end

PORT = 4567
server = start_static_server(PORT)

begin
  chrome_opts = Selenium::WebDriver::Chrome::Options.new
  chrome_opts.add_argument('--headless')
  chrome_opts.add_argument('--disable-gpu')

  driver = Selenium::WebDriver.for :chrome, options: chrome_opts

  url = "http://localhost:#{PORT}/login.html"
  driver.navigate.to url

  username_input = driver.find_element(id: 'username')
  password_input = driver.find_element(id: 'password')
  login_button = driver.find_element(tag_name: 'button')
  message = driver.find_element(id: 'message')

  # ========== Test Case 1: Valid Login ==========
  username_input.send_keys('admin')
  password_input.send_keys('1234')
  login_button.click
  sleep 0.5
  if message.text == 'Login successful!'
    puts "✅ Test Case 1 Passed: Valid login works."
  else
    puts "❌ Test Case 1 Failed: Expected 'Login successful!' but got '#{message.text}'"
  end

  # ========== Test Case 2: Invalid Login ==========
  username_input.clear
  password_input.clear
  username_input.send_keys('wrong')
  password_input.send_keys('pass')
  login_button.click
  sleep 0.5
  if message.text == 'Invalid credentials!'
    puts "✅ Test Case 2 Passed: Invalid login handled correctly."
  else
    puts "❌ Test Case 2 Failed: Expected 'Invalid credentials!' but got '#{message.text}'"
  end

ensure
  begin
    driver.quit if driver
  rescue => _e
  end
  begin
    server.shutdown if server
  rescue => _e
  end
end
