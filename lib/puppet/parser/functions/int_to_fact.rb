module Puppet::Parser::Functions
  newfunction(:int_to_fact, :type => :rvalue, :doc => <<-EOS
    Takes one argument, the interface name, and returns it formatted for use
    with facter. Example: int_to_fact(bond0:0) would return 'ipaddress_bond0_0'
    EOS
  ) do |args|

    raise(Puppet::ParseError, "int_to_fact(): Wrong number of arguments " +
      "given (#{args.size} for 1)") if args.size != 1

    interface = "ipaddress_#{args[0]}"
    #formatted_interface = interface.gsub!(/[^a-z0-9_]/i, '_')
    #formatted_interface
    interface.gsub(/[^a-z0-9_]/i, '_')
  end
end
