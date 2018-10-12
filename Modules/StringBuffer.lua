-- <pre>
--[=[Doc
@module StringBuffer
@description Provides an easy way to deal with strings.
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

--[[Doc
@class StringBuffer
@description The `StringBuffer` class is meant to
help creating more complex strings, that require
lots of checks and/or several concatenations.
@exportable
]]
local StringBuffer = {};
StringBuffer.__index = StringBuffer;
StringBuffer.__class = StringBuffer;

--[[Doc
@function StringBuffer new
@description Initializes an instance of `StringBuffer`.
@return {StringBuffer} New instance of `StringBuffer`.
]]
function StringBuffer.new()
	local data = {
		buffer = {},
	};

	return setmetatable( data, StringBuffer );
end

--[[Doc
@method StringBuffer add
@description Appends content to the buffer.
@parameter {string|nil} content The content to append.
@return {StringBuffer} `self`
]]
function StringBuffer:add( content )
	table.insert( self.buffer, content )

	return self;
end

--[[Doc
@method StringBuffer addLine
@description Appends a line to the buffer.
@parameter {string|nil} content The content to append as a line.
@return {StringBuffer} `self`
]]
function StringBuffer:addLine( content )
	return self:add( (content or '') .. '\n' );
end

--[[Doc
@method StringBuffer flush
@description Flushes the content. Concats all of the buffer
entries using the `delimiter` given. Then, the buffer is reset
and the previous concatenation inserted into it.
@parameter {string|nil} delimiter The delimiter to use to
concat the buffer entries.
@return {StringBuffer} `self`
@todo Check empty buffer.
]]
function StringBuffer:flush( delimiter )
	self.buffer = {
		table.concat( self.buffer, delimiter or '' );
	}

	return self;
end

--[[Doc
@method StringBuffer toString
@description Renders a string from the buffer.
@return {string} String rederization of the `StringBuffer`.
]]
function StringBuffer:toString()
	return table.concat( self.buffer );
end

--[[Doc
@exports The `StringBuffer` class.
]]
return StringBuffer;
-- </pre>