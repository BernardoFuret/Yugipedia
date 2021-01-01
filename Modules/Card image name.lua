-- <pre>
-- @name Card image name
-- @description Converts a card name to be used in the file name.
-- @see {{Card image name}}
-- @author [[User:Becasita]]
-- @contact [[User talk:Becasita]]

-------------------
-- Export variable:
-------------------
local CardImageName = {};

----------------
-- Load modules:
----------------
local DATA = require( 'Module:Data' );
local UTIL = require( 'Module:Util' );

---------------------
-- Utility functions:
---------------------
-- mw functions:
local split = mw.text.split;

--------------------
-- Module functions:
--------------------
-- @name getPageName
-- @description
local function getPageName( card )
	if not card then
		return '';
	end

	local smwName;
	local query = mw.smw.ask( {
		('[[%s]]'):format( card:gsub( '#', '' ) ),
		'?Page name=',
		limit     = 1,
		mainlabel = '-'
	} );

	if not query or UTIL.count( query ) == 0 or UTIL.count( query[1] ) == 0 then
		return card;
	end

	return query[ 1 ][ 1 ];
end

local function normalize( pagename )
	if not pagename then
		return '';
	end

	return (split( pagename, '%s*%(' )[ 1 ])
		:gsub( ' ' , '')
		:gsub( '%-', ''):gsub( '–' , '')
		:gsub( ',' , ''):gsub( '%.', ''):gsub( ':', '')
		:gsub( '\'', ''):gsub( '"' , ''):gsub( '&', '')
		:gsub( '%?', ''):gsub( '!' , ''):gsub( '@', '')
		:gsub( '%%', ''):gsub( '=' , '')
		:gsub( '%[', ''):gsub( '%]', '')
		:gsub( '<' , ''):gsub( '>' , '')
		:gsub( '/' , ''):gsub( '\\', '')
		:gsub( '☆' , ''):gsub( '・' , '')
	;
end

-- @name processArgs
-- @description Handles args (template call vs. module call).
local function processArgs( v )
	if UTIL.isString( v ) then
		-- If used through other modules.
		return { UTIL.trim( v ) };
	end

	return require( 'Module:Arguments' ).getArgs( v, {
		trim         = true,
		removeBlanks = true,
		parentOnly   = true
	} );
end

-- @name main
-- @description Main function to be invoked. Handles args and execution.
function CardImageName.main( frame )
	local PAGENAME  = mw.title.getCurrentTitle().text;
	local arg       = processArgs( frame )[ 1 ];
	local pagename  = arg and arg ~= PAGENAME and arg ~= split( PAGENAME, '%s*%(' )[ 1 ]
		and getPageName( arg )
		or PAGENAME
	;
	local imageName = normalize( pagename );
	return imageName;
end

----------
-- Return:
----------
return CardImageName;
-- </pre>