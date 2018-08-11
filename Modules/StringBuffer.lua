-- <pre>
-- @description Provides an easy way to deal with strings.
-- @author [[User:Becasita]]
-- @contact [[User talk:Becasita]]

--[[Doc
@class StringBuffer
@description The `StringBuffer` class is meant to
help creating more complex strings, that require
lots of checks and/or several concatenations.
]]
local StringBuffer = {};
StringBuffer.__index = StringBuffer;
StringBuffer.__class = StringBuffer;

--[[Doc
@description Initializes the instance of the `StringBuffer`.
@return {StringBuffer} New instance of `StringBuffer`.
]]
function StringBuffer.new()
	local data = {
		buffer = {},
	};

	return setmetatable( data, StringBuffer );
end

--[[Doc
@description Appends content to the buffer.
@parameter {string|nil} content The content to append.
@return {StringBuffer} `self`
]]
function StringBuffer:add( content )
	table.insert( self.buffer, content )

	return self;
end

--[[Doc
@description Appends a line to the buffer.
@parameter {string|nil} content The content to append as a line.
@return {StringBuffer} `self`
]]
function StringBuffer:addLine( content )
	return self:add( (content or '') .. '\n' );
end

--[[Doc
@description Flushes the content. Concats all of the buffer
entries using the `delimiter` given. Then, the buffer is reset
and the previous concatenation inserted into it.
@parameter {string|nil} delimiter The delimiter to use to
concat the buffer entries.
@return {StringBuffer} `self`
]]
function StringBuffer:flush( delimiter )
	self.buffer = {
		table.concat( self.buffer, delimiter or '' );
	}

	return self;
end

--[[Doc
@description Renders a string from the `buffer`.
@return {StringBuffer} String rederization of the `StringBuffer`.
]]
function StringBuffer:toString()
	return table.concat( self.buffer );
end

--[[Doc
@exports The `StringBuffer` class.
]]
return StringBuffer;
-- </pre>