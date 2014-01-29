module Puppet::Parser::Functions
  newfunction(:local_users, :type => :rvalue, :doc => <<-EOS
Accepts an array of allowed users/groups names & a list of all users.
Returns a hash of allowed users.
    EOS
  ) do |arguments|
    Puppet::Parser::Functions.autoloader.loadall
    raise(Puppet::ParseError, "local_users(): Wrong number of arguments " +
      "given (#{arguments.size} for 2)") if arguments.size != 2

    result = Hash.new
    lookup = arguments[0]
    users = arguments[1]

    unless lookup.is_a?(Array)
      raise(Puppet::ParseError, 'local_users(): Requires an Array to work with')
    end

    unless users.is_a?(Hash)
      raise(Puppet::ParseError, 'local_users(): Requires a Hash to work with')
    end

    lookup.each do |lval|
        for name in users.keys
          if users[name]['groups'].kind_of?(Array)
            if users[name]['groups'].include? lval
              lookup.push(name)
            end
          end
        end
    end

    lookup.each do |lval|
      users.each do |key,value|
        if key == lval
          result[key] = value
        end
      end
    end

  return result
  end
end

# vim: set ts=2 sw=2 et :
