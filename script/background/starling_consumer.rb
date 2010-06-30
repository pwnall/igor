#!/usr/bin/env ruby

# Load Rails.
ENV['RAILS_ENV'] = ARGV[1] || 'development'
require File.expand_path('../../../config/environment.rb', __FILE__)

# More ARGV-based setup. 
FileUtils.mkpath ARGV[3] unless ARGV[3].nil? or File.exists? ARGV[3]


# Restore timestamps in the log.
class Logger
  def format_message(severity, timestamp, progname, msg)
    "#{severity[0,1]} [#{timestamp} PID:#{$$}] #{progname}: #{msg}\n"
  end
end


require 'simple-daemon'
class StarlingConsumer < SimpleDaemon::Base
  SimpleDaemon::WORKING_DIRECTORY = ARGV[3] || "#{RAILS_ROOT}/log"
  
  def self.start
    STDOUT.sync = true
    @logger = Logger.new(STDOUT)
    @logger.level = RAILS_ENV =~ /prod/ ? Logger::INFO : Logger::DEBUG

    starling = nil
    
    loop do 
      # execute tasks
      begin
        if starling.nil?
          @logger.info "Starting starling consumer"      
          starling = MemCache.new(ARGV[2] || '127.0.0.1:16020')            
          @logger.info "Started starling consumer"          
        end
        
        task = starling.get('pulls')
        task = starling.get('pushes') unless task
      rescue Exception => e
        # This gets thrown when we need to get out.
        raise if e.kind_of? SystemExit
        
        @logger.error "MemCache fetching error - #{e.class.name}: #{e}"
        @logger.info e.backtrace.join("\n")
        
        Kernel.sleep 5
        next
      end
      
      if task
        3.times do |i|
          begin
            ActiveRecord::Base.verify_active_connections!
            OfflineTasks.do_task task
          rescue Exception => e
            # This gets thrown when we need to get out.
            raise if e.kind_of? SystemExit
            
            @logger.error "Error processing task - #{e.class.name}: #{e}"
            @logger.info e.backtrace.join("\n")
            
            Kernel.sleep 5
          end          
        end        
      else
        Kernel.sleep 1
      end
    end
  end
  def self.stop
    @logger.info "Stopping starling consumer"
  end
end

StarlingConsumer.daemonize
