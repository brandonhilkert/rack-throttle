require File.dirname(__FILE__) + '/spec_helper'

describe Rack::Throttle::Limiter do
  include Rack::Test::Methods

  describe 'with default config' do
    def app
      @target_app ||= example_target_app
      @app ||= Rack::Throttle::Limiter.new(@target_app)
    end

    describe "basic calling" do
      it "should return the example app" do
        get "/foo"
        last_response.body.should show_allowed_response
      end

      it "should call the application if allowed" do
        app.should_receive(:allowed?).and_return(true)
        get "/foo"
        last_response.body.should show_allowed_response
      end

      it "should give a rate limit exceeded message if not allowed" do
        app.should_receive(:allowed?).and_return(false)
        get "/foo"
        last_response.body.should show_throttled_response
      end
    end

    describe "allowed?" do
      it "should return true if whitelisted" do
        app.should_receive(:whitelisted?).and_return(true)
        get "/foo"
        last_response.body.should show_allowed_response
      end

      it "should return false if blacklisted" do
        app.should_receive(:blacklisted?).and_return(true)
        get "/foo"
        last_response.body.should show_throttled_response
      end

      it "should return true if not whitelisted or blacklisted" do
        app.should_receive(:whitelisted?).and_return(false)
        app.should_receive(:blacklisted?).and_return(false)
        get "/foo"
        last_response.body.should show_allowed_response
      end
    end
  end

  describe 'with rate_limit_exceeded callback' do
    def app
      @target_app ||= example_target_app
      @app ||= Rack::Throttle::Limiter.new(@target_app, :rate_limit_exceeded_callback => lambda {|request| @app.callback(request) } )
    end

    it "should call rate_limit_exceeded_callback w/ request when rate limit exceeded" do
      app.should_receive(:blacklisted?).and_return(true)
      app.should_receive(:callback).and_return(true)
      get "/foo"
      last_response.body.should show_throttled_response
    end
  end
end