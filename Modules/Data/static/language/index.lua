-- <pre>
local thisData = mw.loadData( 'Module:Data/static/language/data' )

local DATA = require( 'Module:Data/sandbox' )

return function( v )
	return thisData.main[
		thisData.normalize[
			( DATA.getRegion( v ) or {} ).index
		]
	]
end
-- </pre>
