# -*- coding: utf-8 -*-
# rubocop:disable GlobalVars, SpecialGlobalVars

# Some reading: http://felipec.wordpress.com/2013/11/04/init/

require 'date'
require 'fileutils'

STDOUT.sync = true

$processes = {}

def log(message)
  puts "[#{DateTime.now}] INIT: #{message}"
end

def run!(*args, &block)
  log "Starting: #{args}" if ENV['DEBUG']
  pid = Process.spawn(*args)
  log "Started #{pid}: #{args.join ' '}"
  $processes[pid] = block || ->{ log "#{args.join ' '}: #{$?}" }
  pid
end

def reconfigure! reason=nil
  if $reconf_pid
    if reason
      log "#{reason}, but cannot reconfigure: already running"
    else
      log "Cannot reconfigure: already running"
    end
    return
  end

  if reason
    log "#{reason}, reconfiguring"
  else
    log "Reconfiguring"
  end

  $reconf_pid = run! '/usr/bin/chef-server-ctl', 'reconfigure' do
    log "Reconfiguration finished: #{$?}"
    $reconf_pid = nil
  end
end

def shutdown!
  unless $runsvdir_pid
    log "ERROR: no runsvdir pid at exit"
    exit 1
  end

  if $reconf_pid
    log "Reconfigure running as #{$reconf_pid}, stopping..."
    Process.kill 'TERM', $reconf_pid
    (1..5).each do
      if $reconf_pid
        sleep 1
      else
        break
      end
    end
    if $reconf_pid
      Process.kill 'KILL', $reconf_pid
    end
  end

  run! '/usr/bin/chef-server-ctl', 'stop' do
    log 'chef-server-ctl stop finished, stopping runsvdir'
    Process.kill('HUP', $runsvdir_pid)
  end
end

log "Starting #{$PROGRAM_NAME}"

{ shmmax: 17179869184, shmall: 4194304 }.each do |param, value|
  if ( actual = File.read("/proc/sys/kernel/#{param}").to_i ) < value
    log "kernel.#{param} = #{actual}, setting to #{value}."
    begin
      File.write "/proc/sys/kernel/#{param}", value.to_s
    rescue
      log "Cannot set kernel.#{param} to #{value}: #{$!}"
      log "You may need to run the container in privileged mode or set sysctl on host."
      raise
    end
  end
end

log 'Preparing configuration ...'
FileUtils.mkdir_p %w'/var/opt/opscode/log /var/opt/opscode/etc /.chef/env', verbose: true
FileUtils.cp '/.chef/chef-server.rb', '/var/opt/opscode/etc', verbose: true

%w'PUBLIC_URL OC_ID_ADMINISTRATORS'.each do |var|
  File.write(File.join('/.chef/env', var), ENV[var].to_s)
end

$runsvdir_pid = run! '/opt/opscode/embedded/bin/runsvdir-start' do
  log "runsvdir exited: #{$?}"
  if $?.success? || $?.exitstatus == 111
    exit
  else
    exit $?.exitstatus
  end
end

Signal.trap 'TERM' do
  shutdown!
end

Signal.trap 'INT' do
  shutdown!
end

Signal.trap 'HUP' do
  reconfigure! 'Got SIGHUP'
end

Signal.trap 'USR1' do
  log 'Chef Server status:'
  run! '/usr/bin/chef-server-ctl', 'status'
end

PKG_VERSION_FILE = '/var/opt/opscode/.chef-server-package-version'
pkg_version = `dpkg -s chef-server-core | awk '/^Version:/ { print $2 }'`.strip
if File.exist? '/var/opt/opscode/bootstrapped'
  last_pkg_version = File.exist?(PKG_VERSION_FILE) ?
                       File.read(PKG_VERSION_FILE).strip :
                       '(UNKNOWN)'
  if last_pkg_version != pkg_version
    log "Chef Server version #{pkg_version} different from previous #{last_pkg_version}, upgrading..."
    # Following https://docs.chef.io/upgrade_server.html
    run! 'chef-server-ctl', 'stop' do
      raise "chef-server-ctl stop: #{$?}" unless $?.success?
      run! 'chef-server-ctl', 'upgrade' do
        raise "chef-server-ctl upgrade: #{$?}" unless $?.success?
        log "Starting Chef Server after upgrade. Please run chef-server-ctl cleanup at some point."
        run! 'chef-server-ctl start'
        File.write(PKG_VERSION_FILE, pkg_version)
      end
    end
  end
else
  # not bootstrapped
  reconfigure! 'Not bootstrapped'
  File.write(PKG_VERSION_FILE, pkg_version)
end

loop do
  log $? if ENV['DEBUG']
  handler = $processes.delete(Process.wait)
  handler.call if handler
end
