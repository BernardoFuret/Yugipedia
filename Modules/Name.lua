-- <pre>
-- @name Card name
-- @description Get the localized name of a card, set or character.
-- @see {{Card name}}
-- @author [[User:Becasita]]
-- @contact [[User talk:Becasita]]

-------------------
-- Export variable:
-------------------
local Name = {};

----------------
-- Load modules:
----------------
local DATA    = require( 'Module:Data' );
local UTIL    = require( 'Module:Util' );
local getArgs = require( 'Module:Arguments' ).getArgs;

---------------------
-- Utility functions:
---------------------
local function _error( message )
	local e = mw.html.create( 'div' )
		:tag( 'strong' ):addClass( 'error' )
			:wikitext( ('Error: %s'):format( message ) )
		:done()
	:allDone();
	local cat = '[[Category:Pages with script errors]][[Category:((Card name)) transclusions to be checked]]'; -- TODO check this, for internal use vs. template.
	return ('%s\n%s'):format( tostring( e ), cat );
end

--------------------
-- Module functions:
--------------------
-- @name execute
-- @description Fetches the localized name for «name» in «language».
local function execute( page, language )
	if not page or not language then
		return '';
	end
	local query = mw.smw.ask( {
		('[[%s]]'):format( page:gsub( '#', '' ) ),
		('?%s name='):format( language ),
		limit     = 1,
		mainlabel = '-'
	} );
	if not query or UTIL.count( query ) == 0 or UTIL.count( query[1] ) == 0 then
		return '';
	end
	return query[1][1];
end

-- @name processArgs
-- @description Handles args (template call vs. module call).
local function processArgs( v, ln )
	if UTIL.isString( v ) then
		-- If used through other modules.
		return { UTIL.trim( v ), UTIL.trim( ln ) };
	end

	return getArgs( v, {
		trim         = true,
		removeBlanks = true,
		parentOnly   = true
	} );
end

-- @name main
-- @description Main function to be invoked. Handles args and execution.
function Name.main( frame, ln )
	if not mw.smw then
		return _error( 'mw.smw module not found!' );
	end

	local args = processArgs( frame, ln );
	
	return execute( args[ 1 ], DATA.getLanguage( args[ 2 ] or 'en' ) );
end

----------
-- Return:
----------
return Name;
-- </pre>