
const api = require( './api' );

const { concurrentIteration, parseContent, exportToJSON } = require( './helpers' );

const parameters = require( './parameters' );

const cardsData = {
	monster: [],
	spell: [],
	trap: [],
	skill: [],
};

function parseDate( miliseconds ) {
	// Works for less than 24 hours.
	return new Date( miliseconds ).toISOString().substr( 11 );
}

function getWholeMatch( regex, s ) {
	return ( regex.exec( s ) || {} )[ 0 ];
}

async function computeCardType( content ) {
	const { card_type: cardType, types } = await parseContent( content, parameters.misc );

	return (
		getWholeMatch( /spell|trap/i, cardType )
		||
		getWholeMatch( /skill/i, types )
		||
		'monster'
	).toLowerCase();
}

function formatData( cardData, spec ) {
	return Object.entries( cardData )
		.map( ( [ parameter, data ] ) => {
			return {
				title: spec[ parameter ].title,
				data,
			};
		} )
		.filter( entry => entry.data.length || ( entry.data.data || [] ).length )
	;
}

async function getCardInfo( { title }, { chainId } ) {
	console.log( `[${chainId}]`, 'Processing', title );

	const content = await api.getRawContent( title );

	const cardType = await computeCardType( content );

	const cardData = await parseContent( content, parameters[ cardType ], { title } );

	cardsData[ cardType ].push( {
		page: `https://yugipedia.com/wiki/${title}`,
		data: formatData( cardData, parameters[ cardType ] ),
	} );

	return title;
}

async function main() {
	const START = new Date();

	const concurrentCalls = parseInt( process.argv[ 3 ] ) || 4;

	let iterations = parseInt( process.argv[ 4 ] ) || 0;

	let continueToken;

	let totalSuccessful = 0;

	do {
		const cmResponse = await api.getTcgCards( continueToken, process.argv[ 2 ] );

		// Update the continue token:
		continueToken = ( cmResponse.continue || {} ).cmcontinue;

		const members = cmResponse.query.categorymembers;

		await concurrentIteration( members, concurrentCalls, getCardInfo )
			.then( results => {
				console.log( 'Finished concurrent iteration!' );

				totalSuccessful = results.reduce( ( total, { reason, value }, i ) => {
					if ( reason ) {
						console.warn( `[${i}]`, 'Error:', reason );

						return total;
					} else {
						console.log( `[${i}]`, 'Success! Processed', value.length, 'entries.' );

						return total + value.length;
					}
				}, totalSuccessful );
			} )
		;
	} while ( continueToken && --iterations );

	const FINISH = new Date();

	console.log( 'Finished! Took', parseDate( FINISH - START ), 'to process', totalSuccessful, 'cards successfully.' );
}

main()
	.catch( e => console.error( 'Unexpected error', e ) )
	.finally( () => exportToJSON( cardsData ) )
;

process.on( 'SIGINT', async () => {
	try {
		await exportToJSON( cardsData );
	} catch ( e ) {
		console.error( 'ERROR:', e );
	} finally {
		process.exit();
	}
} );
