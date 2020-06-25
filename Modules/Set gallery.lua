-- <pre>
--[=[Doc
@module 
@description 
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
TODO:
- Cleanup
- Refactor: split responsibilities more strictly;
- Add header parameter?
- Interpolation should return nil instead of empty string
- Merge with set list (metamodule)

- Printed-name if no localized name was found (will display after the English name).
]=]

local DATA = require( 'Module:Data' )
local UTIL = require( 'Module:Util' )

local Reporter = require( 'Module:Reporter' )
local StringBuffer = require( 'Module:StringBuffer' )

local LANGUAGE_ENGLISH = DATA.getLanguage( 'English' )
local RARITY_COMMON = DATA.getRarity( 'Common' )

local currentTitle = mw.title.getCurrentTitle()

local NS = currentTitle.nsText
local PAGENAME = NS == 'Module'
	and 'Sneak Peek Participation Cards: Series 6 (TCG-EN-LE)'
	or currentTitle.text

local TAG_BR = '<br />'

local mwText = mw.text
local mwHtmlCreate = mw.html.create
local mwTextGsplit = mwText.gsplit
local mwTextSplit = mwText.split

local reporter

local parameters = { -- TODO: split to own module
	header = {},

	abbr = {},

	rarity = {},

	alt = {},

	notes = {},

	description = {},

	[ '$description' ] = {},

	[ 1 ] = {
		required = true,
		default = '',
--		options = {
--			[ 'file' ] = {},
--			[ 'abbr' ] = {},
--			[ 'extension' ] = {},
--			[ 'printed-name' ] = {},
--			[ 'description' ] = {
--				allowEmpty = true,
--			},
--		}
	},
}

-- NOTE: validation
local function validateArguments( args ) -- TODO: split to own module
	local validated = {}

	for param, arg in pairs( args ) do
		-- Invalid parameter:
		if not parameters[ param ] then
			local message = ( 'Invalid parameter `%s`!' )
				:format( param )

			local category = 'transclusions with invalid parameters'

			reporter
				:addError( message )
				:addCategory( category )

		-- Empty parameter that is not allowed to be empty:
		elseif not UTIL.trim( arg ) and not parameters[ param ].allowEmpty then
			local message = ( 'Empty parameter `%s`!' )
				:format( param )

			local category = 'transclusions with empty parameters'

			reporter
				:addError( message )
				:addCategory( category )

		-- Valid parameter with valid argument:
		else
			validated[ param ] = arg
		end
	end

	-- TODO: verify required parameters without looping again
	for param, definition in pairs( parameters ) do
		if not validated[ param ] then
			if definition.required then
				local message = ( 'Missing required parameter `%s`!' ) -- TODO: for `1` it might not be obivous to the editor what's missing
					:format( param )

				local category = 'transclusions with missing required parameters' 

				reporter
					:addError( message )
					:addCategory( category )
			end

			validated[ param ] = definition.default
		end
	end

	return validated
end

local function validateRarity( rawRaritiy )
	local rarity = DATA.getRarity( rawRaritiy )

	if not rarity then
		local message = ( 'No such rarity for `%s`, at parameter `rarity`.' )
			:format( rawRaritiy )

		local category = 'transclusions with invalid rarities'

		reporter
			:addError( message )
			:addCategory( category )
	end

	return rarity
end

local function getRegion()
	local index = PAGENAME:match( 'CG%-(%a+)%-?' )

	local region = DATA.getRegion( index ) -- TODO: handle erroneous region (nil)?

	return region
end

local function getEdition()
	local index = PAGENAME:match( 'CG%-%a+%-(%w+)' )

	local edition = DATA.getEdition( index ) -- TODO: handle erroneous edition (nil)?

	return edition
end

-- NOTE: Parsing
--[[local function parseOptionsHandler( container, key, value )
	container[ key ] = value
end--]]

local function parseOptions( rawOptions, handler ) -- TODO: check and disallow: `::value`
	local options = {}

	for optionPairString in mwTextGsplit( rawOptions, '%s*;%s*' ) do
		local optionPairString = UTIL.trim( optionPairString )

		if optionPairString then -- TODO: check if :: is used more than once?
			local optionPair = mwTextSplit( optionPairString, '%s*::%s*' )

			local optionKey = optionPair[ 1 ]

			local optionValue = optionPair[ 2 ] or ''

--			( handler or parseOptionsHandler )( options, optionKey, optionValue )
			options[ optionKey ] = optionValue
		else
			-- TODO: empty option; not allowed
		end
	end

	return options
end

local function parseValues( rawValues )
	return mwTextSplit( rawValues, '%s*;%s*' )
end

-- NOTE: interpolation
local function handleInterpolation( value, template, default ) -- NOTE: Generic function 
	if not UTIL.trim( value ) then
		return value or default -- this will result in returning empty string or default
	end

	if not template then
		return value
	end

	if template then
		local parts = mwTextSplit( value, '%s*,%s*' )

		return template:gsub( '%$(%d)', function( n )
			return parts[ tonumber( n ) ] or ''
		end )
	end

	error( 'Should never reach this point' )
end

-- Note: Structure/Presentation
local function errorEntry( lineno, region )
	return ( 'Back-%s.png | File number %d\n' ):format(
		( {
			JP = 'JP',
			AE = 'AE',
			KR = 'KR',
		} )[ region.index ] or 'EN',
		lineno
	)
end

local function fileToString( file )
	return file.file or StringBuffer()
		:add( UTIL.getImgName( file.name ) )
		:add( file.abbr )
		:add( file.region.index )
		:add( file.rarity.abbr )
		:add( file.edition.abbr )
		:add( UTIL.trim( file.alt ) )
		:flush( '-' )
		:add( file.extension )
		:flush( '.' )
		:toString()
end

local function captionToString( caption )
	local rarityContent = ( '(%s)' ):format( UTIL.link( caption.rarity.abbr ) )

	local nameContent = UTIL.wrapInQuotes(
		UTIL.link(
			caption.name,
			caption.name:match( 'Token%s%(' ) and caption.name
		),
		LANGUAGE_ENGLISH.index
	)

	local printedNameContent = caption[ 'printed-name' ]
		and ( '(as %s)' ):format(
			UTIL.wrapInQuotes(
				caption[ 'printed-name' ],
				caption.language.index
			)
		)

	local localizedNameContent = caption.localizedName
		and UTIL.wrapInQuotes(
			caption.localizedName,
			caption.language.index
		)

	return StringBuffer()
		:add( caption.cardNumber and UTIL.link( caption.cardNumber ) )
		:add( rarityContent )
		:flush( ' ' )
		:add( nameContent )
		:flush( TAG_BR )
		:add( not caption.localizedName and printedNameContent or nil )
		:flush( ' ' )
		:add( localizedNameContent )
		:flush( TAG_BR )
		:add( printedNameContent )
		:flush( ' ' )
		:add( UTIL.trim( caption.description ) )
		:flush( TAG_BR )
		:toString()
end

local function createDataEntry( row, globalData )
	local file = {
		region = globalData.region,
		edition = globalData.edition,
	}

	local caption = {
		language = globalData.language,
	}

	local valuesIndex = 1

	-- Card number (and abbr):
	if row.options.abbr or globalData.abbr then
		file.abbr = row.options.abbr or globalData.abbr
	else
		local cardNumber = UTIL.trim( row.values[ valuesIndex ] )

		if cardNumber then
			file.abbr = mwTextSplit( cardNumber, '%-' )[ 1 ]:gsub( '/', '' )

			caption.cardNumber = cardNumber
		else
			local message = ( 'Missing card number at file number `%s`!' )
				:format( row.lineno )

			local category = 'transclusions with missing card number'

			reporter
				:addError( message )
				:addCategory( category )

			return errorEntry( row.lineno, globalData.region ) 
		end

		valuesIndex = valuesIndex + 1
	end

	-- Card name (English and localized):
	do
		local cardName = UTIL.trim( row.values[ valuesIndex ] )

		if cardName then
			file.name = cardName
			
			caption.name = cardName

			if globalData.language.index ~= LANGUAGE_ENGLISH.index then
				caption.localizedName = DATA.getName(
					cardName:gsub( '#', '' ),
					globalData.language
				)
			end
		else
			local message = ( 'Missing card name at file number `%s`!' )
				:format( row.lineno )

			local category = 'transclusions with missing card name'

			reporter
				:addError( message )
				:addCategory( category )

			return errorEntry( row.lineno, globalData.region ) 
		end

		valuesIndex = valuesIndex + 1
	end

	-- Rarity:
	do
		local rarityInput = UTIL.trim( row.values[ valuesIndex ] )

		local rarityValidated = DATA.getRarity( rarityInput )

		if rarityInput and not rarityValidated then
			local message = ( 'No such rarity for `%s`, at file number %d.' )
				:format( rarityInput, row.lineno )

			reporter:addError( message )

			return errorEntry( row.lineno, globalData.region ) 
		end
		
		rarityValidated = rarityValidated or globalData.rarity or RARITY_COMMON

		file.rarity = rarityValidated

		caption.rarity = rarityValidated

		valuesIndex = valuesIndex + 1
	end

	-- Alt:
	do
		file.alt = UTIL.trim( row.values[ valuesIndex ] ) or globalData.alt

		valuesIndex = valuesIndex + 1
	end

	-- File:
	do
		file.file = row.options.file
	end

	-- Extension:
	do -- TODO: this and other options should be validated programmatically    
		local extenisonInput = row.options.extension

		local extensionValidated = UTIL.trim( extenisonInput ) 

		if extenisonInput and not extensionValidated then
			local message = ( 'Empty `extension` is not allowed, at line %d.' )
				:format( row.lineno )

			local category = 'transclusions with empty extension'

			reporter
				:addWarning( message )
				:addCategory( category )
		end

		file.extension = extensionValidated or 'png'
	end

	-- Printed name:
	do
		local printedNameInput = row.options[ 'printed-name' ]

		local printedNameValidated = UTIL.trim( printedNameInput )

		if printedNameInput and not printedNameValidated then
			local message = ( 'Empty `printed-name` is not allowed, at line %d.' )
				:format( row.lineno )

			local category = 'transclusions with empty printed-name'

			reporter
				:addWarning( message )
				:addCategory( category )
		end

		caption[ 'printed-name' ] = printedNameValidated
	end

	-- Description:
	do
		caption.description = handleInterpolation( -- TODO: UTIL.trim( description ) here or on caption stringify?
			row.options.description,
			globalData[ '$description' ],
			globalData.description
		)
	end

	return ( '%s | %s\n' ):format(
		fileToString( file ),
		captionToString( caption )
	)
end

local function processNotes( notes )
	return tostring( mwHtmlCreate( 'div' )
		:addClass( 'set-gallery__notes' )
		:wikitext( notes )
	)
end

-- NOTE: Main
local function main( frame, rawArguments )
	reporter = Reporter( 'Set gallery' )

	-- NOTE: init args
	local globalData = validateArguments( rawArguments )

	globalData.rarity = globalData.rarity and validateRarity( globalData.rarity ) -- TODO: find better place for this.

	globalData.region = getRegion()

	globalData.language = DATA.getLanguage( globalData.region.index )

	globalData.edition = getEdition()

	-- NOTE: create structure
	local setGallery = mwHtmlCreate( 'gallery' )
--		:attr( 'id', 'set-gallery__main--' .. globalData.header )
		:attr{
			heights = "175px",
			position= "center",
			captionalign="center",
		}
		:addClass( 'set-gallery__main' )
		:newline()

	do
		local lineno = 0 -- Count of non-empty lines.

		for entry in mwTextGsplit( globalData[ 1 ], '%s*\n%s*' ) do
			local entry = UTIL.trim( entry )

			if entry then
				lineno = lineno + 1

				local rowPair = mwTextSplit( entry, '%s*//%s*' )

				local rowValues = parseValues( rowPair[ 1 ] )

				local rowOptions = parseOptions( rowPair[ 2 ] or '' )

				local row = {
					lineno = lineno,
					values = rowValues,
					options = rowOptions,
				}

				setGallery:node( createDataEntry( row, globalData ) )
			end
		end
	end

	return mwHtmlCreate( 'div' )
--		:attr( 'id', 'set-gallery--' .. globalData.header )
		:addClass( 'set-gallery' )
		:node( reporter:dump() )
		:node( processNotes( globalData.notes ) )
		:node( frame:preprocess( tostring( setGallery ) ) )
end

return setmetatable( {
	main = function( frame )
		return main( frame, frame:getParent().args )
	end,
}, {
	__call = function( t, arguments )
		local defaultTestArguments = {
			[ 1 ] = [=[
				REDU-ENSP1; Noble Knight Gawayn
				ABYR-ENSP1; Ignoble Knight of Black Laundsallyn // description::Abyss Rising
				CBLZ-ENSP1; Noble Arms - Caliburn // description::Cosmo Blazer
				LTGY-ENSP1; Mecha Phantom Beast Turtletracer // description::Lord of the Tachyon Galaxy
				JOTL-ENSP1; Galaxy Serpent // description::Judgment of the Light
				SHSP-ENSP1; Ghostrick Ghoul // description::Shadow Specters
				LVAL-ENSP1; Sylvan Bladefender; ; ALT // description::Legacy of the Valiant
				PRIO-ENSP1; Artifact Scythe // description::Primal Origin
				            Glory of the King's Hand // abbr::YGLD
				            Set Sail for The Kingdom; NoR // abbr::YGLD
				            Duelist Kingdom (card) // abbr::YGLD
				YGLD-ENA10; Winged Dragon, Guardian of the Fortress #1; Common; CCC
			]=],
--			[ 'abbr' ]   = 'B01',
			[ 'rarity' ] = 'UR',
			[ 'alt' ] = 'AB',
			[ 'description' ]  = "''[[Return of the Duelist|Return of the Duelist]]'' (default desc)", 
			[ '$description' ] = "''[[$1]]''",
		}

		return main( mw.getCurrentFrame(), arguments or defaultTestArguments )
	end,
} )
-- </pre>
