require 'barnes'
require 'minitest/autorun'
require 'pathname'

require 'wait_for_it'
require 'simplecov'
SimpleCov.start

def fixture_path(path = "")
  return Pathname.new(__dir__).join("fixtures").join(path).expand_path
end


require 'socket'
require 'timeout'

def is_port_open?(ip, port)
  begin
    Timeout::timeout(1) do
      begin
        s = TCPServer.new(ip, port)
        s.listen(1024)
        s.close
        return true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        return false
      end
    end
  rescue Timeout::Error
  end

  return false
end

def next_open_port
  (9292...10000).each do |port|
    if is_port_open?('localhost', port)
      return port
    end
  end
  raise "Could not find a port"
end
