# Copyright (c) 2013-2015 Aman Gupta
# Released under the MIT license
# https://github.com/tmm1/stackprof/blob/v0.2.11/LICENSE

require 'fileutils'
require 'stackprof'

# Modified original profiler (StackProf::Middleware) to reflect request path and method
module IsuconProfiler
  class Middleware
    def initialize(app, options = {})
      @app       = app
      @options   = options
      @num_reqs  = options[:save_every] || nil

      Middleware.mode     = options[:mode] || :cpu
      Middleware.interval = options[:interval] || 1000
      Middleware.raw      = options[:raw] || false
      Middleware.enabled  = options[:enabled]
      options[:path]      = 'tmp/' if options[:path].to_s.empty?
      Middleware.path     = options[:path]
      # at_exit{ Middleware.save } if options[:save_at_exit]
    end

    def call(env)
      enabled = Middleware.enabled?(env)
      StackProf.start(mode: Middleware.mode, interval: Middleware.interval, raw: Middleware.raw) if enabled
      @app.call(env)
    ensure
      if enabled
        StackProf.stop
        if @num_reqs && (@num_reqs-=1) == 0
          @num_reqs = @options[:save_every]
          Middleware.save(path_info: env["PATH_INFO"], method: env["REQUEST_METHOD"])
        end
      end
    end

    class << self
      attr_accessor :enabled, :mode, :interval, :raw, :path

      def enabled?(env)
        if enabled.respond_to?(:call)
          enabled.call(env)
        else
          enabled
        end
      end

      def save(path_info: 'unknown', method: 'Unknown')
        if results = StackProf.results
          path = Middleware.path
          is_directory = path != path.chomp('/')

          if is_directory
            filename = "stackprof-#{results[:mode]}-#{Process.pid}-#{method}-#{path_info.gsub('/', '_')}-#{Time.now.to_i}.dump"
          else
            filename = File.basename(path)
            path = File.dirname(path)
          end

          FileUtils.mkdir_p(path)
          File.open(File.join(path, filename), 'wb') do |f|
            f.write Marshal.dump(results)
          end
          filename
        end
      end
    end
  end
end
