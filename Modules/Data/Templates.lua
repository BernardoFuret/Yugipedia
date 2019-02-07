-- <pre>
--[=[Doc
@module Data/Templates
@description Interface for template interaction.
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

local DATA = require( 'Module:Data' )

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
		after2
		short
		oceanic
		english
		after
	]]
	return getRegion( frame ).full or ''
end

function D.rgo( frame )
	return getMedium( frame ).abbr or ''
end

return D
-- </pre>