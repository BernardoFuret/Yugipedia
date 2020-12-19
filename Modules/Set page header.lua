-- <pre>
--[=[Doc
@module Set page header
@description 
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
TODO:
- Validate stuff?
- Create instance?
]=]

local DATA = require( 'Module:Data' )
local UTIL = require( 'Module:Util' )

local LANGUAGE_ENGLISH = DATA.getLanguage( 'English' )

local mwTitle = mw.title

local function getRegion( pagename )
	local index = pagename:match( 'CG%-(%a+)%-?' )

	local region = DATA.getRegion( index ) -- TODO: handle erroneous region (nil)?

	return region
end

local function getEdition( pagename )
	local index = pagename:match( 'CG%-%a+%-(%w+)' )

	local edition = DATA.getEdition( index ) -- TODO: handle erroneous edition (nil)?

	return edition
end

local function getSetPagename( pagename )
	local parts = mw.text.split( pagename, '%(' )

	return table.concat( parts, '(', 1, #parts - 1 )
end

local function makeHeader( setPagename, region, edition )
	local language = DATA.getLanguage( region.index )

	local medium = DATA.getMedium( region.index )

	local englishName = DATA.getName(
		setPagename,
		LANGUAGE_ENGLISH
	)

	local localizedName = DATA.getName(
		setPagename,
		language
	)

	local header = mw.html.create( 'div' ):addClass( 'page-header' )

	-- Link to set page:
	header:tag( 'div' )
		:addClass( 'page-header__link' )
		:wikitext( UTIL.link( setPagename, englishName ) )

	-- Localized set name:
	if language.index ~= LANGUAGE_ENGLISH.index and localizedName then
		header:tag( 'div' )
			:addClass( 'page-header__localized' )
			:attr( 'lang', language.index )
			:wikitext( localizedName )
	end

	-- Region and edition
	header:tag( 'div' )
		:addClass( 'page-header__caption' )
		:wikitext( region.full )
		:wikitext( edition and ( ' - %s' ):format( edition.full ) )

	return tostring( header )
end

local function makeCategories( ns, region, edition )
	return table.concat{
		( '[[Category:%s %s]]' ):format( region.full, ns ),
		edition and ( '[[Category:%s %s]]' ):format( edition.full, ns ),
	}
end

function main( args )
	local currentTitle = args.pagename
		and mwTitle.new( args.pagename )
		or mwTitle.getCurrentTitle()

	local ns = currentTitle.subjectNsText

	if not UTIL.trim( ns ) then
		return
	end

	local pagename = currentTitle.text

	local region = getRegion( pagename )

	local edition = getEdition( pagename )

	local setPagename = args.set or getSetPagename( pagename )

	local header = makeHeader( setPagename, region, edition )

	local categories = makeCategories( ns, region, edition )

	return table.concat{
		header,
		categories,
	}
end

return setmetatable({
	main = function( frame )
		local args = frame:getParent().args

		return main( args )
	end,
}, {
	__call = function( t, args )
		mw.log( main( args ) )
	end,
})
-- </pre>
