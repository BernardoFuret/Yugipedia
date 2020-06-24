-- <pre>
--[=[Doc
@module Card collection/Parser
@description 
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

local UTIL = require( 'Module:Util' )

local Reporter = require( 'Module:Reporter' )

local DefaultHandlers = require( 'Module:Card collection/DefaultHandlers' )

local mwText = mw.text
local mwTextGsplit = mwText.gsplit
local mwTextSplit = mwText.split

local function makeDependenciesPath( root, dependency )
	return table.concat( {
		'Module:Card collection',
		'modules',
		root,
		dependency,
	}, '/' )
end

local function loadParameters( root )
	local parametersPath = makeDependenciesPath( root, 'parameters' )

	local parameters = require( parametersPath ) -- TODO: should be mw.loadData, but is read only... TODO: safeRquire?

	-- Parameter 1 is mandatory and has a minimal standard definition: 
	parameters[ 1 ] = parameters[ 1 ] or {}

	parameters[ 1 ].required = true

	parameters[ 1 ].default = parameters[ 1 ].default or ''

	return parameters
end

local function loadHandlers( root )
	local handlersPath = makeDependenciesPath( root, 'handlers' )

	local handlers = require( handlersPath ) -- or {} TODO: safeRquire?

	return setmetatable( handlers, {
		__index = DefaultHandlers,
	} )
end

local function parseRowEntry( handlers, entry, lineno ) -- TODO: have this on utils?
	local rowPair = mwTextSplit( entry, '%s*//%s*' )

	local rowValues = handlers.utils:parseValues( rowPair[ 1 ] )

	local rowOptions = handlers.utils:parseOptions( rowPair[ 2 ] or '' )

	return {
		raw = entry,
		lineno = lineno,
		values = rowValues,
		options = rowOptions,
	}
end

local Parser = {};
Parser.__index = Parser;

function Parser.new( name )
	local data = {
		name = name,
		parameters = loadParameters( name ),
		handlers = loadHandlers( name ),
	}

	return setmetatable( data, Parser )
end

function Parser:parse( arguments ) -- TODO: pass frame here?
	local reporter = Reporter( self.name )

	local handlers = self.handlers( self.name, reporter )

	local globalData = handlers.utils:validateArguments( self.parameters, arguments )

	globalData = handlers:initData( globalData ) or globalData -- TODO: for internal use in modules: split here.

	local mainStructure = handlers:initStructure( globalData )
		:allDone()
		:addClass( handlers.utils:makeCssClass( 'main' ) )

	do
		local lineno = 0 -- Count of non-empty lines.

		for entry in mwTextGsplit( globalData[ 1 ], '%s*\n%s*' ) do
			local entry = UTIL.trim( entry )

			if entry then
				lineno = lineno + 1

				local row = parseRowEntry( handlers, entry, lineno )

				local parsedRow = handlers:handleRow( row, globalData )

				mainStructure:node( tostring( parsedRow ) )
			end
		end
	end

	local wrapper = mwHtmlCreate( 'div' )
		:addClass( handlers.utils:makeCssClass() )

	local allStructures = { handlers:finalize( mainStructure, globalData ) }

	wrapper:node( reporter:dump() )

	for _, structure in ipairs( allStructures ) do
		wrapper:node( tostring( structure ) )
	end

	return tostring( wrapper )
end

return setmetatable( Parser, {
	__call = function( t, name )
		assert(
			t == Parser,
			'Cannot apply Card collection/Parser constructor except to itself'
		)

		return Parser.new( name )
	end
} )
-- </pre>
