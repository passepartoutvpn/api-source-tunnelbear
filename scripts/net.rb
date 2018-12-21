require "json"
require "resolv"
require "ipaddr"

cwd = File.dirname(__FILE__)
Dir.chdir(cwd)

servers = File.foreach("../template/servers.csv")

ca = File.read("../certs/ca.pem")
client = File.read("../certs/client.pem")
key = File.read("../certs/client.key")

###

pools = []
servers.with_index { |line, n|
    name, hostname = line.strip.split(",")
    country = hostname.split(".")[0].upcase

    #print "Resolving #{hostname} ..."
    addresses = Resolv.getaddresses(hostname)
    #addresses = ["1.2.3.4"]
    #addresses = []

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

strong = {
    id: "default",
    name: "Default",
    comment: "256-bit encryption",
    cfg: {
        ep: ["UDP:443", "UDP:7011", "TCP:443"],
        cipher: "AES-256-CBC",
        auth: "SHA256",
        ca: ca,
        client: client,
        key: key,
        frame: 1,
        ping: 10,
    }
}
presets = [strong]

defaults = {
    :username => "user@mail.com",
    :pool => "us",
    :preset => "default"
}

###

infra = {
    :pools => pools,
    :presets => presets,
    :defaults => defaults
}

puts infra.to_json
puts
