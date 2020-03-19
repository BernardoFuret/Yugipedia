-- <pre>
--[=[Doc
@module Card table
@description Card table module implementation.
@author [[User:Deltaneos]]
@author [[User:Dinoguy1000]]
@author [[User:Becasita]]
]=]

local UTIL = require( 'Module:Util' )

local StringBuffer = require( 'Module:StringBuffer' )

local ct = {}

local mwTitle = mw.title
local mwSiteNamespaces = mw.site.namespaces
local mwHtmlCreate = mw.html.create

local currentTitle = mwTitle.getCurrentTitle()

local function createTrackingCategory( param )
	return ('[[Category:((Card table)) transclusions using (((%s)))]]'):format( param )
end

local function track( categories, args )
	local params = {
		'max_width',
		'above_image',
		'image_raw',
		'image_right',
	}

	for _, param in ipairs( params ) do
		if args[ param ] then
			categories:add( createTrackingCategory( param ) )
		end
	end
end

local function warn( ... )
	local res = StringBuffer()

	local arguments = {
		size = select( '#', ... ),
		...
	};

	for i = 1, arguments.size do
		res:add( arguments[ i ] );
	end

	return tostring(
		mwHtmlCreate( 'div' )
			:addClass( 'card-table__error' )
			:tag( 'strong' )
				:wikitext( res:flush( ' ' ):toString() )
		:allDone()
	)
end

local function checkArgs( warnings, categories, args )
	local unsupported;

	local parameters = require( 'Module:Card table/Parameters' )

	for parameter, argument in pairs( args ) do
		if not parameters[ parameter ] then
			unsupported = true;

			local message = ('The parameter `%s` is not supported!'):format(
				UTIL.formatParameter( parameter )
			);

			warnings:add( warn( message ) )
		end
	end

	if unsupported then
		categories:add( '[[Category:((Card table)) with unsupported parameters]]' )
	end
end

local function validExtension( extension )
	return ( {
		['image/png'] = true,
		['image/jpg'] = true,
	} )[ extension:lower() ]
end

local function getFileData( args )
	local CARD_BACK = 'Back-EN.png'

	local MAX_IMAGE_WIDTH = tonumber( args.image_width ) or 300

	local filePageData = mwTitle.new( args.image or '', 6 )

	local fileData = filePageData and filePageData.file

	local validFile = fileData
		and fileData.exists
		and validExtension( fileData.mimeType )
		and fileData.width > 0
		and fileData.height > 0

	return {
		name  = validFile and filePageData.text or CARD_BACK,
		width = validFile
			and (fileData.width < MAX_IMAGE_WIDTH and fileData.width or MAX_IMAGE_WIDTH)
			or MAX_IMAGE_WIDTH, -- Getting the width of the card back is expensive (without hardcoding it). This assumes all goes fine.
		link  = validFile
			and ( UTIL.trim( args.image_link ) or filePageData.fullText )
			or tostring( mw.uri.fullUrl( 'Special:Upload', {
				wpDestFile = args.image -- TODO this might ask to upload a not well formed link (e.g., wrong extension)
			} ) ),
	}
end

local function concatStyles( main, spec )
	return StringBuffer()
		:add( main )
		:add( spec )
		:flush( ' ' )
		:toString()
end

local function makeRow( args )
	if UTIL.trim( args.header ) then
		return tostring(
			mwHtmlCreate( 'tr' )
				:tag( 'th' )
					:addClass( args.class )
					:attr( 'colspan', 2 )
					:css( 'text-align', 'center' )
					:cssText( args.headerstyle )
					:wikitext( args.header )
			:allDone()
		)
	end

	if UTIL.trim( args.data ) then
		local tr = mwHtmlCreate( 'tr' )
			:addClass( args.rowclass )

		local td = mwHtmlCreate( 'td' )
			:addClass( args.class )
			:wikitext( args.data )

		if UTIL.trim( args.label ) then
			td:cssText( args.datastyle )

			tr
				:tag( 'th' )
					:attr( 'scope', 'row' )
					:css( 'text-align', 'center' )
					:cssText( args.labelstyle )
					:wikitext( args.label )
				:done()
				:node( tostring( td ) )
		else
			td
				:attr( 'colspan', 2 )
				:css( 'text-align', 'center' )
				:cssText( args.datastyle )

			tr:node( tostring( td ) )
		end

		return tostring( tr )
	end
end

local function isCardTableTemplate( currentTitle )
	return StringBuffer()
		:add( mwSiteNamespaces[ 'template' ].canonicalName )
		:add( currentTitle.baseText )
		:flush( ':' )
		:toString()
		==
		currentTitle.fullText
		--[[table.concat( {
			mwSiteNamespaces[ 'template' ].canonicalName,
			currentTitle.baseText,
		}, ':' ) == currentTitle.fullText]]
end

local function pad( v )
	return v:len() < 3 and pad( '0' .. v ) or v
end

function makeSortkey()
	local replaceCb = function( full, no )
		return full:gsub( no, pad( no ) )
	end

	local sortkey = currentTitle.text
		:gsub( '^(Number%s*%u?(%d-):)', replaceCb )
		:gsub( '^(New Order%s*(%d-):)', replaceCb )

	return sortkey
end

local function defaultsort( defaultkey )
	return ('{{DEFAULTSORT:%s}}'):format(
		UTIL.trim( defaultkey ) or makeSortkey()
	)
end

function ct._main( args )
	local warnings = StringBuffer()

	local categories = StringBuffer()

	track( categories, args )

	checkArgs( warnings, categories, args )

	local mainWrapper = mwHtmlCreate( 'div' )
		:addClass( 'card-table' )
		:addClass( UTIL.trim( args.bodyclass ) or 'blank-card' )
		:cssText( args.bodystyle )

	if UTIL.trim( args.title ) then
		mainWrapper
			:tag( 'div' )
				:addClass( 'heading' )
				:addClass( args.titleclass )
				:cssText( args.titlestyle )
				:wikitext( args.title )
	end

	if UTIL.trim( args.above ) then
		mainWrapper
			:tag( 'div' )
				:addClass( 'above' )
				:wikitext( args.above )
	end

	local tableColumnsWrapper = mainWrapper
		:tag( 'div' )
			:addClass( 'card-table-columns' )

	local imagecolumnWrapper = tableColumnsWrapper
		:tag( 'div' )
			:addClass( 'imagecolumn' )
			--:attr( 'data-max_width', '$ct_max_width' )

--	if UTIL.trim( args.above_image ) then
--		imagecolumnWrapper
--			:tag( 'div' )
--				:addClass( 'aboveimage' )
--				:wikitext( args.above_image )
--	end

	if UTIL.trim( args.image_raw ) then
		imagecolumnWrapper:node( args.image_raw )
	else
		local fileData = getFileData( args )

		local mainImageWrapper = imagecolumnWrapper
			:tag( 'div' )
				:addClass( 'cardtable-main_image-wrapper' )
				:wikitext(
					('[[File:%s|%spx|link=%s|alt=%s]]'):format(
						fileData.name,
						fileData.width,
						fileData.link,
						args.title or currentTitle.text
					)
				)
	end

	if UTIL.trim( args.below_image ) then
		imagecolumnWrapper
			:tag( 'div' )
				:addClass( 'aboveimage' )
				:wikitext( args.below_image )
	end

	local innertable = tableColumnsWrapper
		:tag( 'div' )
			:addClass( 'infocolumn' )
			:tag( 'table' )
				:addClass( 'innertable' )

	for number = 1, 20 do
		local row = makeRow{
			header      = args[ 'header' .. number ],
			headerstyle = concatStyles( args.headerstyle, args[ 'headerstyle' .. number ] ),
			label       = args[ 'label' .. number ],
			labelstyle  = concatStyles( args.labelstyle, args[ 'labelstyle' .. number ] ),
			data        = args[ 'data' .. number ],
			datastyle   = concatStyles( args.datastyle, args[ 'datastyle' .. number ] ),
			class       = args[ 'class' .. number ],
			rowclass    = args[ 'rowclass' .. number ],
		}

		innertable:node( row )
	end

	if UTIL.trim( args.below ) then
		mainWrapper
			:tag( 'div' )
				:addClass( 'below' )
				:addClass( args.belowclass )
				:wikitext( args.below )
	end

	if currentTitle.namespace then
		if isCardTableTemplate( currentTitle ) then
			categories:add( '[[Category:Card table templates]]' )
		end
	else
		categories:add( '[[Category:All cards]]' )

		local gallery = mwTitle.makeTitle(
			mwSiteNamespaces[ 'card gallery' ].id,
			UTIL.trim( args.main ) or currentTitle.text
		)

		if not gallery.exists then
			categories:add( '[[Category:Cards that need a gallery]]' )
		end

		if mw.smw then
			local setResult = mw.smw.set{
				['Page name'] = currentTitle.fullText,
				['Page type'] = 'Card page',
			}

			if not setResult then
				warnings:add(
					warn( 'Could not set SMW properties:', result.error )
				)
			end
		else
			warnings:add( warn( '`mw.smw` module not found' ) )
		end
	end

	return table.concat{
		warnings:toString(),
		tostring( mainWrapper ),
		categories:toString(),
		mw.getCurrentFrame():preprocess(
			defaultsort( args.defaultsort )
		),
	}
end

function ct.main( frame )
	return ct._main( frame:getParent().args )
end

return ct
-- </pre>
