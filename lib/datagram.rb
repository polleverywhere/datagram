require "datagram/version"
require "logger"

module Datagram
  autoload :CLI,    'datagram/cli'
  autoload :Model,  'datagram/model'
  autoload :App,    'datagram/application'

  # Expose a logger for everything datagram.
  def self.logger
    @logger ||= Logger.new($stdout)
  end
end
