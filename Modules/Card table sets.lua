-- <pre>
--[=[Doc
@module Card table sets
@description Handles sets.
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

local DATA = require( 'Module:Data' )
local UTIL = require( 'Module:Util' )

local StringBuffer = require( 'Module:StringBuffer' )

local LANGUAGE_ENGLISH = DATA.getLanguage( 'English' )

local mwText = mw.text
local mwHtmlCreate = mw.html.create

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

local function mapRarities( rarities )
	local mapped = {}

	for _, r in ipairs( rarities ) do
		if UTIL.trim( r ) then
			local rarity = DATA.getRarity( r )

			if rarity then
				table.insert( mapped, UTIL.link( rarity.full ) )
			else
				-- error?
			end
		end
	end

	return table.concat( mapped, '<br />' )
end

local function createHeader( id, text )
	return tostring( mwHtmlCreate( 'th' )
		:attr{
			scope = 'col',
			id = table.concat{ 'card-table-sets__header--', id }
		}
		:addClass( 'card-table-sets__header' )
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
		:addClass( 'card-table-sets__data' )
		:addClass( table.concat{ 'card-table-sets__data--', id } )
		:wikitext( text )
	)
end

local function createDataRow( regionFull, languageFull, line )
	local parts = mwText.split( line, '%s*;%s*' )

	local cardNumber = parts[ 1 ]
	local setName = parts[ 2 ]
	local rarities = parts[ 3 ]
		and mwText.split( parts[ 3 ], '%s*,%s*' )
		or {}

	local tr = mwHtmlCreate( 'tr' )
		:node( createCell( 'release', getSetReleaseDate( setName, regionFull ) ) )
		:node( createCell( 'number', UTIL.link( cardNumber ) ) )
		:node( createCell( 'set', UTIL.italicLink( setName ) ) )

	if languageFull ~= LANGUAGE_ENGLISH.full then
		tr:node(
			createCell(
				'set-localized',
				UTIL.getName( setName, languageFull )
			)
		)
	end

	tr:node( createCell( 'rarity', mapRarities( rarities ) ) )

	return tostring( tr )
end


local function main( regionInput, setsInput )
	local region = DATA.getRegion( regionInput )

	local language = DATA.getLanguage( regionInput )

	local setsTable = mwHtmlCreate( 'table' )
		:addClass( 'wikitable' )
		:addClass( 'sortable' )
		:addClass( 'card-list' )
		:tag( 'caption' )
			:addClass( 'mobile-show' )
			:wikitext( region.full )
		:done()
		:node( createHeaderRow( language.full ) )

	for line in mwText.gsplit( setsInput, '%s*\n%s*' ) do
		if UTIL.trim( line ) then
			setsTable:node( createDataRow( region.full, language.full, line ) )
		end
	end

	return tostring( setsTable )
end

return setmetatable( {
	main = function( frame )
		local arguments = frame:getParent().args

		return main( arguments.region, arguments[ 1 ] )
	end
}, {
	__call = function( t, ... )
		return main( ... )
	end,
} )
-- </pre>