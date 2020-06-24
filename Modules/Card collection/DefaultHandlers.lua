-- <pre>
--[=[Doc
@module Card collection/DefaultHandlers
@description 
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

local DefaultHandlers = {}

--[[Doc
@function DefaultHandlers new
@description 
@return 
]]
function DefaultHandlers:new( name, reporter )
	local data = {
		name = name,
		reporter = reporter,
		utils = require( 'Module:Card collection/Utils' )( name, reporter ), -- TODO: add require( 'Module:Card collection/Utils' ) to the metatable?
	}

	return setmetatable( data, {
		__index = self,
	} )
end

--[[Doc
@method DefaultHandlers initData
@description 
@return 
]]
function DefaultHandlers:initData( globalData )
	return globalData
end

--[[Doc
@method DefaultHandlers initStructure
@description 
@return HTML (`mw.html`) instance.
]]
function DefaultHandlers:initStructure( globalData )
	return mw.html.create( 'div' )
end

--[[Doc
@method DefaultHandlers handleRow
@description Parses the row content
@return 
]]
function DefaultHandlers:handleRow( row, globalData )
	local rowString = ( 'Non-empty line: %d »» %s' )
		:format( row.lineno, row.raw )

	return mw.html.create( 'p' ):wikitext( rowString )
end

--[[Doc
@method DefaultHandlers finalize
@description Applied after the rows have been parsed.
Used to supply extra containers to be added to the
main wrapper.
@return Multiple values that will be appended to the
main wrapper (including the main structure).
]]
function DefaultHandlers:finalize( mainStructure, globalData )
	return tostring( mainStructure )
end

--[[Doc
@exports The `DefaultHandlers` class, with
the `__call` metamethod to allow instantiation.
]]
return setmetatable( DefaultHandlers, {
	__call = function( self, name, reporter ) -- TODO: test passing `DefaultHandlers.new`
		return self:new( name, reporter )
	end
} )
-- </pre>
