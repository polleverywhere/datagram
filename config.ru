require 'datagram'

# Don't buffer stdout so that we can see our log output.
$stdout.sync = true

# Allow PUT requests from crappy old web browsers.
use Rack::MethodOverride

# Tell Rack & Sinatra to use the Datagram logger
use Rack::CommonLogger, Datagram.logger

# Reload datagram for env environment between requests.
use Rack::Reloader

# The app we've all been waitin for!
run Datagram::App.new