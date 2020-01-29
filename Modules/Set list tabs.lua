-- <pre>
--[=[Doc
@module Set list tabs
@description Display set lists for all eligible
regions on their respective set pages, using a tabber.
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

-- TODO: handle cases of a single region entered.

local DATA = require( 'Module:Data' )
local UTIL = require( 'Module:Util' )

local navbar = require( 'Module:Navbar' )._navbar

local Reporter = require( 'Module:Reporter' )
local StringBuffer = require( 'Module:StringBuffer' )

local mwText = mw.text
local mwHtmlCreate = mw.html.create

local reporter;

local function makeSetListPage( setPage, region )
	local medium = DATA.getMedium( region.index )

	return ( 'Set Card Lists:%s (%s-%s)' ):format( setPage, medium.abbr, region.index )
end

local function generateNavbar( pagename )
	return tostring(
		mwHtmlCreate( 'div' )
			:addClass( 'set-lists-tabber__tab-navbar' ) -- float:right; clear:both
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
			:wikitext( success and content or table.concat{
				'[[', fullpagename, ']]'
			} )
	)

	generateContent = generateContentRest

	return ret
end

local function main( regionsInput, frame )
	reporter = Reporter( 'Set list tabs' )

	local tabberContainer = mwHtmlCreate( 'div' )
		:addClass( 'set-lists-tabber' ) -- margin-bottom: 5px; clear: both;

	local tabberContent = StringBuffer()

	local setPage = mw.title.getCurrentTitle().text

	generateContent = generateContentFirst
	
	for regionInput in mwText.gsplit( regionsInput, '%s*,%s*' ) do
		local region = DATA.getRegion( regionInput )

		if region then
			local setListPage = makeSetListPage( setPage, region )

			local tabContent = StringBuffer()
				:add( region.full:gsub( 'Worldwide ', '' ) )
				:add( '=' )
				:add( generateNavbar( setListPage ) )
				:add( generateContent( setListPage, frame ) )

			tabberContent:add( tabContent:toString() )
		else
			local message = ( 'Invalid region: `%s`' ):format( regionInput )

			local category = '((Set list tabs)) transclusions with invalid regions'

			reporter
				:addError( message )
				:addCategory( category )
		end
	end

	tabberContainer
		:wikitext(
			reporter:dump(),
			frame:extensionTag{
				name = 'tabber',
				content = tabberContent:flush( '|-|' ):toString(),
			}
		)

	return tostring( tabberContainer )
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
