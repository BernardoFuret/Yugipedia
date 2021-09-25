/**
 * (browser)
 * Remove Portuguese entries for Speed Duel: Battle City Box.
 */
( async ( window, $, mw, console ) => {
	"use strict";

	const __errors = [];

	const __existing = [];

	const __promises = {};

	let chainId = 0;

	let processedPages = 0;

	const api = await mw.loader.using( 'mediawiki.api' ).then( () => new mw.Api() );

	const sleep = ms => new Promise( r => window.setTimeout( r, ms ) );

	const link = pagename => $( '<a>', {
		target: '_blank',
		href: `https://yugipedia.com/wiki/${pagename}`,
		text: pagename,
	} ).prop( 'outerHTML' );

	const getDabPages = qpoffset => api.get( {
		action: 'query',
		list: 'querypage',
		qppage: 'DisambiguationPages',
		qplimit: 300,
		qpoffset,
		format: 'json',
	} );

	const redirect = ( newDabPageName, redirectTo ) => api.postWithToken( 'csrf', {
		action: 'edit',
		title: newDabPageName,
		createonly: true,
		text: `#REDIRECT [[${redirectTo}]] {{R to disambiguation page}}`,
		summary: `Creating redirects to dab pages: Redirected page to [[${redirectTo}]].`,
		bot: true,
	} )
		.then( data => console.log(
			'Redirected page to',
			link(redirectTo),
			$( '<a>', {
				target: '_blank',
				href: `https://yugipedia.com/index.php?diff=${data.edit.newrevid}`,
				text: `(${data.edit.newrevid})`,
			} ).prop( 'outerHTML' )
		) )
		.catch( (...args) => {
			console.warn( `Error redirecting [[${newDabPageName}]]:`, ...args );

			__errors.push( { error: args, type: 'redirect error' } );

			if (args[0] === 'articleexists') {
				__existing.push( newDabPageName );
			}
		} )
	;

	let offset = window.OFFSET;

	window.DEBUG = true;

	const START_TIME = window.performance.now();

	try {

		loop:
		do {
			if ( window.STOP_SCRIPT ) {
				break loop;
			}

			const qpResponse = await getDabPages( offset );

			offset = qpResponse.continue?.qpoffset;

			console.log( 'Next batch (offset):', offset );

			const dabPages = qpResponse.query.querypage.results;

			( id => {
				__promises[ id ] = Promise.resolve( dabPages )
					.then( async dabPages => {
						for ( const { title, ns } of dabPages ) {
							if ( window.STOP_SCRIPT ) {
								throw new Error( 'Halt!' );
							}

							console.log( `[${id}]`, 'Processing', link(title) );

							processedPages += 1;

							if (ns || title.endsWith( ' (disambiguation)' )) {
								console.warn( `[${id}]`, 'Skipping', link( title ), 'ns:', ns );

								continue;
							}

							await sleep( window.SCRIPT_LATENCY || 1000 );

							await redirect( `${title} (disambiguation)`, title );
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

		} while ( offset );

	} catch ( err ) {
		console.error( 'Something wrong happened:', err.message, err );

		__errors.push( { error: err } );
	}

	Promise.allSettled( Object.values( __promises ) ).then( () => {
		const END_TIME = window.performance.now();

		window[ `__errors$${Date.now().toString( 36 )}` ] = __errors;

		window[ `__existing$${Date.now().toString( 36 )}` ] = __existing;

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
