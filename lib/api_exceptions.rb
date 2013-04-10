module ApiExceptions

	class EntityNotFoundError < StandardError
	end

	class AccessDenied < StandardError
	end

	class WTFError < StandardError
	end	

end