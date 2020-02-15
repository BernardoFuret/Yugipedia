-- <pre>
--[=[Doc
@module Set list tabs
@description Display set lists for all eligible
regions on their respective set pages, using a tabber.
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

local DATA = require( 'Module:Data' )
local UTIL = require( 'Module:Util' )

local navbar = require( 'Module:Navbar' )._navbar

local Reporter = require( 'Module:Reporter' )

local mwHtmlCreate = mw.html.create

local reporter;

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

local function makeSetListPage( setNameForLink, region ) -- TODO: special cases
	local medium = DATA.getMedium( region.index )

	return ( 'Set Card Lists:%s (%s-%s)' ):format( setNameForLink, medium.abbr, region.index )
end

local function generateNavbar( pagename )
	return tostring(
		mwHtmlCreate( 'div' )
			:addClass( 'set-lists-tabber__tab-navbar' )
			:wikitext( navbar{
				':' .. pagename,
				plain = 1,
			} )
	)
end

local generateContent = nil

local function transcludeSetList( fullpagename, frame )
	return frame:expandTemplate{
		title = fullpagename,
	}
end

local function generateContentRest( fullpagename )
	return tostring(
		mwHtmlCreate( 'div' )
			:addClass( 'set-list-tab' )
			:addClass( 'set-list-ajax-tab' )
			:attr( 'data-page', fullpagename )
			:wikitext( table.concat{
				'Loading [[', fullpagename, ']]...'
			} )
	)
end

local function generateContentFirst( fullpagename, frame )
	local success, content = pcall( transcludeSetList, fullpagename, frame )

	local ret = tostring(
		mwHtmlCreate( 'div' )
			:addClass( 'set-list-tab' )
			:attr( 'data-page', fullpagename )
			:wikitext( '\n', success and content or table.concat{
				'[[', fullpagename, ']]'
			} )
	)

	generateContent = generateContentRest

	return ret
end

local function printContent( listsContent )
	local tabberContent = {}

	for _, listData in ipairs( listsContent ) do
		table.insert(
			tabberContent,
			table.concat{
				listData.region, '=', listData.content, '|-|',
			}
		)
	end

	return table.concat( tabberContent )
end

local function main( regionsInput, frame )
	reporter = Reporter( 'Set list tabs' )

	local listsContainer = mwHtmlCreate( 'div' )
		:addClass( 'set-lists-tabber' )

	local listsContent = {}

	local setPagename = mw.title.getCurrentTitle().text

	local setNameForLink = normalizeSetNameForLink( setPagename )

	generateContent = generateContentFirst
	
	for regionInput in mw.text.gsplit( regionsInput, '%s*,%s*' ) do
		local region = DATA.getRegion( regionInput )

		if region then
			local setListPage = makeSetListPage( setNameForLink, region )

			table.insert( listsContent, {
				region = region.full:gsub( 'Worldwide ', '' ),
				content = generateNavbar( setListPage ) .. generateContent( setListPage, frame ),
			} )
		else
			local message = ( 'Invalid region: `%s`' ):format( regionInput )

			local category = '((Set list tabs)) transclusions with invalid regions'

			reporter
				:addError( message )
				:addCategory( category )
		end
	end

	listsContainer
		:wikitext(
			reporter:dump(),
			listsContent[ 2 ]
				and frame:extensionTag{
					name = 'tabber',
					content = printContent( listsContent ),
				}
				or listsContent[ 1 ].content
		)

	return tostring( listsContainer )
end

return setmetatable( {
	main = function( frame )
		local arguments = frame:getParent().args

		return main( UTIL.trim( arguments[ 1 ] ) or 'EN,FR,DE,IT,SP,JP,JA,KR', frame )
	end
}, {
	__call = function( t, ... )
		return main( ..., mw.getCurrentFrame() )
	end,
} )
-- </pre>
