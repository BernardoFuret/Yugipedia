-- <pre>
local thisData = mw.loadData( 'Module:Data/static/rarity/data' )

local function normalize( v )
	return type( v ) == 'string'
		and mw.text.trim( v )
			:lower()
			:gsub(    ' rare$', '' )
			:gsub( "[/%s%-_']", '' )
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
