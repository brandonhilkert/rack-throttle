require File.dirname(__FILE__) + '/spec_helper'

describe Rack::Throttle::Minute do
  include Rack::Test::Methods

  def app
    @target_app ||= example_target_app
    @app ||= Rack::Throttle::Minute.new(@target_app, :max_per_minute => 3)
  end

  it "should be allowed if not seen this minute" do
    get "/foo"
    last_response.body.should show_allowed_response
  end
  
  it "should be allowed if seen fewer than the max allowed per minute" do
    2.times { get "/foo" }
    last_response.body.should show_allowed_response
  end
  
  it "should not be allowed if seen more times than the max allowed per minute" do
    4.times { get "/foo" }
    last_response.body.should show_throttled_response
  end
  
  it "should not count last minute's requests against this minute's" do
    one_hour_ago = Time.now
    Timecop.freeze(DateTime.now - 1/24.0/60.0) do
      4.times { get "/foo" }
      last_response.body.should show_throttled_response
    end

    get "/foo"
    last_response.body.should show_allowed_response
  end
end
