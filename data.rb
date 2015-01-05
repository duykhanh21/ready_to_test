require 'uri'
require "rubygems"
require "pry"
require "date"
proj = ARGV[0]
sprint = ARGV[1]
from = Date.parse(ARGV[2])
to = Date.parse(ARGV[3])
@user = ARGV[4]
@password = ARGV[5]

def fetch(proj, sprint, date)
  tomorrow = date.next.to_s
  reg = /total\"\:(\d+)/
  url = "https://#{proj}.atlassian.net/rest/api/2/search"
  jql = URI::escape('jql=status="Ready to Test" AND sprint='+ sprint + ' AND resolved >=' + date.to_s + ' AND resolved <' + tomorrow)
  res = `curl -s -D- -u #{@user}:#{@password} -X GET -H 'Content-Type: application/json' #{url}?#{jql}`.chomp

  "#{date.to_s}, #{reg.match(res)[1].to_i}"
end

result = []
(from..to).each do |date|
  result << fetch(proj, sprint, date)
end
print result.join("*")
