-- <pre>
-- @name Card gallery/File
-- @description Card Gallery file factory. Decides which type of file to create.
-- @author [[User:Becasita]]
-- @contact [[User talk:Becasita]]

-------------------
-- Export variable:
------------------
local File = {};

----------------
-- Load modules:
----------------
local UTIL = require( 'Module:Util' );

---------------------
-- Utility functions:
---------------------
-- mw functions:
local  split = mw.text.split;
local gsplit = mw.text.gsplit;

--------------------
-- Module functions:
--------------------
-- @name buildStandard
-- @description Builds a "standard" object from the "standard" part of the input entry.
local function buildStandard( arg )
	local standard = {};

	if not UTIL.trim( arg ) then
		return standard;
	end

	for value in gsplit( arg, '%s*;%s*' ) do
		if value then
			table.insert( standard, UTIL.trim( value ) or '' );
		end
	end

	return standard;
end

-- @name buildReleases
-- @description Builds a "releases" object from the "releases" part of the input entry.
local function buildReleases( arg )
	local releases = {};

	if not UTIL.trim( arg ) then
		return releases;
	end

	for value in gsplit( arg, '%s*,%s*' ) do
		if value then
			table.insert( releases, UTIL.trim( value ) or '' );
		end
	end

	return releases;
end

-- @name buildOptions
-- @description Builds an "options" object from the "options" part of the input entry.
local function buildOptions( arg )
	local options = {};

	if not UTIL.trim( arg ) then
		return options;
	end

	for option in gsplit( arg, '%s*;%s*' ) do
		local opt = UTIL.trim( option );
		if opt then
			local optTemp = split( opt, '%s*::%s*' );
			local optName  = UTIL.trim( optTemp[ 1 ] );
			local optValue = UTIL.trim( optTemp[ 2 ] );
			if optName and optValue then
				options[ optName ] = optValue;
			end
		end
	end

	return options;
end

-- @name splitEntry
-- @description Splits an input entry into the standard values, the releases and the options.
local function splitEntry( entry )
	if not UTIL.trim( entry ) then
		return {}, {}, {};
	end

	local temp1   = split( entry, '//' );
	local tempOpt = table.concat( temp1, '//', 2 );
	local temp2   = split( temp1[ 1 ], '%s*::%s*' );
	local tempRel = temp2[ 2 ];
	local tempStd = temp2[ 1 ];

	local standard = buildStandard( tempStd );
	local releases = buildReleases( tempRel );
	local options  = buildOptions( tempOpt );

	return standard, releases, options;
end

-- @name factory
-- @description Decides which kind of file to instantiate.
function File.factory( entry, info )
	local standard, releases, options = splitEntry( entry );

	local countStd = UTIL.count( standard );
	local countRel = UTIL.count( releases );
	local countOpt = UTIL.count( options );

	local Module = '';

	if countStd == 0 and countRel == 0 and countOpt == 0 then
		-- Not enough info to even try to build. TODO: barricade to delete this.
		return nil;
	elseif info.type == 'Anime' then
		Module = 'Anime'; 
	elseif info.type == 'Manga' then
		Module = 'Manga'; 
	elseif info.type == 'Video games' then
		Module = 'VG';
	elseif info.type == 'Other' then
		Module = ''; -- TODO
	else
		-- No info.type; defaults to the card game entries:
		if countStd < 2 and countRel > 0 then
			Module = 'NoNumberNoSet'; --Mirror Force and OEPD from the arc-v (assumes there's no edition, even for DT ones (they don't exist)).
		else
			Module = 'CG';
		end
	end

	return require( 'Module:Card gallery/File/' .. Module ).new( standard, releases, options, info );
end

----------
-- Return:
----------
return File;
-- </pre>