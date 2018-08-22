-- <pre>
-- @name Data
-- @description Interface for [[Module:Data/data]].
-- @notes Internal-only, so far.
-- @author [[User:Becasita]]
-- @contact [[User talk:Becasita]]

-------------------
-- Export variable:
-------------------
local D = {};

--------------
-- Load data:
--------------
local DATA = mw.loadData( 'Module:Data/data' );
local NORM = DATA.normalize -- mw.loadData( 'Module:Data/normalize' );

-------------
-- Constants:
-------------
-- @description
--local WORD_DELIMITERS = "[%s%-_]";

---------------------
-- Utility functions:
---------------------
-- mw functions:
local trim = mw.text.trim;

-- @name normalize
-- @description Normalizes the input applying a specific set of rules.
-- The rules are applied in case the input is of the type `string`
-- @parameter {*} arg Argument to be normalized.
-- @parameter {function} rules Normalization rules to apply.
-- @return A generally normalized arg to be used to index the normalization table.
local function normalize( arg, rules )
	return type( arg ) == type( 'string' )
		and rules( trim( arg ):lower() )
		or nil
	;
end

-- @name normalizeRegionLanguageMedium
-- @description Normalizes the input for region, language and medium,
-- since there are dependencies between these.
-- @parameter {*} arg Argument to be normalized.
-- @return A normalized arg to be used to index the normalization table.
local function normalizeRegionLanguageMedium( arg )
	return normalize( arg, function( normalizedArg )
		return normalizedArg
			:gsub( "[%s%-_'!]", '' ) -- Remove a bunch of commonly used characters.
			:gsub(     'north', '' ) -- Remove "north" (for region and language).
			:gsub(    'yugioh', '' ) -- Remove "yugioh" (becuase of the medium).
			:gsub(  'cardgame', '' ) -- Remove "cardgame" (because of the medium).
		;
	end );
end

-- @name normalizeRarity
-- @description Normalizes the input for rarity.
-- @parameter {*} arg Argument to be normalized.
-- @return A normalized arg to be used to index the normalization table.
--[[local function normalizeRarity( arg )
	return normalize( arg, function( normalizedArg )
		return NORM.rarity[ normalizedArg
			:gsub(   ' rare$', '' ) -- Remove " rare" at the end (and with a space before it).
			:gsub( "[%s%-_']", '' ) -- Remove a bunch of commonly used characters.
		];
	end );
end--]]

-----------------------
-- Methods (Interface):
-----------------------
-- @name getRegion
-- @description Gets the region for `arg`. `nil` if not found.
-- @parameter {string} arg
-- @return {table|nil} A region or nil.
function D.getRegion( arg )
	return DATA.region[
		NORM.region[
			normalizeRegionLanguageMedium( arg )
		]
	];
end

-- @name getLanguage
-- @description Gets the language for `arg`. `nil` if not found.
-- @parameter {string} arg
-- @return {table|nil} A language or nil.
function D.getLanguage( arg )
	return DATA.language[
		NORM.language[
			NORM.region[
				normalizeRegionLanguageMedium( arg )
			]
		]
	];
end

-- @name getMedium
-- @description Gets the language for `arg`. `nil` if not found.
-- @parameter {string} arg
-- @return {table|nil} A language or nil.
function D.getMedium( arg )
	local normalizedArg = normalizeRegionLanguageMedium( arg );
	return DATA.medium[
		NORM.medium[
			NORM.region[
				normalizedArg
			] or normalizedArg
		]
	];
end

-- @name getEdition
-- @description Gets the edition for `arg`. `nil` if not found.
-- @parameter {string} arg
-- @return {string|nil} An edition or nil.
function D.getEdition( arg )
	return DATA.edition[
		normalize( arg, function( normalizedArg )
			return NORM.edition[ normalizedArg
				:gsub( '[%s%-_]', '' ) -- Remove a bunch of commonly used characters.
				:gsub( 'edition', '' ) -- Redundant.
			];
		end )
	];
end

-- @name getRelease
-- @description Gets the release for `arg`. `nil` if not found.
-- @parameter {string} arg
-- @return {string|nil} A release or `nil`.
function D.getRelease( arg )
	return DATA.release[
		normalize( arg, function( normalizedArg )
			return NORM.release[ normalizedArg
				:gsub(  '[%s%-_]', '' ) -- Remove a bunch of commonly used characters.
				:gsub(     'case', '' ) -- for "Case Topper".
				:gsub(     'card', '' ) -- for "Giant Card".
				:gsub( 'official', '' ) -- For "Official Proxy".
			];
		end )
	];
end

-- @name getRarity
-- @description Gets the rarity for `arg`. `nil` if not found.
-- @parameter {string} arg
-- @return {string|nil} A rarity or `nil`.
function D.getRarity( arg )
	return DATA.rarity[
		normalize( arg, function( normalizedArg )
			return NORM.rarity[ normalizedArg
				:gsub(   ' rare$', '' ) -- Remove " rare" at the end (and with a space before it).
				:gsub( "[%s%-_']", '' ) -- Remove a bunch of commonly used characters.
			];
		end )
	];
end

---------------
-- Anime stuff:
---------------
-- @name getAnimeRelease
-- @description Gets the anime release for `arg`. `nil` if not found.
-- @parameter {string} arg
-- @return {string|nil} Anime release or `nil`.
function D.getAnimeRelease( arg )
	return DATA.anime.release[
		normalize( arg, function( normalizedArg )
			return NORM.anime.release[ normalizedArg
				:gsub( '[%s%-_]', '' ) -- Remove a bunch of commonly used characters.
			];
		end )
	];
end

-- @name getAnimeSeries
-- @description Gets the anime series name for `arg`. `nil` if not found.
-- @parameter {string} arg
-- @return {string|nil} Anime series or `nil`.
function D.getAnimeSeries( arg )
	return DATA.anime.series[
		normalize( arg, function( normalizedArg )
			return NORM.anime.series[ normalizedArg
				:gsub( "[%s%-_'/:!]", '' ) -- Remove a bunch of commonly used characters.
				:gsub(         'the', '' )
				:gsub(         'ygo', '' ) 
				:gsub(      'yugioh', '' )
			];
		end )
	];
end

---------------
-- Manga stuff:
---------------
-- @name getMangaRelease
-- @description Gets the manga release for `arg`. `nil` if not found.
-- @parameter {string} arg
-- @return {string|nil} Manga release or `nil`.
function D.getMangaRelease( arg )
	return DATA.manga.release[
		normalize( arg, function( normalizedArg )
			return NORM.manga.release[ normalizedArg
				:gsub( '[%s%-_]', '' ) -- Remove a bunch of commonly used characters.
			];
		end )
	];
end

-- @name getMangaSeries
-- @description Gets the manga series name for `arg`. `nil` if not found.
-- @parameter {string} arg
-- @return {string|nil} Manga series or `nil`.
function D.getMangaSeries( arg )
	return DATA.manga.series[
		normalize( arg, function( normalizedArg )
			return NORM.manga.series[ normalizedArg
				:gsub( "[%s%-_'/:!]", '' ) -- Remove a bunch of commonly used characters.
				:gsub(         'the', '' )
				:gsub(   'strongest', '' )
				:gsub(         'ygo', '' ) 
				:gsub(      'yugioh', '' )
			];
		end )
	];
end

-------------------
-- Templates stuff:
-------------------
-- @name getCardGalleryType
-- @description Gets the `{{Card gallery}}` type for `arg`. `nil` if not found.
-- @parameter {string} arg
-- @return {string|nil} `{{Card gallery}}` possible `{{{type}}}`s.
function D.getCardGalleryType( arg )
	return DATA.templates[ 'Card gallery' ].types[
		normalize( arg, function( normalizedArg )
			return normalizedArg
				:gsub( "[%s%-s]", '' ) -- Remove a bunch of commonly used characters.
				:gsub(   'video', '' ) -- Remove "video".
			;
		end )
	];
end

----------
-- Return:
----------
-- @exports `D`: Interface to interact with [[Module:Data/data]].
return D;
-- </pre>