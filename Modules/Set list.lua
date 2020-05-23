-- <pre>
--[=[Doc
@module 
@description 
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
TODO:
- Cleanup
- Refactor: split responsibilities more strictly;
- Check unused code;
- condense option parsing (review syntax) (parse arguments.columns as options);
- Sort and display columns in alphabetical order
- Validate default quantity as a number
- Keep header parameter? What to do with it?

- What's not being tracked:
-- Validation of row options (admissible values, including columns)
-- If there are incompatibilities in values: no card name, but there is printed-name (this is allowed for now)
]=]

local DATA = require( 'Module:Data' )
local UTIL = require( 'Module:Util' )

local Reporter = require( 'Module:Reporter' )
local StringBuffer = require( 'Module:StringBuffer' )

local LANGUAGE_ENGLISH = DATA.getLanguage( 'English' )

local mwText = mw.text
local mwHtmlCreate = mw.html.create
local mwTextGsplit = mwText.gsplit
local mwTextSplit = mwText.split

local reporter;

local parameters = { -- TODO: split to own module
	region = {
		required = true,
		default = 'EN',
	},

	header = {},

	rarities = {
		default = '',
	},

	print = {
		allowEmpty = true,
	},

	qty = {},

	description = {},

	[ '$description' ] = {},

	options = {
		default = '',
	},

	columns = {},

	[ 1 ] = {
		required = true,
		default = '',
--		options = {
--			[ 'printed-name' ] = {},
--			[ 'description' ] = {
--				allowEmpty = true,
--			},
--		}
	},
}

-- NOTE: validation
local function validateArguments( args ) -- TODO: split to own module
	local validated = {}

	for param, arg in pairs( args ) do
		-- Invalid parameter:
		if not parameters[ param ] then
			local message = ( 'Invalid parameter `%s`!' )
				:format( param )

			local category = '((Set list)) transclusions with invalid parameters'

			reporter
				:addError( message )
				:addCategory( category )

		-- Empty parameter that is not allowed to be empty:
		elseif --[[arg and]] not UTIL.trim( arg ) and not parameters[ param ].allowEmpty then
			local message = ( 'Empty parameter `%s`!' )
				:format( param )

			local category = '((Set list)) transclusions with empty parameters'

			reporter
				:addError( message )
				:addCategory( category )

		-- Valid parameter with valid argument:
		else
			validated[ param ] = arg
		end
	end

	-- TODO: verify required parameters without looping again
	for param, definition in pairs( parameters ) do
		if not validated[ param ] then
			if definition.required then
				local message = ( 'Missing required parameter `%s`!' ) -- TODO: for `1` it might not be obivous to the editor what's missing
					:format( param )

				local category = '((Set list)) transclusions with missing required parameters' 

				reporter
					:addError( message )
					:addCategory( category )
			end

			validated[ param ] = definition.default
		end
	end

	return validated
end

-- NOTE: Parsing
local function parseRarities( rawRarities, lineno ) -- NOTE: this may not be classified as a general function.
	local rarities = {}

	if not UTIL.trim( rawRarities ) then
		return rarities
	end

	local position = 0

	local nonEmptyposition = 0

	for rawRaritiy in mwTextGsplit( rawRarities, '%s*,%s*' ) do
		position = position + 1

		local rawRaritiy = UTIL.trim( rawRaritiy )

		if rawRaritiy then
			nonEmptyposition = nonEmptyposition + 1

			local rarity = DATA.getRarity( rawRaritiy )

			if rarity then
				table.insert( rarities, UTIL.link( rarity.full ) )
			else
				local message = ( 'No such rarity for `%s`, at non-empty input line %d, at non-empty position %d.' )
					:format( rawRaritiy, lineno, nonEmptyposition )

				local category = '((Set list)) transclusions with invalid rarities'

				reporter
					:addError( message )
					:addCategory( category )
			end
		else
			local message = ( 'Empty rarity input, at non-empty input line %d, at position %d.' )
				:format( lineno, position )

			local category = '((Set list)) transclusions with empty rarities'

			reporter
				:addError( message )
				:addCategory( category )
		end
	end

	return rarities
end

local function parseOptions( rawOptions, handler ) -- TODO: check and disallow: `::value`
	local handler = handler or function( container, key, value )
		container[ key ] = value
	end

	local options = {}

	for optionPairString in mwTextGsplit( rawOptions, '%s*;%s*' ) do
		local optionPairString = UTIL.trim( optionPairString )

		if optionPairString then -- TODO: check if :: is used more than once?
			local optionPair = mwTextSplit( optionPairString, '%s*::%s*' )

			local optionKey = optionPair[ 1 ]

			local optionValue = optionPair[ 2 ] or ''

			handler( options, optionKey, optionValue )
--			options[ optionKey ] = optionValue
		else
			-- TODO: empty option; not allowed
		end
	end

	return options
end

local function parseValues( rawValues )
	return mwTextSplit( rawValues, '%s*;%s*' )
end

-- NOTE: interpolation
--[[local function interpolateWith( rawValue )
	local values = mwTextSplit( rawValue, '%s*,%s*' )

	return function( n )
		return values[ tonumber( n ) ] or ''
	end
end--]]

local function handleInterpolation( value, template, default )
	--[[DOC
if row.desc==''                        => row.desc
if row.desc~=nil and $desc==nil        => row.desc
if row.desc~=nil and $desc~=nil        => interpolate row.desc in $desc
if row.desc==nil and default.desc~=nil => default.desc
if row.desc==nil and default.desc==nil => nil
	--]]
	if not UTIL.trim( value ) then
		return value or default -- this will result in returning empty string or default
	end

	if not template then
		return value
	end

	if template then
		local parts = mwTextSplit( value, '%s*,%s*' )

		return template:gsub( '%$(%d)', function( n )
			return parts[ tonumber( n ) ] or ''
		end )
	end

	error( 'Should never reach this point' )
end

-- NOTE: Structure/Presentation
local function createHeader( id, text )
	return tostring( mwHtmlCreate( 'th' )
		:attr( 'scope', 'col' )
		:addClass( 'set-list__main__header' )
		:addClass( 'set-list__main__header--' .. id )
		:wikitext( text )
	)
end

local function createHeaderRow( globalData )
	local headerTr = mwHtmlCreate( 'tr' )

	if not globalData.options.noabbr then
		headerTr:node( createHeader( 'card-number', 'Card number' ) )
	end

	if globalData.language.index == LANGUAGE_ENGLISH.index then
		headerTr:node( createHeader( 'name', 'Name' ) )
	else
		headerTr
			:node( createHeader( 'name', 'English name' ) )
			:node( createHeader( 'localized-name', globalData.language.full .. ' name' ) )
	end

	headerTr
		:node( createHeader( 'rarity', 'Rarity' ) )
		:node( createHeader( 'category', 'Category' ) )

	if globalData.print then
		headerTr:node( createHeader( 'print', 'Print' ) )
	end

	if globalData.qty then
		headerTr:node( createHeader( 'quantity', 'Quantity' ) )
	end

	for columnName, _ in pairs( globalData.columns ) do
		local columnId = columnName:lower():gsub( '%s+', '-' )

		headerTr:node( createHeader( columnId, columnName ) )
	end

	return tostring( headerTr )
end

local function createCell( text )
	return tostring( mwHtmlCreate( 'td' )
		:wikitext( text )
	)
end

local function createDataRow( row, globalData ) -- TODO: refactor: extract functions
	local rowTr = mwHtmlCreate( 'tr' )

	local valuesIndex = 1

	local cardNameInput

	-- Card number:
	if not globalData.options.noabbr then
		local cardNumberInput = UTIL.trim( row.values[ valuesIndex ] )

		cardNameInput = UTIL.trim( row.values[ valuesIndex + 1 ] ) -- TODO: move to outer scope (all *Input )

		local cardNumberContent = cardNumberInput
			and ( ( cardNumberInput:match( '?' ) or not cardNameInput )
				and cardNumberInput
				or UTIL.link( cardNumberInput )
			)
			or ''

		rowTr:node( createCell( cardNumberContent ) )

		valuesIndex = valuesIndex + 1
	end

	-- Card name (English and localized):
	do
		local languageIsEnglish = globalData.language.index == LANGUAGE_ENGLISH.index

		cardNameInput = UTIL.trim( row.values[ valuesIndex ] ) -- TODO: move to outer scope (all *Input )

		local cardName = cardNameInput and UTIL.wrapInQuotes(
			UTIL.link(
				cardNameInput,
				cardNameInput:match( 'Token%s%(' ) and cardName
			),
			LANGUAGE_ENGLISH.index
		) or ''

		local printedName = row.options[ "printed-name" ] -- TODO: should only be considered if there's a cardNameInput?
			and table.concat{
				'(as ',
				UTIL.wrapInQuotes( row.options[ "printed-name" ], LANGUAGE_ENGLISH ),
				')',
			}

		local description = handleInterpolation( -- TODO: should only be considered if there's a cardNameInput? Or if the user adds it, it should be added? Display default or blank if there isn't a cardNameInput
			row.options.description,
			globalData[ '$description' ],
			globalData.description
		)

		local cardNameCellContent = StringBuffer()
			:add( cardName )
			:add( languageIsEnglish and printedName or nil )
			:add( description )
			:flush( ' ' )
			:toString()

		rowTr:node( createCell( cardNameCellContent ) )

		if not languageIsEnglish then
			local cardLocalizedName = cardNameInput
				and UTIL.wrapInQuotes(
					DATA.getName( cardNameInput, globalData.language ),
					globalData.language.index
				)

			local cardLocalizedNameCellContent = StringBuffer()
				:add( cardLocalizedName )
				:add( not languageIsEnglish and printedName or nil )
				:flush( ' ' )
				:toString()

			rowTr:node( createCell( cardLocalizedNameCellContent ) )
		end

		valuesIndex = valuesIndex + 1
	end

	-- Rarities:
	do
		local raritiesInput = row.values[ valuesIndex ]

		local linkedRarities = parseRarities( raritiesInput or '', row.lineno )

		rowTr:node(
			createCell(
				table.concat(
					linkedRarities[ 1 ] and linkedRarities or globalData.rarities,
					'<br />'
				)
			)
		)

		valuesIndex = valuesIndex + 1
	end

	-- Category:
	do
		local cardFullType = cardNameInput and DATA.getFullCardType( cardNameInput )

		rowTr:node( createCell( cardFullType ) )
	end

	-- Print:
	if globalData.print then
		-- DOC: if print is empty, don't override default value (just treat as nil). This is to prevent overriding when qty is being used and we want the default print value. 
		local printInput = UTIL.trim( row.values[ valuesIndex ] )

		rowTr:node( createCell( printInput or globalData.print ) )

		valuesIndex = valuesIndex + 1
	end

	-- Quantity:
	if globalData.qty then
		local qtyInput = row.values[ valuesIndex ]

		local qtyNumber = tonumber( qtyInput )

		if qtyInput and not qtyNumber then
			local message = ( 'Invalid quantity value at line %d. `%s` cannot be parsed as a number.' )
				:format( row.lineno, qtyInput )

			local category = '((Set list)) transclusions with invalid quantity values'

			reporter
				:addError( message )
				:addCategory( category )

			qtyInput = ''
		end

		rowTr:node( createCell( qtyInput or globalData.qty ) )

		valuesIndex = valuesIndex + 1
	end

	-- Extra columns
	for columnName, columnData in pairs( globalData.columns ) do
		local columnInput = row.options[ '@' .. columnName ]

		local columnContent = handleInterpolation(
			columnInput,
			columnData.template,
			columnData.default
		)

		rowTr:node( createCell( columnContent ) )
	end

	return tostring( rowTr )
end

-- NOTE: Main
local function main( frame, rawArguments )
	reporter = Reporter( 'Set list' )

	-- NOTE: init args
	local globalData = validateArguments( rawArguments )

	globalData.rarities = parseRarities( globalData.rarities, 0 ) -- TODO: find better place for this. Pass correct location instead of mock lineno

	globalData.options = parseOptions( globalData.options ) -- TODO: find better place for this

	local columnsHandler = function( columns, columnName, columnValue )
		local columnName, interpolation = columnName:gsub( '^%$', '' )

		columns[ columnName ] = columns[ columnName ] or {}

		if interpolation ~= 0 then
			columns[ columnName ].template = columnValue
		else
			columns[ columnName ].default = columnValue
		end
	end 

	globalData.columns = parseOptions( globalData.columns, columnsHandler ) -- TODO: find better place for this

	-- NOTE: init general info
	local regionInput = globalData.region

	globalData.region = DATA.getRegion( globalData.region )

	if not globalData.region then
		local message = ( 'Invalid `region` provided: `%s`!' )
			:format( regionInput )

		local category = '((Set list)) transclusions with invalid region'

		reporter
			:addError( message )
			:addCategory( category )

		globalData.region = parameters.region.default -- TODO: Depend on `parameters`? For other cases they may need to be may not be consistent
	end

	globalData.language = DATA.getLanguage( globalData.region.index )

	-- NOTE: create structure
	local setList = mwHtmlCreate( 'table' )
--		:attr( 'id', 'set-list__main--' .. globalData.header )
		:addClass( 'wikitable' )
		:addClass( 'sortable' )
		:addClass( 'card-list' )
		:addClass( 'set-list__main' )
		:node( createHeaderRow( globalData ) )

	do
		local lineno = 0 -- Count of non-empty lines.

		for entry in mwTextGsplit( globalData[ 1 ], '%s*\n%s*' ) do
			local entry = UTIL.trim( entry )

			if entry then
				lineno = lineno + 1

				-- TODO: split to parseRowToData(); parseDataToHtml ?
				local rowPair = mwTextSplit( entry, '%s*//%s*' )

				local rowValues = parseValues( rowPair[ 1 ] )

				local rowOptions = parseOptions( rowPair[ 2 ] or '' )

				local row = {
					lineno = lineno,
					values = rowValues,
					options = rowOptions,
				}

				setList:node( createDataRow( row, globalData ) )
			end
		end
	end

	return mwHtmlCreate( 'div' )
--		:attr( 'id', 'set-list--' .. globalData.header )
		:addClass( 'set-list' )
		:node( reporter:dump() )
		:node( tostring( setList ) )
end

return setmetatable( {
	main = function( frame )
		return main( frame, frame:getParent().args )
	end,
}, {
	__call = function( t, arguments )
		local defaultTestArguments = {
			[ 1 ] = [=[
				YZ01-JP001; Kachi Kochi Dragon; ; Reprint; 2
				YZ02-JP001; Number 50: Blackship of Corn; ; Reprint // @Volume::2
				YZ03-JP001; Number 22: Zombiestein; ; ; Not a numeric quantity // @Volume::3
				YZ04-JP001; Number 47: Nightmare Shark; UR, SR // @Volume::4
				YZ05-JP001; Number 72: Shogi Rook // description::Bold, Italics; @Volume::5
				YZ06-JP001; Number 52: Diamond Crab King // @Volume::6
				YZ07-JP001; Number 23: Lancelot, Dark Knight of the Underworld // @Volume::7
				YZ08-JP001; Number S39: Utopia the Lightning // printed-name::Super Shiny Utopia; @Volume::8; description::And sooner as UTOPIA
				YZ09-JP001; Gagaga Head; ; ; 2 // @Volume::9
				YZ??-JP???; Gagaga Body // description:: ; @Some notes::Here, the description is inputted as empty, preventing the default description and interpolation.
				YZ01-JP001;  // @Volume:: ; @Some notes::Here, the Volume is inputted as empty, preventing the default volume and interpolation.
				YZ01-JP001; ; ; ; 2 // @Some notes:No name, default rarities, default print, but quantity.
				          ; Gagaga Neck; ; Reprint // printed-name::Super Shiny Utopia;
			]=],
			[ 'region' ]   = 'JP',
			[ 'rarities' ] = 'UR',
			[ 'print' ]    = 'New',
			[ 'qty' ]      = '1',
			[ 'columns' ]  = '$Volume::[[Yu-Gi-Oh! ZEXAL Volume $1 promotional card|Volume $1]]; Volume::[[Yu-Gi-Oh! ZEXAL Volume 1 promotional card|Volume 1 (default)]]; Some notes;',
			[ 'description' ]  = 'Default desc', 
			[ '$description' ] = 'Bold: <b>$1</b>; Italics: <i>$2</i>',
		}

		return main( mw.getCurrentFrame(), arguments or defaultTestArguments )
	end,
} )
