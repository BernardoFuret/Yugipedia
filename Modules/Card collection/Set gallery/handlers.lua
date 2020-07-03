-- <pre>
--[=[Doc
@module 
@description 
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
TODO:
- Cleanup
- Refactor: split responsibilities more strictly;
- Interpolation should return nil instead of empty string

- Printed-name if no localized name was found (will display after the English name).
]=]

local DATA = require( 'Module:Data' )
local UTIL = require( 'Module:Util' )

local StringBuffer = require( 'Module:StringBuffer' )

local LANGUAGE_ENGLISH = DATA.getLanguage( 'English' )
local RARITY_COMMON = DATA.getRarity( 'Common' )

local currentTitle = mw.title.getCurrentTitle()

local NS = currentTitle.nsText
local PAGENAME = NS == 'Module'
	and 'Sneak Peek Participation Cards: Series 6 (TCG-EN-LE)'
	or currentTitle.text

local TAG_BR = '<br />'

local mwTextSplit = mw.text.split

local function validateRarity( self, rawRaritiy )
	local rarity = DATA.getRarity( rawRaritiy )

	if not rarity then
		local message = ( 'No such rarity for `%s` at parameter `rarity`.' )
			:format( rawRaritiy )

		local category = 'transclusions with invalid rarities'

		self.reporter
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

	return StringBuffer() -- TODO: check that double printedNameContent
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

local function processNotes( self, notes )
	return tostring( mw.html.create( 'div' )
		:addClass( self.utils:makeCssClass( 'notes' ) )
		:wikitext( notes )
	)
end

local handlers = {}

function handlers:initData( globalData )
	globalData.rarity = globalData.rarity and validateRarity( self, globalData.rarity )

	globalData.region = getRegion()

	globalData.language = DATA.getLanguage( globalData.region.index )

	globalData.edition = getEdition()
end

function handlers:initStructure( globalData )
	return mw.html.create( 'gallery' )
		:attr{
			heights = '175px',
			position = 'center',
			captionalign ='center',
		}
		:newline()
end

function handlers:handleRow( row, globalData )
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
			local message = ( 'Missing card number at file number %d!' )
				:format( row.lineno )

			local category = 'transclusions with missing card number'

			self.reporter
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
			local message = ( 'Missing card name at file number %d!' )
				:format( row.lineno )

			local category = 'transclusions with missing card name'

			self.reporter
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
			local message = ( 'No such rarity for `%s` at file number %d!' ) -- TODO: merge with validateRarity
				:format( rarityInput, row.lineno )

			self.reporter:addError( message )

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
			local message = ( 'Empty `extension` is not allowed at line %d!' )
				:format( row.lineno )

			local category = 'transclusions with empty extension'

			self.reporter
				:addError( message )
				:addCategory( category )
		end

		file.extension = extensionValidated or 'png'
	end

	-- Printed name:
	do
		local printedNameInput = row.options[ 'printed-name' ]

		local printedNameValidated = UTIL.trim( printedNameInput )

		if printedNameInput and not printedNameValidated then
			local message = ( 'Empty `printed-name` is not allowed at line %d.' )
				:format( row.lineno )

			local category = 'transclusions with empty printed-name'

			self.reporter
				:addError( message )
				:addCategory( category )
		end

		caption[ 'printed-name' ] = printedNameValidated
	end

	-- Description:
	do
		caption.description = self.utils:handleInterpolation( -- TODO: UTIL.trim( description ) here or on caption stringify?
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

function handlers:finalize( mainStructure, globalData )
	return processNotes( self, globalData.notes ), self.frame:preprocess( tostring( mainStructure ) )
end

return handlers
-- </pre>
