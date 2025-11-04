require 'selenium-webdriver'

# Create a Chrome WebDriver instance
driver = Selenium::WebDriver.for :chrome

# Open the local HTML login page
driver.navigate.to "file:///C:/path/to/your/login.html"  # <-- change this to your actual file path

# Find the elements
username_input = driver.find_element(id: 'username')
password_input = driver.find_element(id: 'password')
login_button = driver.find_element(tag_name: 'button')
message = driver.find_element(id: 'message')

# ========== Test Case 1: Valid Login ==========
username_input.send_keys('admin')
password_input.send_keys('1234')
login_button.click
sleep 1
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
sleep 1
if message.text == 'Invalid credentials!'
  puts "✅ Test Case 2 Passed: Invalid login handled correctly."
else
  puts "❌ Test Case 2 Failed: Expected 'Invalid credentials!' but got '#{message.text}'"
end

# Close browser
driver.quit
