-- <pre>
-- @name Card gallery
-- @description Builds a card gallery section for a single region.
-- @author [[User:Becasita]]
-- @contact [[User talk:Becasita]]

----------------------
-- "Global" variables:
----------------------
local CardGallery = {}; -- Export variable.
local INFO        = {}; -- Module info object.

----------------
-- Load modules:
----------------
local DATA    = require( 'Module:Data' );
local UTIL    = require( 'Module:Util' );
local getArgs = require( 'Module:Arguments' ).getArgs;
local File    = require( 'Module:Card gallery/File' );

---------------------
-- Utility functions:
---------------------
-- mw functions:
local gsplit = mw.text.gsplit;
local HTML   = mw.html.create;

-- @name _error
-- @description Generates an error and places it on the error table.
local function _error( message, default, category )
	INFO.errors.exists = true;
	local err = HTML( 'div' ):css( 'padding-left', '1.6em' )
		:tag( 'strong' ):addClass( 'error' )
			:wikitext( ('Error: %s'):format( message ) )
		:done()
	:allDone();
	local cat = category and ('[[Category:%s]]'):format( category ) or '';

	table.insert(
		INFO.errors, table.concat( {
			tostring( err ), cat
		} )
	);

	return default or '';
end

--------------------
-- Module functions:
--------------------
-- @name getInfo
-- @description Handles generic info.
local function getInfo()
	-- Region and language:
	INFO.rg = DATA.getRg( INFO.args[ 'region' ] ) or _error(
		('Invalid «region»: %s!'):format( INFO.args[ 'region' ] or '(no region given)' ),
		DATA.getRg( 'en' )
	);
	INFO.region   = DATA.getRegion( INFO.rg );
	INFO.ln       = DATA.getLn( INFO.rg );
	INFO.language = DATA.getLanguage( INFO.rg );

	-- Page:
	local mwTitle  = mw.title.getCurrentTitle();
	INFO.PAGENAME  = mwTitle.text;
	INFO.NAMESPACE = mwTitle.nsText;

	-- Type of gallery:
	INFO.type  = INFO.args[ 'type' ] and DATA.getCardGalleryType( INFO.args[ 'type' ] );
	INFO.title = INFO.args[ 'title' ];
end

-- @name wrapInQuotes
-- @description Wraps «name» in proper quotation marks.
local function wrapInQuotes( name )
	if not UTIL.trim( name ) then
		return '';  --  Return empty string.
	end

	return (INFO.ln ~= 'ja' and INFO.ln ~= 'zh')
		and table.concat( { '"', name, '"' } )
		or  table.concat( { '「', name, '」' } )
	;
end

-- @name printErrors
-- @description Stringifies the errors table.
local function printErrors()
	local category = '[[Category:((Card gallery)) transclusion to be checked]]';

	if not INFO.errors.exists then
		return '';
	end

	table.insert( INFO.errors, category );

	return table.concat( INFO.errors, '\n' );
end

-- @name buildGallery
-- @description Builds the gallery.
local function buildGallery()
	if not INFO.args[ 1 ] then
		return _error( 'Empty or no input provided for the gallery!', '' );
	end

	local galleryEntries = {};
	for inputEntry in gsplit( INFO.args[ 1 ], '\n' ) do
		local entry = UTIL.trim( inputEntry ) and File.factory( inputEntry, INFO );
		if entry then
			table.insert( galleryEntries, tostring( entry ) );
			-- Extend INFO.errors with entry.errors:
			for _, message in ipairs( entry.errors ) do
				_error( message ); -- TODO: check this.
			end
		end
	end

	return table.concat( {
		'<gallery heights="175px" position="center" captionalign="center">',
		table.concat( galleryEntries, '\n' ),
		'</gallery>'
	}, '\n' );
end

-- @name buildAll
-- @description Builds the full gallery section, ToC and container.
local function buildAll( frame, gallery, errors )
	local sectionHeader = (
		(INFO.type or INFO.title) and '== %s - %s ==' or '== %s =='
	):format(
		(INFO.type or INFO.title) or INFO.region, INFO.region
	);
	local toc = HTML( 'div' ):addClass( 'card-gallery-toc' )
		:tag( 'ul' )
		:done()
	:allDone();
	local container = HTML( 'div' ):addClass( 'card-galleries' )
		:node( errors )
		:newline()
		:node( frame:preprocess( gallery ) )
	:allDone();

	return table.concat( {
		sectionHeader,
		tostring( toc ),
		tostring( container )
	}, '\n' );
end

-- @name main
-- @notes exportable 
-- @description To be called through #invoke.
function CardGallery.main( frame )
	INFO.errors = {};
	INFO.args   = getArgs( frame, {
		trim         = true,
		removeBlanks = true,
		parentOnly   = true
	} );

	getInfo();

	local gallery = buildGallery();
	local errors  = printErrors();

	return buildAll( frame, gallery, errors );
end

----------
-- Return:
----------
return CardGallery;
-- </pre>