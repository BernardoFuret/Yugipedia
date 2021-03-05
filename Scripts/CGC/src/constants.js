/* eslint-disable no-multi-spaces */
const regions = [
	{ index: 'EN', full: 'Worldwide English'      },
	{ index: 'NA', full: 'North American English' },
	{ index: 'EU', full: 'European English'       },
	{ index: 'AU', full: 'Australian English'     },
	//{ index: 'OC', full: 'Oceanic English'        },
	{ index: 'FR', full: 'French'                 },
	{ index: 'FC', full: 'French-Canadian'        },
	{ index: 'DE', full: 'German'                 },
	{ index: 'IT', full: 'Italian'                },
	{ index: 'PT', full: 'Portuguese'             },
	{ index: 'SP', full: 'Spanish'                },
	{ index: 'AE', full: 'Asian-English'          },
];

const languages = [
	{ index: 'fr', full: 'French'     },
	{ index: 'de', full: 'German'     },
	{ index: 'it', full: 'Italian'    },
	{ index: 'pt', full: 'Portuguese' },
	{ index: 'es', full: 'Spanish'    },
];

const editions = [
	{ abbr: '1E', full: '1st Edition'       },
	{ abbr: 'UE', full: 'Unlimited Edition' },
	{ abbr: 'LE', full: 'Limited Edition'   },
	{ abbr: 'DT', full: 'Duel Terminal'     },
];

const rarities = [
	{ abbr: 'C',   full: 'Common'            },
	{ abbr: 'NR',  full: 'Normal Rare'       },
	{ abbr: 'SP',  full: 'Short Print'       },
	{ abbr: 'SSP', full: 'Super Short Print' },
	{ abbr: 'R',   full: 'Rare'              },

	{ abbr: 'SR',  full: 'Super Rare'       },
	{ abbr: 'UR',  full: 'Ultra Rare'       },
	{ abbr: 'UtR', full: 'Ultimate Rare'    },
	{ abbr: 'GR',  full: 'Ghost Rare'       },
	{ abbr: 'HGR', full: 'Holographic Rare' },

	{ abbr: 'ScR',      full: 'Secret Rare'           },
	{ abbr: 'PScR',     full: 'Prismatic Secret Rare' },
	{ abbr: 'UScR',     full: 'Ultra Secret Rare'     },
	{ abbr: 'ScUR',     full: 'Secret Ultra Rare'     },
	{ abbr: 'EScR',     full: 'Extra Secret Rare'     },
	{ abbr: '20ScR',    full: '20th Secret Rare'      },
	{ abbr: '10000ScR', full: '10000 Secret Rare'     },
	{ abbr: 'StR',      full: 'Starlight Rare'        },

	{ abbr: 'GUR',   full: 'Gold Rare'            },
	{ abbr: 'GScR',  full: 'Gold Secret Rare'     },
	{ abbr: 'GGR',   full: 'Ghost/Gold Rare'      },
	{ abbr: 'PGR',   full: 'Premium Gold Rare'    },
	{ abbr: 'PlR',   full: 'Platinum Rare'        },
	{ abbr: 'PlScR', full: 'Platinum Secret Rare' },

	{ abbr: 'MLR',   full: 'Millennium Rare'        },
	{ abbr: 'MLSR',  full: 'Millennium Super Rare'  },
	{ abbr: 'MLUR',  full: 'Millennium Ultra Rare'  },
	{ abbr: 'MLScR', full: 'Millennium Secret Rare' },
	{ abbr: 'MLGR',  full: 'Millennium Gold Rare'   },

	{ abbr: 'NPR',   full: 'Normal Parallel Rare'       },
	{ abbr: 'SPR',   full: 'Super Parallel Rare'        },
	{ abbr: 'UPR',   full: 'Ultra Parallel Rare'        },
	{ abbr: 'ScPR',  full: 'Secret Parallel Rare'       },
	{ abbr: 'EScPR', full: 'Extra Secret Parallel Rare' },
	{ abbr: 'HGPR',  full: 'Holographic Parallel Rare'  },

	{ abbr: 'DNPR',  full: 'Duel Terminal Normal Parallel Rare'      },
	{ abbr: 'DNRPR', full: 'Duel Terminal Normal Rare Parallel Rare' },
	{ abbr: 'DRPR',  full: 'Duel Terminal Rare Parallel Rare'        },
	{ abbr: 'DSPR',  full: 'Duel Terminal Super Parallel Rare'       },
	{ abbr: 'DUPR',  full: 'Duel Terminal Ultra Parallel Rare'       },
	{ abbr: 'DScPR', full: 'Duel Terminal Secret Parallel Rare'      },

	{ abbr: 'KCC',  full: 'Kaiba Corporation Common'     },
	{ abbr: 'KCR',  full: 'Kaiba Corporation Rare'       },
	{ abbr: 'KCSR', full: 'Kaiba Corporation Super Rare' },
	{ abbr: 'KCUR', full: 'Kaiba Corporation Ultra Rare' },

	{ abbr: 'RR', full: 'Rush Rare' },

	{ abbr: 'HFR', full: 'Holofoil Rare'    },
	{ abbr: 'SFR', full: 'Starfoil Rare'    },
	{ abbr: 'MSR', full: 'Mosaic Rare'      },
	{ abbr: 'SHR', full: 'Shatterfoil Rare' },
	{ abbr: 'CR',  full: 'Collectors Rare'  },
];

module.exports = {
	regions,
	languages,
	editions,
	rarities,
};
