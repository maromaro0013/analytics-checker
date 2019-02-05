require "json"
require "net/http"

def http_get_response(uri, client_id)
  uri = URI.parse(uri)
  http_request = Net::HTTP::Get.new(uri.request_uri)
  http_request[:client] = client_id

  http = Net::HTTP.new(uri.host, uri.port)
  http.request(http_request)
end

cluster_ips = {
  "2": "54.65.13.184",
  "3": "54.64.139.162",
  "4": "52.68.222.125",
  "5": "52.196.68.30",
  "6": "13.230.83.25"
}

ip = cluster_ips[ARGV[0].to_sym]
client_id = ARGV[1]

v1_uri = "http://#{ip}/statistics/v1?mode=time_series&division=monthly&item=pv&device=all&show=now"
v2_uri = "http://#{ip}/statistics/v2?mode=time_series&division=monthly&item=pv&device=all&show=now"

begin
  ret = http_get_response(v1_uri, client_id)
  v1_result = JSON.parse(ret.body)
  ret = http_get_response(v2_uri, client_id)
  v2_result = JSON.parse(ret.body)
rescue
  p "#{client_id} - error"
  return
end

v1_pvs = v1_result["value"].map { |val| [val["date"], val["pv"]] }.to_h
v2_pvs = v2_result["value"].map { |val| [val["date"], val["pv"]] }.to_h

v1_pvs.each { |key, val|
  p "#{client_id} - monthly pv difference: #{key}" if val != v2_pvs[key]
}

v1_previews = v1_result["value"].map { |val| [val["date"], val["pv_preview"]] }.to_h
v2_previews = v2_result["value"].map { |val| [val["date"], val["pv_preview"]] }.to_h

v1_previews.each { |key, val|
  p "#{client_id} - monthly preview difference: #{key}" if val != v2_previews[key]
}
