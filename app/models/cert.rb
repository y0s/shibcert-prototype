# coding: utf-8
class Cert < ActiveRecord::Base
  belongs_to :cert_type
  belongs_to :cert_state
  belongs_to :user

  module PurposeType
    CLIENT_AUTH_CERTIFICATE = 5
    SMIME_CERTIFICATE = 7
  end
  
  module State
    # 新規発行
    NEW_REQUESTED_FROM_USER = 10 # 利用者から受付後、NIIへ申請前
    NEW_REQUESTED_TO_NII = 11   # 利用者から受付後、NIIへ申請直後
    NEW_RECEIVED_MAIL = 12 # 利用者から受付後、NIIへ申請後、メール受信済み
    NEW_GOT_PIN = 13 # 利用者から受付後、NIIへ申請後、メール受信済み、PIN受取済み
    NEW_DISPLAYED_PIN = 14 # 利用者から受付後、NIIへ申請後、メール受信済み、PIN受取済み、利用者へ受け渡し後
    NEW_ERROR = 19

    # 更新
    RENEW_REQUESTED_FROM_USER = 20 # 利用者から受付後、NIIへ申請前
    RENEW_REQUESTED_TO_NII = 21   # 利用者から受付後、NIIへ申請直後
    RENEW_RECEIVED_MAIL = 22 # 利用者から受付後、NIIへ申請後、メール受信済み
    RENEW_GOT_PIN = 23 # 利用者から受付後、NIIへ申請後、メール受信済み、PIN受取済み
    RENEW_DISPLAYED_PIN = 24 # 利用者から受付後、NIIへ申請後、メール受信済み、PIN受取済み、利用者へ受け渡し後
    RENEW_ERROR = 29

    # 失効
    REVOKE_REQUESTED_FROM_USER = 30 # 利用者から受付後、NIIへ申請前
    REVOKE_REQUESTED_TO_NII = 31   # 利用者から受付後、NIIへ申請直後
    REVOKE_RECEIVED_MAIL = 32 # 利用者から受付後、NIIへ申請後
    REVOKED = 33 # 利用者による失効済み
    REVOKE_ERROR = 39

    UNKNOWN = -1                # 不明
  end
end
