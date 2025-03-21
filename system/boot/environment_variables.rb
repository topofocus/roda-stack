# frozen_string_literal: true

# This file contains setup for environment variables using Dotenv.

Application.register_provider(:environment_variables) do
  start do
    env = Application.env

    # Load environment variables if current environment is development or test.
    if %w[development test].include?(env)
      require 'dotenv'

      Dotenv.load('.env', ".env.#{env}")
    end
  end
end
