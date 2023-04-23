/**
 * (browser)
 * Convert Set gallery to new version
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

	const getCategoryMembers = cmcontinue => api.get( {
		action: 'query',
		list: 'categorymembers',
		cmtitle: 'Category:((Set gallery)) old transclusions',
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
		.catch( console.error.bind( console, 'Error fetching content for', link( pagename ) ) )
	;

	const shouldSkip = content => /Set page header/gi.test( content );

	const getArgsFromWikitext = ( text, paramSep, assignSep ) => text
		.split( paramSep )
		.reduce( ( acc, e ) => {
			if ( !e.trim() ) {
				return acc;
			}

			const [ param, arg ] = e.split( assignSep );

			return {
				...acc,
				[ param ]: arg,
			};
		}, {} )
	;

	const argsToWikitext = args => {
		return Object.entries( args )
			.map( ( [ param, arg ] ) => `${param}=${arg}|` )
			.join( '' )
		;
	};

	const convert = content => {
		return content
			.replace( /description\s*::\s*\(as (?:「|")(.*?)(?:」|")\)/gi, 'printed-name::$1' )
			.replace( /name-local\s*::\s*(?:「|")(.*?)(?:」|")(?:\s*)(;|$)/gim, 'printed-name::$1$2' )
			.replace( /^\s*;(.*?)\/\/(.*?)abbr::/gim, $0 => $0.replace( /^\s*;/gm, '' ) )
			.replace( /(set|region)\s*=\s*.*?\|/gi, '' )
		;
	};

	const convertSections = content => {
		let templateArgs = {};

		return content.split( '\n' )
			.reduce( ( acc, line ) => {
				// Template call:
				if ( /set gallery/gi.test( line ) ) {
					templateArgs = getArgsFromWikitext(
						line.replace( /^\s*{{\s*Set gallery\s*\|\s*/im, '' ),
						/\s*\|\s*/,
						/\s*=\s*/,
					);

					return [ ...acc, line ];
				}

				// Section header
				if ( /^\s*!:/m.test( line ) ) {
					const headerArgs = getArgsFromWikitext(
						line.replace( /^\s*!:\s*/m, '' ),
						/\s*;\s*/,
						/\s*::\s*/,
					);

					const { header = '', ...headerArgsRest } = headerArgs;

					const allArgs = {
						...templateArgs,
						...headerArgsRest,
						...( /\bReprint\b/i.test( header ) && { alt: 'Reprint' } ),
					};

					return [
						...acc.filter( e => e ),
						'}}',
						' ',
						`== ${header} ==`,
						`{{Set gallery|${argsToWikitext( allArgs )}`,
					];
				}

				// Rest:
				return [ ...acc, line ];
			}, [] )
			.join( '\n' )
			.replace( /{{\s*set gallery(.*?)\s*}}/gi, '' )
			.replace( /^[ \t]$/gm, '' )
			.trim()
			.split( /\n{2,}/ )
			.map( setGallery => {
				const trimmedSetGallery = setGallery.trim();

				const [ header, ...restOfSetGallery ] = trimmedSetGallery.split( '\n' );

				return /^==/m.test( header )
					? `${header}\n${convert( restOfSetGallery.join( '\n' ) )}`
					: convert( trimmedSetGallery )
				;
			} )
			.join( '\n\n' )
			.replace( /^[ \t]$/gm, '' )
		;
	};

	const updateContent = content => {
		const newContent = /^\s*!:/m.test( content )
			? convertSections( content )
			: convert( content )
		;

		const setName = /(set\s*=\s*(.*?)\s*\|)/gi.exec( content )?.[2];

		const setPageHeader = `{{Set page header${setName ? `|set=${setName}` : ''}}}`;

		return `${setPageHeader}\n\n${newContent}`
		;
	};

	const edit = ( pagename, content ) => api.postWithToken( 'csrf', {
		action: 'edit',
		title: pagename,
		nocreate: true,
		text: content,
		summary: 'Restoring/redoing old bot updates: Update to new version of {{Set gallery}}. Add {{Set page header}}.',
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

							if ( shouldSkip( content ) ) {
								console.warn( `[${id}]`, 'Skipping', link( title ) );

								continue;
							}

							const updatedContent = updateContent( content );

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

							// console.log( id, title );
							// window.console.log( updatedContent );
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
