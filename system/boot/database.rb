# frozen_string_literal: true

# This file contain code to setup the database connection.

Application.register_provider(:database) do |container|
  # Load environment variables before setting up database connection.

  prepare do

    module Arcade
      ProjectRoot = Pathname.new File.expand_path("../../../",__FILE__)
    # check if the former does not fit
      # ProjectRoot = Dir["#{File.expand_path('config/locales')}/*.yml"]
    end
    require 'arcade'


    loader = Zeitwerk::Loader.new
    loader.push_dir(Arcade::ProjectRoot.join("model"))
    loader.setup
  end

  start do
    # Delete DATABASE_URL from the environment, so it isn't accidently passed to subprocesses.
    target.start :environment_variables
    database = Arcade::Init.connect Application.env

    container.register(:db, database)
  end
end
