class System::HealthController < ApplicationController
  before_filter :authenticated_as_admin

  def index    
    @processes = Sys::ProcTable.ps.sort { |a, b| b.pid <=> a.pid }
  end

  def show
    @process =
        Sys::ProcTable.ps.select { |p| p.pid.to_s == params[:id].to_s }.first
  end

  def destroy
    @process =
        Sys::ProcTable.ps.select { |p| p.pid.to_s == params[:id].to_s }.first
    
    if @process.nil?
      flash[:error] = "No process with PID #{@process.pid}"
    else
      Zerg::Support::Process::kill_tree @process.pid
      flash[:notice] = "Started killing process #{@process.pid} (#{@process.comm})"
    end
    
    redirect_to :controller => :health, :action => :index
  end
  
  def stat_system
    @server = {
      :os_name => Sys::Uname.sysname,
      :node_name => Sys::Uname.nodename,
      :os_arch => Sys::Uname.machine,
      :os_ver => Sys::Uname.version,
      :os_release => Sys::Uname.release,
      :boot_time => Sys::Uptime.boot_time,
      :uptime => Sys::Uptime.dhms,
      :load => Sys::CPU.load_avg,
    }
    
    @cpus = []
    case RUBY_PLATFORM
    when /darwin/
      # NOTE: it would be nice to have stats for CPUs 
      cpu0 = {
        :freq => (Sys::CPU.freq rescue 0),
        :arch => Sys::CPU.architecture,
        :machine => Sys::CPU.machine,
        :model => Sys::CPU.model,
        :cores => 0
      }
      num_cpus = Sys::CPU.num_cpu
      @cpus = (0...(Sys::CPU.num_cpu)).map { |i| cpu0 }     
    when /win/
      Sys::CPU.processors do |p|
        @cpus << {
          :freq => p.freq,
          :model => p.description,
          :arch => p.architecture,
          :machine => p.family,
          :cores => 0
        }
      end
    else
      Sys::CPU.processors do |p|
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
