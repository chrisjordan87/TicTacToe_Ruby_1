require_relative 'cli_renderer.rb'
require_relative 'main.rb'

TTT::Main.new(TTT::CLIRenderer.new).run
