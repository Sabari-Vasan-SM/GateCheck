# GateCheck

Small project with a simple static `login.html`, a `site_checker.rb` link-checker using Selenium + HTTP pre-checks, and a `test_login.rb` integration test that runs against the local `login.html`.

## Prerequisites

- Ruby (2.5+)
- Chrome browser
- chromedriver (matching Chrome version) available on PATH
- Bundler (`gem install bundler`)

## Setup

1. Install gems:

```powershell
# from project root
bundle install
```

2. (Optional) Start the static server to manually browse the page:

```powershell
ruby serve.rb
# open http://localhost:4567/login.html
```

## Run the link checker

Basic usage:

```powershell
ruby site_checker.rb --url https://yourwebsite.com --wait 2 --no-headless
```

Environment variables supported as well:

```powershell
$env:BASE_URL = 'https://example.com'; $env:WAIT_TIME = '1.5'; $env:HEADLESS = 'true'
ruby site_checker.rb
```

## Run the login test

This test starts a small local HTTP server and opens the `login.html` page in headless Chrome.

```powershell
ruby test_login.rb
```

If tests fail, check that `chromedriver` is on PATH and that your Chrome version matches.

## Notes

- `site_checker.rb` will pre-flight links with an HTTP HEAD (with GET fallback) and skip navigation for responses >= 400.
- `test_login.rb` runs headless by default and serves the project directory on port 4567.