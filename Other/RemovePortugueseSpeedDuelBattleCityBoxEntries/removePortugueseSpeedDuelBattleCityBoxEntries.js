/**
 * (browser)
 * Remove Portuguese entries for Speed Duel: Battle City Box.
 */
( async ( window, $, mw, console ) => {
	"use strict";

	const __errors = [];

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

	const getBacklinks = blcontinue => api.get( {
		action: 'query',
		list: 'backlinks',
		bltitle: 'Speed Duel: Battle City Box',
		bllimit: 600,
		blcontinue,
		format: 'json',
	} );

	const getContent = pagename => api.get( {
		action: 'query',
		redirects: false,
		prop: 'revisions',
		rvprop: 'content',
		format: 'json',
		formatversion: 2,
		titles: pagename
	} )
		.then ( data => data.query.pages[ 0 ].revisions[ 0 ].content )
		.catch( console.error.bind( console, 'Error fetching content for', link( pagename ) ) )
	;

	const shouldSkip = ns => ![3004, 0].includes( ns );

	const updateMainNsContent = content => content.replace(
		/\|[ \t]*pt_sets[ \t]*=([\s\S])*?(?=\|)/g,
		$0 => {
			const replaced = $0.replace( /^(.*?)Speed Duel: Battle City Box(.*?)\n/gm, '' );

			return ( /\|[ \t]*pt_sets[ \t]*=\s+$/.test( replaced )
				? ''
				: replaced
			);
		}
	);

	const updateCardGalleryNsContent = content => content.replace(
		/^[ \t]*\{\{[ \t]*Card gallery(.*?)region[ \t]*=[ \t]*pt[ \t]*\|[\s\S]*?\}\}\n\n/gmi,
		$0 => {
			const replaced = $0.replace( /^(.*?)Speed Duel: Battle City Box(.*?)\n/gm, '' );

			return ( /^[ \t]*\{\{[ \t]*Card gallery(.*?)region[ \t]*=[ \t]*pt[ \t]*\|[\s]*?\}\}/gmi.test( replaced )
				? ''
				: replaced
			);
		}
	);

	const updateContent = ( content, ns ) => (ns === 0
		? updateMainNsContent( content )
		: updateCardGalleryNsContent( content )
	);

	const edit = ( pagename, content ) => api.postWithToken( 'csrf', {
		action: 'edit',
		title: pagename,
		nocreate: true,
		text: content,
		summary: 'Removing Portuguese entry for [[Speed Duel: Battle City Box]].',
		bot: true,
	} )
		.then( data => console.log(
			'Updated',
			link(pagename),
			$( '<a>', {
				target: '_blank',
				href: `https://yugipedia.com/index.php?diff=${data.edit.newrevid}`,
				text: `(${data.edit.newrevid})`,
			} ).prop( 'outerHTML' ),
		) )
		.catch( console.warn.bind( console, `Error updating ${pagename}:` ) )
	;

	let continueToken = window.START_TOKEN;

	window.DEBUG = true;

	const START_TIME = window.performance.now();

	try {

		loop:
		do {
			if ( window.STOP_SCRIPT ) {
				break loop;
			}

			const blResponse = await getBacklinks( continueToken );

			// Update the continue token:
			continueToken = blResponse.continue?.blcontinue;

			console.log( 'Next batch:', continueToken );

			const { backlinks } = blResponse.query;

			( id => {
				__promises[ id ] = Promise.resolve( backlinks )
					.then( async backlinks => {
						for ( const { title, ns } of backlinks ) {
							if ( window.STOP_SCRIPT ) {
								throw 'Halt!';
							}

							console.log( `[${id}]`, 'Processing', link(title) );

							processedPages++;

							const content = await getContent( title );

							await sleep( window.SCRIPT_LATENCY || 1000 );

							if ( !content ) {
								console.warn( `[${id}]`, 'No content for', link( title ) );

								__errors.push( {
									title,
									type: 'No content',
								} );

								continue;
							}

							if ( shouldSkip( ns ) ) {
								console.warn( `[${id}]`, 'Skipping', link( title ), 'ns:', ns );

								continue;
							}

							const updatedContent = updateContent( content, ns );

							if ( updatedContent === content ) {
								console.warn( `[${id}]`, 'No changes for', link( title ) );

								window.console.warn( `[${id}]`, 'No changes for', link( title ) );
								window.console.log( `[${id}]`, content );

								__errors.push( {
									title,
									type: 'No changes',
								} );

								continue;
							}

							await edit( title, updatedContent );
						}
					} )
					.catch( err => {
						if ( err === 'Halt!' ) {
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

			await sleep( 500 );

		} while ( continueToken );

	} catch ( err ) {
		console.error( 'Something wrong happened:', err.message, err );

		__errors.push( { error: err } );
	}

	Promise.allSettled( Object.values( __promises ) ).then( () => {
		const END_TIME = window.performance.now();

		window[ `__errors$${Date.now().toString( 36 )}` ] = __errors;

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
