-- <pre>
--[=[Doc
@module 
@description 
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
TODO:
- Cleanup
- Refactor: split responsibilities more strictly;

- Printed-name if no localized name was found (will display after the English name).
]=]

local DATA = require( 'Module:Data' )
local UTIL = require( 'Module:Util' )

local StringBuffer = require( 'Module:StringBuffer' )
local getCardImageName = require( 'Module:Card image name' );

local LANGUAGE_ENGLISH = DATA.getLanguage( 'English' )
local RARITY_COMMON = DATA.getRarity( 'Common' )

local currentTitle = mw.title.getCurrentTitle()

local NS = currentTitle.nsText

-- For testing:
local PAGENAME = NS == 'Module'
	and 'Sneak Peek Participation Cards: Series 6 (TCG-EN-LE)'
	or currentTitle.text

local TAG_BR = '<br />'

local mwTextSplit = mw.text.split

local function validateRarity( self, rawRaritiy, location )
	if not UTIL.trim( rawRaritiy ) then
		return
	end

	local rarity = DATA.getRarity( rawRaritiy )

	if not rarity then
		local message = ( 'No such rarity for `%s` at %s!' )
			:format( rawRaritiy, location )

		local category = 'transclusions with invalid rarities'

		self.reporter
			:addError( message )
			:addCategory( category )

		return {
			err = true
		}
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

local function wrapLocalizedName( name, language )
	return name and tostring( mw.html.create( 'span' )
		:attr{ lang = language.index }
		:wikitext( name )
	)
end

local function fileToString( file )
	return file.file or StringBuffer()
		:add( getCardImageName( file.name or file.pagename ) )
		:add( file.abbr )
		:add( file.region.index )
		:add( file.rarity.abbr )
		:add( file.edition and file.edition.abbr )
		:add( UTIL.trim( file.alt ) )
		:flush( '-' )
		:add( file.extension )
		:flush( '.' )
		:toString()
end

local function captionToString( caption )
	local nameContent = UTIL.wrapInQuotes(
		UTIL.link(
			caption.pagename,
			caption.name
		),
		LANGUAGE_ENGLISH.index
	)

	local rarityContent = ( '(%s)' ):format(
		UTIL.link(
			caption.rarity.full,
			caption.rarity.abbr
		)
	)

	local printedNameContent = caption[ 'printed-name' ]
		and ( '(as %s)' ):format(
			wrapLocalizedName(
				UTIL.wrapInQuotes(
					caption[ 'printed-name' ],
					caption.language.index
				),
				caption.language
			)
		)

	local localizedNameContent = caption.localizedName
		and wrapLocalizedName(
			UTIL.wrapInQuotes(
				caption.localizedName,
				caption.language.index
			),
			caption.language
		)

	return StringBuffer()
		:add( caption.cardNumber and UTIL.link( caption.cardNumber ) )
		:add( rarityContent )
		:flush( ' ' )
		:add( nameContent )
		:flush( TAG_BR )
		:add( localizedNameContent )
		:flush( TAG_BR )
		:add( printedNameContent )
		:flush( ' ' )
		:add( caption.description )
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
	globalData.rarity = validateRarity( self, globalData.rarity, 'parameter `rarity`' )

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

function handlers:handleEntry( entry, globalData )
	local file = {
		region = globalData.region,
		edition = globalData.edition,
	}

	local caption = {
		language = globalData.language,
	}

	local valuesIndex = 1

	local cardNameInput

	-- Card number (and abbr):
	if entry.options.abbr or globalData.abbr then
		file.abbr = entry.options.abbr or globalData.abbr
	else
		local cardNumber = UTIL.trim( entry.values[ valuesIndex ] )

		if cardNumber then
			file.abbr = mwTextSplit( cardNumber, '%-' )[ 1 ]:gsub( '/', '' )

			caption.cardNumber = cardNumber
		else
			if not entry.options.file then
				local message = ( 'Missing card number at file number %d!' )
					:format( entry.lineno )

				local category = 'transclusions with missing card number'

				self.reporter
					:addError( message )
					:addCategory( category )

				return errorEntry( entry.lineno, globalData.region )
			end
		end

		valuesIndex = valuesIndex + 1
	end

	-- Card name (English and localized):
	do
		cardNameInput = UTIL.trim( entry.values[ valuesIndex ] )

		if cardNameInput then
			local cardNameNormalized = cardNameInput:gsub( '#', '' )

			local cardNameDisplay = entry.options[ 'force-SMW' ]
				and DATA.getName( cardNameNormalized, LANGUAGE_ENGLISH )

			local tokenCardLink = cardNameInput:match( 'Token%s%(' ) and UTIL.removeDab( cardNameInput ) 

			local tokenCardDab = cardNameInput:match( 'Token%s%(' ) and UTIL.getDab( cardNameInput )

			local tokenCardDescription = tokenCardDab
				and UTIL.link( cardNameInput, ( '(%s)' ):format( tokenCardDab ) )
				or nil

			file.pagename = cardNameNormalized

			file.name = cardNameDisplay

			caption.pagename = tokenCardLink or cardNameInput

			caption.name = cardNameDisplay

			caption.description = tokenCardDescription

			if globalData.language.index ~= LANGUAGE_ENGLISH.index then
				caption.localizedName = DATA.getName(
					cardNameNormalized,
					globalData.language
				)
			end
		else
			local message = ( 'Missing card name at file number %d!' )
				:format( entry.lineno )

			local category = 'transclusions with missing card name'

			self.reporter
				:addError( message )
				:addCategory( category )

			return errorEntry( entry.lineno, globalData.region )
		end

		valuesIndex = valuesIndex + 1
	end

	-- Rarity:
	do
		local rarityInput = UTIL.trim( entry.values[ valuesIndex ] )

		local rarityValidated = validateRarity(
			self,
			rarityInput,
			( 'file number %d' ):format( entry.lineno )
		)

		if ( rarityValidated or globalData.rarity or {} ).err then
			return errorEntry( entry.lineno, globalData.region )
		end

		rarityValidated = rarityValidated or globalData.rarity or RARITY_COMMON

		file.rarity = rarityValidated

		caption.rarity = rarityValidated

		valuesIndex = valuesIndex + 1
	end

	-- Alt:
	do
		file.alt = UTIL.trim( entry.values[ valuesIndex ] )
			or globalData.alt
			or (
				( cardNameInput or '' ):match( 'Token%s%(' ) and getCardImageName(
					UTIL.getDab( cardNameInput )
				)
			)

		valuesIndex = valuesIndex + 1
	end

	-- File:
	do
		file.file = entry.options.file
	end

	-- Extension:
	do -- TODO: this and other options should be validated programmatically
		local extenisonInput = entry.options.extension

		local extensionValidated = UTIL.trim( extenisonInput )

		if extenisonInput and not extensionValidated then
			local message = ( 'Empty `extension` is not allowed at line %d!' )
				:format( entry.lineno )

			local category = 'transclusions with empty extension'

			self.reporter
				:addError( message )
				:addCategory( category )
		end

		file.extension = extensionValidated or 'png'
	end

	-- Printed name:
	do
		local printedNameInput = entry.options[ 'printed-name' ]

		local printedNameValidated = UTIL.trim( printedNameInput )

		if printedNameInput and not printedNameValidated then
			local message = ( 'Empty `printed-name` is not allowed at line %d.' )
				:format( entry.lineno )

			local category = 'transclusions with empty printed-name'

			self.reporter
				:addError( message )
				:addCategory( category )
		end

		caption[ 'printed-name' ] = printedNameValidated
	end

	-- Description:
	do
		caption.description = self.utils:handleInterpolation(
			entry.options.description,
			globalData[ '$description' ],
			globalData.description
		) or caption.description
	end

	return ( '%s | %s\n' ):format(
		fileToString( file ),
		captionToString( caption )
	)
end

function handlers:finalize( mainStructure, globalData )
	local toc = mw.html.create( 'div' ):addClass( 'set-gallery__toc' )

	return toc, processNotes( self, globalData.notes ), self.frame:preprocess( tostring( mainStructure ) )
end

return handlers
-- </pre>
