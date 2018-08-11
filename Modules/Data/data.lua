-- <pre>
-- @name Database
-- @description Serves as database for the other modules.
-- NEVER INTERACT DIRECTLY WITH THIS MODULE. USE [[Module:Data]].

-- @name rg
-- @description Region indexes. Main map.
local rg = {
	-- Worldwide English (EN):
	['en'] = 'en', ['ew'] = 'en', ['we'] = 'en', ['ww'] = 'en',
	['english'] = 'en', ['worldwide'] = 'en',
	['worldwideenglish'] = 'en', ['englishworldwide'] = 'en',

	-- North American English (NA): (filter 'north')
	['na'] = 'na', ['american'] = 'na', ['americanenglish'] = 'na',

	-- European English (EU):
	['eu'] = 'eu', ['e'] = 'eu', ['european'] = 'eu', ['europeanenglish'] = 'eu',

	-- Australian/Oceanic English (AU/OC):
	['au'] = 'au', ['australian'] = 'au', ['australianenglish'] = 'au',
	['oc'] = 'oc', ['oceanic']    = 'oc', ['oceanicenglish']    = 'oc',

	-- French (FR):
	['fr'] = 'fr', ['f'] = 'fr', ['french'] = 'fr',

	-- French Canadian (FC):
	['fc'] = 'fc', ['c'] = 'fc', ['canadian'] = 'fc', ['frenchcanadian'] = 'fc',

	-- German (DE):
	['de'] = 'de', ['g'] = 'de', ['german'] = 'de',

	-- Italian (IT):
	['it'] = 'it', ['i'] = 'it', ['italian'] = 'it',

	-- Portuguese (PT):
	['pt'] = 'pt', ['p'] = 'pt', ['portuguese'] = 'pt',

	-- Spanish (SP):
	['sp'] = 'sp', ['es'] = 'sp', ['s'] = 'sp', ['spanish'] = 'sp',

	-- Japanese (JP):
	['jp'] = 'jp', ['j'] = 'jp', ['jap'] = 'jp', ['japanese'] = 'jp', 

	-- Japanese Asian (JA):
	['ja'] = 'ja', ['japaneseasian'] = 'ja', ['asianjapanese'] = 'ja', 

	-- Asian English (AE):
	['ae'] = 'ae', ['asianenglish'] = 'ae', ['englishasian'] = 'ae',

	-- Chinese (TC):
	['tc'] = 'tc', ['zh'] = 'tc', ['ch'] = 'tc', ['chinese'] = 'tc',

	-- Korean (KR):
	['kr'] = 'kr', ['ko'] = 'kr', ['k'] = 'kr', ['korean'] = 'kr',
};

-- @name region
-- @description Region names.
local region = {
	['en'] = 'Worldwide English',
	['na'] = 'North American English',
	['eu'] = 'European English',
	['au'] = 'Australian English', ['oc'] = 'Oceanic English', -- TODO: check this.
	['fr'] = 'French',  ['fc'] = 'French-Canadian',
	['de'] = 'German',
	['it'] = 'Italian',
	['pt'] = 'Portuguese',
	['es'] = 'Spanish', ['sp'] = 'Spanish',
	['jp'] = 'Japanese',
	['ja'] = 'Japanese-Asian',
	['ae'] = 'Asian-English',
	['tc'] = 'Chinese', ['zh'] = 'Chinese',
	['ko'] = 'Korean',  ['kr'] = 'Korean',
};

-- @name ln
-- @description Language indexes.
local ln = {
	['en'] = 'en',
	['na'] = 'en',
	['eu'] = 'en',
	['au'] = 'en', ['oc'] = 'en',
	['fr'] = 'fr', ['fc'] = 'fr',
	['de'] = 'de',
	['it'] = 'it',
	['pt'] = 'pt',
	['es'] = 'es', ['sp'] = 'es',
	['jp'] = 'ja', ['ja'] = 'ja',
	['ae'] = 'en',
	['tc'] = 'zh', ['zh'] = 'zh',
	['ko'] = 'ko', ['kr'] = 'ko',
};

-- @name language
-- @description Language names.
local language = {
	['en'] = 'English',
	['fr'] = 'French',
	['de'] = 'German',
	['it'] = 'Italian',
	['pt'] = 'Portuguese',
	['es'] = 'Spanish',
	['ja'] = 'Japanese',
	['zh'] = 'Chinese',
	['ko'] = 'Korean',
};

-- @name ed
-- @description Edition abbreviations.
local ed = {
	['1e'] = '1e', ['1'] = '1e', ['first']     = '1e', ['1st'] = '1e',
	['ue'] = 'ue', ['u'] = 'ue', ['unlimited'] = 'ue',
	['le'] = 'le', ['l'] = 'le', ['limited']   = 'le',
	['dt'] = 'dt',            ['duelterminal'] = 'dt',
};

-- @name edition
-- @description Edition names.
local edition = {
	['1e'] = '1st Edition',
	['ue'] = 'Unlimited Edition',
	['le'] = 'Limited Edition',
	['dt'] = 'Duel Terminal',
};

-- @name rel
-- @description Release abbreviations.
local rel = {
	['op'] = 'op', ['proxy']   = 'op', ['officialproxy'] = 'op',
	['gc'] = 'gc', ['giant']   = 'gc', ['giantcard']     = 'gc',
	['ct'] = 'ct', ['topper']  = 'ct', ['casetopper']    = 'ct',
	['rp'] = 'rp', ['replica'] = 'rp',
};

-- @name release
-- @description Release names.
local release = {
	['op'] = 'Official Proxy',
	['gc'] = 'Giant Card',
	['ct'] = 'Case Topper',
	['rp'] = 'Replica',
};

-- @name amRel
-- @description Anime and manga release abbreviations.
local amRel = {
	['nc'] = 'nc', ['noncard'] = 'nc',
	['ca'] = 'ca', ['cardart'] = 'ca', ['art'] = 'ca',
};

-- @name amRelease
-- @description Anime and manga release names.
local amRelease = {
	['nc'] = 'Non-card',
	['ca'] = 'Card art',
};

-- @name r
-- @description Rarity abbreviations.
-- TODO
local r = {
	-- Stadard non-foils:
	['c']    = 'C',      ['common']          = 'C',  ['n'] = 'C',
	['nr']   = 'NR',     ['normal']          = 'NR',
	['sp']   = 'SP',     ['shortprint']      = 'SP',
	['ssp']  = 'SSP',    ['supershortprint'] = 'SSP',
	['r']    = 'R',      ['rare']            = 'R',

	-- Stadard foils:
	['sr']   = 'SR',     ['super']       = 'SR',
	['ur']   = 'UR',     ['ultra']       = 'UR',
	['utr']  = 'UtR',    ['ultimate']    = 'UtR',
	['gr']   = 'GR',     ['ghost']       = 'GR',
	['hgr']  = 'HGR',    ['holographic'] = 'HGR',

	-- Secrets:
	['scr']   = 'ScR',   ['secret']      = 'ScR',
	['pscr']  = 'PScR',  ['prismatic']   = 'PScR', ['prismaticsecret'] = 'PScR',
	['uscr']  = 'UScR',  ['ultrasecret'] = 'UScR',
	['scur']  = 'ScUR',  ['secretultra'] = 'ScUR',
	['20scr'] = '20ScR', ['20thsecret']  = '20ScR',
	['escr']  = 'EScR',  ['extrasecret'] = 'EScR',

	-- Precious:
	['gur']   = 'GUR',   ['gold']           = 'GUR', ['goldultra'] = 'GUR',
	['gscr']  = 'GScR',  ['goldsecret']     = 'GScR',
	['ggr']   = 'GGR',   ['ghostgold']      = 'GGR',
	['pir']   = 'PIR',   ['platinum']       = 'PIR',
	['piscr'] = 'PIScR', ['platinumsecret'] = 'PIScR',

	-- Millennium:
	['mlr']   = 'MLR',   ['millennium']      = 'MLR',
	['mlsr']  = 'MLSR',  ['millenniumsuper'] = 'MLSR',
	['mlur']  = 'MLUR',  ['millenniumultra'] = 'MLUR',
	['mlscr'] = 'MLScR', ['millenniumultra'] = 'MLUR',
	['mlgr']  = 'MLGR',  ['millenniumgold']  = 'MLGR', -- Why not MLGUR?

	-- Parallel:
	['npr']   = 'NPR',   ['normalparallel']      = 'NPR',
	['spr']   = 'SPR',   ['superparallel']       = 'SPR',
	['upr']   = 'UPR',   ['ultraparallel']       = 'UPR',
	['scpr']  = 'ScPR',  ['secretparallel']      = 'ScPR',
	['escpr'] = 'EScPR', ['extrasecretparallel'] = 'EScPR',
	['hgpr']  = 'HGPR' , ['holographicparallel'] = 'HGPR',

	-- Duel terminal: (Why not removing the "parallel rare" part?)
	['dnpr']  = 'DNPR',  ['duelterminalnormalparallel']     = 'DNPR', -- Duel Terminal Common
	['dnrpr'] = 'DNRPR', ['duelterminalnormalrareparallel'] = 'DNRPR',
	['drpr']  = 'DRPR',  ['duelterminalrareparallel']       = 'DRPR',
	['dspr']  = 'DSPR',  ['duelterminalsuperparallel']      = 'DSPR',
	['dupr']  = 'DUPR',  ['duelterminalultraparallel']      = 'DUPR',
	['dscpr'] = 'DScPR', ['duelterminalsecretparallel']     = 'DScPR',

	-- Kaiba's:
	['kcc']  = 'KCC',  ['kaibacorporationcommon'] = 'KCC',
	['kcn']  = 'KCC',  ['kaibacorporationnormal'] = 'KCC',  -- Yes, they are the same
	['kcr']  = 'KCR',  ['kaibacorporation']       = 'KCR',
	['kcsr'] = 'KCSR', ['kaibacorporationsuper']  = 'KCSR', ['kcs'] = 'KCSR',
	['kcur'] = 'KCUR', ['kaibacorporationultra']  = 'KCUR', ['kcu'] = 'KCUR',

	-- Other:
	['hfr'] = 'HFR', ['holofoil']    = 'HFR',
	['sfr'] = 'SFR', ['starfoil']    = 'SFR',
	['msr'] = 'MSR', ['mosaic']      = 'MSR',
	['shr'] = 'SHR', ['shatterfoil'] = 'SHR',
	['cr']  = 'CR',  ['collectors']  = 'CR',
};

-- @name rarity
-- @description Rarity names.
local rarity = {
	-- Stadard non-foils:
	['C']    = 'Common',
	['NR']   = 'Normal Rare',
	['SP']   = 'Short Print',
	['SSP']  = 'Super Short Print',
	['R']    = 'Rare',

	-- Stadard foils:
	['SR']   = 'Super Rare',
	['UR']   = 'Ultra Rare',
	['UtR']  = 'Ultimate Rare',
	['GR']   = 'Ghost Rare',
	['HGR']  = 'Holographic Rare',

	-- Secrets:
	['ScR']   = 'Secret Rare',
	['PScR']  = 'Prismatic Secret Rare ',
	['UScR']  = 'Ultra Secret Rare',
	['ScUR']  = 'Secret Ultra Rare',
	['EScR']  = 'Extra Secret Rare',
	['20ScR'] = '20th Secret Rare',

	-- Precious:
	['GUR']   = 'Gold Rare',
	['GScR']  = 'Gold Secret Rare',
	['GGR']   = 'Ghost/Gold Rare',
	['PIR']   = 'Platinum Rare',
	['PIScR'] = 'Platinum Secret Rare',

	-- Millennium:
	['MLR']   = 'Millennium Rare',
	['MLSR']  = 'Millennium Super Rare',
	['MLUR']  = 'Millennium Ultra Rare',
	['MLScR'] = 'Millennium Secret Rare',
	['MLGR']  = 'Millennium Gold Rare',

	-- Parallel:
	['NPR']   = 'Normal Parallel Rare',
	['SPR']   = 'Super Parallel Rare',
	['UPR']   = 'Ultra Parallel Rare',
	['ScPR']  = 'Secret Parallel Rare',
	['EScPR'] = 'Extra Secret Parallel Rare',
	['HGPR']  = 'Holographic Parallel Rare',

	-- Duel terminal:
	['DNPR']  = 'Duel Terminal Normal Parallel Rare',
	['DNRPR'] = 'Duel Terminal Normal Rare Parallel Rare',
	['DRPR']  = 'Duel Terminal Rare Parallel Rare',
	['DSPR']  = 'Duel Terminal Super Parallel Rare',
	['DUPR']  = 'Duel Terminal Ultra Parallel Rare',
	['DScPR'] = 'Duel Terminal Secret Parallel Rare',

	-- Kaiba's:
	['KCC']  = 'Kaiba Corporation Common',
	['KCR']  = 'Kaiba Corporation Rare',
	['KCSR'] = 'Kaiba Corporation Super Rare',
	['KCUR'] = 'Kaiba Corporation Ultra Rare',

	-- Other:
	['HFR'] = 'Holofoil Rare',
	['SFR'] = 'Starfoil Rare',
	['MSR'] = 'Mosaic Rare',
	['SHR'] = 'Shatterfoil Rare',
	['CR']  = 'Collectors Rare',
};

-- @name s
-- @description Series code.
local ser = {
	anime = {
		-- Shorts:
		['toei'] = 'toei', -- TODO: TOEI = Yu-Gi-Oh! (Toei anime) and Yu-Gi-Oh! The Movie
		['dm']   = 'dm', ['duelmonsters'] = 'dm',
		['gx']   = 'gx',
		['5d']   = '5d', ['5ds']    = '5d',
		['zx']   = 'zx', ['zexal']  = 'zx',
		['av']   = 'av', ['arcv']   = 'av', 
		['vr']   = 'vr', ['vrains'] = 'vr',

		-- Movies:
		['mov']  = 'mov',  ['pyramidoflight'] = 'mov', ['moviepyramidoflight'] = 'mov',  ['pol']  = 'mov',
		['mov2'] = 'mov2', ['3dbondsbeyondtime'] = 'mov2', ['bondsbeyondtime'] = 'mov2', ['bbt']  = 'mov2',
		['mov3'] = 'mov3', ['darksideofdimensions'] = 'mov3',                            ['dsod'] = 'mov3',
	},

	manga = {
		-- Manga:
		['r']  = 'r',
		['dz'] = 'dz', ['dteam'] = 'dz', ['dteamzexal'] = 'dz',
		-- TODO
	}
};

-- @name series
-- @description Series name.
local series = {
	anime = {
		-- Shorts:
		['toei'] = {
			page  = 'Yu-Gi-Oh! (Toei anime)',
			label = 'Yu-Gi-Oh! (Toei)',
		},
		['dm'] = {
			page  = 'Yu-Gi-Oh! (anime)',
			label = 'Yu-Gi-Oh!',
		},
		['gx'] = {
			page  = "Yu-Gi-Oh! GX",
			label = "Yu-Gi-Oh! GX"
		},
		['5d'] = {
			page  = "Yu-Gi-Oh! 5D's",
			label = "Yu-Gi-Oh! 5D's"
		},
		['zx'] = {
			page  = 'Yu-Gi-Oh! ZEXAL',
			label = 'Yu-Gi-Oh! ZEXAL',
		},
		['av'] = {
			page  = 'Yu-Gi-Oh! ARC-V',
			label = 'Yu-Gi-Oh! ARC-V',
		},
		['vr'] = {
			page  = 'Yu-Gi-Oh! VRAINS',
			label = 'Yu-Gi-Oh! VRAINS',
		},

		-- Movies:
		['mov']  = {
			page  = 'Yu-Gi-Oh! The Movie: Pyramid of Light',
			label = 'Yu-Gi-Oh! The Movie: Pyramid of Light',
		},
		['mov2'] = {
			page  = 'Yu-Gi-Oh! 3D Bonds Beyond Time',
			label = 'Yu-Gi-Oh! 3D Bonds Beyond Time',
		},
		['mov3'] = {
			page  = 'Yu-Gi-Oh! The Dark Side of Dimensions',
			label = 'Yu-Gi-Oh! The Dark Side of Dimensions',
		},
	},

	manga = {}
};

local CardGallery = {
	parameters = {
		[ 1 ]     = true,
		['1']     = true,
		['type']  = true,
		['title'] = true,
	},
	
	types = {
		['anime'] = 'Anime',
		['manga'] = 'Manga',
		['game']  = 'Video games', ['vg'] = 'Video games',
		['other'] = 'Other',
	}
};

----------------
-- Return table:
----------------
return {
	-- Globals:
	['rg']        = rg,
	['region']    = region,
	['ln']        = ln,
	['language']  = language,
	['ed']        = ed,
	['edition']   = edition,
	['rel']       = rel,
	['release']   = release,
	['amRel']     = amRel,
	['amRelease'] = amRelease,
	['r']         = r,
	['rarity']    = rarity,

	-- Series:
	['ser']    = ser,
	['series'] = series,

	-- Templates:
	['Card gallery'] = CardGallery,
};

