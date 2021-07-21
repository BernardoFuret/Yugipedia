-- <pre>
local thisData = mw.loadData( 'Module:Data/namespaces/videoGames/static/name/data' )

local function normalize( v )
	if type( v ) ~= 'string' then
		return nil
	end
	
	local normalizedV = table.concat( { v, ' ' } )
		:lower()
		-- Replace roman numerals:
		:gsub(   ' viii[!: ]', '8' )
		:gsub(    ' vii[!: ]', '7' )
		:gsub(     ' vi[!: ]', '6' )
		:gsub(      ' v[!: ]', '5' )
		:gsub(     ' iv[!: ]', '4' )
		:gsub(    ' iii[!: ]', '3' )
		:gsub(     ' ii[!: ]', '2' )
		:gsub(      ' i[!: ]', '1' )
		-- Remove a bunch of commonly used characters:
		:gsub( "[%s%-_'/:! ]",  '' )
		-- Remove series names:
		:gsub(       'yugioh',  '' )
		:gsub(          '5ds',  '' )
		:gsub(        'zexal',  '' )
		:gsub(         'arcv',  '' )
		:gsub(       'vrains',  '' )
		:gsub(      'rushduel', '' )
		-- Remove some redundant words:
		:gsub(          'the',  '' )
		:gsub(      'gameboy',  '' )
		:gsub( '%(videogame%)', '' )
		-- Normalize some titles:
		:gsub(      'expert', 'ex' )
		:gsub( 'worldchampionshiptournament', 'worldchampionship' )

	-- Remove "gx" and "ygo", if it's large enough (preserve "gx01", "gx3", "ygoo", "ygo" ):
	if normalizedV:len() > 4 then
		normalizedV = normalizedV
			:gsub(  'gx', '' )
			:gsub( 'ygo', '' )
		
		-- Remove "duelmonsters", if it's large enough (preserve cases like /duelmonsters\d/):
		if normalizedV:len() > 13 then
			normalizedV = normalizedV:gsub( 'duelmonsters', '' )

			-- Remove "worldchampionship", if it's large enough (preserve cases like /worldchampionship20\d\d/):
			if normalizedV:len() > 21 then
				normalizedV = normalizedV:gsub( 'worldchampionship', '' )
			end
		end
	end

	return normalizedV
end

return function( v )
	return thisData.main[
		thisData.normalize[
			normalize( v )
		]
	]
end
-- </pre>
