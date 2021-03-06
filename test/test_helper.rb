ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'rack/test'
require 'sinatra'
require 'rr'
require 'fakeweb'

FakeWeb.allow_net_connect = false

set :environment, :test

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
end

class Test::Unit::TestCase
  include Webrat::Matchers
  include Rack::Test::Methods
  include RR::Adapters::TestUnit unless include?(RR::Adapters::TestUnit)

  def response_body
    @response.body
  end
end

def regenerate_index
  FileUtils.rm_rf(
    %w[server/cache/*
    server/*specs*
    server/quick
    server/specifications
    server/source_index].map { |d| Dir[d] })
  Gemcutter.indexer.generate_index
end

def create_gem(owner, opts = {})
  @gem = Factory(:rubygem, :name => opts[:name] || Factory.next(:name))
  Factory(:version, :rubygem => @gem)
  @gem.ownerships.create(:user => owner, :approved => true)
end
