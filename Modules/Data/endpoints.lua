-- <pre>
return {
	-- Static data:
	getRegion   = 'static/region',
	getLanguage = 'static/language',
	getMedium   = 'static/medium', -- TODO: Rename. "medium" could be CG, anime, manga, VG, etc..
	getRarity   = 'static/rarity',
	getEdition  = 'static/edition',
	getRelease  = 'static/release',

	-- SMW data:
	getName         = 'smw/name',
	getReleaseDate  = 'smw/releaseDate',
	getFullCardType = 'smw/cardType', -- TODO: move module?
	
	-- Sub-Namespaces:
	anime      = 'namespaces/anime',
	manga      = 'namespaces/manga',
	videoGames = 'namespaces/videoGames',
}
-- </pre>
