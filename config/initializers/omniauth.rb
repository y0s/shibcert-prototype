Rails.application.config.middleware.use OmniAuth::Builder do
#  provider :shibboleth, { :debug => true }
  provider :shibboleth, {
	:uid_field => 'uid',
	:name_field => 'displayName',
        :info_fields => {
          :email    => 'email',
          :location => 'contactAddress',
          :image    => 'photo_url',
          :phone    => 'contactPhone',
        },
#       :debug => true,
#	:request_type => :header,
  }

  provider :github, '8b0c5bd290b61b887ff2', 'c86673a9871429ab1a6f8b7b29076f8e785f8d0a' 
end
