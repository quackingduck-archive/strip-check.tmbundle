# See: http://growl.info/documentation/applescript-support.php
# This is still pretty much voodoo to me
#
# The name argument specifies the name that will appear in the "Applications"
# tab of the Growl preferences pane.
def RBGrowl(name, title, body, icon = 'Console')
  name, title, body, icon = [name, title, body, icon].map { |v| v.inspect }
  ascript = %{
  -- detect if growl is running
  tell application "System Events"
    set isRunning to (count of (every process whose bundle identifier is "com.Growl.GrowlHelperApp")) > 0
  end tell

  if isRunning then
    tell application id "com.Growl.GrowlHelperApp"
      -- Make a list of all the notification types that this script will ever send:
      set the allNotificationsList to {#{name}}

      -- Make a list of the notifications that will be enabled by default.
      set the enabledNotificationsList to {#{name}}

      -- Register our script with growl.
      register as application #{name} ¬
        all notifications allNotificationsList ¬
        default notifications enabledNotificationsList ¬
        icon of application #{icon}

      --  Send a Notification...
      notify with name #{name} ¬
        title #{title} ¬
        description #{body} ¬
        application name #{name}
    end tell
  end if
  }
  system 'osascript', '-e', ascript
end
# The above also available here: http://gist.github.com/379866

def check(path, dir = nil)
  dir ||= File.dirname(path)
  return '' if dir == '/'
  checker = dir + '/.check'
  if File.exists? checker
    # probably should use real shell escaping here
    errors = `#{checker.inspect} #{path.inspect}`
    $?.success? ? errors : check(path, File.dirname(dir))
  else
    check(path, File.dirname(dir))
  end
end

errors = check ENV['TM_FILEPATH']
RBGrowl "Syntax Checker Bundle", "Syntax Error", errors unless errors.empty?
