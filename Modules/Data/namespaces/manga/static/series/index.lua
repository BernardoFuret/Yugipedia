-- <pre>
local thisData = mw.loadData( 'Module:Data/namespaces/manga/static/series/data' )

local function normalize( v )
	return type( v ) == 'string'
		and mw.text.trim( v )
			:lower()
			:gsub( "[%s%-_'/:!]", '' )
			:gsub(         'the', '' )
			:gsub(   'strongest', '' )
			:gsub(         'ygo', '' )
			:gsub(      'yugioh', '' )
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
