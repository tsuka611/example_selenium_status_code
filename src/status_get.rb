#!/usr/bin/env ruby

if ARGV.length != 1
  puts "#{$0} TargetURL"
  exit 1
end

require "bundler/setup"
Bundler.require

Selenium::WebDriver::Remote::Http::Default.new

target_url = ARGV[0]

http_client = Selenium::WebDriver::Remote::Http::Default.new
http_client.read_timeout = 60

browser_name = 'chrome'
remote_url = 'http://selenium:4444/wd/hub'

logging_prefs = {
  driver: 'ALL',
  server: 'OFF',
  browser: 'ALL',
  performance: 'ALL'
}

caps = Selenium::WebDriver::Remote::Capabilities.new(
  browser_name: browser_name,
  javascript_enabled: true,
  css_selectors_enabled: true,
  takes_screenshot: true,
  native_events: true,
  proxy: nil,
  loggingPrefs: logging_prefs
)

driver = nil
begin
  # seleniumの起動
  driver = Selenium::WebDriver.for :remote, desired_capabilities: caps, url: remote_url, http_client: http_client

  # 対象ページへリクエスト
  print "getting [#{target_url}] ... "
  driver.get target_url
  puts "Okey!"

  # ブラウザのアドレスバーに表示されるURLを取得
  current_url = driver.current_url
  puts "latest URL ... [#{current_url}]"

  # パフォーマンスログを取得
  # driver.manage.logsは揮発するらしく、一度取得しておく必要がある。
  performance_logs = driver.manage.logs.get(:performance).map do |log|
    next JSON.parse log.message, symbolize_names: true
    rescue JSON::ParserError
    next nil
  end.compact.map { |e| e[:message] }.compact

  # 処理をごにょにょする -- ここから
  def check_unreachable? current_url, logs
    logs.each do |log|
      next if log[:method] != 'Page.frameNavigated'

      params = log[:params] || {}
      frame = params[:frame] || {}
      return true if frame[:unreachableUrl] == current_url
    end
    false
  end

  def extract_status_code current_url, logs
    logs.each do |log|
      next if log[:method] != 'Network.responseReceived'

      params = log[:params] || {}
      response = params[:response] || {}
      next if response[:url] != current_url

      return response[:status].to_i
    end
    0
  end
  # 処理をごにょにょする -- ここまで

  # ステータスコードを判定する
  if check_unreachable? current_url, performance_logs
    puts "Browser cannot reach website!!"
  else
    status_code = extract_status_code current_url, performance_logs
    if status_code == 0
      puts "Cannot get http status code..."
    else
      puts "Website returns status code... [#{status_code}]"
    end
  end

ensure
  driver&.quit
end
