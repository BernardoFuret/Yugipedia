-- <pre>
local thisData = mw.loadData( 'Module:Data/static/medium/data' )

local getRegion = require( 'Module:Data/static/region' )

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
			( getRegion( v ) or {} ).index
			or normalize( v )
		]
	]
end
-- </pre>
