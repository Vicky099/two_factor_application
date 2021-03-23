class AuthyResponseService

	def initialize(params)
		@params = params
	end


	def id
		params['id']
	end

	def ok?
		@params.ok?
	end

	def success?
		@params.success?
	end

	def errors
		@params.errors
	end

	def message
		@params.message
	end

	def error_message
		JSON.parse(errors['error'])['message']
	end


end