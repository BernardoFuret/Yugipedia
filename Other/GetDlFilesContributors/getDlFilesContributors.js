/**
 * (browser)
 */
( async ( window, $, mw, console ) => {
	"use strict";

	const __errors = [];

	const __promises = {};

	const __acceptedImages = [];

	let chainId = 0;

	let processedPages = 0;

	const api = await mw.loader.using( 'mediawiki.api' ).then( () => new mw.Api() );

	const sleep = ms => new Promise( r => window.setTimeout( r, ms ) );

	const link = pagename => $( '<a>', {
		target: '_blank',
		href: `https://yugipedia.com/wiki/${pagename}`,
		text: pagename,
	} ).prop( 'outerHTML' );

	const getCategoryPages = cmcontinue => api.get( {
		action: 'query',
		list: 'categorymembers',
		cmtitle: 'Category:Yu-Gi-Oh! Duel Links card images',
		cmlimit: window.LIMIT || 'max',
		cmcontinue: cmcontinue,
		format: 'json',
	} );

	const getContributors = async (pagename) => {
		const pcResponse  = await api.get( {
			action: 'query',
			titles: pagename,
			prop: 'contributors',
			format: 'json',
			formatversion: 2,
		} );

		const { contributors = [] } = pcResponse?.query?.pages?.[ 0 ] || {};

		return contributors;
	};

	const checker = window.CHECKER || ( () => true );

	let continueToken = window.START_TOKEN;

	window.DEBUG = true;

	const START_TIME = window.performance.now();

	try {

		loop:
		do {
			if ( window.STOP_SCRIPT ) {
				break loop;
			}

			const cmResponse = await getCategoryPages( continueToken );

			// Update the continue token:
			continueToken = cmResponse.continue?.cmcontinue;

			console.log( 'Next batch:', continueToken );

			const pages = cmResponse.query.categorymembers;

			( id => {
				__promises[ id ] = Promise.resolve( pages )
					.then( async pages => {
						for ( const { title, ns } of pages ) {
							if ( window.STOP_SCRIPT ) {
								throw new Error( 'Halt!' );
							}

							console.log( `[${id}]`, 'Processing', link(title) );

							processedPages += 1;

							if ( !( ns === 6 && title.match( '-DULI-EN-VG' ) ) ) {
								console.warn( `[${id}]`, 'Skipping', link( title ), 'ns:', ns );

								continue;
							}

							try {
								console.log( `[${id}]`, 'Getting contributors for', link( title ) );

								const contributors = await getContributors( title );

								if ( checker( title, contributors ) ) {
									console.log( `[${id}]`, 'Adding contributors for', link( title ) );

									__acceptedImages.push( {
										title,
										contributors,
									} );
								}
							} catch ( err ) {
								console.log( `[${id}]`, 'Error processing contributors for', link( title ), '::', err.message, err );

								__errors.push( { error: err, title } );
							}

							await sleep( window.SCRIPT_LATENCY || 1000 );
						}
					} )
					.catch( err => {
						if ( err.message === 'Halt!' ) {
							console.log( `[${id}]`, 'Terminating chain with ID', id );

							return;
						}

						console.error( `[${id}]`, 'Unknown error:', err.message, err );

						__errors.push( { error: err } );
					} )
					.finally( () => {
						delete __promises[ id ];
					} )
				;
			} )( chainId++ );

			await sleep( window.SCRIPT_LATENCY || 500 );

		} while ( continueToken );

	} catch ( err ) {
		console.error( 'Something wrong happened:', err.message, err );

		__errors.push( { error: err } );
	}

	Promise.allSettled( Object.values( __promises ) ).then( () => {
		const END_TIME = window.performance.now();

		window[ `__errors$${Date.now().toString( 36 )}` ] = __errors;

		window[ `__acceptedImages$${Date.now().toString( 36 )}` ] = __acceptedImages;

		window.DEBUG = true;

		console.log( window.STOP_SCRIPT ? 'Stopped!' : 'All done!' );

		console.log( 'Took', END_TIME - START_TIME );

		console.log( 'Processed', processedPages, 'pages' );
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
