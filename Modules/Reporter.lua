-- <pre>
--[=[Doc
@module Reporter
@description Creates an object to store module info.
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

local mwHtmlCreate = mw.html.create

local namespace = mw.title.getCurrentTitle().namespace

local canDumpCategories = (
	namespace ~= 10
	and
	namespace % 2 == 0
)

--[[Doc
@class Reporter
@description Stores and provides an interface to manage module info.
@exportable
]]
local Reporter = {} -- TODO: check if it's efficient enough (html library vs raw strings)
Reporter.__index = Reporter
Reporter.__class = Reporter

--[[Doc
@function Reporter new
@description Initializes an instance of `Reporter`.
@return {Reporter} New instance of `Reporter`.
]]
function Reporter.new( title )
	local data = { -- TODO: use local references as fields?
		_categories = {},
		_warnings   = {},
		_errors     = {},
	}

	Reporter.setTitle( data, title )

	return setmetatable( data, Reporter )
end

--[[Doc
@method Reporter setTitle
@description Changes the instance title.
@parameter {string|nil} title The new title. If `nil`, the empty string is used.
@return {Reporter} `self`
]]
function Reporter:setTitle( title )
	self._title = tostring( title or '' ) -- TODO: default to better name? Escape title? Accept nil to avoid default category?

	return self
end

--[[Doc
@method Reporter addCategory
@description Stores a new category.
@parameter {string} category The category name.
@parameter {string|nil} sortkey The sortkey for this category.
@return {Reporter} `self`
]]
function Reporter:addCategory( category, sortkey )
	table.insert(
		self._categories,
		category and { category, sortkey }
	)

	return self
end

--[[Doc
@method Reporter addWarning
@description Stores a new warning.
@parameter {string} message The warning message.
@return {Reporter} `self`.
]]
function Reporter:addWarning( message )
	self._warnings.exists = true

	table.insert( self._warnings, message )

	return self
end

--[[Doc
@method Reporter error
@description Stores a new error.
@parameter {string} message The error message.
@return {Reporter} `self`.
]]
function Reporter:addError( message )
	self._errors.exists = true

	table.insert( self._errors, message )

	return self
end

local function formatCategory( self, name, sortkey )
	return ( sortkey and '[[Category:((%s)) %s|%s]]' or '[[Category:((%s)) %s]]' )
		:format( self._title, name, sortkey )
end

--[[Doc
@function dumpCategories
]]
local function dumpCategories( self )
	local categories = {
		(
			self._warnings.exists
			or
			self._errors.exists
		) and formatCategory( self, 'transclusions to be checked', ' ' )
	}

	for index, categoryPair in ipairs( self._categories ) do
		table.insert(
			categories,
			formatCategory( self, categoryPair[ 1 ], categoryPair[ 2 ] )
		)
	end

	return table.concat( categories )
end

--[[Doc
@function dumpWarnings
]]
local function dumpWarnings( self )
	local container = mwHtmlCreate( 'div' )
		:addClass( 'reporter__warnings' )
		:tag( 'ul' )

	for _, warning in ipairs( self._warnings ) do
		container:tag( 'li' ):wikitext( warning )
	end

	return tostring( container:allDone() )
end

--[[Doc
@function dumpErrors
]]
local function dumpErrors( self )
	local container = mwHtmlCreate( 'div' )
		:addClass( 'reporter__errors' )
		:tag( 'ul' )

	for _, err in ipairs( self._errors ) do
		container:tag( 'li' ):wikitext( err )
	end

	return tostring( container:allDone() )
end

--[[Doc
@method Reporter dump
]]
function Reporter:dump()
	return tostring( mwHtmlCreate( 'div' )
		:addClass( 'reporter' )
		:node( canDumpCategories and dumpCategories( self ) )
		:node( self._errors.exists and dumpErrors( self ) )
		:node( self._warnings.exists and dumpWarnings( self ) )
	)
end

--[=[Doc
@exports The `Reporter` class constructor (`new`).
@see [[#Reporter.new]]
]=]
return setmetatable( Reporter, {
	__call = function( t, title )
		assert(
			t == Reporter,
			'Cannot apply Reporter constructor except to itself'
		)

		return Reporter.new( title )
	end
} )
-- </pre>
