--  <pre>
--  Module for {{Card type}}.
--  Can also be used through other modules.
--  @@@ for ideas. 
local CardType = {};

---------------------
--  External modules:
---------------------
local getArgs = require( 'Module:Arguments' ).getArgs;

---------
--  Data:
---------
local data             = mw.loadData( 'Module:Card type/data' );
local FAQtypes         = data.FAQtypes;
local abilities        = data.abilities;
local monsterCardTypes = data.monsterCardTypes;

------------------
--  Aux functions:
------------------
--  mw functions:
local split = mw.text.split;

--  Trim function:
--  Trims white space from front and tail of string.
--  If the input is only white space, returns nil.
function _trim( s )
	if s and not s:match( '^%s*$' ) then
		return mw.text.trim( s ); -- If not nil nor empty.
	end
end

--  Link function:
--  If a string is passed, links it;
--  uses a label, when given.
--  If a table is passed, links every instance of it;
--  uses a table of labels, respectively for each entry, when given.
function _link( v, ... )
	local labels = type( ... or nil ) == 'table' and ... or  { ... };  --  Make sure it's a table.
	local function __link( v, label )
		return ('[[%s|%s]]'):format( v, (_trim( label ) or split( v, ' %(' )[1]) );
	end
	if type( v ) == 'string' then
		return __link( v, labels[1] );
	elseif type( v ) == 'table' then
		local t = {};
		for key, value in ipairs( v ) do
			table.insert( t, __link( value, labels[key] ) );
		end
		return t;
	else
		return v; -- @@@ error()
	end
end

--  Unlink function:
--  If a string is passed, unlinks
--  and returns the page name (not the label, unless «getLabel»).
--  If a table is passed, unlinks every instance of it
--  and returns the table with the page names for each respective entry.
function _unlink( v, getLabel )
	local function __unlink( v, getLabel )
		return _trim( v ) and (getLabel and v:match( '%[%[:?.-|(.-)]]' ) or v:match( '%[%[:?(.-)[|%]]' )) or _trim( v );
	end
	if type( v ) == 'string' then
		return __unlink( v, getLabel );
	elseif type( v ) == 'table' then
		local t = {};
		for key, value in ipairs( v ) do
			table.insert( t, __unlink( value, getLabel ) );
		end
		return t;
	else
		return v; -- @@@ error()
	end
end

--  Table count function:
--  Given a table, counts how many valuee it has.
function _count( t ) -- @@@ error() for wrong type()
	local counter = 0;
	for key, value in pairs( t ) do
		counter = counter + 1;
	end
	return counter;
end

--  Categories function:
--  Receives categories' names.
--  Returns the linked categories.
function _categories( ... )
	local categories = type( ... or nil ) == 'table' and ... or  { ... };  --  Make sure it's a table.
	local t = {};
	for _, category in pairs( categories ) do
		table.insert( t, ('[[Category:%s]]'):format( category ) );
	end
	return table.concat( t, '\n' );
end
	
--  Error function:
--  Generates error messages and categories.
function _error( message )
	local _error = mw.html.create( 'div' )
		:tag( 'strong' ):addClass( 'error' )
			:wikitext( ('Error: %s'):format( message ) ):done()
	:allDone();
	local cat = _categories( 'Pages with script errors', '((Card type)) transclusions to be checked' );
	return ('%s\n%s'):format( tostring( _error ), cat ); -- @@@ or error()
end

function _redirect( card )
	local pagename = _trim( _show( card, 'Page name' ) );
	return pagename ~= card and pagename;
end

--  Show function:
--  Similar to #show parser function.
--  Returns string with the results.
function _show( page, property, link )
	--  At this point, SMW is enabled and «page» is formatted properly (as pagename).
	local result =  mw.smw.ask{
		('[[%s]]'):format( page ),
		('?%s='):format( property ),
		mainlabel = '-'
	};
	
	if not result or _count( result ) == 0 or _count( result[1] ) == 0 then
		return;
	end
	
	local show = type( result[1][1] ) == 'string' and result[1] or result[1][1];

	return table.concat( link and show or _unlink( show ), '\n' );
end

-------------------
--  Main functions:
-------------------
--  Monster card type function:
--  Only one allowed per card.
--  «Pendulum» is not included here.
function _monsterCardType( t )
	for key, value in ipairs( t ) do
		if monsterCardTypes[_trim( value:lower():gsub( ' monster', '' ) )] then
			return value;
		end
	end
end

--  Ability function:
--  Only one allowed per card.
function _ability( t )
	for key, value in ipairs( t ) do
		if abilities[_trim( value:lower():gsub( ' monster', '' ) )] then
			return value;
		end
	end
end

--  Effect function:
--  Misleading name; checks for Effect/Normal Monster. 
function _effect( t )
	for key, value in ipairs( t ) do
		if value:match('Effect') then
			return 'Effect Monster';
		elseif value:match('Normal') then
			return 'Normal Monster';
		end
	end
end

--  Full card type function (for monsters only):
--  Given every value a monster can have,
--  Concatenates them and returns.
function _full( pendulum, monsterCardType, tuner, ability, effect )
	--  Effect <Ability> Tuner <Monster card type> Pendulum
	--  Build backwards.
	local cardType = {};
	local notLast  = false;
	if pendulum then
		table.insert( cardType, 1, _link( 'Pendulum Monster' ) );
		notLast = true;
	end
	if monsterCardType then
		table.insert( cardType, 1, _link( monsterCardType, notLast and monsterCardType:gsub( ' [Mm]onster', '' ) ) );
		notLast = true;
	end
	if tuner then
		table.insert( cardType, 1, _link( 'Tuner monster' , notLast and 'Tuner' ) );
		notLast = true;
	end
	if ability then
		table.insert( cardType, 1, _link( ability, notLast and ability:gsub( ' [Mm]onster', '' ) ) );
		notLast = true;
	end
	if effect and not ability then
		table.insert( cardType, 1, _link( effect, notLast and effect:gsub( ' [Mm]onster', '' ) ) );
	end

	return table.concat( cardType, ' ' ) -- @@@ [[Tuner Synchro]], unlink.
end

--  Monster card function:
--  Fetches monster card type, ability, Pendulum, Tuner, Token.
--  Prints full card type.
function _monster( card )
	local primary = _show( card, 'Primary type' );
	if not _trim( primary ) then
		return card:match( '(original)' ) and _link( 'Monster Card' ) --  For Egyptian Gods.
			or _error( 'On «_monster»; No primary type available!' );
	end
	if primary:match( 'Token' ) then
		return _link( 'Monster Token', 'Token' );
	end
	
	--  Primary type:
	local primaryTable    = split( primary, '\n' );
	local monsterCardType = _monsterCardType( primaryTable );
	local pendulum        = primary:match( 'Pendulum' );
	local effect          = _effect( primaryTable );
	
	--  Secondary type:
	local secondary      = _trim( _show( card, 'Secondary type' ) );
	local secondaryTable = secondary and split( secondary, '\n' );
	local ability        = secondary and _ability( secondaryTable );
	local tuner          = secondary and secondary:match( 'Tuner' );
	
	--  Full monster card type:
	return _full( pendulum, monsterCardType, tuner, ability, effect );
end

--  Spell/Trap card function:
--  Fetches property,
--  Prints full card type.
function _spellTrap( card, ST )
	local _property = _show( card, 'Property' );
	if not _trim( _property ) then
		return _error( 'On «_spellTrap»; No property available!' )
	end
	
	--return ('%s %s'):format( _link( table.concat( { _property, ST }, ' ' ), _property ), _link( ST ) );
	return ('%s %s'):format( _link( _property, _property:gsub(ST..' Card', '') ), _link( ST ) );
end

function _nonGame( t )
	if _count( t ) > 1 then 
		return _error( 'On «_nonGame»; Too many card types!' )
	elseif ( t[ 1 ] or '' ):match( '?' ) then
		return '???'
	else
		return _link( FAQtypes[t[1]:lower():gsub( ' card', '' )] ) or _error( 'On «_nonGame»; Non-standard card type!' );
	end
end

--  Type function:
--  Processes the card, to figure out the actual card type:
--  Monster, Spell, Trap, other.
--  (where «other» can be Tip, Strategy, etc..) 
function _type( card )
	local cardType = _show( card, 'Card type' );
	if not _trim( cardType ) then
		return _error( 'On «_type»; No card type available!' );
	end
	
	cardType = cardType:lower();
	if cardType:match( 'monster' ) then
		return _monster( card );
	elseif cardType:match( 'spell' ) then
		return _spellTrap( card, 'Spell' );
	elseif cardType:match( 'trap' ) then
		return _spellTrap( card, 'Trap' );
	else
		return _nonGame( split( cardType, '\n' ) );
	end
end

--  _main function:
--  Processes a string, the card name.
--  Looks for errors (if empty).
--  Else, figures the card type.
function _main( s )
	local _card = _unlink( s );
	if not _card then
		return _error( 'Empty value!' );
	end
	local _page = _card:gsub( '#', '' );
	local redirect = _redirect( _page ); -- @@@cat + text
	
	if not _trim( _show( _page, 'Page name' ) ) then
		-- If the page doesn't exist, basically. @@@ Fails for cases where SMW is down.
		return _categories( '((Card type)) transclusions to be checked' );
	end
	return _type( _page );--@@@ function _class( _page )
end

--  Main function:
--  Processes input;
--  if it's a frame (used externally, through {{Card type}},
--  fetch value, throws errors regarding the number of arguments; Then sends it to _main.
--  Else, (if it's a string (should be, if used through other modules!))
--  Send it to _main directly.
function CardType.main( frame )
	if not mw.smw then
		return _error( 'mw.smw module not found' );
	end
	if type( frame ) == 'string' then
		--  If used through other modules.
		return _main( frame );
	end
	--  «args» for the args table;
	--  «argsN» for the number or arguments;
	local args = getArgs( frame, { trim = true, parentOnly = true } ); -- Args table.
	
	local argsN = _count( args );
	if argsN > 1 then
		return _error( 'Too many arguments! Use only one!' );
	elseif argsN < 1 then
		return _error( 'No arguments! Use one!' );
	end
	
	return _main( args[1] );
end

return CardType;
--  </pre>
