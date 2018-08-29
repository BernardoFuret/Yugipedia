-- <pre>
-- @name Util
-- @description Holds commonly used simple functions.
-- @author [[User:Becasita]]
-- @contact [[User talk:Becasita]]

-------------------
-- Export variable:
-------------------
-- @export
local U = {};

-------------
-- Functions:
-------------
-- mw functions:
local mwTextSplit = mw.text.split;
local mwTextTrim = mw.text.trim;

-- @name bold
-- @description Renders bold wikitext markup.
function U.bold( s )
	return ("'''%s'''"):format( s )
end

-- @name italic
-- @description Renders italics wikitext markup.
function U.italic( s )
	return ("''%s''"):format( s )
end

-- @name italicButDab
-- @description Renders italics wikitext markup, except for the dab.
-- Also normalizes the space between the dab and the rest.
function U.italicNoDab( s )
	local dab = U.getDab( s );
	local noDab = U.removeDab( s )
	return table.concat( { ("''%s''"):format( noDab ), dab }, ' ' );
end

-- @name trim
-- @description Trims white space from front and tail of string. Returns nil if only whitespace.
-- @see [[mw:Extension:Scribunto/Lua reference manual#mw.text.trim]]
function U.trim( s )
	if s and not s:match( '^%s*$' ) then
		return mwTextTrim( s );
	end
end

-- @name count
-- @description Counts the number of elements in a table.
function U.count( t )
	local counter = 0;
	for key, value in pairs( t ) do
		counter = counter + 1;
	end
	return counter;
end

-- @name link
-- @description Creates a wikitext link.
function U.link( page, label )
	return ('[[%s|%s]]'):format(
		page:gsub( '#', '' ),
		label or U.removeDab( page )
	);
end

-- @name getDab
-- @description Gets the dab text of a title, if it has dab.
function U.getDab( title )
	return title:match( '%(([^%(]*)%)%s*$' ) or '';
end

-- @name removeDab
-- @description Removes the dab text of a title.
function U.removeDab( title )
	return title:gsub( '%s*%(([^%(]*)%)%s*$', '' );
end

-- @name isSomething
-- @description Meta-function for type checkers.
local function isSomething( toCompare, compareTo )
	return type( toCompare ) == type( compareTo );
end

-- @name isBoolean
function U.isBoolean( v )
	return isSomething( v, true );
end

-- @name isFunction
function U.isFunction( v )
	return isSomething( v, function() end );
end

-- @name isNil
function U.isNil( v )
	return isSomething( v, nil );
end

-- @name isNumber
function U.isNumber( v )
	return isSomething( v, 1 );
end

-- @name isString
function U.isString( v )
	return isSomething( v, '' );
end

-- @name isTable
function U.isTable( v )
	return isSomething( v, {} );
end

-- @name isEmpty
function U.isEmpty( v )
	return (
		U.isString( v ) and mwTextTrim( v ) == ''
		or
		U.isTable( v ) and U.count( v ) == 0
	);
end

-- @name validate
-- @description Asserts if a value has content.
--[[function U.validate( v )
	-- If boolean, function or nil, just return them: 
	if U.isBoolean( v ) or U.isFunction( v ) or U.isNil( v ) then return v end
	-- If number, it is accepted if it's not 0: 
	if U.isNumber( v ) then return v ~= 0 and v end
	-- If string, it is accepted if it's not the empty string:
	if U.isString( v ) then return mwTextTrim( v ) ~= '' and v end
	-- If table, it is accepted if it has elements:
	if U.isTable( v ) then return  U.count( v ) ~= 0 and v end
end--]]

-- @param ln A language index.
-- @description
function U.wrapInQuotes( name, ln )
	if not UTIL.trim( name ) then
		return '';  --  Return empty string.
	end

	return (ln ~= 'ja' and ln ~= 'zh')
		and table.concat( { '"', name, '"' } )
		or  table.concat( { '「', name, '」' } )
	;
end

--[[function U.processArgs( frame, ... )
	return
end]]
-- @name getArgs
-- @description Parses arguments.
-- @see [[Module:Arguments]]
local getArgs;
function U.getArgs( ... )
	getArgs = getArgs or require( 'Module:Arguments' ).getArgs;
	return getArgs( ... );
end

-- @name getName
-- @description Gets the localized name of a card, set or character.
-- @see [[Module:Name]]
local getName;
function U.getName( ... )
	getName = getName or require( 'Module:Name' ).main;
	return getName( ... );
end

-- @name getImgName
-- @description Gets the localized name of a card, set or character.
-- @see [[Module:Name]]
local getImgName;
function U.getImgName( ... )
	getImgName = getImgName or require( 'Module:Card image name' ).main;
	return getImgName( ... );
end

-- @name newInfoObject
-- @description
-- @see [[Module:Info class]]
local InfoClass;
function U.newInfoObject( title )
	InfoClass = InfoClass or require( 'Module:Info class' );
	return InfoClass.new( title );
end

-- @name newStringBuffer
-- @description
-- @see [[Module:StringBuffer]]
local StringBuffer;
function U.newStringBuffer()
	StringBuffer = StringBuffer or require( 'Module:StringBuffer' );
	return StringBuffer.new();
end

----------
-- Return:
----------
return U;
-- </pre>