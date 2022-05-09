# frozen_string_literal: true

# This file contains setup for Ruby internationalization and localization (i18n).

Application.register_provider(:i18n) do
  prepare do
    require 'i18n'
  end

  start do
    # Load all locale .ym lfiles in /config/locales folder.
    I18n.load_path << Dir["#{File.expand_path('config/locales')}/*.yml"]

    # Add :pl to to the list of available locales.
    I18n.config.available_locales = %i[en de]

    # Set default locale to :pl.
    I18n.default_locale = :en
  end
end
