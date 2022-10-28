-- <pre>
local thisData = mw.loadData( 'Module:Data/static/rarity/data' )

local function normalize( v )
	return type( v ) == 'string'
		and mw.text.trim( v )
			:lower()
			:gsub( "[/%-_'%(%)]", '' )
			:gsub(      ' rare$', '' )
			:gsub(          's$', '' )
			:gsub(          '%s', '' )
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
