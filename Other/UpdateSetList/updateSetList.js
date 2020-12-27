/**
 * (browser)
 * Convert Set list to new version
 */
( async ( window, $, mw, console ) => {
	"use strict";

	const __errors = [];

	const __promises = {};

	let chainId = 0;

	let processedPages = 0;

	const api = await mw.loader.using( 'mediawiki.api' ).then( () => new mw.Api() );

	const sleep = ms => new Promise( r => window.setTimeout( r, ms ) );

	const quote = pagename => `"${pagename}"`;

	const getCategoryMembers = cmcontinue => api.get( {
		action: 'query',
		list: 'categorymembers',
		cmtitle: 'Category:((Set list)) old transclusions',
		cmlimit: '1000',
		format: 'json',
		cmcontinue: cmcontinue,
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
		.catch( console.error.bind( console, 'Error fetching content for', quote( pagename ) ) )
	;

	const shouldSkip = content => /col\s*=|^\s*!:|(name(-local)?|category|rarity)\s*::|Set page header/img.test( content );

	const convert = content => {
		const newContent = content
			.replace( /rarity\s*=/, 'rarities=' )
			.replace( /description\s*::\s*\(as "(.*?)"\)/gi, 'printed-name::$1' )
			.replace( /set\s*=\s*.*?\|/gi, '' )
			.replace( /abbr\s*=\s*no/gi, 'options=noabbr' )
		;

		return ( /print\s*=/gi.test( content ) && !/qty\s*=/gi.test( newContent ) )
			? newContent.replace( /(;\s*);(.*?)\s*(?=\/\/|$)/gm, '$1$2' )
			: newContent
		;
	};

	const updateContent = content => {
		const newContent = convert( content );

		const setName = /(set\s*=\s*(.*?)\s*\|)/gi.exec( content )?.[2];

		const setPageHeader = `{{Set page header${setName ? `|set=${setName}` : ''}}}`;

		return newContent !== content && `${setPageHeader}\n\n${newContent}`;
	};

	const edit = ( pagename, content ) => api.postWithToken( 'csrf', {
		action: 'edit',
		title: pagename,
		nocreate: true,
		text: content,
		summary: 'Update to new version of {{Set list}}.',
		bot: true,
	} )
		.then( data => console.log(
			`Updated ${pagename}!`,
			$( '<a>', {
				target: '_blank',
				href: `https://yugipedia.com/index.php?diff=${data.edit.newrevid}`,
				text: data.edit.newrevid
			} ).prop( 'outerHTML' ),
		) )
		.catch( console.warn.bind( console, 'Error updating:' ) )
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
						
							processedPages++;

							const content = await getContent( title );

							await sleep( window.SCRIPT_LATENCY || 1000 );

							if ( !content ) {
								console.warn( 'No content for', quote( title ) );

								__errors.push( {
									title,
									type: 'No content',
								} );

								continue;
							}

							if ( shouldSkip( content ) ) {
								console.warn( 'Skipping', quote( title ) );

								continue;
							}

							const updatedContent = updateContent( content );

							if ( !updatedContent ) {
								console.warn( 'No changes for', quote( title ) );

								window.console.warn( 'No changes for', quote( title ) );
								window.console.log( content );

								__errors.push( {
									title,
									type: 'No changes',
								} );

								continue;
							}

							// window.console.log( title );
							// window.console.log( updatedContent );
							await edit( title, updatedContent );
						}
					} )
					.catch( err => {
						if ( err === 'Halt!' ) {
							console.log( 'Terminating chain with ID', id );

							return;
						}

						console.error( 'Unknown error:', err.message, err );

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
