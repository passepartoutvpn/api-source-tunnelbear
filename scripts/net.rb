require "json"
require "resolv"
require "ipaddr"
require "nokogiri"

cwd = File.dirname(__FILE__)
Dir.chdir(cwd)
load "country_codes.rb"

###

servers_html = File.read("../template/servers.html")
ca = File.read("../static/ca.crt")
client = File.read("../static/client.crt")
key = File.read("../static/client.key")

servers = Nokogiri::HTML.parse(servers_html)
country_names = servers.css(".country").map(&:text).map(&:strip)

cfg = {
  ca: ca,
  client: client,
  key: key,
  ep: [
    "UDP:443",
    "UDP:7011",
    "TCP:443"
  ],
  cipher: "AES-256-CBC",
  auth: "SHA256",
  frame: 1,
  ping: 10,
  eku: true
}

external = {
  hostname: "${id}.lazerpenguin.com"
}

recommended = {
  id: "default",
  name: "Default",
  comment: "256-bit encryption",
  cfg: cfg,
  external: external
}
presets = [recommended]

defaults = {
  :username => "user@mail.com",
  :pool => "us",
  :preset => "default"
}

###

pools = []
country_names.each { |name|
  name.strip!
  country = name.to_country_code
  next if country.nil?
  id = country.downcase
  hostname = "#{id}.lazerpenguin.com"

  addresses = nil
  if ARGV.include? "noresolv"
    addresses = []
    #addresses = ["1.2.3.4"]
  else
    addresses = Resolv.getaddresses(hostname)
  end
  addresses.map! { |a|
    IPAddr.new(a).to_i
  }

  pool = {
    :id => id,
    :country => country,
    :addrs => addresses
  }
  pools << pool
}

###

infra = {
  :pools => pools,
  :presets => presets,
  :defaults => defaults
}

puts infra.to_json
puts
