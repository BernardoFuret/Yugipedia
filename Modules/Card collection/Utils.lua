-- <pre>
--[=[Doc
@module Card collection/Utils
@description Util functions for concrete Card collection modules.
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]
-- TODO:
-- * better name for this module
-- * on the parameters schema, track parameters that cannot be empty,
-- but have an empty default value?

local UTIL = require( 'Module:Util' )

local mwText = mw.text
local mwTextGsplit = mwText.gsplit
local mwTextSplit = mwText.split

local Utils = {}
Utils.__index = Utils

function Utils.new( name, reporter, frame )
	local data = {
		name = name,
		reporter = reporter,
		frame = frame,
		separator = nil,
		escapedSeparator = nil,
	}

	return setmetatable( data, Utils )
end

function Utils:setSeparator( separator )
	self.separator = separator

	self.escapedSeparator = UTIL.escape( separator )

	return self
end

function Utils:validateArguments( parameters, arguments, moduleArguments )
	local validated = {}

	local hasHaltingError = false

	for parameter, moduleArgument in pairs( moduleArguments ) do
		local schema = parameters[ parameter ]

		local argument = arguments[ parameter ]

		-- Invalid parameter:
		if not schema then
			local message = ( 'Invalid parameter `%s`!' )
				:format( parameter )

			local category = 'transclusions with invalid parameters'

			self.reporter
				:addError( message )
				:addCategory( category )

		-- Empty parameter that is not allowed to be empty:
		elseif (
			not schema.allowEmpty
			and not UTIL.trim( moduleArgument )
			and not UTIL.trim( argument )
		) then
			local message = ( 'Empty parameter `%s`!' )
				:format( parameter )

			local category = 'transclusions with empty parameters'

			self.reporter
				:addError( message )
				:addCategory( category )

			hasHaltingError = true

		-- Valid parameter with valid argument:
		else
			validated[ parameter ] = moduleArgument
		end
	end

	for parameter, argument in pairs( arguments ) do
		local schema = parameters[ parameter ]

		local moduleArgument = moduleArguments[ parameter ]

		-- Invalid parameter:
		if not schema then
			local message = ( 'Invalid parameter `%s`!' )
				:format( parameter )

			local category = 'transclusions with invalid parameters'

			self.reporter
				:addError( message )
				:addCategory( category )

		-- Empty parameter that is not allowed to be empty:
		elseif (
			not schema.allowEmpty
			and not UTIL.trim( argument )
			and not UTIL.trim( moduleArgument )
		) then
			local message = ( 'Empty parameter `%s`!' )
				:format( parameter )

			local category = 'transclusions with empty parameters'

			self.reporter
				:addError( message )
				:addCategory( category )

			hasHaltingError = true

		-- Valid parameter with valid argument:
		else
			validated[ parameter ] = argument
		end
	end

	for parameter, schema in pairs( parameters ) do
		if schema.required and schema.default then
			local message = ( 'Required parameter `%s` with set default value!' )
				:format( parameter )

				local category = 'transclusions with required parameters with set default values'

			hasHaltingError = true
		end

		if not arguments[ parameter ] and not moduleArguments[ parameter ] then
			if schema.required then
				-- TODO: for `1` it might not be obvious to the editor what's missing
				local message = ( 'Missing required parameter `%s`!' )
					:format( parameter )

				local category = 'transclusions with missing required parameters'

				self.reporter
					:addError( message )
					:addCategory( category )

				hasHaltingError = true
			elseif schema.default then
				validated[ parameter ] = schema.default
			end
		end
	end

	if hasHaltingError then
		return {
			hasHaltingError = true
		}
	end

	return validated
end

local function parseOptionsHandler( container, key, value )
	container[ key ] = value
end

function Utils:parseOptions( rawOptions, location, config ) -- TODO: check and disallow: `::value`
	local config = config or {}

	local options = config.initial or {}

	if not UTIL.trim( rawOptions ) then
		return options
	end

	local position = 0

	local optionsSplitter = table.concat{ '%s*', self.escapedSeparator, '%s*' }

	for optionPairString in mwTextGsplit( rawOptions, optionsSplitter ) do
		position = position + 1

		local optionPairString = UTIL.trim( optionPairString )

		if optionPairString then -- TODO: check if :: is used more than once?
			local optionPair = mwTextSplit( optionPairString, '%s*::%s*' )

			local optionKey = optionPair[ 1 ]

			local optionValue = optionPair[ 2 ] or ''

			( config.handler or parseOptionsHandler )( options, optionKey, optionValue )
		else
			local message = ( 'Empty option, at %s, at position %d!' )
				:format( location, position )

			local category = 'transclusions with empty options'

			self.reporter
				:addError( message )
				:addCategory( category )
		end
	end

	return options
end

local function makeCssClassName( v )
	-- The extra parenthesis are to avoid returning
	-- the multiple values returned by `gsub`.
	return ( v:lower():gsub( '%s+', '-' ) )
end

function Utils:makeCssClass( ... )
	local names = {
		makeCssClassName( self.name ),
	}

	for _, name in ipairs{ ... } do
		table.insert( names, makeCssClassName( name ) )
	end

	return table.concat( names, '__' )
end

function Utils:parseValues( rawValues )
	local valuesSplitter = table.concat{ '%s*', self.escapedSeparator, '%s*' }

	return mwTextSplit( rawValues, valuesSplitter )
end

function Utils:handleInterpolation( value, template, default )
	--[[DOC
value    = row.desc
template = $desc not empty
default  = default.desc

if row.desc==empty                    => nil
if row.desc==nil                      => trim default.desc
if row.desc~=empty|nil and $desc==nil => row.desc
if row.desc~=empty|nil and $desc~=nil => interpolate row.desc in $desc
	--]]
	if not UTIL.trim( value ) then
		return UTIL.trim( value or default )
	end

	if not template then
		return value
	end

	if template then
		local parts = mwTextSplit( value, '%s*,%s*' )

		return template:gsub( '%$(%d)', function( n )
			return parts[ tonumber( n ) ] or ''
		end )
	end

	error( 'Should never reach this point' )
end

return setmetatable( Utils, {
	__call = function( t, name, reporter, frame )
		assert(
			t == Utils,
			'Cannot apply Card collection/Utils constructor except to itself'
		)

		return Utils.new( name, reporter, frame )
	end
} )
-- </pre>
