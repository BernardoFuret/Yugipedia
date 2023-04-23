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

	const shouldSkip = content => false // Never skip
		&& /(name(-local)?|category|rarity)\s*::/img.test( content )
	;

	const convertColumns = content => {
		const columnName = /col\s*=\s*(.*?)\|/gi.exec( content )?.[ 1 ];

		return columnName
			? content
				.replace( /col\s*=\s*/gi, 'columns=' )
				.replace( new RegExp( `${columnName}\\s*::`, 'gi' ), `@${columnName}::` )
			: content
		;
	};

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
		let newContent = content
			.replace( /rarity\s*=/gi, 'rarities=' )
			.replace( /description\s*::\s*\(as "(.*?)"\)/gi, 'printed-name::$1' )
			.replace( /set\s*=\s*.*?\|/gi, '' )
			.replace( /abbr\s*=\s*no/gi, 'options=noabbr' )
		;

		newContent = convertColumns( newContent );

		return /print\s*=/gi.test( content )
			? newContent
				.replace( /print\s*=\s*1/gi, 'print=Reprint' )
				.split( '\n' )
				.map( line => {
					if ( /^\s*$|^\s*(?:\{|\}|\|)|[^{]=/gim.test( line ) ) {
						return line;
					}

					const [ lineValues, ...lineOptions ] = line.split( /\s*\/\/\s*/ );

					const lineValuesParts = lineValues.split( ';' );

					[ lineValuesParts[ 3 ], lineValuesParts[ 4 ] ] = [ lineValuesParts[ 4 ], lineValuesParts[ 3 ] ];

					return [
						lineValuesParts.join( ';' ).replace( /(\s*;)+$/gm, '' ),
						...lineOptions,
					].join( ' // ' );
				})
				.join( '\n' )
			: newContent
		;
	};

	const convertSections = content => {
		let templateArgs = {};

		return content.split( '\n' )
			.reduce( ( acc, line ) => {
				// Template call:
				if ( /set list/gi.test( line ) ) {
					templateArgs = getArgsFromWikitext(
						line.replace( /^\s*{{\s*Set list\s*\|\s*/im, '' ),
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

					const { header, ...headerArgsRest } = headerArgs;

					const allArgs = {
						...templateArgs,
						...headerArgsRest,
					};

					return [
						...acc.filter( e => e ),
						'}}',
						' ',
						`== ${header} ==`,
						`{{Set list|${argsToWikitext( allArgs )}`,
					];
				}

				// Rest:
				return [ ...acc, line ];
			}, [] )
			.join( '\n' )
			.replace( /{{\s*set list(.*?)\s*}}/gi, '' )
			.replace( /^[ \t]$/gm, '' )
			.trim()
			.split( /\n{2,}/ )
			.map( setList => {
				const trimmedSetList = setList.trim();

				const [ header, ...restOfSetList ] = trimmedSetList.split( '\n' );

				return /^==/m.test( header )
					? `${header}\n${convert( restOfSetList.join( '\n' ) )}`
					: convert( trimmedSetList )
				;
			} )
			.join( '\n\n' )
			.replace( /^[ \t]$/gm, '' )
		;
	};

	const oldUpdateContent = content => {
		const newContent = /^\s*!:/m.test( content )
			? convertSections( content )
			: convert( content )
		;

		const setName = /(set\s*=\s*(.*?)\s*\|)/gi.exec( content )?.[2];

		const setPageHeader = `{{Set page header${setName ? `|set=${setName}` : ''}}}`;

		return newContent !== content && ( /Set page header/g.test( newContent )
			? newContent
			: `${setPageHeader}\n\n${newContent}`
		);
	};

	const updateContent = content => {
		const newContent = oldUpdateContent( content );

		if (!newContent) {
			return '';
		}

		let updatedContent = newContent.replace( /print\s*=\s*1/gi, 'print=Reprint' )
		
		if ( !/Set page header/ig.test( newContent ) ) {
			updatedContent = `{{Set page header}}\n\n${updatedContent}`;
		}

		return content !== updatedContent && updatedContent;
	};


	const edit = ( pagename, content ) => api.postWithToken( 'csrf', {
		action: 'edit',
		title: pagename,
		nocreate: true,
		text: content,
		summary: 'Restoring/redoing old bot updates: Update to new version of {{Set list}}.',
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
