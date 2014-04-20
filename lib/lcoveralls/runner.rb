#!/usr/bin/ruby -w
#
# Copyright 2014 Paul Colby
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'find'

module Lcoveralls

  # Runs the Lcoveralls application.
  class Runner

    # Initializes a new Locveralls::Runner instance.
    def initialize
      # Parse the command line options.
      parser = Lcoveralls::OptionParser.new
      @options = parser.parse! ARGV

      # Setup a logger instance.
      @log = Logger.new(STDERR)
      @log.formatter = Lcoveralls::ColorFormatter.new @options[:color]
      @log.sev_threshold = @options[:severity]
      @log.debug { "Options: #{@options}" }
    end

    # Attempts to auto-detect the git repository root.
    #
    # This method looks throuhgh all source files covered by the supplied
    # tracefiles, and for each, check if they are part of a git repository.
    # The method then returns git repository's root directory.
    #
    # If more than one git repository are found to be covered by the tracefiles
    # then a warning will be logged, and the root of the repository with the
    # largest number of source files covered will be returned.
    #
    # If no git repository roots could be found, then +nil+ is returned.
    #
    # @param info_files [Array] A list of LCOV tracefiles (aka *.info files).
    #
    # @return [String, nil] A git repository root, if found, otherwise +nil+.
    def find_root(info_files)
      # Try source file(s) covered by the lcov tracefile(s).
      root_dirs = Hash.new(0)
      info_files.each do |file|
        File.open(file).each do |line|
          line.match(/^SF:(.*)$/) do |match|
            Dir.chdir(File.dirname(match[1])) do
              root_dir = `"#{@options[:git]}" rev-parse --show-toplevel`.rstrip
             root_dirs[root_dir] = root_dirs[root_dir] + 1 unless root_dir.empty?
            end if Dir.exist?(File.dirname(match[1]))
          end
        end
      end

      if root_dirs.empty?
        nil
      elsif root_dirs.size == 1
        root_dirs.shift[0]
      else
        root_dir = root_dirs.max_by { |key, value| value }[0]
        @log.warn "Found multiple possible repo roots; settled on: #{root_dir}"
        root_dir
      end
    end

    # Format a percentage string.
    #
    # This method formats the number of lines hit, as a percentage of the total
    # number of lines, including prepended spaces, and color codes where
    # appropriate.
    #
    # If the percentage cannot be calculated (for example, either parameter is
    # +nil+, NaN, +/- ininity, etc), then this function will return a 'blank'
    # string - one with enough spaces to match the width of other valid
    # percentage strings returned by this function.
    #
    # @param lines_hit [Integer, nil] Number of lines hit by unit tests.
    # @param lines_found [Integer, nil] Number of executable lines.
    #
    # @return [String] Percentage of lines overered.
    def get_percentage(lines_hit, lines_found, bold=false)
      perc = lines_hit.to_f / lines_found.to_f * 100.0
      color = case when perc >= 90; 32 when perc >= 75; 33 else 31 end
      if bold then color = "1;#{color}" end
      perc = perc.finite? ? format('%5.1f%', perc) : ' ' * 6
      perc = "\x1b[#{color}m#{perc}\x1b[0m" if @options[:color] and color
      perc
    end

    # Builds a hash of source files matching the Coveralls API.
    #
    # This method will build a Hash containing all source files covered by the
    # supplies LCOV tracefiles, that reside within the specified repository
    # root directory.
    #
    # @param info_file [Array] LCOV tracefiles containing source files to load.
    # @param root_dir [String] Repository root directory.
    #
    # @return [Hash] Source files in Coveralls API structure.
    def get_source_files(info_files, root_dir)
      sources = {}
      total_lines_found = 0
      total_lines_hit = 0
      info_files.each do |file|
        @log.debug "Processing tracefile: #{file}"
        source_pathname = nil
        in_record = false
        lines_found = nil
        lines_hit = nil
        File.open(file).each do |line|
          @log.debug "#{file}: #{line.rstrip}"

          # SF:<absolute path to the source file>
          line.match('^SF:' + Regexp.quote(root_dir) + '/(.*)$') do |match|
            @log.warn 'Found source filename without preceding end_of_record' if in_record
            @log.debug "Found source filename: #{match[1]}"
            source_pathname = match[1]
            if !sources.has_key?(source_pathname) then
              source = File.read(match[1])
              sources[source_pathname] = {
                :name => source_pathname,
                :source => source,
                :coverage => Array.new(source.lines.count)
              }
            end
            in_record = true
          end

          # DA:<line number>,<execution count>[,<checksum>]
          line.match(/^DA:(?<line>\d+),(?<count>\d+)(,(?<checksum>.*))?$/) do |match|
            line_index = match[:line].to_i - 1
            if !sources[source_pathname][:coverage][line_index] then
              sources[source_pathname][:coverage][line_index] = 0
            end
            sources[source_pathname][:coverage][line_index] = 
              sources[source_pathname][:coverage][line_index] + match[:count].to_i;
          end if in_record

          # LF:<lines found> or LH:<lines hit>
          line.match(/^LF:(?<count>\d+)$/) { |match| lines_found = match[:count] }
          line.match(/^LH:(?<count>\d+)$/) { |match| lines_hit   = match[:count] }

          # end_of_record
          if line == "end_of_record\n" and in_record then
            @log.info begin
              perc = get_percentage(lines_hit, lines_found)
              "[#{perc}] #{source_pathname} (#{lines_hit}/#{lines_found})"
            end
            total_lines_found = total_lines_found + lines_found.to_i
            total_lines_hit = total_lines_hit + lines_hit.to_i
            in_record = false
            lines_found = nil
            lines_hit = nil
          end
        end
      end

      @log.info begin
        perc = get_percentage(total_lines_hit, total_lines_found, true)
        "[#{perc}] Total (#{total_lines_hit}/#{total_lines_found})"
      end

      sources.values
    end

    # Get git repository information in the Coveralla API structure.
    #
    # @param root_dir Git repository root directory.
    #
    # @return [Hash] Git repository information.
    def get_git_info(root_dir)
      Dir.chdir(root_dir) do
        info = {
          :head => {
            :id             => `"#{@options[:git]}" show --format='%H' --no-patch`.rstrip,
            :author_name    => `"#{@options[:git]}" show --format='%an' --no-patch`.rstrip,
            :author_email   => `"#{@options[:git]}" show --format='%ae' --no-patch`.rstrip,
            :commiter_name  => `"#{@options[:git]}" show --format='%cn' --no-patch`.rstrip,
            :commiter_email => `"#{@options[:git]}" show --format='%ce' --no-patch`.rstrip,
            :message        => `"#{@options[:git]}" show --format='%B' --no-patch`.rstrip,
          },
          :branch  => `"#{@options[:git]}" rev-parse --abbrev-ref HEAD`.rstrip,
          :remotes => []
        }

        `"#{@options[:git]}" remote --verbose`.each_line do |line|
          line.match(/^(?<name>\S+)\s+(?<url>\S+)(\s+\((fetch|push)\))?/) do |match|
            info[:remotes] << Hash[match.names.zip(match.captures)]
          end
        end
        info[:remotes].uniq!
        info.delete(:remotes) if info[:remotes].empty?

        info
      end if Dir.exist?(root_dir)
    end

    # Should we retry a failed Coveralls API request?
    #
    # This method is called by {#run} on internal and server errors to check if
    # the API request should be retried. Specifically, this function checks the
    # :retry_count option, and if greater than zero decrements it before
    # returning +true+.
    #
    # Additionally, if retrying is appropriate, and the :retry_interval option
    # is greater than zero, this function will also sleep for that interval.
    #
    # @return [Boolean] +true+ if the caller should retry the API request, or
    #         +false+ if no more retries should be attempted.
    def should_retry?
      return false unless @options[:retry_count] > 0
      @options[:retry_count] = @options[:retry_count] - 1;

      if @options[:retry_interval] > 0 then
        @log.info { "Sleeping for #{@options[:retry_interval]} seconds before retrying" }
        begin
          sleep @options[:retry_interval]
        rescue Interrupt
          return false
        end
      end
      true
    end

    # Runs the Lcoveralls application.
    #
    # This method does the real work of building up the Coveralls API request
    # according to the parsed options, and submitting the request to Coveralls.
    def run
      # Find *.info tracefiles if none specified on the command line.
      Find.find('.') do |path|
        @log.trace { "Looking for tracefiles: #{path}" }
        if path =~ /.*\.info$/ then
          @log.info { "Found tracefile: #{path}" }
          ARGV << path
        end
      end unless ARGV.any?

      @options[:root] = find_root(ARGV) unless @options.include?(:root)
      if !@options[:root] then
        @log.error 'Root not specified, nor detected; consider using --root'
        exit!
      end

      # Build the coveralls.io job request.
      job = {}
      job[:repo_token] = @options[:token] if @options.has_key? :token
      job[:service_name] = @options[:service] if @options.has_key? :service
      job[:service_job_id] = @options[:job_id] if @options.has_key? :job_id
      if !job.has_key?(:token) and !job.has_key?(:service_job_id) then
        @log.warn 'No service job id detected; consider using --token'
      end
      job[:source_files] = get_source_files(ARGV, @options[:root])
      job[:git] = get_git_info(@options[:root]) unless !@options[:git]
      job[:run_at] = Time.new
      request = Lcoveralls::CoverallsRequest.new(job)
      @log.trace { request.body }

      # If asked to, export the Coveralls API job request JSON document.
      if @options.has_key? :export then
        @options[:export].write(JSON::pretty_generate job);
      end

      # Send (if not in dryrun mode) the Coveralls API request.
      uri = URI('https://coveralls.io/api/v1/jobs')
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = @options[:timeout] if @options.has_key? :timeout
      http.read_timeout = @options[:timeout] if @options.has_key? :timeout
      http.ssl_timeout = @options[:timeout] if @options.has_key? :timeout
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER

      if !@options[:dryrun] then
        begin
          @log.debug { "Sending #{request.body.size} bytes to coveralls.io" }
          response = http.request(request)
          @log.debug { "HTTP response status: #{response.code} #{response.message}" }
          raise response.code unless response.is_a? Net::HTTPSuccess
          puts response.body
        rescue RuntimeError
          raise unless response
          @log.error { "Received non-OK response: #{response.code} #{response.message}" }
          puts response.body
          retry if should_retry? unless response.is_a? Net::HTTPClientError
          exit!
        rescue SocketError => error
          @log.error { error }
          retry if should_retry?
          exit!
        end
      end
    end

  end
end
