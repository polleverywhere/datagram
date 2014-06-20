require 'thor'

module Datagram
  class CLI < Thor
    desc "migrate [VERSION]", "Migrates the database schema"
    method_options %w( force -f ) => :boolean
    def migrate(version=nil)
      Datagram::Model.migrate(options)
    end

    desc "version", "Current version of datagram"
    def version
      puts Datagram::VERSION
    end
  end
end
