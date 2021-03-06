class Notifier < ActionMailer::Base

  def self.send_geofence_notifications(logger)
    # NOTE: eliminate legacy geofences 'entergeofence_et11' and 'exitgeofence_et52'
    readings_to_notify = Reading.find(:all, :conditions => "#{NotificationState.instance.reading_bounds_condition} AND geofence_event_type != '' AND event_type != 'entergeofen_et11' AND event_type != 'exitgeofen_et52'")

    logger.info("Notification needed for #{readings_to_notify.size.to_s} readings\n")

    readings_to_notify.each do |reading|
      action = (reading.geofence_event_type == 'exit') ? "exited geofence " : "entered geofence "
      action += reading.get_fence_name unless reading.get_fence_name.nil?
      send_notify_reading_to_users(action,reading) unless reading.device.provision_status_id == Device::STATUS_DELETED
    end
  end

  def self.send_device_offline_notifications(logger)
    devices_to_notify = Device.find(:all, :conditions => "(unix_timestamp(now())-unix_timestamp(last_online_time))/60>online_threshold and provision_status_id=1")
    devices_to_notify.each do |device|
      last_notification = device.last_offline_notification
      if (last_notification.nil? || Time.now - last_notification.created_at > 24*60*60)
         if !device.account.nil?
            device.account.users.each do |user|
              if user.enotify == 1
                logger.info("device offline, notifying: #{user.email}\n")
                mail = deliver_device_offline(user, device)
              elsif user.enotify == 2
                devices_ids = user.group_devices_ids
                if devices_ids.include?(device.id)
                  logger.info("device offline, notifying: #{user.email}\n")
                  mail = deliver_device_offline(user, device)
                end
              end
              if user.enotify != 0
                notification = Notification.new
                notification.user_id = user.id
                notification.device_id = device.id
                notification.notification_type = "device_offline"
                notification.save
              end
            end
         end
      end
    end
  end

  def self.send_gpio_notifications(logger)
    devices_to_notify = Device.find_by_sql("select devices.* from devices,device_profiles where profile_id = device_profiles.id and provision_status_id = 1 and (watch_gpio1 or device_profiles.watch_gpio2)")
    devices_to_notify.each do |device|
      readings_to_notify = Reading.find(:all,:conditions => "#{NotificationState.instance.reading_bounds_condition} and device_id = #{device.id} and gpio1 is not null") # NOTE: assumes if gpio1 is not null, then gpio2 is not null also
      readings_to_notify.each do |reading|
        if device.last_gpio1.nil?
          device.last_gpio1 = reading.gpio1
          device.save
        elsif device.profile.watch_gpio1 and not reading.gpio1.eql?(device.last_gpio1)
          device.last_gpio1 = reading.gpio1
          device.save
          action = reading.gpio1 ? device.profile.gpio1_high_notice : device.profile.gpio1_low_notice
          send_notify_reading_to_users(action,reading) if action
        end
        if device.last_gpio2.nil?
          device.last_gpio2 = reading.gpio2
          device.save
        elsif device.profile.watch_gpio2 and reading.gpio2 != device.last_gpio2
          device.last_gpio2 = reading.gpio2
          device.save
          action = reading.gpio2 ? device.profile.gpio2_high_notice : device.profile.gpio2_low_notice
          send_notify_reading_to_users(action,reading) if action
        end
      end
    end
  end

  def self.send_maintenance_notifications(logger)
    tasks_to_notify = MaintenanceTask.find(:all,:conditions => "completed_at is null",:order => "device_id,established_at")
    tasks_to_notify.each do |task|
      action = task.update_status
      send_notify_task_to_users(action,task) if action
      task.save
    end
  end

  def self.send_speed_notifications(logger)
    devices_to_notify = Device.find_by_sql("select devices.* from devices,device_profiles,accounts where provision_status_id = 1 and profile_id = device_profiles.id and device_profiles.speeds and account_id = accounts.id and max_speed is not null")
    devices_to_notify.each do |device|
      readings_to_notify = Reading.find(:all,:conditions => "#{NotificationState.instance.reading_bounds_condition} and device_id = #{device.id} and (speed > #{device.account.max_speed} or speed = 0)")
      readings_to_notify.each do |reading|
        if device.speeding_at and reading.speed == 0
          device.speeding_at = nil
          device.save
        elsif device.speeding_at.nil? and reading.speed > device.account.max_speed
          device.speeding_at = reading.created_at
          device.save
          if reading.event_type == 'normal' # NOTE: we're only setting the "speeding" event if nothing else is set to avoid overwriting anything
            reading.event_type = 'speeding'
            reading.save
          end
          send_notify_reading_to_users("maximum speed of #{device.account.max_speed} MPH exceeded",reading)
        end
      end
    end
  end

  def self.send_notify_reading_to_users(action,reading)
    if reading.device.account.nil?
      logger.error("Cannot notify for unassigned device")
      return
    end
    reading.device.account.users.each do |user|
      if user.enotify == 1
        logger.info("notifying(1): #{user.email} about: #{action}\n")
        mail = deliver_notify_reading(user, action, reading)
      elsif user.enotify == 2
        device_ids = user.group_devices_ids
        if  !device_ids.empty? && device_ids.include?(reading.device.id)
          logger.info("notifying(2): #{user.email} about: #{action}\n")
          mail = deliver_notify_reading(user, action, reading)
        end
      end
    end
  end

  def self.send_notify_task_to_users(action,task)
    task.device.account.users.each do |user|
      if user.enotify == 1
        logger.info("notifying(1): #{user.email} about: #{action}\n")
        mail = deliver_notify_task(user, action, task)
      elsif user.enotify == 2
        device_ids = user.group_devices_ids
        if  !device_ids.empty? && device_ids.include?(task.device.id)
          logger.info("notifying(2): #{user.email} about: #{action}\n")
          mail = deliver_notify_task(user, action, task)
        end
      end
    end
  end

  def forgot_password(user, url=nil)
    setup_email(user)

    @subject = "Forgotten Password Notification"

    # Email body substitutions
    @body["name"] = "#{user.first_name} #{user.last_name}"
    @body["login"] = user.email
    @body["url"] = url
    @body["app_name"] = COMPANY
  end

  def change_password(user, password, url=nil)
    setup_email(user)

    # Email header info
    subject "Changed Password Notification"

    # Email body substitutions
    body :name => "#{user.first_name} #{user.last_name}", :login => user.email, :password => password, :url => url, :app_name => COMPANY
  end

  def notify_reading(user, action, reading)
    recipients user.email
    from ALERT_EMAIL
    subject reading.device.name + ' ' + action
    if !user.nil? && user.time_zone
      Time.zone = user.time_zone
    else
      Time.zone = 'Central Time (US & Canada)'
    end
    body :action => action, :name => "#{user.first_name} #{user.last_name}", :device_name => reading.device.name, :display_time => reading.get_local_time(reading.created_at.in_time_zone.inspect)
  end

  def notify_task(user,action,task)
    @recipients = user.email
    @from = ALERT_EMAIL
    @subject = task.device.name + ' ' + action
    @body["action"] = action
    @body["name"] = "#{user.first_name} #{user.last_name}"
    @body["device_name"] = task.device.name
    if !user.nil? && user.time_zone
      Time.zone = user.time_zone
    else
      Time.zone = 'Central Time (US & Canada)'
    end
    @body["display_time"] = task.get_local_time(task.reviewed_at.in_time_zone.inspect)
  end

  def device_offline(user, device)
    recipients user.email
    from ALERT_EMAIL
    subject "Device Offline Notification"
    body :device_name => device.name, :last_online => device.last_online_time, :name => "#{user.first_name} #{user.last_name}"
  end

  def setup_email(user)
    @recipients = "#{user.email}"
    @from       = SUPPORT_EMAIL
    @sent_on    = Time.now
    @headers['Content-Type'] = "text/plain; charset=utf-16"
  end

  # Send email to support from contact page
  def app_feedback(email, subdomain, feedback)
    @from = SUPPORT_EMAIL
    @recipients = SUPPORT_EMAIL
    @subject = "Feedback from #{subdomain}.#{DOMAIN}"
    @body["feedback"] = feedback
    @body["sender"] = email
  end
end
