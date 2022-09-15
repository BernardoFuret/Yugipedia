-- <pre>
local normalize = {
	-- Monster Capsule:
	['mc']   = 'mcbb', ['mcbb'] = 'mcbb', ['monstercapsule']   = 'mcbb', ['monstercapsulebreedandbattle'] = 'mcbb', ['monstercapsulebreed&battle'] = 'mcbb',
	['mcgb'] = 'mcgb', ['gb']   = 'mcgb', ['monstercapsulegb'] = 'mcgb',

	-- Duel Monsters:
	['g1'] = 'dm1', ['gb1'] = 'dm1', ['dm1'] = 'dm1', ['duelmonsters1'] = 'dm1', ['duelmonsters'] = 'dm1', ['g'] = 'dm1', ['dm'] = 'dm1',
	['g2'] = 'dm2', ['gb2'] = 'dm2', ['dm2'] = 'dm2', ['duelmonsters2'] = 'dm2', ['2darkduelstories']  = 'dm2',
	['g3'] = 'dm3', ['gb3'] = 'dm3', ['dm3'] = 'dm3', ['duelmonsters3'] = 'dm3', ['3triholdadvent'] = 'dm3', ['triholdadvent'] = 'dm3', -- adjusted because of the `gsub` of "ygo"
	['g4'] = 'dm4', ['gb4'] = 'dm4', ['dm4'] = 'dm4', ['duelmonsters4'] = 'dm4', ['4battleofgreatduelist'] = 'dm4', ['battleofgreatduelist'] = 'dm4',
	--['ex'] = '',
	['g5'] = 'dm5', ['gb5'] = 'dm5', ['dm5'] = 'dm5', ['duelmonsters5'] = 'dm5', ['5'] = 'dm5', ['5ex'] = 'dm5', ['5ex1'] = 'dm5', ['5exi'] = 'dm5', ['exi'] = 'dm5', ['ex1'] = 'dm5',
	['g6'] = 'dm6', ['gb6'] = 'dm6', ['dm6'] = 'dm6', ['duelmonsters6'] = 'dm6', ['ex2'] = 'dm6', ['6ex'] = 'dm6',  ['6ex2'] = 'dm6',
	['g7'] = 'dm7', ['gb7'] = 'dm7', ['dm7'] = 'dm7', ['duelmonsters7'] = 'dm7', ['7duelcitylegend'] = 'dm7', ['duelcitylegend'] = 'dm7',
	['tsc'] = 'tsc', ['sacredcards'] = 'tsc',
	['g8'] = 'gb8', ['dm8'] = 'gb8', ['duelmonsters8'] = 'gb8', ['8reshefofdestruction'] = 'gb8', ['gb8'] = 'gb8',
	['rod'] = 'rod',   ['reshefofdestruction'] = 'rod',
	['dds'] = 'dds', ['darkduelstories'] = 'dds',
	['gbi'] = 'sdd', ['dmi'] = 'sdd',   ['di'] = 'sdd',   ['di1'] = 'sdd',  ['international1'] = 'sdd', ['international'] = 'sdd', ['worldwide'] = 'sdd',  ['worldwideedition'] = 'sdd', ['sdd'] = 'sdd', ['worldwideeditionstairwaytodestinedduel']  = 'sdd', ['stairwaytodestinedduel'] = 'sdd',
	['eds'] = 'eds', ['eternalduelistsoul'] = 'eds', ['eternalduelistssoul'] = 'eds',

	-- Legacy of the Duelist:
	['lotd'] = { abbr = 'LD',   full = 'Yu-Gi-Oh! Legacy of the Duelist'                 },
	['lod2'] = { abbr = 'LOD2', full = 'Yu-Gi-Oh! Legacy of the Duelist: Link Evolution' },

	-- Power of Chaos:
	['poc'] = 'poc', ['powerofchaos']      = 'poc', ['pc'] = 'poc', -- TODO: too generic (series). Useful?
	['pcj'] = 'pcj', ['powerofchaosjoey']  = 'pcj', ['powerofchaosjoeypassion']  = 'pcj', ['joey']  = 'pcj', ['joeypassion']  = 'pcj',
	['pck'] = 'pck', ['powerofchaoskaiba'] = 'pck', ['powerofchaoskaibarevenge'] = 'pck', ['kaiba'] = 'pck', ['kaibarevenge'] = 'pck',
	['pcy'] = 'pcy', ['powerofchaosyugi']  = 'pcy', ['powerofchaosyugidestiny']  = 'pcy', ['yugi']  = 'pcy', ['yugidestiny']  = 'pcy',

	-- Tag Force:
	['gx2'] = 'gx02', ['gx02'] = 'gx02', ['tf'] = 'gx02',  ['tf1'] = 'gx02',  ['tf01'] = 'gx02',  ['tagforce1'] = 'gx02', ['tagforce'] = 'gx02',
	['gx4'] = 'gx04', ['gx04'] = 'gx04', ['tf2'] = 'gx04', ['tf02'] = 'gx04',  ['tagforce2'] = 'gx04',
	['gx5'] = 'gx05', ['gx05'] = 'gx05', ['tfe'] = 'gx05', ['tagforceevolution'] = 'gx05',  ['beginningofdestiny'] = 'gx05',
	['gx6'] = 'gx06', ['gx06'] = 'gx06', ['tf3'] = 'gx06', ['tf03'] = 'gx06',  ['tagforce3'] = 'gx06',
	['tf4'] = 'tf04', ['tf04'] = 'tf04', ['tagforce4'] = 'tf04',
	['tf5'] = 'tf05', ['tf05'] = 'tf05', ['tagforce5'] = 'tf05',
	['tf6'] = 'tf06', ['tf06'] = 'tf06', ['tagforce6'] = 'tf06',
	['tfs'] = 'tfsp', ['tfsp'] = 'tfsp', ['tagforcespecial'] = 'tfsp',

	-- True Duel Monsters:
	['s1']  = 'fmr', ['true1'] = 'fmr', ['truesealedmemories']    = 'fmr', ['sealedmemories'] = 'fmr', ['fmr'] = 'fmr', ['forbiddenmemories'] = 'fmr', ['fm'] = 'fmr',
	['s2']  = 'dor', ['true2'] = 'dor', ['truesucceededmemories'] = 'dor', ['true2succeededmemories'] = 'dor', ['succeededmemories'] = 'dor', ['dor'] = 'dor', ['duelistsofroses'] = 'dor', ['duelistofroses'] = 'dor',

	-- World Championship:
	['wc4']  = 'wc4', ['wc04'] = 'wc4', ['dm2004'] = 'wc4', ['worldchampionship2004'] = 'wc4', ['ex3'] = 'wc4',
	['wc5']  = 'wc5', ['wc05'] = 'wc5', ['dm2005'] = 'wc5', ['worldchampionship2005'] = 'wc5', ['7trialstoglory'] = 'wc5', ['7trialstoglory2005'] = 'wc5', ['20057trialstoglory'] = 'wc5', ['dayofduelist'] = 'wc5', ['dayofduelist2005'] = 'wc5', ['2005dayofduelist'] = 'wc5', ['di2']  = 'wc5', ['international2']  = 'wc5', ['worldwide2'] = 'wc5', ['worldwideedition2'] = 'wc5',
	['wc6']  = 'wc6', ['wc06'] = 'wc6', ['w6s'] = 'wc6', ['worldchampionship2006'] = 'wc6', ['ultimatemasters'] = 'wc6', ['ultimatemasters2006'] = 'wc6', ['2006ultimatemasters'] = 'wc6',
	['dm2006'] = 'e06',  ['e06'] = 'e06', ['ex2006'] = 'e06',
	['wc7'] = 'wc07', ['wc07'] = 'wc07', ['dm2007'] = 'wc07', ['worldchampionship2007'] = 'wc07',
	['wc8'] = 'wc08', ['wc08'] = 'wc08', ['dm2008'] = 'wc08', ['worldchampionship2008'] = 'wc08',
	['wc9'] = 'wc09', ['wc09'] = 'wc09', ['dm2009'] = 'wc09', ['worldchampionship2009'] = 'wc09', ['stardustaccelerator'] = 'wc09', ['stardustaccelerator2009'] = 'wc09', ['2009stardustaccelerator'] = 'wc09',
	['wc10'] = 'wc10', ['dm2010'] = 'wc10', ['worldchampionship2010'] = 'wc10', ['reverseofarcadia'] = 'wc10', ['2010reverseofarcadia'] = 'wc10', ['reverseofarcadia2010'] = 'wc10',
	['wc11'] = 'wc11', ['dm2011'] = 'wc11', ['worldchampionship2011'] = 'wc11', ['overnexus'] = 'wc11', ['2011overnexus'] = 'wc11', ['overnexus2011'] = 'wc11',x

	-- Other:
	-- B:
	['bam'] = 'bam',

	-- C:
	['cmc'] = 'cmc', ['capsulemonstercoliseum'] = 'cmc', ['capsulemonstercolosseum'] = 'cmc',
	['crdu'] = 'crdu', ['cr'] = 'crdu', ['crossduel'] = 'crdu',

	-- D:
	['dar']  = 'dar',  ['duelarena']      = 'dar',  ['da']   = 'dar',
	['dbt']  = 'dbt',  ['destinyboardtraveler'] = 'dbt', ['sugorokunosugoroku'] = 'dbt',
	['ddm']  = 'ddm',  ['dungeondicemonsters']  = 'ddm',
	['dg']   = 'dg',   ['duelgeneration'] = 'dg',   ['mddg'] = 'dg',
	['duli'] = 'duli', ['duellinks']      = 'duli', ['dl']   = 'duli',
	['dod']  = 'dod',  ['dawnofdestiny']  = 'dod',
	['dt']   = 'dt',   ['duelterminal']   = 'dt',
	['5dd']  = '5dd',  ['decadeduels']    = '5dd',   ['dd']  = '5dd',
	['5ddp'] = '5ddp', ['decadeduelsplus'] = '5ddp', ['ddp'] = '5ddp',

	-- G:
	['gx1']  = 'gx1',  ['gx01']   = 'gx1',  ['duelacademy'] = 'gx1',   ['mezaseduelking'] = 'gx1',  ['awakenduelking'] = 'gx1',
	['gx3']  = 'gx03', ['gx03']   = 'gx03', ['spiritcaller'] = 'gx03', ['spiritsummoner'] = 'gx03',
	['g001'] = 'dbr',  ['rdg001'] = 'dbr',
	['g002'] = 'g002', ['rdg002'] = 'g002', ['saikyobattleroyaleletsgogorush'] = 'g002', ['letsgogorush'] = 'g002',

	-- M:
	['madu'] = 'madu', ['masterduel']      = 'madu',
	['md']   = 'md',   ['millenniumduels'] = 'md', -- Check if correct abbr.
	['mm']   = 'mm',   ['multimaster']     = 'mm', -- Check if correct abbr.
	['mnst'] = 'mnst', ['monsterstrike']   = 'mnst',

	-- N:
	['nt'] = 'ntr', ['ntr'] = 'ntr', ['nightmaretroubadour'] = 'ntr',

	-- S:
	['sbr'] = 'dbr', ['saikyobattleroyale'] = 'dbr',
	['dbr'] = 'dbr', ['dawnofbattleroyale'] = 'dbr',

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
}

local main = {
	-- Monster Capsule:
	['mcbb'] = { abbr = 'MCBB', full = 'Yu-Gi-Oh! Monster Capsule: Breed and Battle' },
	['mcgb'] = { abbr = 'MCGB', full = 'Yu-Gi-Oh! Monster Capsule GB'                },

	-- Duel Monsters:
	['dm1'] = { abbr = 'DM1', full = 'Yu-Gi-Oh! Duel Monsters (video game)'                       },
	['dm2'] = { abbr = 'DM2', full = 'Yu-Gi-Oh! Duel Monsters II: Dark duel Stories'              },
	['dm3'] = { abbr = 'DM3', full = 'Yu-Gi-Oh! Duel Monsters III: Tri-Holy God Advent'           },
	['dds'] = { abbr = 'DDS', full = 'Yu-Gi-Oh! Dark Duel Stories'                                },
	['dm4'] = { abbr = 'DM4', full = 'Yu-Gi-Oh! Duel Monsters 4: Battle of Great Duelist'         },
	['dm5'] = { abbr = 'DM5', full = 'Yu-Gi-Oh! Duel Monsters 5: Expert 1'                        },
	['eds'] = { abbr = 'EDS', full = 'Yu-Gi-Oh! The Eternal Duelist Soul'                         },
	['dm6'] = { abbr = 'DM6', full = 'Yu-Gi-Oh! Duel Monsters 6: Expert 2'                        },
	['dm7'] = { abbr = 'DM7', full = 'Yu-Gi-Oh! Duel Monsters 7: The Duelcity Legend'             },
	['tsc'] = { abbr = 'TSC', full = 'Yu-Gi-Oh! The Sacred Cards'                                 },
	['gb8'] = { abbr = 'GB8', full = 'Yu-Gi-Oh! Reshef of Destruction'                            },
	['rod'] = { abbr = 'ROD', full = 'Yu-Gi-Oh! Reshef of Destruction'                            },
	['sdd'] = { abbr = 'SDD', full = 'Yu-Gi-Oh! Worldwide Edition: Stairway to the Destined Duel' },

	-- Legacy of the Duelist:
	['lotd'] = { abbr = 'LD',   full = 'Yu-Gi-Oh! Legacy of the Duelist'                 },
	['lod2'] = { abbr = 'LOD2', full = 'Yu-Gi-Oh! Legacy of the Duelist: Link Evolution' },

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
	['tfsp'] = { abbr = 'TFSP', full = 'Yu-Gi-Oh! ARC-V Tag Force Special' },

	-- True Duel Monsters:
	['dor'] = { abbr = 'DOR', full = 'Yu-Gi-Oh! The Duelists of the Roses' },
	['fmr'] = { abbr = 'FMR', full = 'Yu-Gi-Oh! Forbidden Memories'        },

	-- World Championship:
	['wc4']  = { abbr = 'WC4',  full = 'Yu-Gi-Oh! World Championship Tournament 2004'                    },
	['wc5']  = { abbr = 'WC5',  full = 'Yu-Gi-Oh! 7 Trials to Glory: World Championship Tournament 2005' },
	['wc6']  = { abbr = 'WC6',  full = 'Yu-Gi-Oh! Ultimate Masters: World Championship Tournament 2006'  },
	['e06']  = { abbr = 'E06',  full = 'Yu-Gi-Oh! Ultimate Masters: World Championship Tournament 2006'  },
	['wc07'] = { abbr = 'WC07', full = 'Yu-Gi-Oh! World Championship 2007'                               },
	['wc08'] = { abbr = 'WC08', full = 'Yu-Gi-Oh! World Championship 2008'                               },
	['wc09'] = { abbr = 'WC09', full = "Yu-Gi-Oh! 5D's World Championship 2009: Stardust Accelerator"    },
	['wc10'] = { abbr = 'WC10', full = "Yu-Gi-Oh! 5D's World Championship 2010: Reverse of Arcadia"      },
	['wc11'] = { abbr = 'WC11', full = "Yu-Gi-Oh! 5D's World Championship 2011: Over the Nexus"          },

	-- Other:
	['bam']  = { abbr = 'BAM',  full = 'Yu-Gi-Oh! BAM'                                },
	['cmc']  = { abbr = 'CMC',  full = 'Yu-Gi-Oh! Capsule Monster Coliseum'           },
	['crdu'] = { abbr = 'CRDU', full = 'Yu-Gi-Oh! Cross Duel'                         },
	['dar']  = { abbr = 'DAR',  full = 'Yu-Gi-Oh! Duel Arena'                         },
	['dbt']  = { abbr = 'DBT',  full = 'Yu-Gi-Oh! Destiny Board Traveler'             },
	['ddm']  = { abbr = 'DDM',  full = 'Yu-Gi-Oh! Dungeon Dice Monsters (video game)' },
	['dg']   = { abbr = 'DG',   full = 'Yu-Gi-Oh! Duel Generation'                    },
	['duli'] = { abbr = 'DULI', full = 'Yu-Gi-Oh! Duel Links'                         },
	['dod']  = { abbr = 'DOD',  full = 'Yu-Gi-Oh! The Dawn of Destiny'                },
	['dt']   = { abbr = 'DT',   full = 'Duel Terminal'                                },
	['5dd']  = { abbr = '5DD',  full = "Yu-Gi-Oh! 5D's Decade Duels"                  },
	['5ddp'] = { abbr = '5DDP', full = "Yu-Gi-Oh! 5D's Decade Duels Plus"             },
	['gx1']  = { abbr = 'GX1',  full = 'Yu-Gi-Oh! GX Duel Academy'                    },
	['gx03'] = { abbr = 'GX03', full = 'Yu-Gi-Oh! GX Spirit Caller'                   },
	['madu'] = { abbr = 'MADU', full = 'Yu-Gi-Oh! Master Duel'                        },
	['mnst'] = { abbr = 'MNST', full = 'Yu-Gi-Oh! Monster Strike'                     },
	['ntr']  = { abbr = 'NTR',  full = 'Yu-Gi-Oh! Nightmare Troubadour'               },
	['dbr']  = { abbr = 'DBR',  full = 'Yu-Gi-Oh! RUSH DUEL: Dawn of the Battle Royale!!' },
	['g002'] = { abbr = 'G002', full = "Yu-Gi-Oh! RUSH DUEL: Saikyo Battle Royale!! Let's Go! Go Rush!!" },
	['tfk']  = { abbr = 'TFK',  full = 'Yu-Gi-Oh! The Falsebound Kingdom'             },
	['wb01'] = { abbr = 'WB01', full = "Yu-Gi-Oh! 5D's Wheelie Breakers"              },
	['ydb1'] = { abbr = 'YDB1', full = 'Yu-Gi-Oh! GX Card Almanac'                    },
	['ydt1'] = { abbr = 'YDT1', full = "Yu-Gi-Oh! 5D's Duel Transer"                  },
	['ygoo'] = { abbr = 'YGOO', full = 'Yu-Gi-Oh! Online'                             },
	['zdc1'] = { abbr = 'ZDC1', full = 'Yu-Gi-Oh! ZEXAL World Duel Carnival'          },

	-- Special cases:
	['md'] = { abbr = 'MD', full = 'Yu-Gi-Oh! Millennium Duels' }, -- TODO: decide on this.
	['mm'] = { abbr = 'MM', full = 'Yu-Gi-Oh! Multi-Master'     }, -- TODO: decide on this.
}

return {
	normalize = normalize,
	main = main,
}
-- </pre>
