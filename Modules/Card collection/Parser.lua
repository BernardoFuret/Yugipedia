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

	parameters[ 1 ].allowEmpty = false

	-- Parameter `separator` has a minimal standard definition:
	parameters.separator = parameters.separator or {}

	parameters.separator.default = parameters.separator.default or ';'

	parameters.separator.allowEmpty = false

	-- TODO: split definitions to their own file and merge with specific definitions?

	return parameters
end

local function loadHandlers( root )
	local handlersPath = makeDependenciesPath( root, 'handlers' )

	local handlers = require( handlersPath ) -- or {} TODO: safeRquire?

	return setmetatable( handlers, {
		__index = DefaultHandlers,
	} )
end

local function parseEntry( handlers, rawEntry, lineno ) -- TODO: have this on utils?
	local entryPair = mwTextSplit( rawEntry, '%s*//%s*' )

	local entryValues = handlers.utils:parseValues( entryPair[ 1 ] )

	local entryOptions = handlers.utils:parseOptions(
		entryPair[ 2 ] or '',
		( 'line %d' ):format( lineno )
	)

	return {
		raw = rawEntry,
		lineno = lineno,
		values = entryValues,
		options = entryOptions,
	}
end

local Parser = {}
Parser.__index = Parser

function Parser.new( name )
	local data = {
		name = name,
		parameters = loadParameters( name ),
		handlers = loadHandlers( name ),
	}

	return setmetatable( data, Parser )
end

function Parser:parse( frame, arguments, moduleArguments )
	local reporter = Reporter( self.name )

	local handlers = self.handlers:new( self.name, reporter, frame )

	local globalData = handlers.utils:validateArguments( self.parameters, arguments, moduleArguments )

	local wrapper = mw.html.create( 'div' )
		:addClass( handlers.utils:makeCssClass() )

	if globalData.hasHaltingError then
		wrapper:node( reporter:dump() )

		return tostring( wrapper )
	end

	handlers.utils:setSeparator( globalData.separator )

	globalData = handlers:initData( globalData ) or globalData -- TODO: for internal use in modules: split here.

	local mainStructure = handlers:initStructure( globalData )
		:allDone()
		:addClass( handlers.utils:makeCssClass( 'main' ) )

	do
		local lineno = 0 -- Count of non-empty lines.

		for rawEntry in mwTextGsplit( globalData[ 1 ], '%s*\n%s*' ) do
			local rawEntry = UTIL.trim( rawEntry )

			if rawEntry then
				lineno = lineno + 1

				local entry = parseEntry( handlers, rawEntry, lineno )

				local handledEntry = handlers:handleEntry( entry, globalData )

				mainStructure:node( tostring( handledEntry ) )
			end
		end
	end

	local allStructures = { handlers:finalize( mainStructure, globalData ) }

	wrapper:node( reporter:dump() )

	for _, structure in ipairs( allStructures ) do
		wrapper:node( tostring( structure ) )
	end

	return tostring( wrapper )
end

function Parser:test( arguments, moduleArguments )
	local parseResult = self:parse(
		mw.getCurrentFrame(),
		arguments or {},
		moduleArguments or {}
	)

	mw.log( parseResult )

	return parseResult
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
