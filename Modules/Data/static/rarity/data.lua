-- <pre>
local normalize = {
	-- Standard non-foils:
	['c']    = 'c',      ['common']          = 'c',  ['n'] = 'c',
	['nr']   = 'nr',     ['normal']          = 'nr',
	['sp']   = 'sp',     ['shortprint']      = 'sp',
	['ssp']  = 'ssp',    ['supershortprint'] = 'ssp',
	['r']    = 'r',      ['rare']            = 'r',

	-- Standard foils:
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
	['escr']  = 'escr',  ['extrasecret'] = 'escr',
	['20scr'] = '20scr', ['20thsecret']  = '20scr',
	['10000scr'] = '10000scr', ['10000secret'] = '10000scr',
	['str']   = 'str',   ['starlight']   = 'str',  ['altr'] = 'str', ['alternate'] = 'str',

	-- Precious:
	['gur']   = 'gur',   ['gold']           = 'gur', ['goldultra'] = 'gur',
	['gscr']  = 'gscr',  ['goldsecret']     = 'gscr',
	['ggr']   = 'ggr',   ['ghostgold']      = 'ggr',
	['pgr']   = 'pgr',   ['premiumgold']    = 'pgr',
	['plr']   = 'plr',   ['platinum']       = 'plr',
	['plscr'] = 'plscr', ['platinumsecret'] = 'plscr',

	-- Millennium:
	['mlr']   = 'mlr',   ['millennium']       = 'mlr',
	['mlsr']  = 'mlsr',  ['millenniumsuper']  = 'mlsr',
	['mlur']  = 'mlur',  ['millenniumultra']  = 'mlur',
	['mlscr'] = 'mlscr', ['millenniumsecret'] = 'mlscr',
	['mlgr']  = 'mlgr',  ['millenniumgold']   = 'mlgr', -- Why not MLGUR?

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

	-- Rush:
	['rr'] = 'rr', ['rush'] = 'rr',

	-- Other:
	['hfr'] = 'hfr', ['holofoil']    = 'hfr',
	['sfr'] = 'sfr', ['starfoil']    = 'sfr',
	['msr'] = 'msr', ['mosaic']      = 'msr',
	['shr'] = 'shr', ['shatterfoil'] = 'shr',
	['cr']  = 'cr',  ['collectors']  = 'cr',
}

local main = {
	-- Standard non-foils:
	['c']   = { abbr = 'C',   full = 'Common'            },
	['nr']  = { abbr = 'NR',  full = 'Normal Rare'       },
	['sp']  = { abbr = 'SP',  full = 'Short Print'       },
	['ssp'] = { abbr = 'SSP', full = 'Super Short Print' },
	['r']   = { abbr = 'R',   full = 'Rare'              },

	-- Standard foils:
	['sr']  = { abbr = 'SR',  full = 'Super Rare'       },
	['ur']  = { abbr = 'UR',  full = 'Ultra Rare'       },
	['utr'] = { abbr = 'UtR', full = 'Ultimate Rare'    },
	['gr']  = { abbr = 'GR',  full = 'Ghost Rare'       },
	['hgr'] = { abbr = 'HGR', full = 'Holographic Rare' },

	-- Secrets:
	['scr']      = { abbr = 'ScR',      full = 'Secret Rare'           },
	['pscr']     = { abbr = 'PScR',     full = 'Prismatic Secret Rare' },
	['uscr']     = { abbr = 'UScR',     full = 'Ultra Secret Rare'     },
	['scur']     = { abbr = 'ScUR',     full = 'Secret Ultra Rare'     },
	['escr']     = { abbr = 'EScR',     full = 'Extra Secret Rare'     },
	['20scr']    = { abbr = '20ScR',    full = '20th Secret Rare'      },
	['10000scr'] = { abbr = '10000ScR', full = '10000 Secret Rare'     },
	['str']      = { abbr = 'StR',      full = 'Starlight Rare'        },

	-- Precious:
	['gur']   = { abbr = 'GUR',   full = 'Gold Rare'            },
	['gscr']  = { abbr = 'GScR',  full = 'Gold Secret Rare'     },
	['ggr']   = { abbr = 'GGR',   full = 'Ghost/Gold Rare'      },
	['pgr']   = { abbr = 'PGR',   full = 'Premium Gold Rare'    },
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

	-- Rush:
	['rr'] = { abbr = 'RR', full = 'Rush Rare' },

	-- Other:
	['hfr'] = { abbr = 'HFR', full = 'Holofoil Rare'    },
	['sfr'] = { abbr = 'SFR', full = 'Starfoil Rare'    },
	['msr'] = { abbr = 'MSR', full = 'Mosaic Rare'      },
	['shr'] = { abbr = 'SHR', full = 'Shatterfoil Rare' },
	['cr']  = { abbr = 'CR',  full = 'Collectors Rare'  },
}

return {
	normalize = normalize,
	main = main,
}
-- </pre>
