-- <pre>
-- TODO: same code as Module:Data/namespaces/anime/static/release/data; refactor (Module:Data/namespaces/common/static/release/data?)
local thisData = mw.loadData( 'Module:Data/namespaces/manga/static/release/data' )

local function normalize( v )
	return type( v ) == 'string'
		and mw.text.trim( v )
			:lower()
			:gsub( '[%s%-_]', '' )
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
