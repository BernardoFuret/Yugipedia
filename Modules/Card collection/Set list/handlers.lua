-- <pre>
--[=[Doc
@module 
@description 
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
TODO:
- Cleanup
- Refactor: split responsibilities more strictly;
- Sort and display columns in alphabetical order?
- Validate default quantity as a number
- A list of only invalid and empty rarities on an entry will
generate error messages, but will default to general rarities.

- What's not being tracked:
-- Validation of row options (admissible values, including columns)
]=]

local DATA = require( 'Module:Data' )
local UTIL = require( 'Module:Util' )

local StringBuffer = require( 'Module:StringBuffer' )

local REGION_ENGLISH = DATA.getRegion( 'English' )

local LANGUAGE_ENGLISH = DATA.getLanguage( 'English' )

local mwHtmlCreate = mw.html.create
local mwTextGsplit = mw.text.gsplit

local function getRegion( self, rawRegion )
	local region = DATA.getRegion( rawRegion )

	if not region then
		local message = ( 'Invalid `region` provided: `%s`!' )
			:format( rawRegion )

		local category = 'transclusions with invalid region'

		self.reporter
			:addError( message )
			:addCategory( category )

		return REGION_ENGLISH
	end

	return region
end

local function parseRarities( self, rawRarities, location )
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
				local message = ( 'No such rarity for `%s`, at %s, at non-empty position %d!' )
					:format( rawRaritiy, location, nonEmptyposition )

				local category = 'transclusions with invalid rarities'

				self.reporter
					:addError( message )
					:addCategory( category )
			end
		else
			local message = ( 'Empty rarity input, at %s, at position %d!' )
				:format( location, position )

			local category = 'transclusions with empty rarities'

			self.reporter
				:addError( message )
				:addCategory( category )
		end
	end

	return rarities
end

local function columnsHandler( columns, columnName, columnValue )
	local columnName, interpolation = columnName:gsub( '^%$', '' )

	columns[ columnName ] = columns[ columnName ] or {}

	if interpolation ~= 0 then
		columns[ columnName ].template = columnValue
	else
		columns[ columnName ].default = columnValue
	end
end

local function createHeader( self, id, text )
	local cssClass = self.utils:makeCssClass( 'main', 'header' )

	return tostring( mwHtmlCreate( 'th' )
		:attr( 'scope', 'col' )
		:addClass( cssClass )
		:addClass( ( '%s--%s' ):format( cssClass, id ) )
		:wikitext( text )
	)
end

local function createHeaderRow( self, globalData )
	local headerTr = mwHtmlCreate( 'tr' )

	if not globalData.options.noabbr then
		headerTr:node( createHeader( self, 'card-number', 'Card number' ) )
	end

	if globalData.language.index == LANGUAGE_ENGLISH.index then
		headerTr:node( createHeader( self, 'name', 'Name' ) )
	else
		headerTr
			:node( createHeader( self, 'name', 'English name' ) )
			:node( createHeader( self, 'localized-name', globalData.language.full .. ' name' ) )
	end

	headerTr
		:node( createHeader( self, 'rarity', 'Rarity' ) )
		:node( createHeader( self, 'category', 'Category' ) )

	if globalData.print then
		headerTr:node( createHeader( self, 'print', 'Print' ) )
	end

	if globalData.qty then
		headerTr:node( createHeader( self, 'quantity', 'Quantity' ) )
	end

	for columnName, _ in pairs( globalData.columns ) do
		local columnId = columnName:lower():gsub( '%s+', '-' )

		headerTr:node( createHeader( self, columnId, columnName ) )
	end

	return tostring( headerTr )
end

local function createCell( text )
	return tostring( mwHtmlCreate( 'td' )
		:wikitext( text )
	)
end

local handlers = {}

function handlers:initData( globalData )
	globalData.rarities = parseRarities( self, globalData.rarities, 'parameter `rarities`' )

	globalData.options = self.utils:parseOptions( globalData.options, 'parameter `options`' )

	globalData.columns = self.utils:parseOptions( globalData.columns, 'parameter `columns`', columnsHandler )

	globalData.region = getRegion( self, globalData.region )

	globalData.language = DATA.getLanguage( globalData.region.index )
end

function handlers:initStructure( globalData )
	return mwHtmlCreate( 'table' )
		:addClass( 'wikitable' )
		:addClass( 'sortable' )
		:addClass( 'card-list' )
		:node( createHeaderRow( self, globalData ) )
end

function handlers:handleRow( row, globalData ) -- TODO: refactor: extract functions
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
				cardNameInput:match( 'Token%s%(' ) and cardNameInput
			),
			LANGUAGE_ENGLISH.index
		) or ''

		local printedNameInput = row.options[ 'printed-name' ]

		local printedNameValidated = UTIL.trim( printedNameInput )

		if printedNameInput and not printedNameValidated then
			local message = ( 'Empty `printed-name` is not allowed at line %d!' )
				:format( row.lineno )

			local category = 'transclusions with empty printed-name'

			self.reporter
				:addError( message )
				:addCategory( category )
		end

		if printedNameValidated and not cardNameInput then
			local message = ( 'Cannot use `printed-name` option when there isn\'t a card name, at line %d!' )
				:format( row.lineno )

			local category = 'transclusions with printed-name but no card name'

			self.reporter
				:addError( message )
				:addCategory( category )

			printedNameValidated = nil
		end

		local printedName = printedNameValidated
			and ( '(as %s)' ):format(
				UTIL.wrapInQuotes(
					printedNameValidated,
					globalData.language.index
				)
			)

		local description = self.utils:handleInterpolation( -- TODO: should only be considered if there's a cardNameInput? Or if the user adds it, it should be added? Display default or blank if there isn't a cardNameInput?
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
					DATA.getName(
						cardNameInput:gsub( '#', '' ),
						globalData.language
					),
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

		local linkedRarities = parseRarities(
			self,
			raritiesInput or '',
			( 'line %d' ):format( row.lineno )
		)

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
		local qtyInput = UTIL.trim( row.values[ valuesIndex ] )

		local qtyNumber = tonumber( qtyInput )

		if qtyInput and not qtyNumber then
			local message = ( 'Invalid quantity value at line %d! Cannot parse `%s` as a number!' )
				:format( row.lineno, qtyInput )

			local category = 'transclusions with invalid quantity values'

			self.reporter
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

		local columnContent = self.utils:handleInterpolation(
			columnInput,
			columnData.template,
			columnData.default
		)

		rowTr:node( createCell( columnContent ) )
	end

	return tostring( rowTr )
end

return handlers
-- </pre>
