-- <pre>
--[=[Doc
@module Set navigation
@description Table containing links for the
set lists and galleries.
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

local DATA = require( 'Module:Data' )
local UTIL = require( 'Module:Util' )

local Reporter = require( 'Module:Reporter' )

local mwHtmlCreate = mw.html.create
local mwTextGsplit = mw.text.gsplit

local reporter;


local regionCache = {}

local mediumCache = {}

local function updateCache( cache, key, value )
	cache[ key ] = value

	return value
end


local SET_NAMES_SPECIAL_CASES = {
	[ '2011' ] = true,
	[ '2018' ] = true,
	[ '2019' ] = true,
	[ 'series' ] = true,
}

local function normalizeSetNameForLink( setPagename )
	-- Remove the dab except for some special cases
	local dab = UTIL.getDab( setPagename )

	return SET_NAMES_SPECIAL_CASES[ dab ]
		and setPagename
		or UTIL.removeDab( setPagename )
end

local function normalizeRegionFull( region )
	return region.full:gsub( 'Worldwide ', '' )
end

local function linkLists( setPagename, region, medium )
	return ( '[[Set Card Lists:%s (%s-%s)|%s]]' )
		:format(
			setPagename,
			medium.abbr,
			region.index,
			normalizeRegionFull( region )
		)
end

local function makeGalleriesLink( edition )
	local REGION_JAPANESE = regionCache[ 'jp' ] or updateCache( regionCache, 'jp', DATA.getRegion( 'jp' ) )

	local REGION_JAPANESE_ASIAN = regionCache[ 'ja' ] or updateCache( regionCache, 'ja', DATA.getRegion( 'ja' ) )
	
	return function --[[linkGalleries]]( setPagename, region, medium )
		if region.full == REGION_JAPANESE.full or region.full == REGION_JAPANESE_ASIAN.full then
			return ( '[[Set Card Lists:%s (%s-%s)|%s]]' )
				:format(
					setPagename,
					medium.abbr,
					region.index,
					normalizeRegionFull( region )
				)
		else
			return ( '[[Set Card Galleries:%s (%s-%s-%s)|%s]]' )
				:format(
					setPagename,
					medium.abbr,
					region.index,
					edition.abbr,
					normalizeRegionFull( region )
				)
		end
	end
end

local function linkStrategyGalleries( setPagename, region )
	return ( '[[Set Card Galleries:%s: Strategy Cards (%s)|%s]]' )
		:format(
			setPagename,
			normalizeRegionFull( region ),
			normalizeRegionFull( region )
		)
end


local ENTRIES = {
	{
		parameter = 'lists',
		title = 'Lists',
		link = linkLists,
	},
	{
		parameter = '1e_galleries',
		title = '1st Edition galleries',
		link = makeGalleriesLink( DATA.getEdition( '1E' ) ),
	},
	{
		parameter = 'ue_galleries',
		title = 'Unlimited Edition galleries',
		link = makeGalleriesLink( DATA.getEdition( 'UE' ) ),
	},
	{
		parameter = 'le_galleries',
		title = 'Limited Edition galleries',
		link = makeGalleriesLink( DATA.getEdition( 'LE' ) ),
	},
	{
		parameter = 'dt_galleries',
		title = 'Duel Terminal galleries',
		link = makeGalleriesLink( DATA.getEdition( 'DT' ) ),
	},
	{
		parameter = 'strategy',
		title = 'Strategy cards galleries',
		link = linkStrategyGalleries,
	},
}

local function main( arguments )
	reporter = Reporter( 'Set navigation' )

	local setPagename = UTIL.trim( arguments[ 1 ] ) or mw.title.getCurrentTitle().text

	local setNameForLink = normalizeSetNameForLink( setPagename )

	local container = mwHtmlCreate( 'div' )
		:addClass( 'set-navigation' )

	local header = mwHtmlCreate( 'div' )
		:addClass( 'set-navigation__header' )
		:wikitext( DATA.getName( setPagename, DATA.getLanguage( 'en' ) ) )

	container:node( tostring( header ) )
	
	for _, entry in ipairs( ENTRIES ) do
		local entryArguments = UTIL.trim( arguments[ entry.parameter ] )

		if entryArguments then
			local row = mwHtmlCreate( 'div' )
				:addClass( 'set-navigation__row' )
				:addClass( 'hlist' )

			local dl = mwHtmlCreate( 'dl' )

			local dt = mwHtmlCreate( 'dt' )
				:wikitext( entry.title )

			dl:node( tostring( dt ) )

			for rg in mwTextGsplit( entryArguments, '%s*,%s*' ) do
				local region = regionCache[ rg ] or updateCache( regionCache, rg, DATA.getRegion( rg ) )

				if region then
					local medium = mediumCache[ rg ] or updateCache( mediumCache, rg, DATA.getMedium( region.index ) )

					local dd = mwHtmlCreate( 'dd' )
						:wikitext( entry.link( setNameForLink, region, medium ) )

					dl:node( tostring( dd ) )
				else
					local message = ( 'Invalid region `%s` provided on `%s` parameter!' ):format(
						regionInput,
						entry.parameter
					)

					local category = '((Set navigation)) transclusions with invalid regions'

					reporter
						:addError( message )
						:addCategory( category )
				end
			end

			row:node( tostring( dl ) )

			container:node( tostring( row ) )
		end

	end

	return tostring( container )
end

return setmetatable( {
	main = function( frame )
		local arguments = frame:getParent().args

		return main( arguments )
	end
}, {
	__call = function( t, ... )
		return main( ... or {
			[ 1 ] = 'Duelist Alliance',
			[ 'lists' ] = 'EN,FR,DE,IT,PT,SP,JP,JA,KR',
			[ '1e_galleries' ] = 'EN,FR,DE,IT,PT,SP,JP,JA,KR',
			[ 'ue_galleries' ] = 'EN,FR,DE,IT,PT,SP,JP,JA,  KR',
			[ 'le_galleries' ] = ' EN  ,FR ,DE,IT,PT,SP,JP,JA,AE,KR  ',
			[ 'dt_galleries' ] = 'EN,JP',
			[ 'strategy' ] = 'EN,FR,DE,IT,PT,SP,KR',
		} )
	end,
} )
-- </pre>
