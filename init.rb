module Arcade
  ProjectRoot =  File.expand_path("../",__FILE__)
end
require 'arcade'
require 'zeitwerk'

module My; end

    loader = Zeitwerk::Loader.new
    loader.push_dir("#{__dir__}/model")
    loader.setup
