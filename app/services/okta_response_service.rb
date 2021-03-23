class OktaResponseService

	def initialize(params, status)
		@params = params
		@status = status
	end

	def id
		@params[:id]
	end
  
	def ok?
		@status == 200
	end
  
	def success?
		@status == 200 || @status == 204 || @status == 202 || @status == 201
	end

	def errors
		return "#{@params[:errorCode]} - #{@params[:errorSummary]} - #{@params[:errorId]} - #{@params[:errorCauses]}"
	end

	def error_message
		begin
			error = @params[:errorCauses].map{|k| p k[:errorSummary]}.join(", ")
		rescue
			error = nil
		end
		return  error.present? ? error : @params.errorSummary
	end

	def barcode
		return @params._embedded[:activation][:_links].qrcode[:href]
	end
end