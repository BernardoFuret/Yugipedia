-- <pre>
-- @name Card gallery/File/VG
-- @description Card Gallery file class for video game entries.
-- @author [[User:Becasita]]
-- @contact [[User talk:Becasita]]

-- «
-- <CardName>-<VideoGame>-<region>-VG-[-NC][-<alt>].<extension>
-- »

-- «
-- <VideoGame>; <alt> :: <Non-card> // <option1>::<value1>; <optionN>::<valueN>
-- »

-------------
-- Constants:
-------------
local VG_CARD_BACK = 'Back-DOR-VG.png';

----------------
-- Load modules:
----------------
local DATA = require( 'Module:Data' );
local UTIL = require( 'Module:Util' );

local StringBuffer = require( 'Module:StringBuffer' );

---------------
-- Helper vars:
---------------
-- These variables are only used by the init functions.
-- Therefore, even though they are re-assigned every time
-- a new instance is created (through `new()`), there's no
-- problem, because their useful lifetime is only inside
-- that very function.
-- This way, having them here kinda as static variables,
-- supports encapsulation, since each instance of `File`
-- doesn't need to have them.
local _standard, _release, _options;

--------------------
-- Helper functions:
--------------------
-- @name initGame
-- @description Sets the `game`.
local function initGame( t )
	t.game = DATA.getVideoGame( _standard[ 1 ] );

	if not t.game then
		return t:error( 'video game' );
	end
end

-- @name initRelease
-- @description Sets the `release` attribute.
local function initRelease( t )
	t.release = DATA.getVideoGameRelease( _release[ 1 ] );
end

-- @name initAlt
-- @description Set the `alt` attribute.
local function initAlt( t )
	t.alt = UTIL.trim( _standard[ 2 ] );
end

-- @name initOptions
-- @description Sets any possible options (`extension` and `description`).
local function initOptions( t )
	-- Extension:
	local extension = _options[ 'extension' ];
	t.extension  = UTIL.isString( extension ) and extension:lower() or 'png';

	-- Description:
	t.description = _options[ 'description' ];
end

-- @name init
-- @description Initializes the attributes of the File instance.
local function init( t )
	initGame( t );
	initRelease( t );
	initAlt( t );
	initOptions( t );
	return t;
end

--------------
-- File class:
--------------
-- @name File
-- @attr counter -> [static] Counts the number of File instances.
local File   = {};
File.__index = File;
File.counter = 0;

-- @name new         -> File constructor.
-- @attr id          -> The file id.
-- @attr flags       -> Control flags:
-- -- hasErrors -> Denotes if a file has errors. Used when parsing the gathered content.
-- @attr game        -> The game.
-- @attr release     -> Non card.
-- @attr alt         -> The alt value.
-- @attr extension   -> The file extension.
-- @attr description -> A short file description.
function File.new( cardGallery, std, rel, opt )
	_standard = std or {};
	_release  = rel or {};
	_options  = opt or {};

	File.counter   = File.counter + 1;
	local fileData = {
		id     = File.counter;
		parent = cardGallery;
		flags  = {
			hasErrors = false,
		},
	};

	return init( setmetatable( fileData, File ) );
end

-- @name error
-- @description Generate consistent error messages.
function File:error( parameter )
	self.flags.hasErrors = true;
	self.parent:error(
		('No %s found for file input number %d!'):format( parameter, self.id )
	)

	return self;
end

-- @name render
-- @description Renders the File by parsing the info gathered.
function File:render()
	if self.flags.hasErrors then
		return ('%s | File #%d'):format( VG_CARD_BACK, self.id );
	end

	-- Build file:
	local file = StringBuffer()
		:add( UTIL.getImgName() )
		:add( self.game.abbr )
		:add( self.parent:getRegion().index )
		:add( 'VG' )
		:add( self.release and self.release.abbr )
		:add( self.alt )
		:flush( '-' )
		:add( self.extension )
		:flush( '.' )
	;

	-- Build caption:
	local caption = StringBuffer()
		:add(
			UTIL.italic(
				UTIL.link(
					self.game.full
				)
			)
		)
		:add( self.description or self.release and self.release.full )
		:flush( '<br />' )
	;

	return ('%s | %s'):format( file:toString(), caption:toString() );
end

----------
-- Return:
----------
-- @exports The `File` class.
return File;
-- </pre>