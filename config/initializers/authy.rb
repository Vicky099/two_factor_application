require 'yaml'
Authy.api_key = Rails.application.credentials.config[:authy][:key]
Authy.api_uri = 'https://api.authy.com/'