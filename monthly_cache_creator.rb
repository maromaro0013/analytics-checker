require "json"
require "net/http"

def http_get_response(uri, client_id)
  uri = URI.parse(uri)
  http_request = Net::HTTP::Get.new(uri.request_uri)
  http_request[:client] = client_id

  http = Net::HTTP.new(uri.host, uri.port)
  http.request(http_request)
end

ip = {
  "2": "54.65.13.184",
  "3": "54.64.139.162",
  "4": "52.68.222.125",
  "5": "52.196.68.30",
  "6": "13.230.83.25"
}[ARGV[0].to_sym]

client_id = ARGV[1]

begin
  ["all", "mobile", "pc", "other"].each { |device|
    ["pv", "uu"].each { |item|
      v2_uri = "http://#{ip}/statistics/v2?mode=time_series&division=monthly&item=#{item}&device=#{device}&show=now"
      ret = http_get_response(v2_uri, client_id)
      v2_result = ret.body
      p v2_result
    }
  }
rescue
  p "#{client_id} - error"
  return
end
