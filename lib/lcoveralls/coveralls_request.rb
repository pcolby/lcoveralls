require 'json'

module Lcoveralls

  class CoverallsRequest < Net::HTTP::Post

    def initialize(job, path='/api/v1/jobs')
      super path
      @boundary = (1...70).map { self.class.boundary_chr(rand(62)) }.join
      set_content_type "multipart/form-data, boundary=#{@boundary}"
      @body =
        "--#{@boundary}\r\n" +
        "Content-Disposition: form-data; name=\"json_file\"; filename=\"json_file\"\r\n" +
        "Content-Type: application/json\r\n\r\n" +
        JSON::generate(job) + "\r\n--#{@boundary}--\r\n"
    end

    # Note, 0-73 is valid for MIME, but only 0-61 is valid for HTTP headers.
    def self.boundary_chr(index)
      case index
      when 0..9
        index.to_s
      when 10..35
        ('a'.ord + index - 10).chr
      when 36..61
        ('A'.ord + index - 36).chr
      when 62..73
        "'()+_,-./:=?"[index - 62]
      else
        abort "Invalid boundary index #{index}"
      end
    end

  end

end
