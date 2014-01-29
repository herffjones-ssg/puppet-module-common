# dnslookup.rb
# does a DNS lookup and returns an array of strings of the results

require 'resolv'

module Puppet::Parser::Functions
    newfunction(:dnslookup, :type => :rvalue) do |args|
        result = []
        result = Resolv.new.getaddresses(args[0])
        return result
    end
end
