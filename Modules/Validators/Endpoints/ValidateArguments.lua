-- <pre>
local libraryUtil = require( 'libraryUtil' )

local UTIL = require( 'Module:Util' )

local DEFAULT_OPTIONS = {
	allowEmpty = false,
	allowUnknown = false,
}

local function validateArguments( arguments, parameters, options )
	libraryUtil.checkType( 'validateArguments', 1, arguments, 'table' )
	libraryUtil.checkType( 'validateArguments', 2, parameters, 'table' )
	libraryUtil.checkType( 'validateArguments', 3, options, 'table', true )

	options = options or DEFAULT_OPTIONS

	local validatedArguments = {}

	local messages = {}

	for parameter, argument in pairs( arguments ) do
		local schema = parameters[ parameter ]

		-- Unknown parameter:
		if not schema and not options.allowUnknown then
			local message = ( 'Invalid parameter `%s`!' ):format( parameter )

			table.insert( messages, message )

		-- Empty parameter that is not allowed to be empty:
		elseif (
			not ( schema and schema.allowEmpty or options.allowEmpty )
			and not UTIL.trim( argument )
		) then
			local message = ( 'Empty parameter `%s`!' ):format( parameter )

			table.insert( messages, message )

		-- Valid parameter with valid argument:
		else
			validatedArguments[ parameter ] = argument -- TODO: transform?
		end
	end

	for parameter, schema in pairs( parameters ) do
		if not arguments[ parameter ] then
			if schema.required then
				local message = ( 'Missing required parameter `%s`!' )
					:format( parameter )

				table.insert( messages, message )
			elseif schema.default then
				validatedArguments[ parameter ] = schema.default
			end
		end
	end

	return {
		messages = messages,
		validatedArguments = validatedArguments,
		isValid = not messages[ 1 ],
	}
end

return validateArguments
-- </pre>
