-- <pre>
--[=[Doc
@module Card reprints tracker
@description 
]=]

-- TODO: track count by region. use region object as table index key-

local DATA = require( 'Module:Data' )
local UTIL = require( 'Module:Util' )

local Reporter = require( 'Module:Reporter' )
local IndexedCounter = require( 'Module:IndexedCounter' )
local StringBuffer = require( 'Module:StringBuffer' )

local DATA_REGIONS = DATA( 'region' )
local DATA_LANGUAGES = DATA( 'language' )

local function computeCategories( arguments )
	-- local byRegion = IndexedCounter()

	local byLanguage = IndexedCounter()

	for _, region in pairs( DATA_REGIONS ) do
		local setsForRegionParameterName = region.index:lower() .. '_sets'

		local setsForRegionArgument = arguments[ setsForRegionParameterName ]

		local hasSetsForRegion = UTIL.trim( setsForRegionArgument )

		if hasSetsForRegion then
			local linesCountForRegion = 0

			for line in mw.text.gsplit( setsForRegionArgument, '\n' ) do
				local isNonEmptyLine = UTIL.trim( line )

				if isNonEmptyLine then
					linesCountForRegion = linesCountForRegion + 1
				end

				-- TODO: Optimize by breaking if > 1?
				-- TODO: calculate language at the top of the iteration and break if already > 1?
			end

			-- byRegion:increment( region, linesCountForRegion )

			local languageFromRegion = DATA.getLanguage( region.index ) -- TODO: account for Asian-English

			byLanguage:increment( languageFromRegion, linesCountForRegion )
		end
	end

	local categories = {}

	for region, regionCount in byLanguage:each() do
		if regionCount == 1 then
			local category = ( '[[Category:%s language releases without a reprint]]' )
				:format( region.full )

			table.insert( categories, category )
		end
	end 

	return table.concat( categories )
end


local function wikitextMain( frame )
	local arguments = frame:getParent().args

	return computeCategories( arguments )
end

local function test()
	local computedCategories = computeCategories( {
		en_sets = [[

			DR3-EN192; Dark Revelation Volume 3; Super Rare

		]],
		kr_sets = [[
			TLM-KR012; The Lost Millennium; Super Rare, Ultimate Rare
			SD7-KR009; Structure Deck: Invincible Fortress; Common
			HGP3-KR192; Expert Edition Volume 3; Super Rare
		]],
		fr_sets = [[
			LDD-F001; Legend of Blue Eyes White Dragon; Ultra Rare
		]],
		fc_sets = [[
			LDD-C001; Legend of Blue Eyes White Dragon; Ultra Rare
		]]
	} )

	mw.log( computedCategories )

	return computedCategories == '[[Category:English language releases without a reprint]]'
end


return setmetatable(
	{
		main = wikitextMain,
		test = test,
	},
	{
		__call = function( self, arguments )
			return computeCategories( arguments or {} )
		end,
	}
)
-- </pre>
