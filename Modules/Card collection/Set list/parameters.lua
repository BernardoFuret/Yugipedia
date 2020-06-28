-- <pre>

local DATA = require( 'Module:Data' )

local CardCollectionUtils = require( 'Module:Card collection/Utils' )

local function columnsHandler( columns, columnName, columnValue )
	local columnName, interpolation = columnName:gsub( '^%$', '' )

	columns[ columnName ] = columns[ columnName ] or {}

	if interpolation ~= 0 then
		columns[ columnName ].template = columnValue
	else
		columns[ columnName ].default = columnValue
	end
end

return {
	region = {
		required = true,
		default = 'EN',
		handler = function( self, rawRegion )
			local region = DATA.getRegion( rawRegion )

			if not region then
				local message = ( 'Invalid `region` provided: `%s`!' )
					:format( rawRegion )

				local category = 'transclusions with invalid region'

				self.reporter
					:addError( message )
					:addCategory( category )
			end

			return region or DATA.getRegion( 'EN' )
		end,
	},

	header = {},

	rarities = {
		default = '',
	},

	print = {
		allowEmpty = true,
	},

	qty = {},

	description = {},

	[ '$description' ] = {},

	options = {
		default = '',
		handler = CardCollectionUtils.parseOptions,
	},

	columns = {
		handler = function( self, rawColumns )
			return CardCollectionUtils.parseOptions( self, rawColumns, columnsHandler )
		end,
	},

	[ 1 ] = {
		required = true,
		default = '',
--		options = {
--			[ 'printed-name' ] = {},
--			[ 'description' ] = {
--				allowEmpty = true,
--			},
--		}
	},
}
-- </pre>
