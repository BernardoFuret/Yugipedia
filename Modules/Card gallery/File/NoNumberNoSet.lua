-- <pre>
-- @name Card gallery/File/NoNumberNoSet
-- @description Card Gallery file class for weird card game entries with no number nor set.
-- @author [[User:Becasita]]
-- @contact [[User talk:Becasita]]

----------------
-- Load modules:
----------------
local DATA       = require( 'Module:Data' );
local UTIL       = require( 'Module:Util' );
local getImgName = require( 'Module:Card image name' ).main;

local EXTERNAL; -- External module info (the «INFO» from other modules).

--------------
-- File class:
--------------
-- @name File
-- @classAttr counter -> [static] Counts the number of File instances.
local File   = {};
File.__index = File;
File.counter = 0;

-- @name new          -> File constructor.
-- @attr flags        -> Control flags:
-- -- exists    => denotes if a file is to be printed.
-- -- isOP      => if it is an Official Proxy.
-- @attr rg           -> The region index.
-- @attr releases     -> The card releases.
-- @attr rels         -> The card releases abbreviations (OP|GC|CT|RP).
-- @attr alt          -> The alt value.
-- @attr extension    -> The file extension.
-- @attr description  -> A short file description.
function File.new( std, rel, opt, info )
	EXTERNAL = info;
	-- @attr _standard -> Contains the trimmed input args for the standard input {enum-like}.
	-- @attr _releases -> Contains the trimmed input arg for the releases (OP|GC|CT|RP) {enum-like}.
	-- @attr _options  -> Contains the trimmed input args for the options {map-like}.
	File.counter    = File.counter + 1;
	local fileData  = {};
	fileData.errors = {};
	fileData.flags  = {
		exists    = true,
		isOP      = false
	};
	fileData._standard = std or {};
	fileData._releases = rel or {};
	fileData._options  = opt or {};

	return setmetatable( fileData, File ):init();
end

-- @name __tostring
-- @description [metamethod] Renders the File.
function File:__tostring()
	if not self.flags.exists then
		return '';
	end

	-- Build file:
	local file = {
		getImgName(), self.rg
	};
	for _, rel in ipairs( self.rels ) do
		table.insert( file, rel );
	end
	if self.flags.isOP then table.insert( file, 'OP' ) end
	if self.alt then table.insert( file, self.alt ) end

	-- Build caption:
	local caption = {};
	for _, release in ipairs( self.releases ) do
		table.insert( caption, UTIL.link( release ) );
	end
	if self.flags.isOP then table.insert( caption, UTIL.link( 'Official Proxy' ) ) end
	if self.description then table.insert( caption, self.description ) end

	-- Stringify:
	local fileString    = ('%s.%s'):format( table.concat( file, '-' ), self.extension );
	local captionString = table.concat( caption, '<br />' );
	
	-- Return concatenation:
	return ('%s | %s'):format( fileString, captionString );
end

-- @name error
-- @description Generate consistent error messages.
function File:error( parameter )
	self.flags.exists = false;
	table.insert( self.errors, ('No %s given for file input number %d!'):format( parameter, File.counter ) );

	return self;
end

-- @name initRegion
-- @description Sets the «rg» attribute.
function File:initRg()
	self.rg = EXTERNAL.rg:upper();

	return self;
end

-- @name initReleases
-- @description Sets the «releases» and «rels» attributes.
function File:initReleases()
	local releasesAsKeys = {}; -- Unsorted; each release is a key, to prevent duplicates.

	for _, value in ipairs( self._releases ) do
		local release = DATA.getRelease( value );
		if release then
			releasesAsKeys[ release ] = true;
		else
			table.insert(
				self.errors,
				('Invalid release value %s given for file input number %d!'):format( value, File.counter )
			);
		end
	end

	local releases = {};

	for releaseAsKey in pairs( releasesAsKeys ) do
		table.insert( releases, releaseAsKey );
	end

	table.sort( releases ); 

	self.releases = {};
	self.rels     = {};

	for _, release in ipairs( releases ) do
		local rel = DATA.getRel( release ):upper();
		self.flags.isOP = (
			rel == 'OP'
			or
			table.insert( self.releases, release ) -- Insert the release name (this returns nil).
			or
			table.insert( self.rels, rel ) -- Insert the release abbreviation (this returns nil).
			or
			self.flags.isOP
		);
	end

	return self;
end

-- @name initAlt
-- @description Set the «alt» attribute.
function File:initAlt()
	self.alt = UTIL.trim( self._standard[ 1 ] );

	return self;
end

-- @name initOptions
-- @description Sets the file extension.
function File:initOptions()
	-- Extension:
	local extension = self._options[ 'extension' ];
	self.extension  = UTIL.isString( extension ) and extension:lower() or 'png';

	-- Description:
	self.description = self._options[ 'description' ];

	return self;
end

-- @name init
-- @description Initializes the attributes of the File instance.
function File:init()
	return self
		:initRg()
		:initReleases()
		:initAlt()
		:initOptions()
	;
end

----------
-- Return:
----------
return File;
-- </pre>