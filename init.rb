# Some reading: http://felipec.wordpress.com/2013/11/04/init/

STDOUT.sync = true

puts "# Initializing sysctl ..."
system 'sysctl -w kernel.shmmax=17179869184 kernel.shmall=4194304' or fail "Sysctl FAIL"

puts "# Starting runsvdir ..."
$pid = Process.spawn '/opt/chef-server/embedded/bin/runsvdir', '-P', '/opt/chef-server/sv', "log: #{'.' * 128}"
puts "# Started runsvdir #{$pid}"

Signal.trap("TERM") do
  puts "# Got SIGTERM, shutting down runsvdir ..."
  Process.kill('HUP', $pid)
end

Signal.trap("INT") do
  puts "# Got SIGINT, shutting down runsvdir ..."
  Process.kill('HUP', $pid)
end

Signal.trap("SIGCHLD") do
  loop do
    begin
      chld = Process.wait(-1, Process::WNOHANG)
      break if chld == nil
      puts "# Reaped PID #{chld} (#{$?})"
    rescue Errno::ECHILD
      break
    end
  end
end

unless File.exist? '/var/opt/chef-server/bootstrapped'
  pid = Process.spawn '/usr/bin/chef-server-ctl', 'reconfigure'
  puts "# Not bootstrapped, running `chef-server-ctl reconfigure' (#{pid})"
end

while true
  chld = Process.wait
  if chld == $pid
    puts "# Runsvdir exited (#{$?}), exiting"
    if $?.success? || $?.exitstatus == 111
      break
    else
      exit $?.exitstatus
    end
  else
    puts "# Reaped PID #{chld} (#{$?})"
  end
end
