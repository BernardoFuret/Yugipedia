-- <pre>
-- @name Card gallery
-- @description Builds a card gallery section for a single region.
-- @author [[User:Becasita]]
-- @contact [[User talk:Becasita]]

----------------
-- Load modules:
----------------
local DATA = require( 'Module:Data' );
local UTIL = require( 'Module:Util' );

local InfoWrapper  = require( 'Module:InfoWrapper' );
local StringBuffer = require( 'Module:StringBuffer' );

local File = require( 'Module:Card gallery/File' );

--------------------
-- Module variables:
--------------------
-- This can be seen as the ast:
local CardGallery = InfoWrapper( 'Card gallery' );

-- Parser state:
local
	PAGENAME,
	NAMESPACE,
	_frame,
	_args,
	_region,
	_language,
	_type,
	_title,
	_debug
;
local _files = {};

-- Methods:
function CardGallery:getRegion()
	return _region;
end

function CardGallery:getLanguage()
	return _language;
end

function CardGallery:getType()
	return _type;
end

---------------------
-- Utility functions:
---------------------
-- mw functions:
local HTML = mw.html.create;

--------------------
-- Module functions:
--------------------
-- @name initInfo
-- @description Handles generic info.
local function initInfo()
	-- Page:
	local mwTitle  = mw.title.getCurrentTitle();
	PAGENAME  = mwTitle.text;
	NAMESPACE = mwTitle.nsText;

	-- Region and language:
	_region = DATA.getRegion( _args[ 'region' ] ) or CardGallery:error(
		('Invalid «region»: %s!'):format( _args[ 'region' ] or '(no region given)' ),
		DATA.getRegion( 'en' )
	);
	_language = DATA.getLanguage( _region.index );

	-- Type of gallery:
	_type  = DATA.getCardGalleryType( _args[ 'type' ] );
	_title = _args[ 'title' ];
	_debug = _args[ 'debug' ];
end

-- @name getFiles
-- @description Assembles the file entries and prepares them to be parsed.
local function initFiles()
	if not _args[ 1 ] then
		return CardGallery:error(
			( _frame.args[ 1 ] and 'Empty' or 'No' ) .. 'input provided for the gallery!'
		);
	end

	for inputEntry in mw.text.gsplit( _args[ 1 ], '\n' ) do
		local entry = UTIL.trim( inputEntry ) and File.factory( CardGallery, inputEntry );
		if entry then
			table.insert( _files, entry );
		end
	end
end

-- @description Builds the mediawiki section header.
local function getMwSectionHeader()
	return (
		(_type or _title) and '== %s - %s ==' or '== %s =='
	):format(
		(_type or _title) or _region.full, _region.full
	);
end

-- @description Builds the ToC skeleton.
local function getToC()
	return tostring(
		HTML( 'div' ):addClass( 'card-gallery__toc' )
			:tag( 'ul' )
			:done()
		:allDone()
	);
end

-- @description Builds the errors' log.
local function getErrors()
	return tostring(
		HTML( 'div' )
			:addClass( 'card-gallery__errors' )
			:tag( 'ul' )
				:node(
					CardGallery:dumpErrors( function( err )
						return tostring(
							HTML( 'li' )
								:tag( 'strong' )
									:wikitext( err )
								:done()
							:allDone()
						)
					end )
				)
			:done()
		:allDone()
	);
end

-- @description Builds the gallery itself.
local function getGallery()
	local gallery = StringBuffer()
		:addLine( '<gallery heights="175px" position="center" captionalign="center">' )
	;
	for _, file in ipairs( _files ) do
		gallery:addLine( file:render() );
	end
	gallery:addLine( '</gallery>' );

	return tostring(
		HTML( 'div' )
			:addClass( 'card-gallery__gallery' )
			:node(
				_debug and tostring(
					HTML( 'pre' ):node( gallery:toString() ):done()
				) or _frame:preprocess(
					gallery:toString()
				)
			)
		:allDone()
	);
end

-- @description Aggregates the categories.
local function getCategories()
	return tostring(
		HTML( 'div' )
			:addClass( 'card-gallery__categories' )
			:wikitext(
				CardGallery:dumpCategories()
			)
		:allDone()
	);
end

local function render()
	local buffer = StringBuffer()
		:addLine( '<div id="card-gallery--' .. _region.index .. '" class="card-gallery">' )
		:addLine( getMwSectionHeader() )
		:addLine( getToC() )
		:addLine( getErrors() )
		:addLine( getGallery() )
		:addLine( getCategories() )
		:add( '</div>' )
	;
	
	return buffer:toString();
end

-- @name main
-- @description To be called through #invoke.
local function main( frame )
	_frame = frame;
	_args  = UTIL.getArgs( frame, {
		trim         = true,
		removeBlanks = true,
		parentOnly   = true
	} );

	initInfo();
	initFiles();

	return render();
end

----------
-- Return:
----------
-- @exports 
return {
	['main'] = main
};
-- </pre>