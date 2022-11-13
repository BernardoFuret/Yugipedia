-- <pre>
--[=[Doc
@module Card reprints tracker
@description 
]=]

local DATA = require( 'Module:Data' )
local UTIL = require( 'Module:Util' )

local Reporter = require( 'Module:Reporter' )
local IndexedCounter = require( 'Module:IndexedCounter' )

local DATA_REGIONS = DATA( 'region' )
local DATA_LANGUAGES = DATA( 'language' )

local FRENCH_CANADIAN_REGION = DATA.getRegion( 'fc' )
local ASIAN_ENGLISH_REGION = DATA.getRegion( 'ae' )

local REGIONS_TO_IGNORE = {
	[ FRENCH_CANADIAN_REGION.index ] = true,
	[ ASIAN_ENGLISH_REGION.index ] = true,
}

local function computeCategories( arguments )
	local byLanguage = IndexedCounter()

	for _, region in pairs( DATA_REGIONS ) do
		local languageFromRegion = DATA.getLanguage( region.index )

		local notAnIgnoredRegion = not REGIONS_TO_IGNORE[ region.index ]

		if byLanguage:get( languageFromRegion ) <= 1 and notAnIgnoredRegion then
			-- If not already more than 1, then count.

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

					if linesCountForRegion > 1 then
						-- If more than 1, there's no need to keep counting.

						break
					end
				end

				byLanguage:increment( languageFromRegion, linesCountForRegion )
			end
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
		eu_sets = [[

			DR3-EN192; Dark Revelation Volume 3; Super Rare
			DR3-EN192; Dark Revelation Volume 3; Super Rare
			DR3-EN192; Dark Revelation Volume 3; Super Rare

		]],
		kr_sets = [[
			TLM-KR012; The Lost Millennium; Super Rare, Ultimate Rare
		]],
		fr_sets = [[
			LDD-F001; Legend of Blue Eyes White Dragon; Ultra Rare
		]],
		fc_sets = [[
			LDD-C001; Legend of Blue Eyes White Dragon; Ultra Rare
		]],
		jp_sets = [[
			LDD-C001; Legend of Blue Eyes White Dragon; Ultra Rare
			LDD-C001; Legend of Blue Eyes White Dragon; Ultra Rare
			LDD-C001; Legend of Blue Eyes White Dragon; Ultra Rare
		]],
		ja_sets = [[]],
	} )

	local check = (
		computedCategories == '[[Category:Korean language releases without a reprint]][[Category:French language releases without a reprint]]'
	)

	mw.log( computedCategories, check )

	return check
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
