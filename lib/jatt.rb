require "./lib/app"

# load config data from file into in-memory
config = {}.freeze

# initialize app with config and start

App.new().launch
