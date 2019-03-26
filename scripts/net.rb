require "json"
require "resolv"
require "ipaddr"

cwd = File.dirname(__FILE__)
Dir.chdir(cwd)

###

servers = File.foreach("../template/servers.csv")
ca = File.read("../template/ca.crt")
client = File.read("../template/client.crt")
key = File.read("../template/client.key")

cfg = {
    ca: ca,
    client: client,
    key: key,
    ep: ["UDP:443", "UDP:7011", "TCP:443"],
    cipher: "AES-256-CBC",
    auth: "SHA256",
    frame: 1,
    ping: 10,
    eku: true
}

recommended = {
    id: "default",
    name: "Default",
    comment: "256-bit encryption",
    cfg: cfg
}
presets = [recommended]

defaults = {
    :username => "user@mail.com",
    :pool => "us",
    :preset => "default"
}

###

pools = []
servers.with_index { |line, n|
    name, hostname = line.strip.split(",")
    country = hostname.split(".")[0].upcase

    addresses = nil
    if ARGV.length > 0 && ARGV[0] == "noresolv"
        addresses = []
        #addresses = ["1.2.3.4"]
    else
        addresses = Resolv.getaddresses(hostname)
    end
    addresses.map! { |a|
        IPAddr.new(a).to_i
    }

    id = hostname.split('.')[0]
    pool = {
        :id => id,
        :name => name,
        :country => country,
        :hostname => hostname,
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
