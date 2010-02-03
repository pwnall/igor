require 'sys/cpu'
require 'sys/proctable'
require 'sys/uname'
require 'sys/uptime'
include Sys

class HealthController < ApplicationController
  before_filter :authenticated_as_admin
  
  def index    
    @processes = ProcTable.ps.sort { |a, b| b.pid <=> a.pid }
  end

  def show
    @process = ProcTable.ps.select { |p| p.pid.to_s == params[:id].to_s }.first
  end

  def destroy
    @process = ProcTable.ps.select { |p| p.pid.to_s == params[:id].to_s }.first
    
    if @process.nil?
      flash[:error] = "No process with PID #{@process.pid}"
    else
      KillTree.of_process(@process.pid)
      flash[:notice] = "Started killing process #{@process.pid} (#{@process.comm})"
    end
    
    redirect_to :controller => :health, :action => :index
  end
  
  def system_stat
    @server = {
      :os_name => Uname.sysname,
      :node_name => Uname.nodename,
      :os_arch => Uname.machine,
      :os_ver => Uname.version,
      :os_release => Uname.release,
      :boot_time => Uptime.boot_time,
      :uptime => Uptime.dhms,
      :load => CPU.load_avg,
    }
    
    @cpus = []
    case RUBY_PLATFORM
    when /darwin/
      # NOTE: it would be nice to have stats for CPUs 
      cpu0 = {
        :freq => (CPU.freq rescue 0),
        :arch => CPU.architecture,
        :machine => CPU.machine,
        :model => CPU.model,
        :cores => 0
      }
      num_cpus = CPU.num_cpu
      @cpus = (0...(CPU.num_cpu)).map { |i| cpu0 }     
    when /win/
      CPU.processors do |p|
        @cpus << {
          :freq => p.freq,
          :model => p.description,
          :arch => p.architecture,
          :machine => p.family,
          :cores => 0
        }
      end
    else
      CPU.processors do |p|
        @cpus << {
          :freq => p.cpu_mhz,
          :model => p.model_name,
          :arch => p.vendor_id,
          :machine => p.flags,
          :cores => p.cpu_cores
        }
      end
    end    
  end
end
