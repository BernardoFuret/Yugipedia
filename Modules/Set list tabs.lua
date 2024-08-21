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

local reporter

local SET_NAMES_SPECIAL_CASES = {
	[ '2011' ] = true,
	[ '2018' ] = true,
	[ '2019' ] = true,
	[ 'series' ] = true,
	[ 'Obelisk the Tormentor' ] = true, -- 20th Anniversary Duel Set
	[ 'Slifer the Sky Dragon' ] = true, -- 20th Anniversary Duel Set
	[ '25th Anniversary Edition' ] = true,
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

local function incrementHeaders( content )
	local contentLines = mw.text.split( content, '\n' )

	local updatedContentLines = {}

	local pattern = '^(=+)(.*)(%1)%s*$'

	for _, line in ipairs( contentLines ) do
		local headerMarkupStart, headerTitle, headerMarkupEnd = line:match( pattern )

		if headerMarkupEnd then
			local headerLevel = headerMarkupEnd:len()

			if headerLevel < 6 then
				local incrementedHeader = table.concat{
					headerMarkupStart, '=',
					headerTitle,
					'=', headerMarkupEnd
				}

				table.insert( updatedContentLines, incrementedHeader )
			else
				table.insert( updatedContentLines, line )
			end
		else
			table.insert( updatedContentLines, line )
		end
	end

	return table.concat( updatedContentLines, '\n' )
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

	local wikitextContent = success
		and incrementHeaders( content )
		or table.concat{ '[[', fullpagename, ']]' }

	local ret = tostring(
		mwHtmlCreate( 'div' )
			:addClass( 'set-list-tab' )
			:attr( 'data-page', fullpagename )
			:wikitext( wikitextContent )
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

local function main( frame, regionsInput, setPagenameInput )
	reporter = Reporter( 'Set list tabs' )

	local listsContainer = mwHtmlCreate( 'div' )
		:addClass( 'set-lists-tabber' )

	local listsContent = {}

	local setPagename = setPagenameInput or mw.title.getCurrentTitle().text

	local setNameForLink = normalizeSetNameForLink( setPagename )

	generateContent = generateContentFirst

	for regionInput in mw.text.gsplit( regionsInput, '%s*,%s*' ) do
		local region = DATA.getRegion( regionInput )

		if region then
			local setListPage = makeSetListPage( setNameForLink, region )

			table.insert( listsContent, {
				region = region.full:gsub( 'Worldwide ', '' ),
				title = setListPage,
				content = generateNavbar( setListPage ) .. generateContent( setListPage, frame ),
			} )
		else
			local message = ( 'Invalid region: `%s`' ):format( regionInput )

			local category = 'transclusions with invalid regions'

			reporter
				:addError( message )
				:addCategory( category )
		end
	end

	listsContainer
		:wikitext(
			reporter:dump(),
			listsContent[ 2 ]
				and frame
					:newChild{
						title = listsContent[ 1 ].title,
					}
					:extensionTag{
						name = 'tabber',
						content = printContent( listsContent ),
					}
				or listsContent[ 1 ].content
		)

	return tostring( listsContainer )
end

return setmetatable(
	{
		main = function( frame )
			local arguments = frame:getParent().args

			local regionsInput = UTIL.trim( arguments[ 1 ] )

			-- TODO: validate if regionsInput exists?
			return main( frame, regionsInput or 'EN,FR,DE,IT,SP,JP,JA,KR' )
		end
	},
	{
		__call = function( t, regionsInput, setPagenameInput )
			return main( mw.getCurrentFrame(), regionsInput, setPagenameInput )
		end,
	}
)
-- </pre>
