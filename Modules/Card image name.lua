-- <pre>
--[=[Doc
@module Card image name
@description Converts a card name to be used in the image name.
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

local function cleanCardName( cardNameOrPagename )
	return cardNameOrPagename:gsub( '[#<>]', '' )
end

local function getEnglishName( cardNameOrPagename )
	local cleanedName = cleanCardName( cardNameOrPagename )

	local query = mw.smw.ask( {
		( '[[%s]]' ):format( cleanedName ),
		'?English name=',
		limit     = 1,
		mainlabel = '-'
	} )

	local cardName = ( ( query or {} )[ 1 ] or {} )[ 1 ]

	local decodedCardName = cardName and mw.text.decode( cardName ) or nil

	return decodedCardName
end

local function removeDab( name )
	return mw.text.split( name, '%s*%(' )[ 1 ]
end

local function processChars( name )
	local normalizedName = mw.ustring.gsub( name, '[ #–,%.:\'"%?!&@%%=%[%]<>/\\☆★・-]', '' )

	-- Sending the result to a reference instead of returning right away
	-- prevents returning multiple values (from `gsub`).
	return normalizedName
end


local function getCardImageName( cardNameOrPagename, options )
	local bypassSmw = ( options or {} ).bypassSmw

	local trimmedCardNameOrpagename = mw.text.trim( cardNameOrPagename or '' )

	if trimmedCardNameOrpagename == '' then
		return ''
	end

	local unencodedName = mw.text.decode( trimmedCardNameOrpagename )

	local englishName = not bypassSmw and getEnglishName( unencodedName )

	local nameAfterDabProcessed = englishName or removeDab( unencodedName )

	return processChars( nameAfterDabProcessed )
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
		{ "Fiend's Hand", 'FiendsHand' },
		{ 'Jinzo #7', 'Jinzo7' },
		{ 'Jinzo 7', 'Jinzo7' },
		{ 'Red Nova (card)', 'RedNova' },
		{ 'Griggle (anime)', 'Griggle' },
		{ 'Dynamic Dino Dynamix (L)', 'DynamicDinoDynamixL' },
		{ 'Yggdrago the Sky Emperor (R) (manga)', 'YggdragotheSkyEmperorR' },
		{ 'Yggdrago the Sky Emperor [R]', 'YggdragotheSkyEmperorR' },
		{ 'The Winged Dragon of Ra (Sphere Mode)', 'TheWingedDragonofRa(SphereMode)' },
		{ 'CotH', 'CalloftheHaunted' },
		{ 'Fiend&#39;s Hand', 'FiendsHand' },
		{ 'This is not a card name', 'Thisisnotacardname' },
		{ 'M∀LICE Pawn White Rabbit', 'MalissPWhiteRabbit' },
		{ 'M∀LICE <Pawn> White Rabbit', 'MalissPWhiteRabbit' },
		{ 'M∀LICE CODE GWC-06', 'MalissCGWC06' },
		{ 'M∀LICE <CODE> GWC-06', 'MalissCGWC06' },
		{ 'M∀LICE <&#67;ODE> GWC-06', 'MalissCGWC06' },
		{ 'Maliss <Q> RED RANSOM', 'MalissQREDRANSOM' },
		{ 'side:Pride', 'sidePride', { bypassSmw = true } },
		{ 'Red Nova (card)', 'RedNova', { bypassSmw = true } },
		{ 'Red Nova (nonexistent dab)', 'RedNova', { bypassSmw = true } },
	}

	for i, testCase in ipairs( testCases ) do
		local inputValue = testCase[ 1 ]

		local expectedValue = testCase[ 2 ]

		local options = testCase[ 3 ]

		local result = getCardImageName( inputValue, options )

		local testPassed = result == expectedValue

		mw.log( ( 'Case %d: %s' ):format( i, testPassed and 'PASSED' or 'FAILED' ) )

		if not testPassed then
			mw.log( '', ( 'Input:    %s' ):format( inputValue ) )
			mw.log( '', ( 'Expected: %s' ):format( expectedValue ) )
			mw.log( '', ( 'Result:   %s' ):format( result ) )
		end
	end
end

return setmetatable(
	{
		main = wikitextMain,
		test = test,
	},
	{
		__call = function( self, cardNameOrPagename, options )
			return getCardImageName( cardNameOrPagename, options )
		end,
	}
)
-- </pre>
