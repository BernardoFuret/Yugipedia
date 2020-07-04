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
	}

	return setmetatable( data, Utils )
end

function Utils:validateArguments( parameters, arguments )
	local validated = {}

	for parameter, argument in pairs( arguments ) do
		local schema = parameters[ parameter ]

		-- Invalid parameter:
		if not schema then
			local message = ( 'Invalid parameter `%s`!' )
				:format( parameter )

			local category = 'transclusions with invalid parameters'

			self.reporter
				:addError( message )
				:addCategory( category )

		-- Empty parameter that is not allowed to be empty:
		elseif not UTIL.trim( argument ) and not schema.allowEmpty then
			local message = ( 'Empty parameter `%s`!' )
				:format( parameter )

			local category = 'transclusions with empty parameters'

			self.reporter
				:addError( message )
				:addCategory( category )

			validated[ parameter ] = schema.default

		-- Valid parameter with valid argument:
		else
			validated[ parameter ] = argument
		end
	end

	local schemaErrors = {}

	for parameter, schema in pairs( parameters ) do
		if schema.required and not schema.default then
			local message = ( 'No default value for required parameter `%s`!' )
				:format( parameter )
		
			table.insert( schemaErrors, message )
		end

		if not arguments[ parameter ] then
			if schema.required then
				local message = ( 'Missing required parameter `%s`!' ) -- TODO: for `1` it might not be obvious to the editor what's missing
					:format( parameter )

				local category = 'transclusions with missing required parameters' 

				self.reporter
					:addError( message )
					:addCategory( category )
			end

			validated[ parameter ] = schema.default
		end
	end

	if schemaErrors[ 1 ] then
		error( table.concat( schemaErrors, '<br />' ) )
	end

	return validated
end

local function parseOptionsHandler( container, key, value )
	container[ key ] = value
end

function Utils:parseOptions( rawOptions, location, handler ) -- TODO: check and disallow: `::value`
	local options = {}

	local position = 0

	for optionPairString in mwTextGsplit( rawOptions, '%s*;%s*' ) do
		position = position + 1

		local optionPairString = UTIL.trim( optionPairString )

		if optionPairString then -- TODO: check if :: is used more than once?
			local optionPair = mwTextSplit( optionPairString, '%s*::%s*' )

			local optionKey = optionPair[ 1 ]

			local optionValue = optionPair[ 2 ] or ''

			( handler or parseOptionsHandler )( options, optionKey, optionValue )
		else
			local message = ( 'Empty option, at %s, at position %d.' )
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
	return mwTextSplit( rawValues, '%s*;%s*' )
end

function Utils:handleInterpolation( value, template, default )
	--[[DOC
if row.desc==''                        => row.desc
if row.desc~=nil and $desc==nil        => row.desc
if row.desc~=nil and $desc~=nil        => interpolate row.desc in $desc
if row.desc==nil and default.desc~=nil => default.desc
if row.desc==nil and default.desc==nil => nil
	--]]
	if not UTIL.trim( value ) then
		return value or default -- this will result in returning empty string or default TODO: trim this?
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
