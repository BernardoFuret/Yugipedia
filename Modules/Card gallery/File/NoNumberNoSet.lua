-- <pre>
-- @name Card gallery/File/NoNumberNoSet
-- @description Card Gallery file class for weird card game entries with no number nor set.
-- @author [[User:Becasita]]
-- @contact [[User talk:Becasita]]

----------------
-- Load modules:
----------------
local DATA = require( 'Module:Data' );
local UTIL = require( 'Module:Util' );

local StringBuffer = require( 'Module:StringBuffer' );

-------------
-- Constants:
-------------
local CARD_BACK_TCG  = 'Back-EN.png';
local CARD_BACK_JP   = 'Back-JP.png';
local CARD_BACK_AE   = 'Back-AE.png';
local CARD_BACK_KR   = 'Back-KR.png';
local OFFICIAL_PROXY = DATA.getRelease( 'OP' );

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
local _standard, _releases, _options;

--------------------
-- Helper functions:
--------------------
-- @description Decides what kind of card backing to present.
local function getCardBack( rg )
	return (
		( rg == 'JP' or rg == 'JA' or rg == 'TC' ) and CARD_BACK_JP
		or
		rg == 'AE' and CARD_BACK_AE
		or
		rg == 'KR' and CARD_BACK_KR
		or
		CARD_BACK_TCG
	);
end

-- @name initReleases
-- @description Sets the `releases` attribute.
local function initReleases( t )
	local releasesAsKeys = {}; -- Unsorted; each release is a key, to prevent duplicates.
	for _, value in ipairs( _releases ) do
		local release = DATA.getRelease( value );
		if release then
			releasesAsKeys[ release.full ] = release;
		else
			t:error(
				('Invalid release value %s given for file input number %d!'):format( value, t.id )
			);
		end
	end

	local releases = {};
	for releaseAsKey in pairs( releasesAsKeys ) do
		table.insert( releases, releaseAsKey );
	end
	table.sort( releases ); 

	t.releases = {};
	for _, releaseFull in ipairs( releases ) do
		t.flags.isOP = (
			releaseFull == OFFICIAL_PROXY.full
			or
			table.insert( t.releases, releasesAsKeys[ releaseFull ] )
			or
			t.flags.isOP
		);
	end
end

-- @name initAlt
-- @description Set the `alt` attribute.
local function initAlt( t )
	t.alt = UTIL.trim( _standard[ 1 ] );
end

-- @name initOptions
-- @description Sets any possible options (`extension` and `description`).
local function initOptions( t )
	-- Extension:
	local extension = _options[ 'extension' ];
	t.extension     = UTIL.isString( extension ) and extension:lower() or 'png';

	-- Description:
	t.description = _options[ 'description' ];
end

-- @name init
-- @description Initializes the attributes of the File instance.
local function init( t )
	initReleases( t );
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
-- @attr flags       -> Control flags:
-- -- hasErrors -> Senotes if a file has errors. Used when parsing the gathered content.
-- -- isOP      -> If it is an Official Proxy.
-- @attr releases    -> The card releases.
-- @attr alt         -> The alt value.
-- @attr extension   -> The file extension.
-- @attr description -> A short file description.
function File.new( cardGallery, std, rel, opt )
	_standard = std or {};
	_releases = rel or {};
	_options  = opt or {};

	File.counter   = File.counter + 1;
	local fileData = {
		id     = File.counter;
		parent = cardGallery;
		flags  = {
			hasErrors = false,
			isOP      = nil,
		},
	};

	return init( setmetatable( fileData, File ) );
end

-- @name error
-- @description Generate consistent error messages.
function File:error( message )
	self.flags.hasErrors = true;
	self.parent:error( message );

	return self;
end

-- @name render
-- @description Renders the File by parsing the info gathered.
function File:render()
	if self.flags.hasErrors then
		return ('%s | File #%d'):format( getCardBack( self.parent:getRegion().index ), self.id );
	end

	-- Build file:
	local file = StringBuffer()
		:add( UTIL.getImgName() )
		:add( self.parent:getRegion().index )
	;

	for _, release in ipairs( self.releases ) do
		file:add( release.abbr );
	end

	file
		:add( self.flags.isOP and OFFICIAL_PROXY.abbr )
		:add( self.alt )
		:flush( '-' )
		:add( self.extension )
		:flush( '.' )
	;
	
	-- Build caption:
	local caption = StringBuffer();
	
	for _, release in ipairs( self.releases ) do
		caption:add( UTIL.link( release.full ) );
	end

	caption
		:add( self.flags.isOP and UTIL.link( OFFICIAL_PROXY.full ) )
		:add( self.description )
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