require 'test_helper'


class GeofenceNotificationTest < ActiveSupport::TestCase
  
  def record_notification(action,reading)
    @notified_actions.push(action)
  end
  
  context "A geofence notification" do
    setup do
      @device = Factory(:device, :account => @account)
      @deleted_device = Factory(:device, :account => @account, :provision_status_id => Device::STATUS_DELETED)
      Reading.delete_all
      #mock out send method for testing
      Notifier.class_eval do
        def Notifier.send_notify_reading_to_users(action,reading)
          @test.record_notification(action,reading)
        end
        def Notifier.set_test(test)
          @test = test
        end
      end
      
      Notifier.set_test(self)
      @notified_actions = Array.new
      @notified_readings = Array.new
    end
    
    teardown do
      #reload notifier to remove mocked method
      Object.class_eval do
        remove_const :Notifier.to_s
        load "notifier.rb"
      end
    end
    
      should "notify on a geofence event" do
        create_reading(@device, 2)
        assert_equal 1, @notified_actions.size
      end

      should "not notify on a device marked for deletion" do
        create_reading(@deleted_device, 2)
        assert_equal 0, @notified_actions.size
      end
      
    end
    
    
  def create_reading(device, geofence)
    Factory.create(:reading, :device => device, :event_type => "entergeofen#{geofence}", :geofence_event_type => 'enter')
    NotificationState.instance.begin_reading_bounds
    Notifier.send_geofence_notifications(Logger.new("logger"))
    NotificationState.instance.end_reading_bounds
  end
  
end