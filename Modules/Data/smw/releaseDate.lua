-- <pre>
--[=[Doc
@module Data/getReleaseDate
@description Returns the release date of an issue in a given region.
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

local DATA = require( 'Module:Data' )

local REGION_WORLDWIDE_ENGLISH = DATA.getRegion( 'English' )

--[[Doc
@function getReleaseDate
@description gets the release date for `pagename` in the given `region`.
@parameter {string} pagename Name of the issue to get the date.
@parameter {string} regionFull .
@return {string|nil} Date.
]]
local function getReleaseDate( pagename, regionFull )
	local prop = table.concat{ regionFull, ' release date' }

	local askResult = mw.smw.ask{
		table.concat{ '[[', pagename, ']]' },
		table.concat{ '?', prop, '#ISO' },
		mainlabel = '-',
	}

	local dateInfo = askResult and askResult[ 1 ] or {}

	-- TODO: remove when the sets store the Sneak Peek dates separately.
	return type( dateInfo[ prop ] ) == type( {} )
		and dateInfo[ prop ][ 1 ]
		or dateInfo[ prop ]
end

--[[Doc
@description gets the release date for `pagename` in the given `region`.
@parameter {string} pagename Name of the issue to get the date for.
@parameter {Region} region
@return {string} Date.
]]
return function( pagename, region )
	return getReleaseDate( pagename, region.full )
		or ( region.full == REGION_WORLDWIDE_ENGLISH.full
			and getReleaseDate( pagename, 'English' )
		) or ''
end
-- </pre>