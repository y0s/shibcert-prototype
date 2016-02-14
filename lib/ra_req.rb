#!/usr/bin/env /usr/home/rails/shibcert/bin/rails runner
# coding: utf-8
# Local Variables:
# mode: ruby
# End:

require 'rubygems'
require 'mechanize'
require 'pp'
require 'logger'

class RaReq
  module New
    def applyType
      1
    end

    def nextState
      Cert::State::NEW_REQUESTED_TO_NII
    end

    def errorState
      Cert::State::NEW_ERROR
    end

    def generate_tsv(cert, user)
      [
        cert.dn,
        cert.purpose_type,
        SHIBCERT_CONFIG[Rails.env]['cert_download_type'] || '1', # 1:P12個別
        '', '', '', '',
        SHIBCERT_CONFIG[Rails.env]['admin_name'],
        SHIBCERT_CONFIG[Rails.env]['admin_ou'],
        SHIBCERT_CONFIG[Rails.env]['admin_mail'],
        user.name,
        'NIIcert' + Time.now.strftime("%Y%m%d-%H%M%S"),
        SHIBCERT_CONFIG[Rails.env]['user_ou'],
        user.email,
      ].join("\t")
    end
  end

  module Renew
    def applyType
      2
    end

    def nextState
      Cert::State::RENEW_REQUESTED_TO_NII
    end

    def errorState
      Cert::State::RENEW_ERROR
    end

    def generate_tsv(cert, user)
      [
        cert.dn,
        cert.purpose_type,
        SHIBCERT_CONFIG[Rails.env]['cert_download_type'] || '1', # 1:P12個別
        cert.serialnumber,
        '', '', '',
        SHIBCERT_CONFIG[Rails.env]['admin_name'],
        SHIBCERT_CONFIG[Rails.env]['admin_ou'],
        SHIBCERT_CONFIG[Rails.env]['admin_mail'],
        user.name,
        'NIIcert' + Time.now.strftime("%Y%m%d-%H%M%S"),
        SHIBCERT_CONFIG[Rails.env]['user_ou'],
        user.email,
      ].join("\t")
    end
  end

  module Revoke
    def applyType
      3
    end

    def nextState
      Cert::State::REVOKE_REQUESTED_TO_NII
    end

    def errorState
      Cert::State::REVOKE_ERROR
    end

    def generate_tsv(cert, user)
      [
        cert.dn,                  # 1
        '','',
        cert.serialnumber,   # 4
        cert.revoke_reason,       # 5
        cert.revoke_comment,      # 6
        '', '', '',
        SHIBCERT_CONFIG[Rails.env]['admin_mail'], # 10
        '', '', '',
        user.email,               # 14
      ].join("\t")
    end
  end

  def initialize
    %w(admin_name admin_ou admin_mail user_ou).each do |key|
      unless SHIBCERT_CONFIG[Rails.env].has_key?(key)
        Rails.logger.debug "Nesesary value '#{key}' in '#{Rails.env}' is not set in system configuration file."
      end
    end
  end

  def self.get_upload_form
    agent = Mechanize.new
    begin
      agent.cert = SHIBCERT_CONFIG[Rails.env]['certificate_file'] # config/shibcert.yml
    rescue => evar
      Rails.logger.info "error: certificate_file '#{SHIBCERT_CONFIG[Rails.env]['certificate_file']}' #{evar.inspect}"
      raise
    end
    begin
      agent.key =  SHIBCERT_CONFIG[Rails.env]['certificate_key_file'] # config/shibcert.yml
    rescue => evar
      Rails.logger.info "error: certificater_key_file '#{SHIBCERT_CONFIG[Rails.env]['certificate_key_file']}' #{evar.inspect}"
      raise
    end
    agent.get('https://scia.secomtrust.net/upki-odcert/lra/SSLLogin.do') # Login with client certificate

    agent.page.frame_with(:name => 'hidari').click

    form = agent.page.form_with(:name => 'MainMenuForm')
    form.forwardName = 'SP1011'     # 「発行・更新・失効」メニューのIDが 'SP1011'

    form2 = form.submit
    form2.form_with(:name => 'SP1011')
  end
  
  def self.request(cert)
    case cert.state
    when Cert::State::NEW_REQUESTED_FROM_USER
      extend New
    when Cert::State::RENEW_REQUESTED_FROM_USER
      extend Renew
    when Cert::State::REVOKE_REQUESTED_FROM_USER
      extend Revoke
    else
      Rails.logger.info "RaReq.request failed because of cert.state is #{cert.state})"
      return nil
    end

    user = User.find_by(id: cert.user_id)
    unless user
      Rails.logger.info "RaReq.request failed because of User.find_by(id: #{cert.user_id}) == nil"
      return nil
    end

    tsv = generate_tsv(cert, user).encode('cp932')
    Rails.logger.debug "#{__method__}: tsv #{tsv.inspect}"

    if Rails.env == 'development' then
      open("sample.tsv", "w") do |fp|
        fp.write(tsv)
      end
    end

    form = self.get_upload_form

    form.applyType = applyType            # 処理内容 1:発行, 2:更新, 3:失効
    form.radiobuttons_with(:name => 'errorFlg')[0].check # エラーが有れば全件処理を中止
    form.file_upload_with(:name => 'file'){|form_upload| # TSV をアップロード準備
      form_upload.file_data = tsv                        # アップロードする内容を文字列として渡す
      form_upload.file_name = 'sample.tsv'               # 何かファイル名を渡す
      form_upload.mime_type = 'application/force-download' # mime_type これで良いのか？
    }
    submitted_form = form.submit    # submit and file-upload

    if Rails.env == 'development' then
      open("body.html", "w") do |fp|
        fp.write submitted_form.body.force_encoding("euc-jp")
      end
    end

    if Regexp.new("ファイルのアップロード処理が完了しました。").match(submitted_form.body.encode("utf-8", "euc-jp"))
      cert.state = nextState
      cert.save
      Rails.logger.debug "#{__method__}: upload success"
      return cert
    else
      cert.state = errorState
      cert.save
      Rails.logger.debug "#{__method__}: upload fail"
      return nil
    end
  end
end


=begin
# TSV format https://certs.nii.ac.jp/archive/TSV_File_Format/client_tsv/
TSV = ['CN=example,OU=001,OU=Example OU,O=Kyoto University,L=Academe,C=JP', # No.1 certificate DN
       '5',                     # No.2 Profile - 4:client(sha1), 5:client(sha256), 6:S/MIME(sha1), 7:S/MIME(sha256)
       '1',                     # No.3 Download Type - 1:P12個別, 2:P12一括, 3:ブラウザ個別
       '',                      # No.4 -
       '',                      # No.5 -
       '',                      # No.6 -
       '',                      # No.7 -
       'Name',                  # No.8 admin user name
       'Example OU',            # No.9 admin OU
       'example@kyoto-u.ac.jp', # No.10 admin mail
       'Name',                  # No.11 user name
       'example20151221C00511', # No.12 P12 filename
       'example OU',            # No.13 user OU 
       'example@kyoto-u.ac.jp', # No.14 user mail
      ].join("\t")
=end

# 最終ページの例

=begin

成功例

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<title>国立情報学研究所 電子証明書自動発行支援システム</title>
</head>

<body>
<table>
    <tr><td arign="center">
    	<img src="/img/submenu_dot.gif"><b>クライアント証明書　発行・更新申請完了画面</b></td></tr>
    <tr><td>&nbsp;</td></tr>
     <tr><td style="position:relative;left:10px">
        ファイルのアップロード処理が完了しました。<br>
        
        
        <ul>
        	<li>証明書発行処理が完了後、利用管理者様宛にワンタイムURL付きアクセスPIN取得案内メールを送信致します。</li>
        	<li>利用者様宛にワンタイムURL付き証明書発行案内メールを送信致します。 ワンタイムURLはアクセスPIN取得後、有効化されます。</li>
        	<li>証明書ダウンロードが完了後、登録担当者様と利用管理者様宛にダウンロード完了案内メールを送信致しますのでお待ち下さい。</li>
        </ul>
        
        
        
    </td></tr>
    <tr><td>&nbsp;</td></tr>
    
    <tr style="position:relative;left:10px;"><td align="center">
        <table border="1" bordercolor="#808080">
            <tr style="background:#AAAAAA">
                <th align="center" nowrap><font size="-1">SEQ</font></th>
                <th align="center" nowrap><font size="-1">処理結果</font></th>
                <th align="center" nowrap><font size="-1">エラー内容</font></th>
                <th align="center" nowrap><font size="-1">機関名</font></th>
                <th align="center" nowrap><font size="-1">所属名</font></th>
                <th align="center" nowrap><font size="-1">氏名</font></th>
                <th align="center" nowrap><font size="-1">メールアドレス</font></th>
            </tr>
            
            <tr>
	            <td align="center" nowrap><font size="-1">
	            	
	            	1
	            </font></td>
	            <td align="center" nowrap><font size="-1">
	            	
	            	OK
	            </font></td>
	            <td align="left" nowrap><font size="-1">
	            	&nbsp;
	            	
	            </font></td>
	            <td align="left" nowrap><font size="-1">
	            	
	            	京都大学
	            </font></td>
	            <td align="left" nowrap><font size="-1">
	            	
	            	Example OU
	            </font></td>
	            <td align="left" nowrap><font size="-1">
	            	
	            	Name
	            </font></td>
	            <td align="left" nowrap><font size="-1">
	            	
	            	user@example.com
	            </font></td>
	        </tr>
	        
        </table>
    </td></tr>
    <tr><td>&nbsp;</td></tr>
</table>
</body>
</html>
=end


=begin
失敗例

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<title>国立情報学研究所 電子証明書自動発行支援システム</title>
</head>

<body>
<table>
    <tr><td arign="center">
    	<img src="/img/submenu_dot.gif"><b>クライアント証明書　発行・更新・失効申請エラー画面</b>
    </td></tr>
    <tr><td>&nbsp;</td></tr>
    <tr style="position:relative;left:10px"><td>
                クライアント証明書　発行処理が以下のエラーにより正常終了しませんでした。
    </td></tr>
    <tr><td>&nbsp;</td></tr>
    <tr style="position:relative;left:10px;"><td align="center">
        <table border="1" bordercolor="#808080">
            <tr style="background:#AAAAAA">
                <th align="center" nowrap><font size="-1">SEQ</font></th>
                <th align="center" nowrap><font size="-1">処理結果</font></th>
                <th align="center" nowrap><font size="-1">エラー内容</font></th>
            </tr>
            
            <tr>
	            <td align="center" nowrap><font size="-1">
	            	
	            	1
	            </font></td>
	            <td align="center" nowrap><font size="-1">
	            	
	            	NG
	            </font></td>
	            <td align="left" nowrap><font size="-1">
	            	
	            	212:1,主体者DN,指定したDNはすでに存在しています。
	            </font></td>
	        </tr>
	        
        </table>
    </td></tr>
    <tr><td>&nbsp;</td></tr>
</table>
</body>
</html>
=end
