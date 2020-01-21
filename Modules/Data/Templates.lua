-- <pre>
--[=[Doc
@module Data/Templates
@description Interface for template interaction.
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

local DATA = require( 'Module:Data' )
local UTIL = require( 'Module:Util' )

local D = {}

local function getLanguage( frame )
	local v = frame:getParent().args[ 1 ]

	return DATA.getLanguage( v ) or {}
end

local function getRegion( frame )
	local v = frame:getParent().args[ 1 ]

	return DATA.getRegion( v ) or {}
end

local function getMedium( frame )
	local v = frame:getParent().args[ 1 ]

	return DATA.getMedium( v ) or {}
end

local function getVideoGameName( frame )
	local v = frame:getParent().args[ 1 ]

	return DATA.videoGames.getName( v ) or {}
end

function D.ln( frame )
	return getLanguage( frame ).index or ''
end

function D.lang( frame )
	return getLanguage( frame ).full or ''
end

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

function D.rgo( frame )
	return getMedium( frame ).abbr or ''
end

function D.vg( frame )
	local full = UTIL.trim( frame:getParent().args[ 'full' ] )

	local link = UTIL.trim( frame:getParent().args[ 'link' ] )

	local game = getVideoGameName( frame )
	
	return full
		and ( link and game.full or UTIL.removeDab( game.full or '' ) )
		or game.abbr
end

return D
-- </pre>
