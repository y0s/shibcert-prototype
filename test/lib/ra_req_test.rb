# coding: utf-8

require 'test_helper'

class RaReqTest < ActiveSupport::TestCase
  setup do
    @cert = certs(:one)
  end

  test "rareq new" do
    rareq = RaReq.new
#    upload_url = rareq.get_upload_url
#    p upload_url
  end
end
