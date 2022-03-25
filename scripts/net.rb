require "json"
require "resolv"
require "ipaddr"
require "nokogiri"

cwd = File.dirname(__FILE__)
Dir.chdir(cwd)
load "country_codes.rb"

###

template = File.read("../template/servers.html")
ca = File.read("../static/ca.crt")
client = File.read("../static/client.crt")
key = File.read("../static/client.key")

servers = Nokogiri::HTML.parse(template)
country_names = servers.css(".country").map(&:text).map(&:strip)

cfg = {
  ca: ca,
  clientCertificate: client,
  clientKey: key,
  cipher: "AES-256-CBC",
  digest: "SHA256",
  compressionFraming: 1,
  keepAliveSeconds: 10,
  checksEKU: true
}

recommended = {
  id: "default",
  name: "Default",
  comment: "256-bit encryption",
  ovpn: {
    cfg: cfg,
    endpoints: [
      "UDP:443",
      "UDP:7011",
      "TCP:443"
    ]
  }
}
presets = [recommended]

defaults = {
  :username => "user@mail.com",
  :country => "US"
}

###

servers = []
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

  server = {
    :id => id,
    :country => country,
    :hostname => hostname,
    :addrs => addresses
  }
  servers << server
}

###

infra = {
  :servers => servers,
  :presets => presets,
  :defaults => defaults
}

puts infra.to_json
puts
