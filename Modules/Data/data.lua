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
	['pir']   = 'pir',   ['platinum']       = 'pir',
	['piscr'] = 'piscr', ['platinumsecret'] = 'piscr',

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
		['pir']   = { abbr = 'PIR',   full = 'Platinum Rare'        },
		['piscr'] = { abbr = 'PIScR', full = 'Platinum Secret Rare' },

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