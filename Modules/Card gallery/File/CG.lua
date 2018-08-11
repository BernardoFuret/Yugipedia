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

-------------
-- Constants:
-------------
local CARD_BACK = 'Back-EN.png';
local OFFICIAL_PROXY = DATA.getRelease( 'OP' );

---------------
-- Helper vars:
---------------
-- These variables are only used by the init functions.
-- Therefore, even though they are re-assigned every time
-- a new instance is created (through `new()`), there's no
-- problem, because their useful lifetime is only inside
-- that function very function.
-- This way, having them here kinda as static variables,
-- supports encapsulation, since each instance of `File`
-- doesn't need to have them.
local _standard, _releases, _options;

--------------------
-- Helper functions:
--------------------
-- @description Boolean indicating if the file doesn't have an edition.
local function hasNoEdition( t )
	local rg = t.parent:getRegion().index;
	return rg == 'JP' or rg == 'JA' or rg == 'TC';
end

-- @name initNumber
-- @description Sets the `number` and `setAbbr` attributes.
local function initNumber( t )
	local cardNumber = _standard[ 1 ];

	if cardNumber == '' then
		return t:error( 'set abbreviation' );
	end

	if cardNumber and cardNumber:match( '^%w-%-%w-$' ) then
		-- Input like «TLM-EN012».
		t.number  = cardNumber:upper();
		t.setAbbr = t.number:match( '^(%w-)%-%w-$' );
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
	t.setEn = UTIL.getName( set ) or set; --TODO: either UTIL.trim or... check later
	t.setLn = UTIL.getName( set, t.parent:getLanguage().index );
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
	local rarity = not t.flags.isOP and _standard[ 3 ];

	if not t.flags.isOP and rarity == '' then
		return t:error( 'rarity' );
	end

	t.rarity = DATA.getRarity( rarity ); -- TODO: error in case there's no rarity found.
end

-- @name initEdtion
-- @description Sets the `edition` attribute.
local function initEdition( t )
	local edition = _standard[ t.flags.isOP and 3 or 4 ];

	t.edition = DATA.getEdition( edition );

	if not hasNoEdition( t ) and not t.edition then
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
	initNumber( t );
	initSet( t );
	initReleases( t );
	initRarity( t );
	initEdition( t );
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
		('No %s given for file input number %d!'):format( parameter, self.id )
	)

	return self;
end

-- @name render
-- @description Renders the File by parsing the info gathered.
function File:render()
	if self.flags.hasErrors then
		return ('%s | File #%d'):format( CARD_BACK, self.id );
	end

	-- Build file:
	local file = UTIL.newStringBuffer()
		:add( UTIL.getImgName() )
		:add( self.setAbbr )
		:add( self.parent:getRegion().index )
		:add( self.rarity and self.rarity.abbr )
		:add( self.edition and self.edition.abbr )
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
	local caption = UTIL.newStringBuffer()
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
	
	return ('%s | %s'):format( file:toString(), caption:toString() );
end

----------
-- Return:
----------
-- @exports The `File` class.
return File;
-- </pre>