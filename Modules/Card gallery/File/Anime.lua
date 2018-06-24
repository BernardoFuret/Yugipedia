-- <pre>
-- @name Card gallery/File/Anime
-- @description Card Gallery file class for anime entries.
-- @author [[User:Becasita]]
-- @contact [[User talk:Becasita]]

-- «
-- <CardName>-<region>-Anime-<Series>[-NC][-<alt>].<extension>
-- »

-- «
-- <Series>; <alt> :: <NonCard> // <option1>::<value1>; <optionN>::<valueN>
-- »

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
-- @attr rg           -> The region index.
-- @attr series       -> The series name.
-- @attr ser          -> The series code.
-- @attr release      -> Non card or card art.
-- @attr rel          -> NC or CA.
-- @attr alt          -> The alt value.
-- @attr extension    -> The file extension.
-- @attr description  -> A short file description.
function File.new( std, rel, opt, info )
	EXTERNAL = info;
	-- @attr _standard -> Contains the trimmed input args for the standard input {enum-like}.
	-- @attr _release  -> Contains the trimmed input arg for the release (OP|GC|CT|RP) {enum-like}.
	-- @attr _options  -> Contains the trimmed input args for the options {map-like}.
	File.counter    = File.counter + 1;
	local fileData  = {};
	fileData.errors = {};
	fileData.flags  = {
		exists = true,
	};
	fileData._standard = std or {};
	fileData._release  = rel or {};
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
		getImgName(), self.rg, 'Anime', self.ser:upper()
	};
	if self.rel then table.insert( file, self.rel:upper() ) end
	if self.alt then table.insert( file, self.alt ) end

	-- Build caption:
	local caption = {
		UTIL.italics( -- TODO: Don't italicize dab.
			UTIL.link( self.series.page, self.series.label )
		)
	};
	if self.description or self.release then table.insert( caption, self.description or self.release ) end

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

-- @name initSeries
-- @description Sets the «series» and «ser» attributes.
function File:initSeries()
	local series = self._standard[ 1 ];

	if series == '' then
		return self:error( 'series' );
	end

	self.series = DATA.getAnimeSeries( series );
	self.ser    = DATA.getAnimeSer( series );

	return self;
end

-- @name initRelease
-- @description Sets the «release» and «rel» attributes.
function File:initRelease()
	local release = self._release[ 1 ];

	self.release = DATA.getAnimeMangaRelease( release );
	self.rel     = DATA.getAnimeMangaRel( release );

	return self;
end

-- @name initAlt
-- @description Set the «alt» attribute.
function File:initAlt()
	self.alt = UTIL.trim( self._standard[ 2 ] );

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
		:initSeries()
		:initRelease()
		:initAlt()
		:initOptions()
	;
end

----------
-- Return:
----------
return File;
-- </pre>