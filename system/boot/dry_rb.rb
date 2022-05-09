# frozen_string_literal: true

# This file contains configuration for dry-rb toolset.

Application.register_provider(:dry_rb) do
  prepare do
    require 'dry-validation'
  end
end
