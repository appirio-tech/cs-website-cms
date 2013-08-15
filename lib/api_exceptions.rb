module ApiExceptions

	class EntityNotFoundError < StandardError
	end

	class AccessDenied < StandardError
	end

	class WTFError < StandardError
	end	

      class SFDCError < StandardError
        attr_reader :code, :message, :url
        def initialize(code, message, url)
          @code = code
          @message = message
          @url = url
        end
      end 

end