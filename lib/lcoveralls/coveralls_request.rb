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
