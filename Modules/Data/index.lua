-- <pre>
-- @name Data
-- @description Interface for Module:Database.
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
local DATA = mw.loadData( 'Module:Database' );

---------------------
-- Utility functions:
---------------------
-- mw functions:
local trim = mw.text.trim;

-- @name normalize
-- @parameter {*} «arg» - Argument to be normalize.
-- @parameter {function} «rules» - Normalization rules to apply. 
-- @description Normalizes the input applying a specific set of rules.
local function normalize( arg, rules )
	return type( arg ) == type( 'string' )
		and rules( trim( arg ):lower() )
		or nil
	;
end

-- @name normalizeGlobals
-- @description Normalizes the input for:
-- rg, region, ln, language, ed, edition,
-- rel, release, amRel, amRelease, r and rarity.
local function normalizeGlobals( arg )
	return normalize( arg, function( normalizedArg )
		return normalizedArg
			:gsub(  ' rare$', '' ) -- Remove " rare" at the end (and with a space before it).
			:gsub(      '%s', '' ) -- Remove whitespace.
			:gsub(      '%-', '' ) -- Remove dashes.
			:gsub(       '/', '' ) -- Remove slashes.
			:gsub(       "'", '' ) -- Remove apostrophe.
			:gsub(   'north', '' ) -- Remove "north".
			:gsub( 'edition', '' ) -- Remove "edition".
		;
	end );
end

-- @name normalizeSeries
-- @description Normalizes the input for: ser and series.
local function normalizeSeries( arg )
	return normalize( arg, function( normalizedArg )
		return normalizedArg
			:gsub(      '%s', '' ) -- Remove whitespace.
			:gsub(      '%-', '' ) -- Remove dashes.
			:gsub(       '/', '' ) -- Remove slashes.
			:gsub(       ':', '' ) -- Remove semi-colon.
			:gsub(       '!', '' ) -- Remove exclamation mark.
			:gsub(       "'", '' ) -- Remove apostrophe.
			:gsub(     'the', '' ) -- Remove "the".
			:gsub(     'ygo', '' ) 
			:gsub(  'yugioh', '' )
		;
	end );
end

-- @name normalizeCardGalleryTypes
-- @description Normalizes the input for: CardGallery.types.
local function normalizeCardGalleryTypes( arg )
	return normalize( arg, function( normalizedArg )
		return normalizedArg
			:gsub(    '%s', '' ) -- Remove whitespace.
			:gsub(    '%-', '' ) -- Remove dashes.
			:gsub(     's', '' ) -- Remove "s".
			:gsub( 'video', '' ) -- Remove "video".
		;
	end );
end

-----------------------
-- Methods (Interface):
-----------------------
-- @name getRg
-- @parameter {string} «arg»
-- @return {string|nil} Region index.
-- @description Gets the region index for «arg». «nil» if not found.
function D.getRg( arg )
	return DATA.rg[ normalizeGlobals( arg ) ];
end

-- @name getRegion
-- @parameter {string} «arg»
-- @return {string|nil} Region name.
-- @description Gets the region name for «arg». «nil» if not found.
function D.getRegion( arg )
	return DATA.region[ D.getRg( arg ) ];
end

-- @name getLn
-- @parameter {string} «arg»
-- @return {string|nil} Language index.
-- @description Gets the language index for «arg». «nil» if not found.
function D.getLn( arg )
	return DATA.ln[ D.getRg( arg ) ];
end

-- @name getLanguage
-- @parameter {string} «arg»
-- @return {string|nil} Language name.
-- @description Gets the language name for «arg». «nil» if not found.
function D.getLanguage( arg )
	return DATA.language[ D.getLn( arg ) ];
end

-- @name getEd
-- @parameter {string} «arg»
-- @return {string|nil} Edition abbreviation.
-- @description Gets the edition abbreviation for «arg». «nil» if not found.
function D.getEd( arg )
	return DATA.ed[ normalizeGlobals( arg ) ];
end

-- @name getEdition
-- @parameter {string} «arg»
-- @return {string|nil} Edition name.
-- @description Gets the edition name for «arg». «nil» if not found.
function D.getEdition( arg )
	return DATA.edition[ D.getEd( arg ) ];
end

-- @name getRel
-- @parameter {string} «arg»
-- @return {string|nil} Release abbreviation.
-- @description Gets the release abbreviation for «arg». «nil» if not found.
function D.getRel( arg )
	return DATA.rel[ normalizeGlobals( arg ) ];
end

-- @name getRelease
-- @parameter {string} «arg»
-- @return {string|nil} Release name.
-- @description Gets the release name for «arg». «nil» if not found.
function D.getRelease( arg )
	return DATA.release[ D.getRel( arg ) ];
end

-- @name getAnimeMangaRel
-- @parameter {string} «arg»
-- @return {string|nil} Anime and manga release abbreviation.
-- @description Gets the anime and manga release abbreviation for «arg». «nil» if not found.
function D.getAnimeMangaRel( arg )
	return DATA.amRel[ normalizeGlobals( arg ) ];
end

-- @name getAnimeMangaRelease
-- @parameter {string} «arg»
-- @return {string|nil} Anime and manga release name.
-- @description Gets the anime and manga release name for «arg». «nil» if not found.
function D.getAnimeMangaRelease( arg )
	return DATA.amRelease[ D.getAnimeMangaRel( arg ) ];
end

-- @name getR
-- @parameter {string} «arg»
-- @return {string|nil} Rarity abbreviation.
-- @description Gets the rarity abbreviation for «arg». «nil» if not found.
function D.getR( arg )
	return DATA.r[ normalizeGlobals( arg ) ];
end

-- @name getRarity
-- @parameter {string} «arg»
-- @return {string|nil} Rarity name.
-- @description Gets the rarity name for «arg». «nil» if not found.
function D.getRarity( arg )
	return DATA.rarity[ D.getR( arg ) ];
end

-- @name getAnimeSer
-- @parameter {string} «arg»
-- @return {string|nil} Anime series code.
-- @description Gets the anime series code for «arg». «nil» if not found.
function D.getAnimeSer( arg )
	return DATA.ser.anime[ normalizeSeries( arg ) ];
end

-- @name getAnimeSeries
-- @parameter {string} «arg»
-- @return {string|nil} Anime series name.
-- @description Gets the anime series name for «arg». «nil» if not found.
function D.getAnimeSeries( arg )
	return DATA.series.anime[ D.getAnimeSer( arg ) ];
end

-- @name getMangaSer
-- @parameter {string} «arg»
-- @return {string|nil} Manga series code.
-- @description Gets the manga series code for «arg». «nil» if not found.
function D.getMangaSer( arg )
	return DATA.ser.manga[ normalizeSeries( arg ) ];
end

-- @name getMangaSeries
-- @parameter {string} «arg»
-- @return {string|nil} Manga series name.
-- @description Gets the manga series name for «arg». «nil» if not found.
function D.getMangaSeries( arg )
	return DATA.series.manga[ D.getMangaSer( arg ) ];
end

-- @name getCardGalleryType
-- @parameter {string} «arg»
-- @return {string|nil} {{Card gallery}} {{{type}}}.
-- @description Gets the {{Card gallery}} type for «arg». «nil» if not found.
function D.getCardGalleryType( arg )
	return DATA['Card gallery'].types[ normalizeCardGalleryTypes( arg ) ];
end

----------
-- Return:
----------
return D;
-- </pre>