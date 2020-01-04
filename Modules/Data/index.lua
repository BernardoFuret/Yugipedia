-- <pre>
local DATA = require( 'Module:Data/loader' )()

return setmetatable( {
	getAnimeRelease = DATA.anime.getRelease,
	getAnimeSeries = DATA.anime.getSeries,

	getMangaRelease = DATA.manga.getRelease,
	getMangaSeries = DATA.manga.getSeries,

	getVideoGameRelease = DATA.videoGames.getRelease,
	getVideoGame = DATA.videoGames.getName,
}, {
	__index = DATA,
	__call  = getmetatable( DATA ).__call,
} )
-- </pre>
