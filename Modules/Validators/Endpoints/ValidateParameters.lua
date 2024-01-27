-- <pre>
local libraryUtil = require( 'libraryUtil' )

local SCHEMA_SPEC = {
	allowEmpty = {
		type = 'boolean',
		required = false,
	},
	required = {
		type = 'boolean',
		required = false,
	},
	default = {
		required = false,
	}
}

local function validateParameterSpec( parameterSchema )
	local messages = {}

	for key, value in pairs( parameterSchema ) do
		if not SCHEMA_SPEC[ key ] then
			local message = ( 'Invalid schema key `%s`!' ):format( key )

			table.insert( messages, message )
		end
	end

	for key, value in pairs( SCHEMA_SPEC ) do
		local parameterDescription = parameterSchema[ key ]

		if not parameterDescription and value.required then
			local message = ( 'Missing required option `%s`!' )
				:format( key )

			table.insert( messages, message )
		end

		local schemaKeyType = type( parameterDescription )

		if parameterDescription and value.type and schemaKeyType ~= value.type then
			local message = ( 'Invalid type `%s` for key `%s`! Valid type is `%s`.' )
				:format( schemaKeyType, key, value.type )

			table.insert( messages, message )
		end
	end

	return {
		messages = messages,
		isValid = not messages[ 1 ],
	}
end

local function validateParameters( parameters )
	libraryUtil.checkType( 'validateParameters', 1, parameters, 'table' )

	local messages = {}

	for parameter, schema in pairs( parameters ) do
		if schema.required and schema.default then
			local message = ( 'Required parameter `%s` with set default value!' )
				:format( parameter )

			table.insert( messages, message )
		end

		local keyValidationResult = validateParameterSpec( schema, SCHEMA_SPEC )

		for _, message in ipairs( keyValidationResult.messages ) do
			local newMessage = ( 'Invalid spec for parameter `%s`: %s' )
				:format( parameter, message )

			table.insert( messages, newMessage )
		end
	end

	return {
		messages = messages,
		isValid = not messages[ 1 ],
	}
end

return validateParameters
-- </pre>
