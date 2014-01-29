#
# regex.rb
#

module Puppet::Parser::Functions
  newfunction(:regex, :type => :rvalue, :doc => <<-EOS
This function searches through a string or array and returns any elements that match
the provided regular expression.

*Examples:*

    regex(['test1', 'testa1'], '(\D+)')

Would return:

    ['test','testa']
    EOS
  ) do |arguments|

    if (arguments.size != 2) then
      raise(Puppet::ParseError, "regex(): Wrong number of arguments "+
        "given #{arguments.size} for 2")
    end

    a = arguments[0]
    pattern = Regexp.new(arguments[1])

    if a.kind_of?(Array)
            result = Array.new
            a.each do |item|
                    result.push(item.match(pattern)[1])
            end
    elsif a.kind_of?(String)
            result = a.match(pattern)
    end

    return result

  end
end

# vim: set ts=2 sw=2 et :
