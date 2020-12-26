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
- An input of only invalid and empty rarities on an entry will
generate error messages, but will default to general rarities.

- What's not being tracked:
-- Validation of entry options (admissible values, including columns)
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

	local duplicated = {}

	local position = 0

	local nonEmptyposition = 0

	for rawRaritiy in mwTextGsplit( rawRarities, '%s*,%s*' ) do
		position = position + 1

		local rawRaritiy = UTIL.trim( rawRaritiy )

		if rawRaritiy then
			nonEmptyposition = nonEmptyposition + 1

			local rarity = DATA.getRarity( rawRaritiy )

			if rarity then
				if duplicated[ rarity.full ] then
					local message = ( 'Duplicate rarity `%s` (same as `%s`, at non-empty position %d), at %s, at non-empty position %d!' )
						:format(
							rawRaritiy,
							duplicated[ rarity.full ].input,
							duplicated[ rarity.full ].nonEmptyposition,
							location,
							nonEmptyposition
						)

					local category = 'transclusions with duplicate rarities'

					self.reporter
						:addError( message )
						:addCategory( category )
				else
					duplicated[ rarity.full ] = {
						input = rawRaritiy,
						nonEmptyposition = nonEmptyposition,
					}

					table.insert( rarities, UTIL.link( rarity.full ) )
				end
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

local function getQty( self, rawQty, location, default )
	local qty = UTIL.trim( rawQty )

	if qty and not qty:match( '^[%d%-]+$') then
		local message = ( 'Invalid quantity `%s`, at %s! Expecting number or range.' )
			:format( rawQty, location )

		local category = 'transclusions with invalid quantity values'

		self.reporter
			:addError( message )
			:addCategory( category )

		return ''
	end

	return qty or default
end

local function columnsTemplatesHandler( columns, columnName, columnValue )
	columns[ columnName ] = {
		template = columnValue,
	}
end

local function columnsHandler( columns, columnName, columnValue )
	columns[ columnName ] = columns[ columnName ] or {}
	
	columns[ columnName ].default = columnValue
end

local function wrapLocalizedName( name, language )
	return name and tostring( mwHtmlCreate( 'span' )
		:attr{ lang = language.index }
		:wikitext( name )
	)
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
	globalData.region = getRegion( self, globalData.region )

	globalData.language = DATA.getLanguage( globalData.region.index )

	globalData.rarities = parseRarities( self, globalData.rarities, 'parameter `rarities`' )

	globalData.qty = getQty( self, globalData.qty, 'parameter `qty`', globalData.qty )

	globalData.options = self.utils:parseOptions( globalData.options, 'parameter `options`' )

	local columnsTemplates = self.utils:parseOptions( globalData[ '$columns' ], 'parameter `columns`', {
		handler = columnsTemplatesHandler,
	} )

	globalData.columns = self.utils:parseOptions( globalData.columns, 'parameter `columns`', {
		initial = columnsTemplates,
		handler = columnsHandler,
	} )
end

function handlers:initStructure( globalData )
	return mwHtmlCreate( 'table' )
		:addClass( 'wikitable' )
		:addClass( 'sortable' )
		:addClass( 'card-list' )
		:node( createHeaderRow( self, globalData ) )
end

function handlers:handleEntry( entry, globalData ) -- TODO: refactor: extract functions
	local rowTr = mwHtmlCreate( 'tr' )

	local valuesIndex = 1

	local cardNameInput

	-- Card number:
	if not globalData.options.noabbr then
		local cardNumberInput = UTIL.trim( entry.values[ valuesIndex ] )

		cardNameInput = UTIL.trim( entry.values[ valuesIndex + 1 ] ) -- TODO: move to outer scope (all *Input )

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

		cardNameInput = UTIL.trim( entry.values[ valuesIndex ] ) -- TODO: move to outer scope (all *Input )

		local cardNameDisplay = entry.options[ 'force-SMW' ]
			and DATA.getName( cardNameInput, LANGUAGE_ENGLISH )
			or ( ( cardNameInput or '' ):match( 'Token%s%(' ) and cardNameInput )

		local cardName = cardNameInput and UTIL.wrapInQuotes(
			UTIL.link(
				cardNameInput,
				cardNameDisplay
			),
			LANGUAGE_ENGLISH.index
		) or ''

		local printedNameInput = entry.options[ 'printed-name' ]

		local printedNameValidated = UTIL.trim( printedNameInput )

		if printedNameInput and not printedNameValidated then
			local message = ( 'Empty `printed-name` is not allowed at line %d!' )
				:format( entry.lineno )

			local category = 'transclusions with empty printed-name'

			self.reporter
				:addError( message )
				:addCategory( category )
		end

		if printedNameValidated and not cardNameInput then
			local message = ( 'Cannot use `printed-name` option when there isn\'t a card name, at line %d!' )
				:format( entry.lineno )

			local category = 'transclusions with printed-name but no card name'

			self.reporter
				:addError( message )
				:addCategory( category )

			printedNameValidated = nil
		end

		local printedName = printedNameValidated
			and ( '(as %s)' ):format(
				wrapLocalizedName(
					UTIL.wrapInQuotes(
						printedNameValidated,
						globalData.language.index
					),
					globalData.language
				)
			)

		local description = self.utils:handleInterpolation(
			entry.options.description,
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
				and wrapLocalizedName(
					UTIL.wrapInQuotes(
						DATA.getName(
							cardNameInput:gsub( '#', '' ),
							globalData.language
						),
						globalData.language.index
					),
					globalData.language
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
		local raritiesInput = entry.values[ valuesIndex ]

		local linkedRarities = parseRarities(
			self,
			raritiesInput,
			( 'line %d' ):format( entry.lineno )
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
		local printInput = UTIL.trim( entry.values[ valuesIndex ] )

		rowTr:node( createCell( printInput or globalData.print ) )

		valuesIndex = valuesIndex + 1
	end

	-- Quantity:
	if globalData.qty then
		local qtyInput = entry.values[ valuesIndex ]

		local qtyNumber = getQty(
			self,
			qtyInput,
			( 'line %d' ):format( entry.lineno ),
			globalData.qty
		)

		rowTr:node( createCell( qtyNumber ) )

		valuesIndex = valuesIndex + 1
	end

	-- Extra columns
	for columnName, columnData in pairs( globalData.columns ) do
		local columnInput = entry.options[ '@' .. columnName ]

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
