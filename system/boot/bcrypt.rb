# frozen_string_literal: true

# This file contains configuration for bcrypt.

Application.register_provider(:bcrypt) do
  prepare do
    require 'bcrypt'
  end

  start do
    # Set BCrypt::Engine.cost to speedup tests.
    BCrypt::Engine.cost = 1 if Application.env == 'test'
  end
end
