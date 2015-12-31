# coding: utf-8

require 'test_helper'

class RaReqTest < ActiveSupport::TestCase
  test "RAreq get_upload_url" do
    rareq = RaReq.new
    upload_url = rareq.get_upload_url
    assert upload_url.title == '国立情報学研究所 電子証明書自動発行支援システム'
  end

  test "RAreq " do
    rareq = RaReq.new
    rareq.request(certs(:one))
  end
end
