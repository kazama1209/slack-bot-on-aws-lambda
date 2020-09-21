require 'rack'
require 'rack/contrib'
require_relative './main'

set :root, File.dirname(__FILE__)

run Sinatra::Application
