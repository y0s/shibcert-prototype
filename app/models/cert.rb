# coding: utf-8
class Cert < ActiveRecord::Base
  belongs_to :cert_type
  belongs_to :cert_state
  belongs_to :user

  module State
    REQUESTED_FROM_USER = 0	# 利用者から受付後、NIIへ申請前
    REQUESTED_TO_NII = 1        # 利用者から受付後、NIIへ申請直後
    RECEIVED_MAIL = 2           # 利用者から受付後、NIIへ申請後、メール受信済み
    GOT_PIN = 3                 # 利用者から受付後、NIIへ申請後、メール受信済み、PIN受取済み
    DISPLAYED_PIN = 4           # 利用者から受付後、NIIへ申請後、メール受信済み、PIN受取済み、利用者へ受け渡し後

    EXPIRED = 10                # 有効期限切れ
    REVOKED = 11                # 利用者による失効済み (期限切れ&失効の場合はこちら、更新後に旧証明書を失効した場合もこちら)

    UNKNOWN = -1                # 不明
  end
end
