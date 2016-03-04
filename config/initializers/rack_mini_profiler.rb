require 'rack-mini-profiler'

Rack::MiniProfilerRails.initialize!(Rails.application)

Rack::MiniProfiler.config.base_url_path = '/_/mini-profiler-resources/'
