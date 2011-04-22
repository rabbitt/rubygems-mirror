require 'rubygems/command_manager'
require 'rubygems/mirror/command'

module Gem #:nodoc:
end

class Gem::Mirror
  VERSION = '1.0.1'
end

Gem::CommandManager.instance.register_command :mirror
