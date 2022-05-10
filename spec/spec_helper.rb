# frozen_string_literal: true

# Set environment to test.
ENV['roda_env'] = 'test'

require 'rack/test'
require 'factory_bot'

# Load all factories defined in spec/factories folder.
FactoryBot.find_definitions

require_relative '../app'

# Require all files in spec/support folder.
root_path = Pathname.new(File.expand_path('..', __dir__))
Dir[root_path.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include Rack::Test::Methods, type: :request
  config.include ApiHelpers,          type: :request
  #config.include ArcadeHelper

  # Include FactoryBot helper methods.
  config.include FactoryBot::Syntax::Methods
	config.mock_with :rspec
	config.color = true
	# enable running single tests
	config.filter_run :focus => true
	config.run_all_when_everything_filtered = true
  ## because we are testing database-sequences:
	config.order = 'defined'  # "random"

  config.include(
    Module.new do
      def app
        App.freeze.app
      end
    end
  )

  # Configuration for database cleaning strategy using Sequel.
#  config.around do |example|
#    Application['database'].transaction(rollback: :always, auto_savepoint: true) { example.run }
#  end
end
## enable testing of private methods
RSpec.shared_context 'private', private: true do
    before :all do
          described_class.class_eval do
	          @original_private_instance_methods = private_instance_methods
		        public *@original_private_instance_methods
			    end
	    end

      after :all do
	    described_class.class_eval do
	            private *@original_private_instance_methods
		        end
	      end

end
