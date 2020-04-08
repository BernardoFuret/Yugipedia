/**
 *  (browser).
 */
( async ( window, $, mw, console ) => {
	"use strict";

	const __actions = new Set();

	const api = await mw.loader.using( "mediawiki.api" ).then( () => new mw.Api() );

	const sleep = ms => new Promise( r => window.setTimeout( r, ms ) );

	const getMembers = offset => api.get( {
		action: 'askargs',
		conditions: 'Actions::+',
		printouts: 'Actions',
		parameters: `limit=300|offset=${offset}`,
		api_version: 3,
	} ).catch( e => ( console.warn( e ) || {
		error: e,
	} ) );

	let offset = window.OFFSET || 0;

	let tryAgain = 3;

	const START_TIME = window.performance.now();

	loop:
	do {
		const response = await getMembers( offset );

		if ( response.error ) {
			if ( tryAgain ) {
				tryAgain--;

				await sleep( 500 );

				continue;
			} else {
				console.error( 'Exhausted all retries.' );

				break;
			}
		}

		tryAgain = 3

		offset = response[ 'query-continue-offset' ];

		for ( const element of response.query.results ) {
			if ( window.STOP_SCRIPT ) {
				break loop;
			}

			const page = Object.keys( element )[ 0 ];

			element[ page ].printouts[ 'Actions' ].forEach( action => __actions.add( action ) );
		}

		await sleep( 500 );
	} while ( offset );

	const END_TIME = window.performance.now();

	window[ `__actions$${Date.now().toString( 36 )}` ] = __actions;

	console.log( ( window.STOP_SCRIPT ) ? "Stopped!" : "All done!" );

	console.log( "Took", END_TIME - START_TIME, "to process" );

} )( window, window.jQuery, window.mediaWiki, window.console ).catch( window.console.error );
