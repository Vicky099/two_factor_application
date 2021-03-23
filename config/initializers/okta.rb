class Okta
	TOKEN = Rails.application.credentials.config[:okta][:key]
	ORG = Rails.application.credentials.config[:okta][:org]
	
	@@client = Oktakit.new(token: TOKEN, organization: ORG)
  
  	def self.client
    	@@client
  	end
end