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

require 'test_helper'

require_relative '../lib/lcoveralls/coveralls_request'

class TestCoverallsRequest < Test::Unit::TestCase

  def test_initialize
    job = { 'foo' => 'bar', 'baz' => 123 }
    request = Lcoveralls::CoverallsRequest.new job

    assert_equal('/api/v1/jobs', request.path)
    assert_match(/^multipart\/form-data, boundary=[\d\w]{70}$/, request.content_type)
    boundary = request.content_type.match(/.*boundary=([\d\w]{70})/)[1]
    lines = request.body.lines.to_a
    assert_equal(6, lines.count)
    assert_equal("--#{boundary}\r\n", lines[0])
    assert_equal(
      "Content-Disposition: form-data; name=\"json_file\"; filename=\"json_file\"\r\n",
      lines[1])
    assert_equal("Content-Type: application/json\r\n", lines[2])
    assert_equal("\r\n", lines[3])
    assert_equal(JSON::generate(job) + "\r\n", lines[4])
    assert_equal("--#{boundary}--\r\n", lines.last)
  end

  def test_boundar_chr
    # First 62 characters should be alphanumeric.
    62.times do |index|
      assert_match /^(\d|\w)$/,
        Lcoveralls::CoverallsRequest::boundary_chr(index)
    end

    # All 74 characters should be valid.
    74.times do |index|
      assert_match /^(\d|\w|[-'()+_,.\/:=?])$/,
        Lcoveralls::CoverallsRequest::boundary_chr(index)
    end

    # Index values outside the range 0..73 should abort.
    assert_raise RuntimeError do
      Lcoveralls::CoverallsRequest::boundary_chr(-1)
    end
    assert_raise RuntimeError do
      Lcoveralls::CoverallsRequest::boundary_chr(74)
    end
    assert_raise RuntimeError do
      Lcoveralls::CoverallsRequest::boundary_chr(100)
    end
  end

end
