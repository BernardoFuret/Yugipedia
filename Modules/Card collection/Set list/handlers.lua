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

					table.insert( rarities, UTIL.link( rarity.full, rarity.full ) )
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
	self.reporter:dumpCategoriesWhen( function( default )
		return (
			default
			and
			mw.title.getCurrentTitle().namespace ~= 0
		)
	end )

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

	local data = self:readData( entry, globalData )

	self:validateData( data, entry )

	-- If there is a card number column, add a cell for it
	if not globalData.options.noabbr then
		-- If the card number exists and isn't "?", add a link to it.
		local cardNumberContent = data.cardNumber
			and ( ( data.cardNumber:match( '?' ) or not data.card )
				and cardNumberInput
				or UTIL.link( data.cardNumber )
			)
			or ''

		-- Add its cell to the row
		rowTr:node( createCell( cardNumberContent ) )
	end

	do
		-- Add link and quotes to the card name
		local cardNameFormatted = data.card and UTIL.wrapInQuotes(
			UTIL.link(
				data.tokenLink or data.card,
				data.name
			),
			LANGUAGE_ENGLISH.index
		) or ''

		-- Add quotes to the printed name
		-- Prepend with "as " and put in parenheses
		local printedNameFormatted = data.printedName
			and ( '(as %s)' ):format(
				wrapLocalizedName(
					UTIL.wrapInQuotes(
						data.printedName,
						globalData.language.index
					),
					globalData.language
				)
			)

		local languageIsEnglish = globalData.language.index == LANGUAGE_ENGLISH.index

		-- Get the content for the "(English) name" cell.
		local cardNameCellContent = StringBuffer()
			:add( cardNameFormatted )
			-- Include printed name if specified and this is an English list
			:add( languageIsEnglish and printedNameFormatted or nil )
			-- Include the description, if applicable
			:add( data.description )
			:flush( ' ' )
			:toString()

		-- Add its cell to the row.
		rowTr:node( createCell( cardNameCellContent ) )

		if not languageIsEnglish then
			-- Wrap the local name in quotes.
			-- And wrap in `span` with `lang` attribute.
			local localNameFormatted = data.card
				and wrapLocalizedName(
					UTIL.wrapInQuotes(
						data.localName,
						globalData.language.index
					),
					globalData.language
				)

			-- Get the content for the local name cell
			local cardLocalizedNameCellContent = StringBuffer()
				:add( localNameFormatted )
				-- Add the printed name, if specified
				:add( printedNameFormatted or nil )
				:flush( ' ' )
				:toString()

			-- Add the cell to the row
			rowTr:node( createCell( cardLocalizedNameCellContent ) )
		end
	end

	do
		local linkedRarities = parseRarities(
			self,
			data.rarities,
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
	end

	-- Add the category cell to the row
	rowTr:node( createCell( data.categories ) )

	-- Print:
	if globalData.print then
		-- DOC: if print is empty, don't override default value (just treat as nil).
		-- This is to prevent overriding when qty is being used and we want the default print value.
		rowTr:node( createCell( data.print or globalData.print ) )
	end

	-- Quantity:
	if globalData.qty then
		rowTr:node( createCell( data.qty ) )
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

-- Extra data from the `entry`, ensuring it is formatted appropriately
function handlers:readData( entry, globalData )
	-- Object with all the default values
	local data = {
		lineno      = entry.lineno,
		cardNumber  = nil,
		card        = nil, -- Page name
		name        = nil, -- English name
		localName   = nil, -- Standard name in the printed language
		printedName = nil, -- Name used in this specific print, if different
		rarities    = nil, -- Comma-separated list of rarity names
		description = nil,
		['print']   = nil, -- e.g. "new" or "reprint"
		qty         = nil, -- for sets where cards have fixed quantities e.g. Structure Decks
		category    = nil, -- Normal Spell, Effect Monster, etc.
		tokenLink   = nil
	}

	--[[
		Extract data from the entry
	--]]
	-- Determine what each unnamed input param refers to.

	-- Build an array where each property's position in the array says what
	-- position it can be found the unnamed parameters.
	local inputCols = {}

	if ( not globalData.options.noabbr ) then
		table.insert( inputCols, 'cardNumber' )
	end

	table.insert( inputCols, 'card' )

	table.insert( inputCols, 'rarities' )

	if ( globalData.print ) then
		table.insert( inputCols, 'print' )
	end

	if ( globalData.qty ) then
		table.insert( inputCols, 'qty' )
	end

	-- Get data from each unnamed param.
	for i, key in pairs( inputCols ) do
		data[ key ] = UTIL.trim( entry.values [ i ] )
	end

	-- Get data from named params
	data.printedName = UTIL.trim( entry.options[ 'printed-name' ] )

	data.description = entry.options.description

	--[[
		Normalize data from the params
	--]]
	data.card = data.card and data.card:gsub( '#', '' )

	-- Get the Token link and description
	data.tokenLink = ( data.card or '' ):match( 'Token%s%(' ) and UTIL.removeDab( data.card )

	local tokenDab = ( data.card or '' ):match( 'Token%s%(' ) and UTIL.getDab( data.card )

	local tokenDescription = tokenDab
		and UTIL.link( data.card, ( '(%s)' ):format( tokenDab ) )
		or nil

	data.description = self.utils:handleInterpolation(
		data.description,
		globalData[ '$description' ],
		globalData.description
	) or tokenDescription

	-- If there is a default quantity, fall back to it
	if ( globalData.qty ) then
		data.qty = getQty(
			self,
			data.qty,
			( 'line %d' ):format( data.lineno ),
			globalData.qty
		)
	end

	--[[
		Perform data lookups
	--]]
	-- Get the English name via SMW query, if `force-SMW` is set.
	-- Otherwise, get from the input.
	data.name = entry.options[ 'force-SMW' ]
		and DATA.getName( data.card, LANGUAGE_ENGLISH )
		or ( ( data.card or '' ):match( 'Token%s%(' ) and UTIL.removeDab( data.card ) )

	-- Look up the local card name for non-English lists.
	if not languageIsEnglish and data.card then
		data.localName = DATA.getName( data.card, globalData.language )
	end

	-- Look up the card's category
	data.categories = data.card and DATA.getFullCardType( data.card )

	return data
end

function handlers:validateData( data, entry )
	-- If the printed name was supplied but is empty after trimming
	if entry.options[ 'printed-name' ] and not data.printedName then
		local message = ( 'Empty `printed-name` is not allowed at line %d!' )
			:format( data.lineno )

		self.reporter
			:addError( message )
			:addCategory( 'transclusions with empty printed-name' )
	end

	if data.printedName and not data.card then
		local message = ( "Cannot use `printed-name` option when there isn't a card name, at line %d!" )
			:format( data.lineno )

		self.reporter
			:addError( message )
			:addCategory( 'transclusions with printed-name but no card name' )
	end
end

return handlers
-- </pre>
