-- <pre>
--[=[Doc
@module Card table/Render
@description 
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

local StringBuffer = require( 'Module:StringBuffer' );

local CARD_BACK = 'Back-EN.png';

--------------------
-- Helper functions:
--------------------
-- mw functions:
local mwHtmlCreate = mw.html.create;
local mwUriFullUrl = mw.uri.fullUrl;

--[[Doc
@function makeId
]]
local function makeId( id )
	return id and ( 'data-table__row--%s' ):format( id );
end

--[[Doc
@function makeHeader
]]
local function makeHeader( title )
	return ( '\n== %s ==\n' ):format( title );
end

--------------------
-- Render functions:
--------------------
--[[Doc
@function renderErrors
@parameter {CardTable} ct
--]]
local function renderErrors( ct )
	return tostring(
		mwHtmlCreate( 'div' )
			:addClass( 'card-table__errors' )
			:tag( 'ul' )
				:node(
					ct:dumpErrors( function( err )
						return tostring(
							mwHtmlCreate( 'li' )
								:tag( 'strong' )
									:wikitext( err )
								:done()
							:allDone()
						);
					end )
				)
			:done()
		:allDone()
	);
end

--[[Doc
@function renderCategories
@parameter {CardTable} ct
--]]
local function renderCategories( ct )
	return tostring(
		mwHtmlCreate( 'div' )
			:addClass( 'card-table__categories' )
			:wikitext( ct:dumpCategories() )
		:allDone()
	);
end

--[[Doc
@function renderHeader
]]
local function renderHeader( header )
	return header:getContent() and tostring(
		mwHtmlCreate( 'div' )
			:addClass( 'card-table__header' ) -- .heading
			:attr( 'id', header:getId() )
			--:tag( 'div' )
				:node( header:getContent() )
			--:done()
		:allDone()
	);
end

--[[Doc
@function renderCaption
]]
local function renderCaption( caption )
	return caption:getContent() and tostring(
		mwHtmlCreate( 'div' )
			:addClass( 'card-table__caption' ) -- .above
			:attr( 'id', caption:getId() )
			:node( caption:getContent() )
		:done()
	);
end

--[[Doc
@function renderImage
]]
local function renderImage( image ) -- TODO: Handle/check default cases and whether or not to display this or that. 
	local wrapper = mwHtmlCreate( 'div' )
		:addClass( 'card-table__columns__image' ) -- imagecolumn
	;

	-- Header:
	wrapper
		:tag( 'div' )
			:attr( 'id', image:Header():getId() )
			:addClass( 'card-table__columns__image--header' ) --
			:node( image:Header():getContent() )
		:done()
	;

	-- Main image:
	wrapper
		:tag( 'div' )
			:attr( 'id', image:getId() )
			:addClass( 'card-table__columns__image--main' ) -- cardtable-main_image-wrapper
			:wikitext(
				(  '[[File:%s|%dpx|link=%s]]' ):format(
					image:getMain() or image:getDefault() or CARD_BACK,
					image:getWidth() or 250,
					image:getMain() or image:getDefault() or tostring( mwUriFullUrl(
						'Special:Upload',
						{
							wpDestFile = image:getMain() or ''
						}
					) )
				)
			)
		:done()
	;

	-- Footer:
	wrapper
		:tag( 'div' )
			:attr( 'id', image:Footer():getId() )
			:addClass( 'card-table__columns__image--footer' ) -- belowimage
			:node( image:Footer():getContent() )
		:done()
	;

	return tostring( wrapper );
end

--[[Doc
@function renderRow
@description Converts a row to string.
@typedef Row {
	header  = string|nil
	content = string|nil
	options = table
}
@parameter {CardTable/Args/Container} row The row to convert to string.
@returns {string} An HTML row.
]]
local function renderRow( row ) -- don't forget row.options
	local tr = mwHtmlCreate( 'tr' )
		:addClass( 'data-table__row' )
		:attr( 'id', makeId( row:getId() ) )
	;

	local th = mw.html.create( 'th' )
		:wikitext( row:getLabel() or '' )
	:done();

	local td = mw.html.create( 'td' )
		:node( row:getContent() or '' )
	:done();

	if not row:getLabel() then
		td:attr( 'colspan', 2 );
		tr:node( td ):allDone();
	elseif not row:getContent() then
		th:attr( 'colspan', 2 );
		tr:node( th ):allDone();
	else
		tr:node( th:attr( 'scope', 'row' ) ):allDone();
		tr:node( td ):allDone();
	end

	return tostring( tr );
end

--[[Doc
@function renderRows
@description Renders the data table rows.
@parameter {CardTable/Args/Mixed} rows
@returns {string} Wikitext for the data table.
]]
local function renderRows( rows )
	local t = mw.html.create( 'table' )
		:addClass( 'card-table__data-table' ) -- innertable
	;

	for row in rows:values() do
		t:node( renderRow( row ) );
	end

	return tostring( t:allDone() );
end

--[[Doc
@function renderFooter
]]
local function renderFooter( footer )
	return footer:getContent() and tostring(
		mwHtmlCreate( 'div' )
			:addClass( 'card-table__footer' ) -- .below
			:node( footer:getContent() )
		:done()
	);
end

--[[Doc
@function renderSection
@parameter {CardTable/Args/Container} section
]]
local function renderSection( section )
	return mwHtmlCreate( 'div' ) -- or <section>
		:addClass( 'data-sections__section' )
		:attr( 'id', makeId( row:getId() ) )
		:wikitext( makeHeader( section:getLabel() ) )
		--:tag( 'div' )
		--	:addClass( 'data-sections__section__content' )
			:node( section:getContent() )
		--:done()
	:allDone();
end

--[[Doc
@function renderSections
@description Renders the sections.
@parameter {CardTable/Args/Mixed} sections
@returns {string} Wikitext for the sections.
]]
function renderSections( sections )
	local s = mwHtmlCreate( 'div' )
		:addClass( 'data-sections' )
	;

	for section in sections:values() do
		s:node( renderSection( section ) );
	end

	s:allDone();

	return tostring( s );
end

--[[Doc
@function renderWrapper
@description This function is actually to be used as a method for `CardTable`.
It renders the card table.
@parameter {CardTable} ct The card table itself.
]]
local function renderWrapper( ct )
	local wrapper = mwHtmlCreate( 'div' )
		:attr( 'id', 'card-table' )
		:addClass( 'card-table' )
	;

	for class in ct:Args():Classes():values() do
		wrapper:addClass( class );
	end

	wrapper
		:node( renderHeader( ct:Args():Header() ) )

		:node( renderCaption( ct:Args():Caption() ) )

		:tag( 'div' )
			:addClass( 'card-table__columns' ) --card-table-columns
			:node( renderImage( ct:Args():Image() ) )

			:tag( 'div' )
				:addClass( 'card-table__columns__data' )
				:node( renderRows( ct:Args():Rows() ) )
			:done()
		:done() -- Close .card-table__columns

		:node( renderFooter( ct:Args():Footer() ) )

	:allDone();

	return tostring( wrapper );
end

----------
-- Return:
----------
--[[Doc
@exports Render function.
@parameter {CardTable} ct The card table itself.
]]
return function( ct )
	local content = StringBuffer()
		:add( renderErrors( ct ) )
		:add( renderWrapper( ct ) )
		:add( renderSections( ct:Args():Sections() ) )
		:add( renderCategories( ct ) )
		:flush( '\n' )
	;

	return content:toString();
end
-- </pre>

