-- <pre>
--[=[Doc
@module Card image name
@description Converts a card name to be used in the image name.
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

local function getEnglishName( cardNameOrpagename )
	local query = mw.smw.ask( {
		( '[[%s]]' ):format( cardNameOrpagename:gsub( '#', '' ) ),
		'?English name=',
		limit     = 1,
		mainlabel = '-'
	} )

	return ( ( query or {} )[ 1 ] or {} )[ 1 ] or cardNameOrpagename
end

local function normalize( name )
	local nameWithoutDab = mw.text.split( name, '%s*%(' )[ 1 ]

	-- TODO: simplify
	local normalizedName = nameWithoutDab
		:gsub( ' ' , '' ):gsub( '#' , '' )
		:gsub( '%-', '' ):gsub( '–' , '' )
		:gsub( ',' , '' ):gsub( '%.', '' ):gsub( ':', '' )
		:gsub( '\'', '' ):gsub( '"' , '' )
		:gsub( '%?', '' ):gsub( '!' , '' )
		:gsub( '&' , '' ):gsub( '@' , '' )
		:gsub( '%%', '' ):gsub( '=' , '' )
		:gsub( '%[', '' ):gsub( '%]', '' )
		:gsub( '<' , '' ):gsub( '>' , '' )
		:gsub( '/' , '' ):gsub( '\\', '' )
		:gsub( '☆' , '' ):gsub( '★' , '' ):gsub( '・' , '' )

	-- Sending the result to a reference instead of returning right away
	-- prevents returning multiple values (from `gsub`).
	return normalizedName
end


local function getCardImageName( cardNameOrpagename )
	local trimmedCardNameOrpagename = mw.text.trim( cardNameOrpagename or '' )

	if trimmedCardNameOrpagename == '' then
		return ''
	end

	local englishName = getEnglishName( trimmedCardNameOrpagename )

	return normalize( englishName )
end

local function wikitextMain( frame )
	local arguments = frame:getParent().args

	return getCardImageName( arguments[ 1 ] )
end

local function test()
	local testCases = {
		{ '', '' },
		{ 'Dark Magician', 'DarkMagician' },
		{ 'Blue-Eyes White Dragon', 'BlueEyesWhiteDragon' },
		{ 'Stardust Dragon/Assault Mode', 'StardustDragonAssaultMode' },
		{ 'Jinzo #7', 'Jinzo7' },
		{ 'Jinzo 7', 'Jinzo7' },
		{ 'Red Nova (card)', 'RedNova' },
		{ 'Griggle (anime)', 'Griggle' },
		{ 'Great Imperial Dinocarriage Dynarmix (L)', 'GreatImperialDinocarriageDynarmixL' },
		{ 'Yggdrago the Sky Emperor (R) (manga)', 'YggdragotheSkyEmperorR' },
		{ 'Yggdrago the Sky Emperor [R]', 'YggdragotheSkyEmperorR' },
		{ 'This is not a card name', 'Thisisnotacardname' },
	}

	for i, testCase in ipairs( testCases ) do
		local inputValue = testCase[ 1 ]

		local expectedValue = testCase[ 2 ]

		local result = getCardImageName( inputValue )

		mw.log( i, '\t', result, '\t', result == expectedValue, '\t', expectedValue )
	end
end

return setmetatable(
	{
		main = wikitextMain,
		test = test,
	},
	{
		__call = function( self, cardNameOrpagename )
			return getCardImageName( cardNameOrpagename )
		end,
	}
)
-- </pre>
