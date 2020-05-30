-- <pre>
--[=[Doc
@module Card table sets
@description Handles sets.
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

local DATA = require( 'Module:Data' )
local UTIL = require( 'Module:Util' )

local Reporter = require( 'Module:Reporter' )
local StringBuffer = require( 'Module:StringBuffer' )

local DATA_REGIONS = DATA( 'region' )
local DATA_LANGUAGES = DATA( 'language' )

local LANGUAGE_ENGLISH = DATA.getLanguage( 'English' )

local mwText = mw.text
local mwHtmlCreate = mw.html.create

local reporter;

local KEY_DATE = 'SET_DATE'
local KEY_NAME = 'SET_NAME'

local function formatCardNumber( cardNumber )
	return cardNumber:match( '?' )
		and cardNumber
		or UTIL.link( cardNumber )
end

local function linkRarities( rarities, lineno )
	local linked = {}

	local position = 0

	local nonEmptyposition = 0

	for _, r in ipairs( rarities ) do
		position = position + 1

		if UTIL.trim( r ) then
			nonEmptyposition = nonEmptyposition + 1

			local rarity = DATA.getRarity( r )

			if rarity then
				table.insert( linked, UTIL.link( rarity.full ) )
			else
				local message = ( 'No such rarity for `%s`, at non-empty input line %d, at non-empty position %d.' )
					:format( r, lineno, nonEmptyposition )

				local category = '((Card table sets)) transclusions with invalid rarities'

				reporter
					:addError( message )
					:addCategory( category )
			end
		else
			local message = ( 'Empty rarity input, at non-empty input line %d, at position %d.' )
				:format( lineno, position )

			local category = '((Card table sets)) transclusions with empty rarities'

			reporter
				:addError( message )
				:addCategory( category )
		end
	end

	return linked
end

local function getWikitextVarValue( frame, varName )
	return UTIL.trim(
		frame:callParserFunction{
			name = '#var',
			args = {
				varName
			}
		}
	)
end

local function setWikitextVarValue( frame, varName, value )
	frame:callParserFunction{
		name = '#vardefine',
		args = {
			varName, value or ''
		}
	}

	return value
end

local function makeWikitextVarName( ... )
	return table.concat( {
		'$$', ...,
	}, '-' )
end

local function getSetSmwInfo( frame, setName )
	local info = {
		[ KEY_DATE ] = {},
		[ KEY_NAME ] = {},
	}

	if not setName then
		return info
	end

	local isCachedVarName = makeWikitextVarName( setName, 'setSmwInfoIsCached' )

	local missingSetPageVarName = makeWikitextVarName( setName, 'pageIsMissing' )

	if getWikitextVarValue( frame, isCachedVarName ) then
		if getWikitextVarValue( frame, missingSetPageVarName ) then
			return info
		end

		for _, region in pairs( DATA_REGIONS ) do
			local varName = makeWikitextVarName( setName, KEY_DATE, region.index )

			info[ KEY_DATE ][ region.index ] = getWikitextVarValue( frame, varName )
		end

		for _, language in pairs( DATA_LANGUAGES ) do
			local varName = makeWikitextVarName( setName, KEY_NAME, language.index )

			info[ KEY_NAME ][ language.index ] = getWikitextVarValue( frame, varName )
		end

		return info
	end

	setWikitextVarValue( frame, isCachedVarName, 1 )

	local smwResult = ( mw.smw.ask{ -- TODO: the props to query should be generated automatically from DATA region and language
		table.concat{ '[[', setName, ']]' },
		'?Page type',

		'?Worldwide English release date#ISO',
		'?English release date#ISO',
		'?North American English release date#ISO',
		'?European English release date#ISO',
		'?Oceanic English release date#ISO',
		'?French release date#ISO',
		'?French-Canadian release date#ISO',
		'?German release date#ISO',
		'?Italian release date#ISO',
		'?Portuguese release date#ISO',
		'?Spanish release date#ISO',
		'?Latin American Spanish release date#ISO',
		'?Japanese release date#ISO',
		'?Japanese-Asian release date#ISO',
		'?Asian-English release date#ISO',
		'?Chinese release date#ISO',
		'?Korean release date#ISO',

		'?English name',
		'?French name',
		'?German name',
		'?Italian name',
		'?Portuguese name',
		'?Spanish name',
		'?Japanese name',
		'?Chinese name',
		'?Korean name',

		mainlabel = '-',
	} or {} )[ 1 ] or {}

	if not smwResult[ 'Page type' ] then
		setWikitextVarValue( frame, missingSetPageVarName, 1 )

		local category = '((Card table sets)) transclusions with set names without a page'

		reporter:addCategory( category )

		return info
	end

	for _, region in pairs( DATA_REGIONS ) do
		local varName = makeWikitextVarName( setName, KEY_DATE, region.index )

		local dateForRegion = smwResult[ table.concat{ region.full, ' release date' } ]

		info[ KEY_DATE ][ region.index ] = setWikitextVarValue( frame, varName, dateForRegion
			and dateForRegion[ 1 ]
			or dateForRegion
		)
	end

	for _, language in pairs( DATA_LANGUAGES ) do
		local varName = makeWikitextVarName( setName, KEY_NAME, language.index )

		local localizedName = smwResult[ table.concat{ language.full, ' name' } ]

		info[ KEY_NAME ][ language.index ] = setWikitextVarValue( frame, varName, localizedName )
	end

	-- Special cases:
	do
		-- Fallback to `English release date`
		local varName = makeWikitextVarName( setName, KEY_DATE, 'EN' )

		info[ KEY_DATE ][ 'EN' ] = info[ KEY_DATE ][ 'EN' ] or setWikitextVarValue( frame, varName, smwResult[ 'English release date' ] )
	end

	return info
end

local function createHeader( id, text )
	return tostring( mwHtmlCreate( 'th' )
		:attr( 'scope', 'col' )
		:addClass( 'cts__header--' .. id )
		:wikitext( text )
	)
end

local function createHeaderRow( languageFull )
	local tr = mwHtmlCreate( 'tr' )
		:node( createHeader( 'release', 'Release' ) )
		:node( createHeader( 'number', 'Number' ) )
		:node( createHeader( 'set', 'Set' ) )

	if languageFull ~= LANGUAGE_ENGLISH.full then
		tr:node(
			createHeader(
				'set-localized',
				table.concat{ languageFull, ' name' }
			)
		)
	end

	tr:node( createHeader( 'rarity', 'Rarity' ) )

	return tostring( tr )
end

local function createCell( id, text )
	return tostring( mwHtmlCreate( 'td' )
		:wikitext( text )
	)
end

local function createDataRow( frame, region, language, line, lineno )
	local parts = mwText.split( line, '%s*;%s*' )

	local cardNumber = UTIL.trim( parts[ 1 ] )
	local setName = UTIL.trim( parts[ 2 ] )
	local rarities = UTIL.trim( parts[ 3 ] )
		and linkRarities(
			mwText.split( parts[ 3 ], '%s*,%s*' ),
			lineno
		)

	if not setName then
		local message = ( 'No set name provided at non-empty input line %d.' )
			:format( lineno )

		local category = '((Card table sets)) transclusions with missing set name'

		reporter
			:addWarning( message )
			:addCategory( category )
	end

	if not rarities then
		local message = ( 'No rarities provided at non-empty input line %d.' )
			:format( lineno )

		local category = '((Card table sets)) transclusions with missing rarities'

		reporter
--			:addWarning( message )
			:addCategory( category )
	end


	local setSmwInfo = getSetSmwInfo( frame, setName )

	local releaseDate = setSmwInfo[ KEY_DATE ][ region.index ]

	if not releaseDate then
		local category = '((Card table sets)) transclusions with missing release dates'

		reporter:addCategory( category )
	end

	local tr = mwHtmlCreate( 'tr' )
		:node( createCell( 'release', releaseDate ) )
		:node( createCell( 'number', cardNumber and formatCardNumber( cardNumber ) ) )
		:node( createCell( 'set', setName and UTIL.italicLink( setName ) ) )

	if language.full ~= LANGUAGE_ENGLISH.full then
		tr:node(
			createCell(
				'set-localized',
				setSmwInfo[ KEY_NAME ][ language.index ]
			)
		)
	end

	tr:node( createCell( 'rarity', rarities and table.concat( rarities, '<br />' ) ) )

	return tostring( tr )
end


local function main( frame, regionInput, setsInput )
	reporter = Reporter( 'Card table sets' )

	local region = DATA.getRegion( regionInput ) -- TODO: handle incorrect regions (necessary?)

	local language = DATA.getLanguage( regionInput )

	local setsTable = mwHtmlCreate( 'table' )
		:attr( 'id', 'cts--' .. region.index )
		:addClass( 'wikitable' )
		:addClass( 'sortable' )
		:addClass( 'card-list' )
		:addClass( 'cts' )
		:node( createHeaderRow( language.full ) )

	if UTIL.trim( setsInput ) then
		local lineno = 0 -- Non-empty lines count.

		for line in mwText.gsplit( setsInput, '%s*\n%s*' ) do
			if UTIL.trim( line ) then
				lineno = lineno + 1

				setsTable:node( createDataRow( frame, region, language, line, lineno ) )
			end
		end
	else
		local message = 'No input provided for the sets.'

		local category = '((Card table sets)) transclusions with no input (((1)))'

		reporter
			:addError( message )
			:addCategory( category )
	end

	return StringBuffer()
		:add( reporter:dump() )
		:add( tostring( setsTable ) )
		:toString()
end

return setmetatable( {
	main = function( frame )
		local arguments = frame:getParent().args

		return main( frame, arguments[ 'region' ], arguments[ 1 ] )
	end
}, {
	__call = function( t, rg, list )
		local testRg = 'EN'

		local testList = [[
TLM-KR012; The Lost Millennium; Super Rare, Ultimate Rare
MVP1-ENSV4; Yu-Gi-Oh! The Dark Side of Dimensions Movie Pack Secret Edition; Ultra Rare
MVP1-ENS55; Yu-Gi-Oh! The Dark Side of Dimensions Movie Pack Secret Edition; Secret Rare

MVP1-ENS55; ; Secret Rare
MVP1-ENS55; PAGE THAT DOESN'T EXIST; Secret Rare

MVP1-ENS55; LOB; Invalid Rare

MVP1-ENS55; LOB; 
; LOB; SR, , R

]]
		return main( mw.getCurrentFrame(), rg or testRg, list or testList )
	end,
} )
-- </pre>
