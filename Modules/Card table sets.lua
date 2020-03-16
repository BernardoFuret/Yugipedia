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

local LANGUAGE_ENGLISH = DATA.getLanguage( 'English' )

local mwText = mw.text
local mwHtmlCreate = mw.html.create

local reporter;

local function formatCardNumber( cardNumber )
	return cardNumber:match( '?' )
		and cardNumber
		or UTIL.link( cardNumber )
end

local function validateRarities( rarities, lineno )
	local validated = {}

	local position = 0

	for _, r in ipairs( rarities ) do
		if UTIL.trim( r ) then
			position = position + 1

			local rarity = DATA.getRarity( r )

			if rarity then
				table.insert( validated, rarity.full )
			else
				local message = ('No such rarity for `%s`, at non-empty input line %d, at non-empty position %d.')
					:format( r, lineno, position )

				reporter:addError( message )
			end
		end
	end

	return validated
end

local function printRarities( rarities )
	local linked = {}

	for _, rarity in ipairs( rarities ) do
		table.insert( linked, UTIL.link( rarity ) )
	end

	return table.concat( linked, '<br />' )
end

local function setSMWProps( cardNumber, setName, rarities, regionFull )
	if not mw.smw then
		reporter:addError( 'SMW is not available!' )

		return
	end

	local setInfoProp = ('--- %s --- %s --- %s --- %s ---')
		:format(
			cardNumber,
			setName,
			table.concat( rarities, ',' ),
			regionFull
		)

	local jsonRarities = {}

	for _, rarity in ipairs( rarities ) do
		table.insert( jsonRarities, '"' .. rarity .. '"' )
	end

	local setInfoJSONProp = ('{ "number": "%s", "name": "%s", "rarity": [%s], "region": "%s" }')
		:format(
			cardNumber,
			setName,
			table.concat( jsonRarities, ',' ),
			regionFull
		)

	local setRes = mw.smw.set{
		['Set information'] = setInfoProp,
		['Set information (JSON)'] = setInfoJSONProp,
	}

	if not setRes then
		reporter:addError( "Failed to set SMW properties for set information!" )
	end
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

local function createDataRow( region, language, line, lineno )
	local parts = mwText.split( line, '%s*;%s*' )

	local cardNumber = UTIL.trim( parts[ 1 ] )
	local setName = UTIL.trim( parts[ 2 ] )
	local rarities = UTIL.trim( parts[ 3 ] )
		and validateRarities(
			mwText.split( parts[ 3 ], '%s*,%s*' ),
			lineno
		)
		or {}

	if not setName then
		local message = ('No set name given at non-empty input line %d.')
			:format( lineno )

		local category = '((Card table sets)) transclusions with missing set name'

		reporter
			:addWarning( message )
			:addCategory( category )
	end

	local tr = mwHtmlCreate( 'tr' )
		:node( createCell( 'release', setName and DATA.getReleaseDate( setName, region ) ) )
		:node( createCell( 'number', cardNumber and formatCardNumber( cardNumber ) ) )
		:node( createCell( 'set', setName and UTIL.italicLink( setName ) ) )

	if language.full ~= LANGUAGE_ENGLISH.full then
		tr:node(
			createCell(
				'set-localized',
				setName and DATA.getName( setName, language )
			)
		)
	end

	tr:node( createCell( 'rarity', printRarities( rarities ) ) )

	setSMWProps( cardNumber or '', setName or '', rarities, region.full )

	return tostring( tr )
end


local function main( regionInput, setsInput )
	reporter = Reporter( 'Card table sets' )

	local region = DATA.getRegion( regionInput ) -- TODO: handle incorrect regions (necessary?)

	local language = DATA.getLanguage( regionInput )

	local setsTable = mwHtmlCreate( 'table' )
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

				setsTable:node( createDataRow( region, language, line, lineno ) )
			end
		end
	else
		local message = 'No input given for the sets.'

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

		return main( arguments[ 'region' ], arguments[ 1 ] )
	end
}, {
	__call = function( t, ... )
		return main( ... )
	end,
} )
-- </pre>
