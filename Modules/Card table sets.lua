-- <pre>
--[=[Doc
@module Card table sets
@description Handles sets.
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

local DATA = require( 'Module:Data' )
local UTIL = require( 'Module:Util' )

local InfoWrapper = require( 'Module:InfoWrapper' ) -- TODO: Reporter
local StringBuffer = require( 'Module:StringBuffer' )

local LANGUAGE_ENGLISH = DATA.getLanguage( 'English' )

local mwText = mw.text
local mwHtmlCreate = mw.html.create

local Log;

local function dumpLog()
	local formatError = function( err )
		return tostring( mwHtmlCreate( 'li' )
			:tag( 'strong' )
				:wikitext( err )
			:allDone()
		)
	end

	local createErrorContainer = function()
		return tostring( mwHtmlCreate( 'div' )
			:addClass( 'cts__errors' )
			:tag( 'ul' )
				:node( Log:dumpErrors( formatError ) )
			:allDone()
		)
	end

	return StringBuffer()
		:add( createErrorContainer() )
		:add( Log:dumpCategories() )
		:toString()
end

local function getSetReleaseDate( setName, regionFull ) -- TODO: move to a dedicated script.
	local prop = table.concat{ regionFull, ' release date' }

	local askResult = mw.smw.ask{
		table.concat{ '[[', setName, ']]' },
		table.concat{ '?', prop, '#ISO' },
		mainlabel = '-',
	}

	local dateInfo = askResult and askResult[ 1 ] or {}

	-- TODO: remove when the sets store the Sneak Peek dates separately.
	return type( dateInfo[ prop ] ) == type( {} )
		and dateInfo[ prop ][ 1 ]
		or dateInfo[ prop ]
		or ''
end

local function formatCardNumber( cardNumber )
	return cardNumber:match( '?' )
		and cardNumber 
		or UTIL.link( cardNumber )
end

local function mapRarities( rarities, lineno )
	local mapped = {}

	local position = 0

	for _, r in ipairs( rarities ) do
		if UTIL.trim( r ) then
			position = position + 1

			local rarity = DATA.getRarity( r )

			if rarity then
				table.insert( mapped, UTIL.link( rarity.full ) )
			else
				local message = ('No such rarity for `%s`, at non-empty input line %d, at non-empty position %d.')
					:format( r, lineno, position )

				Log:error( message )
			end
		end
	end

	return table.concat( mapped, '<br />' )
end

local function createHeader( id, text )
	return tostring( mwHtmlCreate( 'th' )
		:attr( 'scope', 'col' )
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

local function createDataRow( regionFull, languageFull, line, lineno )
	local parts = mwText.split( line, '%s*;%s*' )

	local cardNumber = UTIL.trim( parts[ 1 ] )
	local setName = UTIL.trim( parts[ 2 ] )
	local rarities = UTIL.trim( parts[ 3 ] )
		and mwText.split( parts[ 3 ], '%s*,%s*' )
		or {}

	if not setName then
		local message = ('No set name given at non-empty input line %d.')
			:format( lineno )

		Log:error( message )
	end

	local tr = mwHtmlCreate( 'tr' )
		:node( createCell( 'release', setName and getSetReleaseDate( setName, regionFull ) ) )
		:node( createCell( 'number', cardNumber and formatCardNumber( cardNumber ) ) )
		:node( createCell( 'set', setName and UTIL.italicLink( setName ) ) )

	if languageFull ~= LANGUAGE_ENGLISH.full then
		tr:node(
			createCell(
				'set-localized',
				UTIL.getName( setName, languageFull )
			)
		)
	end

	tr:node( createCell( 'rarity', mapRarities( rarities, lineno ) ) )

	return tostring( tr )
end


local function main( regionInput, setsInput )
	Log = InfoWrapper( 'Card table sets' )

	local region = DATA.getRegion( regionInput ) -- TODO: handle incorrect regions (necessary?)

	local language = DATA.getLanguage( regionInput )

	local setsTable = mwHtmlCreate( 'table' )
		:addClass( 'wikitable' )
		:addClass( 'sortable' )
		:addClass( 'card-list' )
		:node( createHeaderRow( language.full ) )

	if UTIL.trim( setsInput ) then 
		local lineno = 0 -- Non-empty lines count.

		for line in mwText.gsplit( setsInput, '%s*\n%s*' ) do
			if UTIL.trim( line ) then
				lineno = lineno + 1

				setsTable:node( createDataRow( region.full, language.full, line, lineno ) )
			end
		end
	else
		local message = 'No input given for the sets.' -- TODO: add tracking categories

		Log:error( message )
	end

	return StringBuffer()
		:addLine( dumpLog() )
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