require "test_helper"

class SendToRudderstackTest < ActiveSupport::TestCase
  setup do
    @mock_analytics = mock("analytics")
    @mock_logger = mock("logger")
    Rails.stubs(:logger).returns(@mock_logger)
  end

  test "should initialize Rudder with correct credentials" do
    Rudder::Analytics.expects(:new).with(
      write_key: Rails.application.credentials.dig(:rudder, :write_key),
      data_plane_url: Rails.application.credentials.dig(:rudder, :data_plane_url),
      on_error: instance_of(Proc)
    ).returns(@mock_analytics)

    SendToRudderstack.initialize_rudder
  end

  test "should memoize the analytics instance" do
    SendToRudderstack.expects(:initialize_rudder).once.returns(@mock_analytics)

    analytics_first_call = SendToRudderstack.analytics
    analytics_second_call = SendToRudderstack.analytics

    assert_equal @mock_analytics, analytics_first_call
    assert_equal analytics_first_call, analytics_second_call
  end

  test "should log error when on_error callback is invoked" do
    error_code = 500
    error_body = "Something went wrong"

    @mock_logger.expects(:error).with("Rudder Error: #{error_code} - #{error_body}")

    on_error_proc = nil

    # Stub Rudder::Analytics.new to capture the on_error proc
    Rudder::Analytics.expects(:new).with(
      write_key: Rails.application.credentials.dig(:rudder, :write_key),
      data_plane_url: Rails.application.credentials.dig(:rudder, :data_plane_url),
      on_error: instance_of(Proc)
    ).returns(@mock_analytics).with { |args|
      on_error_proc = args[:on_error]
    }

    SendToRudderstack.initialize_rudder

    # Manually invoke the on_error proc to simulate the error callback
    on_error_proc.call(error_code, error_body, nil, nil) if on_error_proc
  end
end
