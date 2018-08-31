-- <pre>
-- @name Data/data
-- @description Serves as a database for other modules.
-- NEVER INTERACT DIRECTLY WITH THIS MODULE. USE [[Module:Data]].

------------------------
-- Normalization tables:
------------------------
local N = {};

-- @description
N.region = {
	-- Worldwide English (EN):
	['en'] = 'en', ['ew'] = 'en', ['we'] = 'en', ['ww'] = 'en',
	['english'] = 'en', ['worldwide'] = 'en',
	['worldwideenglish'] = 'en', ['englishworldwide'] = 'en',

	-- North American English (NA):
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

-- @description
N.language = {
	['en'] = 'en',
	['na'] = 'en', ['eu'] = 'en',
	['au'] = 'en', ['oc'] = 'en',
	['fr'] = 'fr', ['fc'] = 'fr',
	['de'] = 'de',
	['it'] = 'it',
	['pt'] = 'pt',
	['sp'] = 'es',
	['jp'] = 'ja', ['ja'] = 'ja',
	['ae'] = 'en',
	['tc'] = 'zh',
	['kr'] = 'ko',
};

-- @description
N.medium = {
	['tcg'] = 'tcg', ['trading'] = 'tcg',
	['en']  = 'tcg',
	['na']  = 'tcg', ['eu'] = 'tcg',
	['au']  = 'tcg', ['oc'] = 'tcg',
	['fr']  = 'tcg', ['fc'] = 'tcg',
	['de']  = 'tcg',
	['it']  = 'tcg',
	['pt']  = 'tcg',
	['sp']  = 'tcg',
	['ocg'] = 'ocg', ['official'] = 'ocg',
	['jp']  = 'ocg', ['ja'] = 'ocg',
	['ae']  = 'ocg',
	['tc']  = 'ocg',
	['kr']  = 'ocg',
};

-- @description
N.edition = {
	['1e'] = '1e', ['1'] = '1e', ['first']     = '1e', ['1st'] = '1e',
	['ue'] = 'ue', ['u'] = 'ue', ['unlimited'] = 'ue',
	['le'] = 'le', ['l'] = 'le', ['limited']   = 'le',
	['dt'] = 'dt',            ['duelterminal'] = 'dt',
};

N.release = {
	['op'] = 'op', ['proxy']   = 'op',
	['gc'] = 'gc', ['giant']   = 'gc',
	['ct'] = 'ct', ['topper']  = 'ct',
	['rp'] = 'rp', ['replica'] = 'rp',
};

-- @description
N.rarity = {
	-- Stadard non-foils:
	['c']    = 'c',      ['common']          = 'c',  ['n'] = 'c',
	['nr']   = 'nr',     ['normal']          = 'nr',
	['sp']   = 'sp',     ['shortprint']      = 'sp',
	['ssp']  = 'ssp',    ['supershortprint'] = 'ssp',
	['r']    = 'r',      ['rare']            = 'r',

	-- Stadard foils:
	['sr']   = 'sr',     ['super']       = 'sr',
	['ur']   = 'ur',     ['ultra']       = 'ur',
	['utr']  = 'utr',    ['ultimate']    = 'utr',
	['gr']   = 'gr',     ['ghost']       = 'gr',
	['hgr']  = 'hgr',    ['holographic'] = 'hgr',

	-- Secrets:
	['scr']   = 'scr',   ['secret']      = 'scr',
	['pscr']  = 'pscr',  ['prismatic']   = 'pscr', ['prismaticsecret'] = 'pscr',
	['uscr']  = 'uscr',  ['ultrasecret'] = 'uscr',
	['scur']  = 'scur',  ['secretultra'] = 'scur',
	['20scr'] = '20scr', ['20thsecret']  = '20scr',
	['escr']  = 'escr',  ['extrasecret'] = 'escr',

	-- Precious:
	['gur']   = 'gur',   ['gold']           = 'gur', ['goldultra'] = 'gur',
	['gscr']  = 'gscr',  ['goldsecret']     = 'gscr',
	['ggr']   = 'ggr',   ['ghostgold']      = 'ggr',
	['plr']   = 'plr',   ['platinum']       = 'plr',
	['plscr'] = 'plscr', ['platinumsecret'] = 'plscr',

	-- Millennium:
	['mlr']   = 'mlr',   ['millennium']      = 'mlr',
	['mlsr']  = 'mlsr',  ['millenniumsuper'] = 'mlsr',
	['mlur']  = 'mlur',  ['millenniumultra'] = 'mlur',
	['mlscr'] = 'mlscr', ['millenniumultra'] = 'mlur',
	['mlgr']  = 'mlgr',  ['millenniumgold']  = 'mlgr', -- Why not MLGUR?

	-- Parallel:
	['npr']   = 'npr',   ['normalparallel']      = 'npr',
	['spr']   = 'spr',   ['superparallel']       = 'spr',
	['upr']   = 'upr',   ['ultraparallel']       = 'upr',
	['scpr']  = 'scpr',  ['secretparallel']      = 'scpr',
	['escpr'] = 'escpr', ['extrasecretparallel'] = 'escpr',
	['hgpr']  = 'hgpr' , ['holographicparallel'] = 'hgpr',

	-- Duel terminal: (Why not removing the "parallel rare" part?)
	['dnpr']  = 'dnpr',  ['duelterminalnormalparallel']     = 'dnpr', -- Duel Terminal Common
	['dnrpr'] = 'dnrpr', ['duelterminalnormalrareparallel'] = 'dnrpr',
	['drpr']  = 'drpr',  ['duelterminalrareparallel']       = 'drpr',
	['dspr']  = 'dspr',  ['duelterminalsuperparallel']      = 'dspr',
	['dupr']  = 'dupr',  ['duelterminalultraparallel']      = 'dupr',
	['dscpr'] = 'dscpr', ['duelterminalsecretparallel']     = 'dscpr',

	-- Kaiba's:
	['kcc']  = 'kcc',  ['kaibacorporationcommon'] = 'kcc',
	['kcn']  = 'kcc',  ['kaibacorporationnormal'] = 'kcc',  -- Yes, they are the same
	['kcr']  = 'kcr',  ['kaibacorporation']       = 'kcr',
	['kcsr'] = 'kcsr', ['kaibacorporationsuper']  = 'kcsr', ['kcs'] = 'kcsr',
	['kcur'] = 'kcur', ['kaibacorporationultra']  = 'kcur', ['kcu'] = 'kcur',

	-- Other:
	['hfr'] = 'hfr', ['holofoil']    = 'hfr',
	['sfr'] = 'sfr', ['starfoil']    = 'sfr',
	['msr'] = 'msr', ['mosaic']      = 'msr',
	['shr'] = 'shr', ['shatterfoil'] = 'shr',
	['cr']  = 'cr',  ['collectors']  = 'cr',
};

---------------
-- Anime stuff:
---------------
N.anime = {};

N.anime.release = {
	['nc'] = 'nc', ['noncard'] = 'nc',
	['ca'] = 'ca', ['cardart'] = 'ca', ['art'] = 'ca',
};

N.anime.series = {
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
};

---------------
-- Manga stuff:
---------------
N.manga = {};

N.manga.release = {
	['nc'] = 'nc', ['noncard'] = 'nc',
	['ca'] = 'ca', ['cardart'] = 'ca', ['art'] = 'ca',
};

N.manga.series = {
	['dm'] = 'dm', ['manga'] = 'dm', ['duelmonsters'] = 'dm',
	['r']  = 'r',
	['gx'] = 'gx',
	['5d'] = '5d', ['5ds']   = '5d',
	['zx'] = 'zx', ['zexal'] = 'zx',
	['dz'] = 'dz', ['dteam'] = 'dz', ['dteamzexal']  = 'dz',
	['av'] = 'av', ['arcv']  = 'av',
	['dy'] = 'dy',                   ['duelistyuya'] = 'dy',
--	['vr']   = 'vr', ['vrains'] = 'vr',
--	Yu-Gi-Oh! VRAINS: Cyber Warrior Yusaku
};

--------------------
-- Video game stuff:
--------------------
N.videoGame = {};

N.videoGame.release = {
	['nc'] = 'nc', ['noncard'] = 'nc',
};

N.videoGame.game = {
	-- Monster Capsule:
	['mc']   = 'mcbb', ['mcbb'] = 'mcbb', ['monstercapsule']   = 'mcbb', ['monstercapsulebreedandbattle'] = 'mcbb', ['monstercapsulebreed&battle'] = 'mcbb',
	['mcgb'] = 'mcgb', ['gb']   = 'mcgb', ['monstercapsulegb'] = 'mcgb',

	-- Duel Monsters:
	['g1'] = 'dm1', ['gb1'] = 'dm1', ['dm1'] = 'dm1', ['duelmonsters']  = 'dm1', ['g'] = 'dm1', ['dm'] = 'dm1',
	['g2'] = 'dm2', ['gb2'] = 'dm2', ['dm2'] = 'dm2', ['duelmonsters2'] = 'dm2', ['2darkduelstories']  = 'dm2',
	['g3'] = 'dds', ['gb3'] = 'dds', ['dm3'] = 'dds', ['duelmonsters3'] = 'dds', ['3triholygodad5ent'] = 'dds', ['triholygodad5ent'] = 'dds', ['dds'] = 'dds',  ['darkduelstories'] = 'dds',
	['g4'] = 'dm4', ['gb4'] = 'dm4', ['dm4'] = 'dm4', ['duelmonsters4'] = 'dm4', ['4battleofgreatduelist'] = 'dm4', ['battleofgreatduelist'] = 'dm4',
	--['ex'] = '',
	['g5'] = 'dm5', ['gb5'] = 'dm5', ['dm5'] = 'dm5', ['duelmonsters5'] = 'dm5', ['5'] = 'dm5', ['5ex'] = 'dm5', ['5ex1'] = 'dm5', ['5exi'] = 'dm5', ['exi'] = 'dm5', ['ex1'] = 'dm5',
	['g6'] = 'dm6', ['gb6'] = 'dm6', ['dm6'] = 'dm6', ['duelmonsters6'] = 'dm6', ['ex2'] = 'dm6', ['6ex'] = 'dm6',  ['6ex2'] = 'dm6',
	['g7'] = 'tsc', ['gb7'] = 'tsc', ['dm7'] = 'tsc', ['duelmonsters7'] = 'tsc', ['7duelcitylegend'] = 'tsc', ['duelcitylegend'] = 'tsc', ['tsc'] = 'tsc', ['sacredcards'] = 'tsc',
	['g8'] = 'rod', ['gb8'] = 'rod', ['dm8'] = 'rod', ['duelmonsters8'] = 'rod', ['8reshefofdestruction'] = 'rod', ['rod'] = 'rod',   ['reshefofdestruction'] = 'rod',
	['gbi'] = 'sdd',  ['dmi'] = 'sdd',   ['di'] = 'sdd',   ['di1'] = 'sdd',  ['international'] = 'sdd',  ['worldwide'] = 'sdd',  ['worldwideedition'] = 'sdd', ['sdd'] = 'sdd', ['worldwideeditionstairwaytodestinedduel']  = 'sdd', ['stairwaytodestinedduel'] = 'sdd',
	['eds'] = 'eds', ['eternalduelistsoul'] = 'eds', ['eternalduelistssoul'] = 'eds',

	-- Power of Chaos:
	['poc'] = 'poc', ['powerofchaos']      = 'poc', ['pc'] = 'poc', -- TODO: too generic (series). Useful?
	['pcj'] = 'pcj', ['powerofchaosjoey']  = 'pcj', ['powerofchaosjoeypassion']  = 'pcj', ['joey']  = 'pcj', ['joeypassion']  = 'pcj',
	['pck'] = 'pck', ['powerofchaoskaiba'] = 'pck', ['powerofchaoskaibarevenge'] = 'pck', ['kaiba'] = 'pck', ['kaibarevenge'] = 'pck',
	['pcy'] = 'pcy', ['powerofchaosyugi']  = 'pcy', ['powerofchaosyugidestiny']  = 'pcy', ['yugi']  = 'pcy', ['yugidestiny']  = 'pcy',

	-- Tag Force:
	['gx2'] = 'gx02', ['gx02'] = 'gx02', ['tf'] = 'gx02',  ['tf1'] = 'gx02',  ['tf01'] = 'gx02',  ['tagforce'] = 'gx02',
	['gx4'] = 'gx04', ['gx04'] = 'gx04', ['tf2'] = 'gx04', ['tf02'] = 'gx04',  ['tagforce2'] = 'gx04',
	['gx5'] = 'gx05', ['gx05'] = 'gx05', ['tfe'] = 'gx05', ['tagforceevolution'] = 'gx05',  ['beginningofdestiny'] = 'gx05',
	['gx6'] = 'gx06', ['gx06'] = 'gx06', ['tf3'] = 'gx06', ['tf03'] = 'gx06',  ['tagforce3'] = 'gx06',
	['tf4'] = 'tf04', ['tf04'] = 'tf04', ['tagforce4'] = 'tf04',
	['tf5'] = 'tf05', ['tf05'] = 'tf05', ['tagforce5'] = 'tf05',
	['tf6'] = 'tf06', ['tf06'] = 'tf06', ['tagforce6'] = 'tf06',
	['tfs'] = 'tfs',  ['tfsp'] = 'tfs',  ['tagforcespecial'] = 'tfs',

	-- True Duel Monsters:
	['s1']  = 'fmr', ['true1'] = 'fmr', ['truesealedmemories']    = 'fmr', ['sealedmemories'] = 'fmr', ['fmr'] = 'fmr', ['forbiddenmemories'] = 'fmr', ['fm'] = 'fmr',
	['s2']  = 'dor', ['true2'] = 'dor', ['truesucceededmemories'] = 'dor', ['true2succeededmemories'] = 'dor', ['succeededmemories'] = 'dor', ['dor'] = 'dor', ['duelistsofroses'] = 'dor', ['duelistofroses'] = 'dor',

	-- World Championship:
	['wc4']  = 'wc4', ['wc04'] = 'wc4', ['dm2004'] = 'wc4', ['worldchampionship2004'] = 'wc4', ['ex3'] = 'wc4',
	['wc5']  = 'wc5', ['wc05'] = 'wc5', ['dm2005'] = 'wc5', ['worldchampionship2005'] = 'wc5', ['7trialstoglory'] = 'wc5', ['7trialstoglory2005'] = 'wc5', ['20057trialstoglory'] = 'wc5', ['dayofduelist'] = 'wc5', ['dayofduelist2005'] = 'wc5', ['2005dayofduelist'] = 'wc5', ['di2']  = 'wc5', ['international2']  = 'wc5', ['worldwide2'] = 'wc5', ['worldwideedition2'] = 'wc5',
	['wc6']  = 'wc6', ['wc06'] = 'wc6', ['dm2006'] = 'wc6', ['w6s'] = 'wc6', ['e06'] = 'wc6', ['worldchampionship2006'] = 'wc6', ['ultimatemasters'] = 'wc6', ['ultimatemasters2006'] = 'wc6', ['2006ultimatemasters'] = 'wc6', ['e06'] = 'wc6', ['ex2006'] = 'wc6',
	['wc7'] = 'wc07', ['wc07'] = 'wc07', ['dm2007'] = 'wc07', ['worldchampionship2007'] = 'wc07',
	['wc8'] = 'wc08', ['wc08'] = 'wc08', ['dm2008'] = 'wc08', ['worldchampionship2008'] = 'wc08',
	['wc9'] = 'wc09', ['wc09'] = 'wc09', ['dm2009'] = 'wc09', ['worldchampionship2009'] = 'wc09', ['stardustaccelerator'] = 'wc09', ['stardustaccelerator2009'] = 'wc09', ['2009stardustaccelerator'] = 'wc09',
	['wc10'] = 'wc10', ['dm2010'] = 'wc10', ['worldchampionship2010'] = 'wc10', ['reverseofarcadia'] = 'wc10', ['2010reverseofarcadia'] = 'wc10', ['reverseofarcadia2010'] = 'wc10',
	['wc11'] = 'wc11', ['dm2011'] = 'wc11', ['worldchampionship2011'] = 'wc11', ['overnexus'] = 'wc11', ['2011overnexus'] = 'wc11', ['overnexus2011'] = 'wc11',

	-- Other:
	-- B:
	['bam'] = 'bam',

	-- C:
	['cmc'] = 'cmc', ['capsulemonstercoliseum'] = 'cmc', ['capsulemonstercolosseum'] = 'cmc',

	-- D:
	['dar']  = 'dar',  ['duelarena']      = 'dar',  ['da']   = 'dar',
	['dbt']  = 'dbt',  ['destinyboardtraveler'] = 'dbt', ['sugorokunosugoroku'] = 'dbt',
	['ddm']  = 'ddm',  ['dungeondicemonsters']  = 'ddm',
	['dg']   = 'dg',   ['duelgeneration'] = 'dg',   ['mddg'] = 'dg',
	['duli'] = 'duli', ['duellinks']      = 'duli', ['dl']   = 'duli',
	['dod']  = 'dod',  ['dawnofdestiny']  = 'dod',
	--['decadeduels'] = '',
	--['decadeduelsplus'] = '',

	-- G:
	['gx1'] = 'gx1',  ['gx01'] = 'gx1',  ['duelacademy'] = 'gx1',   ['mezaseduelking'] = 'gx1',  ['awakenduelking'] = 'gx1',
	['gx3'] = 'gx03', ['gx03'] = 'gx03', ['spiritcaller'] = 'gx03', ['spiritsummoner'] = 'gx03',

	-- L:
	['ld'] = 'ld', ['lod'] = 'ld', ['legacyofduelist'] = 'ld',

	-- M:
	['md'] = 'md', ['millenniumduels'] = 'md', -- Check if correct abbr.
	['mm'] = 'mm', ['multimaster'] = 'mm', -- Check if correct abbr.

	-- N:
	['ntr'] = 'ntr', ['nightmaretroubadour'] = 'ntr',

	-- T:
	['tfk'] = 'tfk', ['fbk']  = 'tfk', ['falseboundkingdom'] = 'tfk',

	-- W:
	['wb01'] = 'wb01', ['wheeliebreakers'] = 'wb01',

	-- Y:
	['ydb1'] = 'ydb1', ['cardalmanac'] = 'ydb1',
	['ydt1'] = 'ydt1', ['dueltranser'] = 'ydt1',  ['masterofcards'] = 'ydt1',
	['ygo']  = 'ygoo', ['ygoo'] = 'ygoo', ['yol'] = 'ygoo', ['online'] = 'ygoo', ['onlineduelevolution'] = 'ygoo', ['duelevolution'] = 'ygoo', ['online3duelaccelerator'] = 'ygoo', ['onlineduelaccelerator'] = 'ygoo', ['duelaccelerator'] = 'ygoo',

	-- Z:
	['zdc1'] = 'zdc1', ['worldduelcarn4al'] = 'zdc1', ['clashduelcarn4al'] = 'zdc1', ['duelcarn4al'] = 'zdc1',
};


--------------------
-- Public interface:
--------------------
--[=[Doc
@exports
<ul>
	<li>region</li>
	<li>language</li>
	<li>medium</li>
	<li>edition</li>
	<li>release</li>
	<li>rarity</li>
	<li>
		anime
		<ul>
			<li>release</li>
			<li>series</li>
		</ul>
	</li>
	<li>
		manga
		<ul>
			<li>release</li>
			<li>series</li>
		</ul>
	</li>
	<li>
		videoGame
		<ul>
			<li>release</li>
			<li>game</li>
		</ul>
	</li>
	<li>
		templates
		<ul>
			<li>[[Template:Card gallery|]]</li>
		</ul>
	</li>
</ul>
]=]
return {
	['normalize'] = N,

	['region'] = {
		['en'] = { index = 'EN', full = 'Worldwide English'      },
		['na'] = { index = 'NA', full = 'North American English' },
		['eu'] = { index = 'EU', full = 'European English'       },
		['au'] = { index = 'AU', full = 'Australian English'     },
		['oc'] = { index = 'OC', full = 'Oceanic English'        },
		['fr'] = { index = 'FR', full = 'French'                 },
		['fc'] = { index = 'FC', full = 'French-Canadian'        },
		['de'] = { index = 'DE', full = 'German'                 },
		['it'] = { index = 'IT', full = 'Italian'                },
		['pt'] = { index = 'PT', full = 'Portuguese'             },
		['sp'] = { index = 'SP', full = 'Spanish'                },
		['jp'] = { index = 'JP', full = 'Japanese'               },
		['ja'] = { index = 'JA', full = 'Japanese-Asian'         },
		['ae'] = { index = 'AE', full = 'Asian-English'          },
		['tc'] = { index = 'TC', full = 'Chinese'                },
		['kr'] = { index = 'KR', full = 'Korean'                 },
	},

	['language'] = {
		['en'] = { index = 'en', full = 'English'    },
		['fr'] = { index = 'fr', full = 'French'     },
		['de'] = { index = 'de', full = 'German'     },
		['it'] = { index = 'it', full = 'Italian'    },
		['pt'] = { index = 'pt', full = 'Portuguese' },
		['es'] = { index = 'es', full = 'Spanish'    },
		['ja'] = { index = 'ja', full = 'Japanese'   },
		['zh'] = { index = 'zh', full = 'Chinese'    },
		['ko'] = { index = 'ko', full = 'Korean'     },
	},

	['medium'] = {
		['tcg'] = { abbr = 'TCG', full = 'Yu-Gi-Oh! Trading Card Game'  },
		['ocg'] = { abbr = 'OCG', full = 'Yu-Gi-Oh! Official Card Game' },
	},

	['edition'] = {
		['1e'] = { abbr = '1E', full = '1st Edition'       },
		['ue'] = { abbr = 'UE', full = 'Unlimited Edition' },
		['le'] = { abbr = 'LE', full = 'Limited Edition'   },
		['dt'] = { abbr = 'DT', full = 'Duel Terminal'     },
	},

	['release'] = {
		['op'] = { abbr = 'OP', full = 'Official Proxy' },
		['gc'] = { abbr = 'GC', full = 'Giant Card'     },
		['ct'] = { abbr = 'CT', full = 'Case Topper'    },
		['rp'] = { abbr = 'RP', full = 'Replica'        },
	},

	['rarity'] = {
		-- Stadard non-foils:
		['c']   = { abbr = 'C',   full = 'Common'            },
		['nr']  = { abbr = 'NR',  full = 'Normal Rare'       },
		['sp']  = { abbr = 'SP',  full = 'Short Print'       },
		['ssp'] = { abbr = 'SSP', full = 'Super Short Print' },
		['r']   = { abbr = 'R',   full = 'Rare'              },

		-- Stadard foils:
		['sr']  = { abbr = 'SR',  full = 'Super Rare'       },
		['ur']  = { abbr = 'UR',  full = 'Ultra Rare'       },
		['utr'] = { abbr = 'UtR', full = 'Ultimate Rare'    },
		['gr']  = { abbr = 'GR',  full = 'Ghost Rare'       },
		['hgr'] = { abbr = 'HGR', full = 'Holographic Rare' },

		-- Secrets:
		['scr']   = { abbr = 'ScR',   full = 'Secret Rare'           },
		['pscr']  = { abbr = 'PScR',  full = 'Prismatic Secret Rare' },
		['uscr']  = { abbr = 'UScR',  full = 'Ultra Secret Rare'     },
		['scur']  = { abbr = 'ScUR',  full = 'Secret Ultra Rare'     },
		['escr']  = { abbr = 'EScR',  full = 'Extra Secret Rare'     },
		['20scr'] = { abbr = '20ScR', full = '20th Secret Rare'      },

		-- Precious:
		['gur']   = { abbr = 'GUR',   full = 'Gold Rare'            },
		['gscr']  = { abbr = 'GScR',  full = 'Gold Secret Rare'     },
		['ggr']   = { abbr = 'GGR',   full = 'Ghost/Gold Rare'      },
		['plr']   = { abbr = 'PlR',   full = 'Platinum Rare'        },
		['plscr'] = { abbr = 'PlScR', full = 'Platinum Secret Rare' },

		-- Millennium:
		['mlr']   = { abbr = 'MLR',   full = 'Millennium Rare'        },
		['mlsr']  = { abbr = 'MLSR',  full = 'Millennium Super Rare'  },
		['mlur']  = { abbr = 'MLUR',  full = 'Millennium Ultra Rare'  },
		['mlscr'] = { abbr = 'MLScR', full = 'Millennium Secret Rare' },
		['mlgr']  = { abbr = 'MLGR',  full = 'Millennium Gold Rare'   },

		-- Parallel:
		['npr']   = { abbr = 'NPR',   full = 'Normal Parallel Rare'       },
		['spr']   = { abbr = 'SPR',   full = 'Super Parallel Rare'        },
		['upr']   = { abbr = 'UPR',   full = 'Ultra Parallel Rare'        },
		['scpr']  = { abbr = 'ScPR',  full = 'Secret Parallel Rare'       },
		['escpr'] = { abbr = 'EScPR', full = 'Extra Secret Parallel Rare' },
		['hgpr']  = { abbr = 'HGPR',  full = 'Holographic Parallel Rare'  },

		-- Duel terminal:
		['dnpr']  = { abbr = 'DNPR',  full = 'Duel Terminal Normal Parallel Rare'      },
		['dnrpr'] = { abbr = 'DNRPR', full = 'Duel Terminal Normal Rare Parallel Rare' },
		['drpr']  = { abbr = 'DRPR',  full = 'Duel Terminal Rare Parallel Rare'        },
		['dspr']  = { abbr = 'DSPR',  full = 'Duel Terminal Super Parallel Rare'       },
		['dupr']  = { abbr = 'DUPR',  full = 'Duel Terminal Ultra Parallel Rare'       },
		['dscpr'] = { abbr = 'DScPR', full = 'Duel Terminal Secret Parallel Rare'      },

		-- Kaiba's:
		['kcc']  = { abbr = 'KCC',  full = 'Kaiba Corporation Common'     },
		['kcr']  = { abbr = 'KCR',  full = 'Kaiba Corporation Rare'       },
		['kcsr'] = { abbr = 'KCSR', full = 'Kaiba Corporation Super Rare' },
		['kcur'] = { abbr = 'KCUR', full = 'Kaiba Corporation Ultra Rare' },

		-- Other:
		['hfr'] = { abbr = 'HFR', full = 'Holofoil Rare'    },
		['sfr'] = { abbr = 'SFR', full = 'Starfoil Rare'    },
		['msr'] = { abbr = 'MSR', full = 'Mosaic Rare'      },
		['shr'] = { abbr = 'SHR', full = 'Shatterfoil Rare' },
		['cr']  = { abbr = 'CR',  full = 'Collectors Rare'  },
	},

	---------------
	-- Anime stuff:
	---------------
	['anime'] = {
		['release'] = {
			['nc'] = { abbr = 'NC', full = 'Non-card' },
			['ca'] = { abbr = 'CA', full = 'Card art' },
		},

		['series'] = {
			-- Shorts:
			['toei'] = {
				abbr  = 'TOEI',
				page  = 'Yu-Gi-Oh! (Toei anime)',
				label = 'Yu-Gi-Oh! (Toei)',
			},
			['dm'] = {
				abbr  = 'DM',
				page  = 'Yu-Gi-Oh! (anime)',
				label = 'Yu-Gi-Oh!',
			},
			['gx'] = {
				abbr  = 'GX',
				page  = 'Yu-Gi-Oh! GX',
				label = 'Yu-Gi-Oh! GX',
			},
			['5d'] = {
				abbr  = '5D',
				page  = "Yu-Gi-Oh! 5D's",
				label = "Yu-Gi-Oh! 5D's",
			},
			['zx'] = {
				abbr  = 'ZX',
				page  = 'Yu-Gi-Oh! ZEXAL',
				label = 'Yu-Gi-Oh! ZEXAL',
			},
			['av'] = {
				abbr  = 'AV',
				page  = 'Yu-Gi-Oh! ARC-V',
				label = 'Yu-Gi-Oh! ARC-V',
			},
			['vr'] = {
				abbr  = 'VR',
				page  = 'Yu-Gi-Oh! VRAINS',
				label = 'Yu-Gi-Oh! VRAINS',
			},

			-- Movies:
			['mov'] = {
				abbr  = 'MOV',
				page  = 'Yu-Gi-Oh! The Movie: Pyramid of Light',
				label = 'Yu-Gi-Oh! The Movie: Pyramid of Light',
			},
			['mov2'] = {
				abbr  = 'MOV2',
				page  = 'Yu-Gi-Oh! 3D Bonds Beyond Time',
				label = 'Yu-Gi-Oh! 3D Bonds Beyond Time',
			},
			['mov3'] = {
				abbr  = 'MOV3',
				page  = 'Yu-Gi-Oh! The Dark Side of Dimensions',
				label = 'Yu-Gi-Oh! The Dark Side of Dimensions',
			},
		},
	},

	---------------
	-- Manga stuff:
	---------------
	['manga'] = {
		['release'] = {
			['nc'] = { abbr = 'NC', full = 'Non-card' },
			['ca'] = { abbr = 'CA', full = 'Card art' },
		},

		['series'] = {
			['dm'] = {
				abbr  = 'DM',
				page  = 'Yu-Gi-Oh! (manga)',
				label = 'Yu-Gi-Oh!',
			},
			['r'] = {
				abbr  = 'R',
				page  = 'Yu-Gi-Oh! R',
				label = 'Yu-Gi-Oh! R',
			},
			['gx'] = {
				abbr  = 'GX',
				page  = 'Yu-Gi-Oh! GX (manga)',
				label = 'Yu-Gi-Oh! GX',
			},
			['5d'] = {
				abbr  = '5D',
				page  = "Yu-Gi-Oh! 5D's (manga)",
				label = "Yu-Gi-Oh! 5D's",
			},
			['zx'] = {
				abbr  = 'ZX',
				page  = 'Yu-Gi-Oh! ZEXAL (manga)',
				label = 'Yu-Gi-Oh! ZEXAL',
			},
			['dz'] = {
				abbr  = 'DZ',
				page  = 'Yu-Gi-Oh! D Team ZEXAL',
				label = 'Yu-Gi-Oh! D Team ZEXAL',
			},
			['av'] = {
				abbr  = 'AV',
				page  = 'Yu-Gi-Oh! ARC-V (manga)',
				label = 'Yu-Gi-Oh! ARC-V',
			},
			['dy'] = {
				abbr  = 'DY',
				page  = 'Yu-Gi-Oh! ARC-V The Strongest Duelist Yuya!!',
				label = 'Yu-Gi-Oh! ARC-V The Strongest Duelist Yuya!!',
			},
		},
	},

	--------------------
	-- Video game stuff:
	--------------------
	['videoGame'] = {
		['release'] = {
			['nc'] = { abbr = 'NC', full = 'Non-card' },
		},

		['game'] = {
			-- Monster Capsule:
			['mcbb'] = { abbr = 'MCBB', full = 'Yu-Gi-Oh! Monster Capsule: Breed and Battle' },
			['mcgb'] = { abbr = 'MCGB', full = 'Yu-Gi-Oh! Monster Capsule GB'                },

			-- Duel Monsters:
			['dm1'] = { abbr = 'DM1', full = 'Yu-Gi-Oh! Duel Monsters (video game)'                       },
			['dm2'] = { abbr = 'DM2', full = 'Yu-Gi-Oh! Duel Monsters II: Dark duel Stories'              },
			['dds'] = { abbr = 'DDS', full = 'Yu-Gi-Oh! Dark Duel Stories'                                },
			['dm4'] = { abbr = 'DM4', full = 'Yu-Gi-Oh! Duel Monsters 4: Battle of Great Duelist'         },
			['dm5'] = { abbr = 'DM5', full = 'Yu-Gi-Oh! Duel Monsters 5 Expert 1'                         },
			['eds'] = { abbr = 'EDS', full = 'Yu-Gi-Oh! The Eternal Duelist Soul'                         },
			['dm6'] = { abbr = 'DM6', full = 'Yu-Gi-Oh! Duel Monsters 6 Expert 2'                         },
			['tsc'] = { abbr = 'TSC', full = 'Yu-Gi-Oh! The Sacred Cards'                                 },
			['rod'] = { abbr = 'ROD', full = 'Yu-Gi-Oh! Reshef of Destruction'                            },
			['sdd'] = { abbr = 'SDD', full = 'Yu-Gi-Oh! Worldwide Edition: Stairway to the Destined Duel' },

			-- Power of Chaos:
			['poc'] = { abbr = 'POC', full = 'Yu-Gi-Oh! Power of Chaos'                    },
			['pcy'] = { abbr = 'PCY', full = 'Yu-Gi-Oh! Power of Chaos: Yugi the Destiny'  },
			['pck'] = { abbr = 'PCK', full = 'Yu-Gi-Oh! Power of Chaos: Kaiba the Revenge' },
			['pcj'] = { abbr = 'PCJ', full = 'Yu-Gi-Oh! Power of Chaos: Joey the Passion'  },

			-- Tag Force:
			['gx02'] = { abbr = 'GX02', full = 'Yu-Gi-Oh! GX Tag Force'            },
			['gx04'] = { abbr = 'GX04', full = 'Yu-Gi-Oh! GX Tag Force 2'          },
			['gx05'] = { abbr = 'GX05', full = 'Yu-Gi-Oh! GX Tag Force Evolution'  },
			['gx06'] = { abbr = 'GX06', full = 'Yu-Gi-Oh! GX Tag Force 3'          },
			['tf04'] = { abbr = 'TF04', full = "Yu-Gi-Oh! 5D's Tag Force 4"        },
			['tf05'] = { abbr = 'TF05', full = "Yu-Gi-Oh! 5D's Tag Force 5"        },
			['tf06'] = { abbr = 'TF06', full = "Yu-Gi-Oh! 5D's Tag Force 6"        },
			['tfs']  = { abbr = 'TFS',  full = 'Yu-Gi-Oh! ARC-V Tag Force Special' },

			-- True Duel Monsters:
			['dor'] = { abbr = 'DOR', full = 'Yu-Gi-Oh! The Duelists of the Roses' },
			['fmr'] = { abbr = 'FMR', full = 'Yu-Gi-Oh! Forbidden Memories'        },

			-- World Championship:
			['wc4']  = { abbr = 'WC4',  full = 'Yu-Gi-Oh! World Championship Tournament 2004'                    },
			['wc5']  = { abbr = 'WC5',  full = 'Yu-Gi-Oh! 7 Trials to Glory: World Championship Tournament 2005' },
			['wc6']  = { abbr = 'WC6',  full = 'Yu-Gi-Oh! Ultimate Masters: World Championship Tournament 2006'  },
			['wc07'] = { abbr = 'WC07', full = 'Yu-Gi-Oh! World Championship 2007'                               },
			['wc08'] = { abbr = 'WC08', full = 'Yu-Gi-Oh! World Championship 2008'                               },
			['wc09'] = { abbr = 'WC09', full = "Yu-Gi-Oh! 5D's World Championship 2009: Stardust Accelerator"    },
			['wc10'] = { abbr = 'WC10', full = "Yu-Gi-Oh! 5D's World Championship 2010: Reverse of Arcadia"      },
			['wc11'] = { abbr = 'WC11', full = "Yu-Gi-Oh! 5D's World Championship 2011: Over the Nexus"          },

			-- Other:
			['bam']  = { abbr = 'BAM',  full = 'Yu-Gi-Oh! BAM'                                },
			['cmc']  = { abbr = 'CMC',  full = 'Yu-Gi-Oh! Capsule Monster Coliseum'           },
			['dar']  = { abbr = 'DAR',  full = 'Yu-Gi-Oh! Duel Arena'                         },
			['dbt']  = { abbr = 'DBT',  full = 'Yu-Gi-Oh! Destiny Board Traveler'             },
			['ddm']  = { abbr = 'DDM',  full = 'Yu-Gi-Oh! Dungeon Dice Monsters (video game)' },
			['dg']   = { abbr = 'DG',   full = 'Yu-Gi-Oh! Duel Generation'                    },
			['duli'] = { abbr = 'DULI', full = 'Yu-Gi-Oh! Duel Links'                         },
			['dod']  = { abbr = 'DOD',  full = 'Yu-Gi-Oh! The Dawn of Destiny'                },
			['gx1']  = { abbr = 'GX1',  full = 'Yu-Gi-Oh! GX Duel Academy'                    },
			['gx03'] = { abbr = 'GX03', full = 'Yu-Gi-Oh! GX Spirit Caller'                   },
			['ld']   = { abbr = 'LD',   full = 'Yu-Gi-Oh! Legacy of the Duelist'              },
			['ntr']  = { abbr = 'NTR',  full = 'Yu-Gi-Oh! Nightmare Troubadour'               },
			['tfk']  = { abbr = 'TFK',  full = 'Yu-Gi-Oh! The Falsebound Kingdom'             },
			['wb01'] = { abbr = 'WB01', full = "Yu-Gi-Oh! 5D's Wheelie Breakers"              },
			['ydb1'] = { abbr = 'YDB1', full = 'Yu-Gi-Oh! GX Card Almanac'                    },
			['ydt1'] = { abbr = 'YDT1', full = "Yu-Gi-Oh! 5D's Duel Transer"                  },
			['ygoo'] = { abbr = 'YGOO', full = 'Yu-Gi-Oh! Online'                             },
			['zdc1'] = { abbr = 'ZDC1', full = 'Yu-Gi-Oh! ZEXAL World Duel Carnival'          },

			-- Special cases:
			['md'] = { abbr = 'MD', full = 'Yu-Gi-Oh! Millennium Duels' }, -- TODO: decide on this.
			['mm'] = { abbr = 'MM', full = 'Yu-Gi-Oh! Multi-Master'     }, -- TODO: decide on this.
		},
	},

	-------------------
	-- Templates stuff:
	-------------------
	['templates'] = {
		['Card gallery'] = {
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
		}
	},
};