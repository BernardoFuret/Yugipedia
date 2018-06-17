-- <pre>
-- @name Card gallery
-- @description Builds a card gallery section for a single region.
-- @author [[User:Becasita]]
-- @contact [[User talk:Becasita]]

----------------------
-- "Global" variables:
----------------------
local CardGallery = {}; -- Export variable.
local _D          = {}; -- Global data object.

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
	_D.errors.exists = true;
	local err = HTML( 'div' ):css( 'padding-left', '1.6em' )
		:tag( 'strong' ):addClass( 'error' )
			:wikitext( ('Error: %s'):format( message ) )
		:done()
	:allDone();
	local cat = category and ('[[Category:%s]]'):format( category ) or '';

	table.insert(
		_D.errors, table.concat( {
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
	_D.rg       = DATA.getRg( _D.args[ 'region' ] ) or _error(
		('Invalid «region»: %s!'):format( _D.args[ 'region' ] or '(no region given)' ),
		DATA.getRg( 'en' )
	);
	_D.region   = DATA.getRegion( _D.rg );
	_D.ln       = DATA.getLn( _D.rg );
	_D.language = DATA.getLanguage( _D.rg );

	-- Page:
	local mwTitle = mw.title.getCurrentTitle();
	_D.PAGENAME   = mwTitle.text;
	_D.NAMESPACE  = mwTitle.nsText;

	-- Type of gallery:
	_D.type = _D.args[ 'type' ] and DATA.getCardGalleryType( _D.args[ 'type' ] );
end

-- @name wrapInQuotes
-- @description Wraps «name» in proper quotation marks.
local function wrapInQuotes( name )
	if not UTIL.trim( name ) then
		return '';  --  Return empty string.
	end

	return (_D.ln ~= 'ja' and _D.ln ~= 'zh')
		and table.concat( { '"', name, '"' } )
		or  table.concat( { '「', name, '」' } )
	;
end

-- @name printErrors
-- @description Stringifies the errors table.
local function printErrors()
	local category = '[[Category:((Card gallery)) transclusion to be checked]]';

	if not _D.errors.exists then
		return '';
	end

	table.insert( _D.errors, category );

	return table.concat( _D.errors, '\n' );
end

-- @name buildGallery
-- @description Builds the gallery.
local function buildGallery()
	if not _D.args[ 1 ] then
		return _error( 'Empty or no input provided for the gallery!', '' );
	end

	local galleryEntries = {};
	for inputEntry in gsplit( _D.args[ 1 ], '\n' ) do
		local entry = UTIL.trim( inputEntry ) and File.factory( inputEntry, _D );
		if entry then
			table.insert( galleryEntries, tostring( entry ) );
			-- Extend _D.errors with entry.errors:
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
		(_D.type and '== %s - %s ==' or '== %s =='):format( _D.type or _D.region, _D.region );
		tostring( toc ),
		tostring( container )
	}, '\n' );
end

-- @name main
-- @notes exportable 
-- @description To be called through #invoke.
function CardGallery.main( frame )
	_D.errors = {};
	_D.args   = getArgs( frame, {
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