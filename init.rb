# Some reading: http://felipec.wordpress.com/2013/11/04/init/

require 'date'

STDOUT.sync = true

def log(message)
  puts "[#{DateTime.now}] INIT: #{message}"
end

log "Starting #{$0}"

log "Initializing sysctl for postgres"
system 'sysctl -w kernel.shmmax=17179869184 kernel.shmall=4194304' or fail "Sysctl FAIL"

unless File.exist?('/var/log/chef-server') || File.symlink?('/var/log/chef-server')
  log 'Linking /var/log/chef-server -> /var/opt/chef-server/log'
  File.symlink '/var/log/chef-server', '/var/opt/chef-server/log'
end

log "Starting runsvdir ..."
$pid = Process.spawn '/opt/chef-server/embedded/bin/runsvdir', '-P', '/opt/chef-server/sv', "log: #{'.' * 128}"
log "Started runsvdir (#{$pid})"

Signal.trap("TERM") do
  log "Got SIGTERM, shutting down runsvdir ..."
  Process.kill('HUP', $pid)
end

Signal.trap("INT") do
  log "Got SIGINT, shutting down runsvdir ..."
  Process.kill('HUP', $pid)
end

Signal.trap("SIGCHLD") do
  loop do
    begin
      chld = Process.wait(-1, Process::WNOHANG)
      break if chld == nil
      log "Reaped PID #{chld} (#{$?}) in SIGCHLD handler"
    rescue Errno::ECHILD
      break
    end
  end
end

unless File.exist? '/var/opt/chef-server/bootstrapped'
  pid = Process.spawn '/usr/bin/chef-server-ctl', 'reconfigure'
  log "Not bootstrapped, running `chef-server-ctl reconfigure' (#{pid})"
end

while true
  chld = Process.wait
  if chld == $pid
    log "Runsvdir exited (#{$?}), exiting"
    if $?.success? || $?.exitstatus == 111
      break
    else
      exit $?.exitstatus
    end
  else
    log "Reaped PID #{chld} (#{$?}) in main loop"
  end
end
