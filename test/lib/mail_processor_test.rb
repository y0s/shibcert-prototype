# coding: utf-8
require 'test_helper'

class MailProcessorTest < ActiveSupport::TestCase

  test 'should do MailProcessor.new' do
    mp = MailProcessor.new
  end

  test 'should update PIN once only' do
    record = Cert.find_by(state: Cert::State::NEW_REQUESTED_TO_NII)
    assert record != nil, "test record not found"

    DN = record.dn
    PIN = '1234'
    assert Cert.update_from_mail(update_target: 'pin', value: PIN, dn: DN) != nil
    record = Cert.find(record.id) # reload
    assert record.state == Cert::State::NEW_GOT_PIN, "invalid cert.state"
    assert record.pin == PIN, "invalid cert.pin"

    # can't update twice
    assert Cert.update_from_mail(update_target: 'pin', value: PIN, dn: DN) == nil
  end


  test 'should update X509_SerialNumber once only' do
    record = Cert.find_by(state: Cert::State::NEW_DISPLAYED_PIN)
    assert record != nil, "test record not found"

    DN = record.dn
    SN = "1234567890"
    assert Cert.update_from_mail(update_target: 'x509_serialnumber', value: SN, dn: DN) != nil
    record = Cert.find(record.id) # reload
    assert record.state == Cert::State::NEW_GOT_SERIAL, "invalid cert.state"
    assert record.serialnumber == SN, "invalid cert.serialnumber"

    # can't update twice
    assert Cert.update_from_mail(update_target: 'x509_serialnumber', value: SN, dn: DN) == nil
  end
end
