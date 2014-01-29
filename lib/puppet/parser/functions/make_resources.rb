# make_resources - A wrapper for Puppet's create_resources function shamelessly copied from hiera_resources
#
# Takes one argument: a hash of puppet resources and their configuration
#
Puppet::Parser::Functions.newfunction(:make_resources) do |args|

  def error(message)
    raise Puppet::Error, message
  end

  error("make_resources requires 1 argument") unless args.length == 1

  args[0].each do |type, resources|
    # function_create_resources is no workie so we'll do this
    method = Puppet::Parser::Functions.function :create_resources
    send(method, [type, resources])
  end
end
