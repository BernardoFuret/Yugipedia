-- <pre>
--[=[Doc
@module Util
@description Holds commonly used simple functions.
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
@todo Remove those last functions to a dedicated module
or simply remove them.
]=]

-------------------
-- Export variable:
-------------------
--[[Doc
@data U
@description Variable to hold the library to be exported.
@exportable
]]
local U = {}

-------------
-- Functions:
-------------
-- mw functions:
local mwTextTrim = mw.text.trim

--[[Doc
@function U bold
@description Renders bold wikitext markup.
@parameter {string} s String to make bold.
@return {string} Bold formatted `s`.
@todo Escape ' ?
]]
function U.bold( s )
	return ("'''%s'''"):format( s )
end

--[[Doc
@function U italic
@description Renders italic wikitext markup.
@parameter {string} s String to italicize.
@return {string} Italicized `s`.
@todo Escape ' ?
]]
function U.italic( s )
	return ("''%s''"):format( s )
end

--[=[Doc
@function U italicNoDab
@description Renders italics wikitext markup, except for the dab.
Also normalizes the space between the dab and the rest.
@parameter {string} s String to italicize, except its dab.
@return {string} Italicized `s`, except its dab.
@see [[#U.getDab]]
@see [[#U.removeDab]]
]=]
function U.italicNoDab( s )
	local dab = U.getDab( s )
	local noDab = U.removeDab( s )
	return table.concat( {
		("''%s''"):format( noDab ),
		dab ~= '' and ("(%s)"):format( dab ) or nil
	}, ' ' )
end

--[=[Doc
@function U trim
@description Trims white space from front and tail of string.
Returns nil if only whitespace.
@parameter {string|nil} s String to trim.
@return {string|nil} Trimmed `s`. If `s` ends up being only whitespace
or `s` is `nil`, it returns `nil`.
@see [[mw:Extension:Scribunto/Lua reference manual#mw.text.trim]]
]=]
function U.trim( s )
	if s and not s:match( '^%s*$' ) then
		return mwTextTrim( s )
	end
end

--[[Doc
@function U count
@description Counts the number of elements in a table.
@parameter {table} t Table to get counted.
@return {number} Number of elements in the table.
]]
function U.count( t )
	local counter = 0
	for key, value in pairs( t ) do
		counter = counter + 1
	end
	return counter
end

--[[Doc
@function U link
@description Creates a wikitext link.
@parameter {string} page Page name to link.
@parameter {string|nil} label Label for the link. If unspecified,
the label used will be `page` with its dab removed.
@return {string} Wikilink.
]]
function U.link( page, label )
	return ('[[%s|%s]]'):format(
		page:gsub( '#', '' ),
		label or U.removeDab( page )
	)
end

--[[Doc
@function U italicLink
@description Creates a wikitext link, italicized. Usually used
to display linked set names, etc..
@parameter {string} page Page name to link.
@parameter {string|nil} label Label for the link. If unspecified,
the label used will be `page` with its dab removed and italicized.
Else, will italicize the label given. 
@return {string} Italicized wikilink.
]]
function U.italicLink( page, label )
	return U.link(
		page,
		label and U.italic( label ) or U.italicNoDab(
			U.removeDab( page ) -- TODO there's some twisted logic here for edge cases of multiple dabs. Check this.
		)
	)
end

--[[Doc
@function U getDab
@description Gets the dab text of a title, if it has dab.
@parameter {string} title Page title to get the dab from.
@return {string} Dab for `title`.
]]
function U.getDab( title )
	return title:match( '%(([^%(]*)%)%s*$' ) or ''
end

--[[Doc
@function U removeDab
@description Removes the dab text of a title.
@parameter {string} title Page title to get its dab removed.
@return {string} `title` with its dab removed.
]]
function U.removeDab( title )
	return title:gsub( '%s*%(([^%(]*)%)%s*$', '' )
end

--[[Doc
@function U escape
@description Escapes a string.
@parameter {string} s String value to be escaped.
@return {string} Escaped `s`.
]]
function U.escape( s )
	return mw.ustring.gsub( s, '([^%w])', '%%%1' )
end

--[[Doc
@function isSomething
@description Meta-function for type checkers.
@parameter {*} toCompare Anything to type-compare.
@parameter {*} compareTo Specific thing to be type-compared with.
@return {boolean} If `toCompare` and `compareTo` have the same type. 
]]
local function isSomething( toCompare, compareTo )
	return type( toCompare ) == type( compareTo )
end

--[=[Doc
@function U isBoolean
@description Checks if it's a `boolean` type.
@parameter {*} v Any value to check if it's a `boolean`.
@return {boolean} If `v` type is `boolean`.
@see [[#isSomething]] 
]=]
function U.isBoolean( v )
	return isSomething( v, true )
end

--[=[Doc
@function U isFunction
@description Checks if it's a `function` type.
@parameter {*} v Any value to check if it's a `function`.
@return {boolean} If `v` type is `function`.
@see [[#isSomething]] 
]=]
function U.isFunction( v )
	return isSomething( v, function() end )
end

--[=[Doc
@function U isNil
@description Checks if it's `nil`.
@parameter {*} v Any value to check if it's `nil`.
@return {boolean} If `v` type `nil`.
@see [[#isSomething]] 
]=]
function U.isNil( v )
	return isSomething( v, nil )
end

--[=[Doc
@function U isNumber
@description Checks if it's a `number` type.
@parameter {*} v Any value to check if it's a `number`.
@return {boolean} If `v` type is `number`.
@see [[#isSomething]] 
]=]
function U.isNumber( v )
	return isSomething( v, 1 )
end

--[=[Doc
@function U isString
@description Checks if it's a `string` type.
@parameter {*} v Any value to check if it's a `string`.
@return {boolean} If `v` type is `string`.
@see [[#isSomething]] 
]=]
function U.isString( v )
	return isSomething( v, '' )
end

--[=[Doc
@function U isTable
@description Checks if it's a `table` type.
@parameter {*} v Any value to check if it's a `table`.
@return {boolean} If `v` type is `table`.
@see [[#isSomething]] 
]=]
function U.isTable( v )
	return isSomething( v, {} )
end

--[[Doc
@function U isEmpty
@description Checks if it's a empty.
@parameter {*} v Any value to check if it's empty.
@return {boolean} If `v` type is empty.
@todo Keep this? Check dependencies.
]]
function U.isEmpty( v )
	return (
		U.isString( v ) and mwTextTrim( v ) == ''
		or
		U.isTable( v ) and U.count( v ) == 0
	)
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

--[[Doc
@function U wrapInQuotes
@description Wraps a name in quotes, based on the language.
@parameter {string|nil} name A name to wrap in quotes.
@parameter {string} ln A language index.
@return {string} Wrapped `name`. If `name` is `nil`, returns the empty string.
@todo Accept `ln` as a language struct.
]]
function U.wrapInQuotes( name, ln )
	if not U.trim( name ) then
		return '';  --  Return empty string.
	end

	return (ln == 'ja' or ln == 'tc')
		and table.concat( { '「', name, '」' } )
		or  table.concat( { '"', name, '"' } )
	
end

--[[Doc
@function U formatParameter
@description
@parameter {string} v
@return {string}
@todo deprecated. remove later.
]]
function U.formatParameter( v )
	return ('&#123;&#123;&#123;%s&#125;&#125;&#125;'):format( v )
end

--[[function U.processArgs( frame, ... )
	return
end]]
-- @name getArgs
-- @description Parses arguments.
-- @todo: deprecated. remove later.
-- @see [[Module:Arguments]]
function U.getArgs( ... )
	return require( 'Module:Arguments' ).getArgs( ... )
end

-- @name getName
-- @description Gets the localized name of a card, set or character.
-- @todo: deprecated. remove later.
-- @see [[Module:Name]]
function U.getName( name, ln )
	local DATA = require( 'Module:Data' )

	local language = DATA.getLanguage( ln )

	return DATA.getName( name:gsub( '#', '' ), language )
end

-- @name getImgName
-- @description Gets the localized name of a card, set or character.
-- @todo: deprecated. remove later.
-- @see [[Module:Name]]
function U.getImgName( ... )
	return require( 'Module:Card image name' ).main( ... )
end

----------
-- Return:
----------
--[[Doc
@exports Util library (`U`).
]]
return U
-- </pre>