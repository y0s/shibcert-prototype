#!/usr/bin/env /usr/home/rails/shibcert/bin/rails runner
# coding: utf-8
# Local Variables:
# mode: ruby
# End:

require 'rubygems'
require 'mechanize'
require 'pp'
require 'logger'

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

class RAreq

  def initialize
  end

  def request(cert)
    return nil if cert.state != 0

    user = User.find_by(id: cert.user_id)

    tsv = [cert.dn,
           cert.cert_type_id,
           SHIBCERT_CONFIG[Rails.env]['cert_download_type'] || '1', # 1:P12個別
           '', '', '', '',
           SHIBCERT_CONFIG[Rails.env]['admin_name'],
           SHIBCERT_CONFIG[Rails.env]['admin_ou'],
           SHIBCERT_CONFIG[Rails.env]['admin_mail'],
           user.name,
           'NIIcert' + Time.now.strftime("%Y%m%d-%H%M%S"),
           SHIBCERT_CONFIG[Rails.env]['user_ou'],
           user.mail,
          ].join("\t")

    agent = Mechanize.new
    agent.cert = SHIBCERT_CONFIG[Rails.env]['certificate_file'] # config/shibcert.yml
    agent.key =  SHIBCERT_CONFIG[Rails.env]['certificate_key_file'] # config/shibcert.yml

    agent.get('https://scia.secomtrust.net/upki-odcert/lra/SSLLogin.do') # Login with client certificate

    agent.page.frame_with(:name => 'hidari').click

    form = agent.page.form_with(:name => 'MainMenuForm')
    form.forwardName = 'SP1011'     # 「発行・更新・失効」メニューのIDが 'SP1011'
    main_menu = form.submit

    form = main_menu.form_with(:name => 'SP1011')
    form.applyType = '1'            # 処理内容 1:発行, 2:更新, 3:失効
    form.radiobuttons_with(:name => 'errorFlg')[0].check # エラーが有れば全件処理を中止
    form.file_upload_with(:name => 'file'){|form_upload| # TSV をアップロード準備
      form_upload.file_data = TSV                        # アップロードする内容を文字列として渡す
      form_upload.file_name = 'sample.tsv'               # 何かファイル名を渡す
      form_upload.mime_type = 'application/force-download' # mime_type これで良いのか？
    }
    submitted_form = form.submit    # submit and file-upload

    #p submitted_form
    #p submitted_form.body.encoding
    $stderr.puts submitted_form.body # アップロード完了ページ．このページの内容を解析して正常終了したかどうかを確認する必要がある

    if Regexp("ファイルのアップロード処理が完了しました。").match(submitted_form.body)
      cert.state = 1
      return cert
    else
      cert.state = -1
      return nil
    end
  end
end


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
