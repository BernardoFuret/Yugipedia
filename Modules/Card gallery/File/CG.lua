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
local DATA       = require( 'Module:Data' );
local UTIL       = require( 'Module:Util' );
local getName    = require( 'Module:Name' ).main;
local getImgName = require( 'Module:Card image name' ).main;

--------------
-- File class:
--------------
-- @name File
-- @classAttr counter -> [static] Counts the number of File instances.
local File   = {};
File.__index = File;
File.counter = 0;

-- @name new          -> File constructor.
-- @attr DATA         -> External data (the «_D» from other modules).
-- @attr flags        -> Control flags:
-- -- exists    => denotes if a file is to be printed.
-- -- noEdition => if it is a Japanese or Chinese print; thus, no edition (except DT ones).
-- -- isOP      => if it is an Official Proxy.
-- @attr number       -> The card number.
-- @attr rg           -> The region index.
-- @attr set          -> The set name inputted.
-- @attr setEn        -> The English name for the set.
-- @attr setLn        -> The localized name for the set.
-- @attr setAbbr      -> The set abbreviation.
-- @attr rarity       -> The rarity name.
-- @attr r            -> The rarity abbreviation.
-- @attr edition      -> The full edition.
-- @attr ed           -> The edition abbreviation.
-- @attr releases     -> The card releases.
-- @attr rels         -> The card releases abbreviations (OP|GC|CT|RP).
-- @attr alt          -> The alt value.
-- @attr extension    -> The file extension.
-- @attr description  -> A short file description.
function File.new( std, rel, opt, data )
	-- @attr _standard -> Contains the trimmed input args for the standard input {enum-like}.
	-- @attr _releases -> Contains the trimmed input args for the releases (OP|GC|CT|RP) {enum-like}.
	-- @attr _options  -> Contains the trimmed input args for the options {map-like}.
	File.counter    = File.counter + 1;
	local fileData  = {};
	fileData.DATA   = data;
	fileData.errors = {};
	fileData.flags  = {
		exists    = true,
		noEdition = false,
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
		getImgName(), self.setAbbr, self.rg
	};
	if self.r  then table.insert( file, self.r  ) end
	if self.ed then table.insert( file, self.ed ) end
	for _, rel in ipairs( self.rels ) do
		table.insert( file, rel );
	end
	if self.flags.isOP then table.insert( file, 'OP' ) end
	if self.alt then table.insert( file, self.alt ) end

	-- Build caption: (this might get better implementation in the future)
	local caption = {};
	local temp1st = {};
	if self.number then table.insert( temp1st, UTIL.link( self.number ) ) end
	if self.rarity then
		table.insert(
			temp1st,
			('(%s)'):format( UTIL.link( self.rarity, self.r ) )
		);
	end
	if UTIL.count( temp1st ) ~= 0 then
		table.insert( caption, table.concat( temp1st, ' ' ) );
	end
	if self.edition then table.insert( caption, UTIL.link( self.edition ) ) end
	for _, release in ipairs( self.releases ) do
		table.insert( caption, UTIL.link( release ) );
	end
	if self.flags.isOP then table.insert( caption, UTIL.link( 'Official Proxy' ) ) end
	table.insert(
		caption,
		UTIL.italics(
			UTIL.link(
				self.set,
				self.setEn:match( '%(2011%)' ) and self.setEn -- or self.setEn:match( '%(series%)' )
			)
		)
	);
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
	self.rg = self.DATA.rg:upper();
	self.flags.noEdition = self.rg == 'JP' or self.rg == 'JA' or self.rg == 'TC';

	return self;
end

-- @name initNumber
-- @description Sets the «number» and «setAbbr» attributes.
function File:initNumber()
	local cardNumber = self._standard[ 1 ];

	if cardNumber == '' then
		return self:error( 'set abbreviation' );
	end

	if cardNumber and cardNumber:match( '^%w-%-%w-$' ) then
		-- Input like «TLM-EN012».
		self.number  = cardNumber:upper();
		self.setAbbr = self.number:match( '^(%w-)%-%w-$' );
	else
		-- Input like «S1».
		self.number  = nil;
		self.setAbbr = cardNumber:upper();
	end

	return self;
end

-- @name initSet
-- @description Sets the «set», «setEn» and «setLn» attributes.
function File:initSet()
	local set = self._standard[ 2 ];

	if set == '' then
		return self:error( 'set name' );
	end

	self.set   = set;
	self.setEn = getName( set ) or set;
	self.setLn = getName( set, self.DATA.language );

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

-- @name initRarity
-- @description Sets the «rarity» and «r» attributes.
function File:initRarity()
	local rarity = not self.flags.isOP and self._standard[ 3 ];

	if not self.flags.isOP and rarity == '' then
		return self:error( 'rarity' );
	end

	self.rarity = DATA.getRarity( rarity );
	self.r      = self.rarity and DATA.getR( self.rarity );

	return self;
end

-- @name initEdtion
-- @description Sets the «edition» and «ed» attributes.
function File:initEdition()
	local edition = self._standard[ self.flags.isOP and 3 or 4 ];

	self.edition = DATA.getEdition( edition );
	self.ed      = self.edition and DATA.getEd( self.edition ):upper();

	if not self.flags.noEdition and not self.edition then
		return self:error( 'edition' );
	end

	return self;
end

-- @name initAlt
-- @description Set the «alt» attribute.
function File:initAlt()
	local index = 5;
	if self.flags.isOP then index = index - 1 end
	if not self.ed     then index = index - 1 end

	self.alt = UTIL.trim( self._standard[ index ] );

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
		:initNumber()
		:initSet()
		:initReleases()
		:initRarity()
		:initEdition()
		:initAlt()
		:initOptions()
	;
end

----------
-- Return:
----------
return File;
-- </pre>