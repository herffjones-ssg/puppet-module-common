#
# dnscmd.rb
#

module Puppet::Parser::Functions
  newfunction(:dnscmd, :type => :rvalue, :doc => <<-EOS
This function generates the dnscmd commands for HJ to create A records in active directory

*Examples:*

    dnscmd('ssgtest.herffjones.hj-int', '192.168.24.1')

Would return:

  dnscmd indc3 /recordadd herffjones.hj-int. ssgtest.herffjones.hj-int. A 192.168.24.1
  dnscmd indc3 /recordadd 168.192.in-addr.arpa. 1.24.168.192.et1.in-addr.arpa. PTR ssgtest.herffjones.hj-int.

    EOS
  ) do |arguments|

    if (arguments.size != 2) then
      raise(Puppet::ParseError, "dnscmd(): Wrong number of arguments "+
        "given #{arguments.size} for 2")
    end

    name = arguments[0]
    ip = arguments[1]

    tlds = [ "hj-int", "com", "org", "biz", "net", "jobs", "edu", "us", "gov", "uk" ]

    if ip =~ /^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$/
            ipmatch = ip.match(/^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$/)
    else
            return "Fail"
    end

    if not tlds.include?(name.match(/^(.*)\.(.*)$/)[2])
            return "Fail: " + name.match(/^(.*)\.(.*)$/)[2] + " does not match a known TLD"
    end

    name = name + "."

    # Get the "domain", ie everything after the first period.
    domain = name.match(/^(\w+)\.(.*)$/)[2]

    # Make sure we can handle this reverse zone.
    if ipmatch[1] + "." + ipmatch[2] ==  "192.168"
            zone="168.192.in-addr.arpa."
    elsif ipmatch[1] == "10"
            zone=ipmatch[3] + "." + ipmatch[2] + "." + ipmatch[1] + ".in-addr.arpa."
    else
            return "Error generating DNS commanss"
    end

    # Print the actual dnscmd lines.
    command = "dnscmd indc3 /recordadd " + domain + " " + name + " A " + ip + "\\n\\n" \
            + "dnscmd indc3 /recordadd " + zone + " " + ipmatch[4] + "." + ipmatch[3] + "." + ipmatch[2] + "." + ipmatch[1] + ".in-addr.arpa. PTR " + name

    return command

  end
end

# vim: set ts=2 sw=2 et :
