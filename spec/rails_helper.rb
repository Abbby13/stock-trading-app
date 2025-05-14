class RSpec::Core::ExampleGroup
    def self.fixture_path=(path)
    end
  end
  
  require 'spec_helper'
  ENV['RAILS_ENV'] ||= 'test'
  require_relative '../config/environment'
  require 'rspec/rails'
  
  begin
    ActiveRecord::Migration.maintain_test_schema!
  rescue ActiveRecord::PendingMigrationError => e
    puts e.message
    exit 1
  end
  
  RSpec.configure do |config|
    
    config.include FactoryBot::Syntax::Methods
  
    config.include Module.new {
      def sign_in(user)
        post login_path, params: { email: user.email, password: user.password }
        follow_redirect!
      end
    }, type: :request
  
    config.use_transactional_fixtures = true
    config.infer_spec_type_from_file_location!
    config.filter_rails_from_backtrace!
  end

  require 'shoulda/matchers'

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library        :rails
  end
end
  