const axios = require( 'axios' ).default;

const api = axios.create( {
	baseURL: 'https://yugipedia.com',
	timeout: 20000,
	headers: {
		'User-Agent': 'Becasita - Scraping for Dan/CGC',
	},
} );

const manager = {

	async get( params ) {
		return api.get( '/api.php', { params } ).then( r => r.data );
	},

};

module.exports = {

	async getTcgCards( cmcontinue, cmlimit = 'max' ) {
		return manager.get( {
			action: 'query',
			list: 'categorymembers',
			cmtitle: 'Category:TCG cards',
			cmlimit,
			cmnamespace: 0,
			format: 'json',
			cmcontinue,
		} );
	},

	async getRawContent( pagename ) {
		return manager.get( {
			action: 'query',
			redirects: false,
			prop: 'revisions',
			rvprop: 'content',
			format: 'json',
			formatversion: 2,
			titles: pagename,
		} ).then( data => data.query.pages[ 0 ].revisions[ 0 ].content );
	},

};
