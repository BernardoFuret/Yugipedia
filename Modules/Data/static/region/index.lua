-- <pre>
local thisData = mw.loadData( 'Module:Data/static/region/data' )

local function normalize( v )
	return type( v ) == 'string'
		and mw.text.trim( v )
			:lower()
			:gsub( "[%s%-_'!]", '' )
			:gsub(     'north', '' )
		or nil
end

return function( v )
	return thisData.main[
		thisData.normalize[
			normalize( v )
		]
	]
end
-- </pre>
