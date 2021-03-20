// https://www.npmjs.com/package/export-to-csv

const { promises: fsp } = require( 'fs' );

const path = require( 'path' );

const resultsDir = path.join( __dirname, '../..', 'results' );

function removeWikitextMarkup( text ) {
	return text
		.replace( /'''?/g, '' )
		.replace( /< *br *\/? *>/gi, '\n' )
		.replace( /\[\[(.*?)(?:\|(.*?))?\]\]/gm, ( m, $1, $2 ) => ( $2 || $1 ) )
		.replace( /< *\/? *(ins|del) *>/gi, '' )
		.replace( /< *(ref) *>.*?< *\/? *\1 *>/gi, '' )
		.replace( /<!--(.*?)-->/g, '' )
	;
}

function getFirstGroup( regex, s ) {
	return ( regex.exec( s ) || {} )[ 1 ] || '';
}

async function parseContent( content, spec, { title } = {} ) {
	return Object.entries( spec ).reduce( async ( all, [ parameter, { handler } ] ) => {
		const regex = new RegExp(
			`^[ \\t]*\\|[ \\t]*${parameter}[ \\t]*=(?:[ \\t]*\\n?(.*?)\\s*)(?=^[ \\t]*(?:\\||}}\\s*$))`,
			'gims',
		);

		const rawValue = getFirstGroup( regex, content );

		return {
			...await all,
			[ parameter ]: await handler( rawValue, { title, content } ),
		};
	}, {} );
}

function regexEscape( s ) {
	// eslint-disable-next-line no-useless-escape
	return s.replace( /[-[\]{}()*+!<=:?.\/\\^$|#\s,]/g, '\\$&' );
}

function throwNewError( message ) {
	throw new Error( message );
}

async function exportToJSON( cardsData ) {
	try {
		await fsp.mkdir( resultsDir, { recursive: true } );
	} catch ( e ) {
		return console.error( 'Error creating dir', resultsDir, e );
	}

	const writingResults = await Promise.allSettled(
		Object.entries( cardsData ).map( ( [ key, data ] ) => {
			const file = path.join( resultsDir, `${key}.json` );

			return fsp.writeFile( file, JSON.stringify( data ) )
				.catch( e => console.error( `Error writing to ${file}:`, e ) )
			;
		} ),
	);

	writingResults.forEach( r => r.reason && console.warn( r.reason ) );
}

module.exports = {
	concurrentIteration: require( './concurrentIteration' ),
	removeWikitextMarkup,
	parseContent,
	regexEscape,
	throwNewError,
	exportToJSON,
};
