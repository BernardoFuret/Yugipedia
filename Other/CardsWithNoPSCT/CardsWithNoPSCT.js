/**
 * (browser)
 * No PSCT.
 * Not printed in OC.
 */
( async ( window, $, mw, console ) => {
	"use strict";

	const __errors = [];

	const __noOcRelease = [];

	const __noPsctRelease = [];

	const __mayHavePsctRelease = [];

	const __promises = {};

	let chainId = 0;

	const REGIONS = [
		'EN',
		'NA',
		'EU',
		'AU',
	];

	const api = await mw.loader.using( 'mediawiki.api' ).then( () => new mw.Api() );

	const sleep = ms => new Promise( r => window.setTimeout( r, ms ) );

	const getCategoryMembers = cmcontinue => api.get( {
		action: 'query',
		list: 'categorymembers',
		cmtitle: 'Category:TCG cards',
		cmlimit: '500',
		cmcontinue: cmcontinue,
	} );

	const textToHtml = text => $( '<div>' )
		.append( $.parseHTML( text ) )
	;

	const getHtml = title => fetch( `https://yugipedia.com/wiki/${title}` )
		.then( data => data.text() )
		.then( textToHtml )
		.catch( err => {
			console.warn( 'Error getting HTML for', title, err );

			__errors.push( {
				title,
				error: err,
			} );
		} )
	;

	const getNthCell = ( $tables, selector ) => $tables
		.find( `td:${selector}` )
			.map( ( i, el ) => el.innerText )
			.get()
	;

	const dateIsAfter2011 = dateString => {
		if ( !dateString ) {
			return false;
		}

		const [ year ] = dateString.split( '-' );

		return parseInt( year ) > 2011;
	};

	let continueToken = window.START_TOKEN;
	const START_TIME = window.performance.now();

	try {

		loop:
		do {
			if ( window.STOP_SCRIPT ) {
				break loop;
			}

			const cmResponse = await getCategoryMembers( continueToken );

			// Update the continue token:
			continueToken = cmResponse.continue?.cmcontinue;

			console.log( 'Next batch:', continueToken );

			const members = cmResponse.query.categorymembers;

			( id => {
				__promises[ id ] = Promise.resolve( members )
					.then( async members => {
						for ( const { title } of members ) {
							if ( window.STOP_SCRIPT ) {
								throw 'Halt!';
							}

							console.log( 'Processing', title );

							const $pageHtml = await getHtml( title );

							if ( !$pageHtml ) {
								console.error( 'No HTML for', title );

								continue;
							}

							const $rgTables = $pageHtml
								.find( REGIONS.map( rg => `#cts--${rg}` ).join() )
							;

							const rgDates = getNthCell( $rgTables, 'first-child' );

							const rgSets = getNthCell( $rgTables, 'nth-child( 3 )' );

							if ( !rgDates.some( dateIsAfter2011 ) ) {
								__noPsctRelease.push( title );

								if ( rgDates.includes( '' ) ) {
									const setsWithNoDate = rgDates.reduce( ( acc, date, index ) => {
										if ( !date ) {
											acc.push( rgSets[ index ] );
										}

										return acc;
									}, [] );

									__mayHavePsctRelease.push( {
										title,
										setsWithNoDate
									} );
								}
							}

							if ( !$rgTables.siblings( '#cts--AU' ).length ) {
								__noOcRelease.push( title );
							}

							await sleep( window.SCRIPT_LATENCY || 500 );
						}
					} )
					.catch( err => {
						if ( err === 'Halt!' ) {
							console.log( 'Terminating' );

							return;
						}

						console.error( 'Unknown error:', err );

						__errors.push( { error: err } );	
					} )
					.finally( () => delete __promises[ id ] )
				;
			} )( chainId++ );

			await sleep( 500 );

		} while ( continueToken );

	} catch ( e ) {
		console.error( 'Something wrong happened:', e );

		__errors.push( { error: e } );
	}

	Promise.allSettled( Object.values( __promises ) ).then( () => {
		const END_TIME = window.performance.now();

		window[ `__errors$${Date.now().toString( 36 )}` ] = __errors;

		window[ `__noOcRelease$${Date.now().toString( 36 )}` ] = __noOcRelease;

		window[ `__noPsctRelease$${Date.now().toString( 36 )}` ] = __noPsctRelease;

		window[ `__mayHavePsctRelease$${Date.now().toString( 36 )}` ] = __mayHavePsctRelease;

		console.log( window.STOP_SCRIPT ? 'Stopped!' : 'All done!' );

		console.log( 'Took', END_TIME - START_TIME );
	} );

} )( window, window.jQuery, window.mediaWiki, ( ( window, $ ) => {
	"use strict";

	const win = window.open();

	const doWrite = ( args, color = 'black' ) => window.DEBUG && win.document.write(
		$( '<pre>', {
			html: args.map( arg => typeof arg !== 'string'
				? JSON.stringify( arg, null, '  ' )
				: arg
			).join( ' ' )
		} ).css( 'color', color ).prop( 'outerHTML' )
	);

	return {
		log: ( ...args ) => doWrite( args ),

		warn: ( ...args ) => doWrite( args, 'darkorange' ),

		error: ( ...args ) => doWrite( args, 'red' ),
	};
} )( window, window.jQuery ) ).catch( window.console.error );
