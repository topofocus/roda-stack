# frozen_string_literal: true

# This file contains logger configuration

Application.register_provider(:logger) do
  prepare do
    require 'logger'
  end

  start do
    # Define Logger instance.
    logger       = Logger.new($stdout)
    logger.level = Logger::INFO # WARN if Application.env == 'test'

    register(:logger, logger)
  end
end
