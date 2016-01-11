# coding: utf-8
require 'test_helper'
require 'pp'

class RaReqTest < ActiveSupport::TestCase

  test "RAreq get_upload_form" do
    upload_form = RaReq.get_upload_form
    # URI of uploade_page must be 'https://scia.secomtrust.net/upki-odcert/lra/MainMenu.do'
=begin
    assert upload_page.uri.scheme == 'https'
    assert upload_page.uri.host == 'scia.secomtrust.net'
    assert upload_page.uri.path == '/upki-odcert/lra/MainMenu.do'

    assert upload_page.title == '国立情報学研究所 電子証明書自動発行支援システム'
=end
    assert upload_form.class == Mechanize::Form
    assert upload_form.action == '/upki-odcert/lra/SP1011.do'

  end

  test "RAreq does not request twice" do
    assert RaReq.request(certs(:old_one)) == nil
    assert RaReq.request(certs(:old_two)) == nil
  end

  test "RAreq request new cert" do
    assert RaReq.request(certs(:one)) != nil
    assert certs(:one).state == Cert::State::NEW_REQUESTED_TO_NII
    assert certs(:one).state == 0
    assert RaReq.request(certs(:two)) != nil
    assert certs(:two).state == Cert::State::NEW_REQUESTED_TO_NII
  end

end
