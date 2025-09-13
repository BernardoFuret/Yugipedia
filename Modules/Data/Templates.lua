-- <pre>
--[=[Doc
@module Data/Templates
@description Interface for template interaction.
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

local DATA = require( 'Module:Data' )
local UTIL = require( 'Module:Util' )

local function getArg( frame, index )
	return frame:getParent().args[ index ]
end

local function getRegion( frame )
	return DATA.getRegion( getArg( frame, 1 ) ) or {}
end

local function getLanguage( frame )
	return DATA.getLanguage( getArg( frame, 1 ) ) or {}
end

local function getMedium( frame )
	return DATA.getMedium( getArg( frame, 1 ) ) or {}
end

local function getRarity( frame )
	return DATA.getRarity( getArg( frame, 1 ) ) or {}
end

local function getVideoGameName( frame )
	return DATA.videoGames.getName( getArg( frame, 1 ) ) or {}
end

---------------------
-- Wikitext interface
---------------------

local D = {}

function D.rg( frame )
	return getRegion( frame ).index or ''
end

function D.region( frame )
	--[[
		short
		short2
		oceanic
		english
		after
		after2
	]]
	return getRegion( frame ).full or ''
end

function D.ln( frame )
	return getLanguage( frame ).index or ''
end

function D.lang( frame )
	return getLanguage( frame ).full or ''
end

function D.rgo( frame )
	return getMedium( frame ).abbr or ''
end

function D.rarity( frame )
	local full = UTIL.trim( getArg( frame, 'full' ) )

	local dbAbbr = UTIL.trim( getArg( frame, 'dbAbbr' ) )

	local rarity = getRarity( frame )

	return ( full
		and rarity.full
		or ( dbAbbr
			and ( rarity.dbAbbr or '' )
			or rarity.abbr
		)
	) or ''
end

function D.vg( frame )
	local full = UTIL.trim( getArg( frame, 'full' ) )

	local link = UTIL.trim( getArg( frame, 'link' ) )

	local game = getVideoGameName( frame )

	return full
		and ( link and game.full or UTIL.removeDab( game.full or '' ) )
		or game.abbr
end

function D.name( frame )
	local pagename = ( getArg( frame, 1 ) or '' ):gsub( '#', '' )

	local language = DATA.getLanguage(
		UTIL.trim( getArg( frame, 2 ) ) or 'en'
	)

	return language and DATA.getName( pagename, language )
end

D['translated name'] = function( frame )
	local pagename = ( getArg( frame, 1 ) or '' ):gsub( '#', '' )

	local language = DATA.getLanguage(
		UTIL.trim( getArg( frame, 2 ) ) or 'en'
	)

	return language and DATA.getTranslatedName( pagename, language )
end

return D
-- </pre>
