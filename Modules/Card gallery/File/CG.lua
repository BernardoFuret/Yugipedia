-- <pre>
-- @name Card gallery/File/CG
-- @description Card Gallery file class for card game entries.
-- @author [[User:Becasita]]
-- @contact [[User talk:Becasita]]

-- «
-- <card number>; <set>; <rarity>; <edition>; <alt> :: <release> // <option1>::<value1>; <optionN>::<valueN>
-- »

----------------
-- Load modules:
----------------
local DATA = require( 'Module:Data' );
local UTIL = require( 'Module:Util' );

local StringBuffer = require( 'Module:StringBuffer' );
local getCardImageName = require( 'Module:Card image name' );

-------------
-- Constants:
-------------
local PAGENAME  = mw.title.getCurrentTitle().text;

local CARD_BACK_TCG    = 'Back-EN.png';
local CARD_BACK_JP     = 'Back-JP.png';
local CARD_BACK_AE     = 'Back-AE.png';
local CARD_BACK_KR     = 'Back-KR.png';
local LANGUAGE_ENGLISH = DATA.getLanguage( 'EN' );
local OFFICIAL_PROXY   = DATA.getRelease( 'OP' );

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
-- @description Boolean indicating if the file doesn't have an edition.
local function hasNoEdition( t )
	local rg = ( t.region or t.parent:getRegion() ).index;

	return rg == 'JP'
		or rg == 'JA'
		or rg == 'TC'
		or rg == 'SC'
		or (
			rg == 'KR'
			and t.setAbbr:match( 'RD/' )
		);
end

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

-- @name initNumber
-- @description Sets the `number` and `setAbbr` attributes.
local function initNumber( t )
	local cardNumber = _standard[ 1 ];

	if cardNumber == '' then
		return t:error( 'set abbreviation' );
	end

	if cardNumber and cardNumber:match( '^[/%w]-%-%w-$' ) then
		-- Input like «TLM-EN012».
		t.number  = cardNumber:upper();
		t.setAbbr = t.number:match( '^([/%w]-)%-%w-$' );
	else
		-- Input like «S1».
		t.number  = nil;
		t.setAbbr = cardNumber:upper();
	end
end

-- @name initSet
-- @description Sets the `set`, `setEn` and `setLn` attributes.
local function initSet( t )
	local set = _standard[ 2 ];

	if set == '' then
		return t:error( 'set name' );
	end

	t.set   = set;
	t.setEn = DATA.getName( set, LANGUAGE_ENGLISH ) or set; --TODO: either UTIL.trim or... check later
	t.setLn = DATA.getName( set, t.parent:getLanguage() );
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
			t.parent:error(
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

-- @name initRarity
-- @description Sets the `rarity` attribute.
local function initRarity( t )
	t.rarity = DATA.getRarity( _standard[ 3 ] );

	if not t.file and not t.flags.isOP and not t.rarity then
		return t:error( 'rarity' );
	end
end

-- @name initEdtion
-- @description Sets the `edition` attribute.
local function initEdition( t )
	local edition = _standard[ t.flags.isOP and 3 or 4 ];

	t.edition = DATA.getEdition( edition );

	if not t.file and not hasNoEdition( t ) and not t.edition then
		return t:error( 'edition' );
	end
end

-- @name initAlt
-- @description Set the «alt» attribute.
local function initAlt( t )
	local index = 5;
	if t.flags.isOP  then index = index - 1 end
	if not t.edition then index = index - 1 end

	t.alt = UTIL.trim( _standard[ index ] );
end

-- @name initOptions
-- @description Sets any possible options (`region`, `extension` and `description`).
local function initOptions( t )
	-- Region:
	t.region = DATA.getRegion( _options[ 'region' ] );

	if _options[ 'region' ] and not t.region then
		t.parent:error(
			('Invalid custom region value %s given for file input number %d!'):format(
				_options[ 'region' ],
				t.id
			)
		);
	end

	-- Extension:
	local extension = _options[ 'extension' ];
	t.extension  = UTIL.isString( extension ) and extension:lower() or 'png';

	-- Description:
	t.description = _options[ 'description' ];

	-- File:
	t.file = _options[ 'file' ];
end

-- @name init
-- @description Initializes the attributes of the File instance.
local function init( t )
	initOptions( t );
	initNumber( t );
	initSet( t );
	initReleases( t );
	initRarity( t );
	initEdition( t );
	initAlt( t );
	return t;
end

local function buildFile( t )
	local file = StringBuffer()
		:add( getCardImageName( PAGENAME ) )
		:add( t.setAbbr )
		:add( ( t.region or t.parent:getRegion() ).index )
		:add( t.rarity and t.rarity.abbr )
		:add( t.edition and t.edition.abbr )

	for _, release in ipairs( t.releases ) do
		file:add( release.abbr )
	end

	file
		:add( t.flags.isOP and OFFICIAL_PROXY.abbr )
		:add( t.alt )
		:flush( '-' )
		:add( t.extension )
		:flush( '.' )

	return file:toString()
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
-- -- hasErrors -> Denotes if a file has errors. Used when parsing the gathered content.
-- -- isOP      -> If it is an Official Proxy.
-- @attr number      -> The card number.
-- @attr set         -> The set name inputted.
-- @attr setEn       -> The English name for the set.
-- @attr setLn       -> The localized name for the set.
-- @attr setAbbr     -> The set abbreviation.
-- @attr rarity      -> The rarity.
-- @attr edition     -> The edition.
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
		return ('%s | File #%d'):format( getCardBack( self.parent:getRegion().index ), self.id );
	end

	-- Build file:
	local file = ( self.file or buildFile( self ) ):gsub( '[/:]' , '' )

	-- Build caption:
	local caption = StringBuffer()
		:add( self.number and UTIL.link( self.number ) )
		:add(
			self.rarity and ('(%s)'):format(
				UTIL.link( self.rarity.full, self.rarity.abbr )
			)
		)
		:flush( ' ' )
		:add( self.edition and UTIL.link( self.edition.full ) )

	for _, release in ipairs( self.releases ) do
		caption:add( UTIL.link( release.full ) );
	end

	caption
		:add( self.flags.isOP and UTIL.link( OFFICIAL_PROXY.full ) )
		:add(
			UTIL.italic(
				UTIL.link(
					self.set,
					self.setEn:match( '%(2011%)' ) and self.setEn -- or self.setEn:match( '%(series%)' )
				)
			)
		)
		:add( self.description )
		:flush( '<br />' )
	;

	return ('%s | %s'):format( file, caption:toString() );
end

----------
-- Return:
----------
-- @exports The `File` class.
return File;
-- </pre>