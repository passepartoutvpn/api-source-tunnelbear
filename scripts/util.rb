def read_tls_wrap(strategy, dir, file, from = 0, count = 16)
    lines = File.foreach(file)
    to = from + count
    key = ""
    lines.with_index { |line, n|
        next if n < from or n >= to
        key << line.strip
    }
    key64 = [[key].pack("H*")].pack("m0")

    return {
        strategy: strategy,
        key: {
            dir: dir,
            data: key64
        }
    }
end
