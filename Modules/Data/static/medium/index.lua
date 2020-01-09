-- <pre>
local thisData = mw.loadData( 'Module:Data/static/medium/data' )

local DATA = require( 'Module:Data' )

local function normalize( v )
	return type( v ) == 'string'
		and mw.text.trim( v )
			:lower()
			:gsub( "[%s%-_'!]", '' )
			:gsub(    'yugioh', '' )
			:gsub(  'cardgame', '' )
		or nil
end

return function( v )
	return thisData.main[
		thisData.normalize[
			( DATA.getRegion( v ) or {} ).index
			or normalize( v )
		]
	]
end
-- </pre>
