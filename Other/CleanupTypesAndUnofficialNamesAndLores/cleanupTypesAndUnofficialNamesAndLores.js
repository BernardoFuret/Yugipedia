/**
 *  (browser).
 */
// https://yugipedia.com/index.php?title=Polymerization&action=raw
// https://yugipedia.com/index.php?title=Gaia%20The%20Fierce%20Knight&action=raw
( async ( window, $, mw, console ) => {
	"use strict";

	const __errors = [];

	const __removedNamesAndLores = [];

	let updateContentPages = -1;

	const api = await mw.loader.using( "mediawiki.api" ).then( () => new mw.Api() );

	const sleep = ms => new Promise( r => window.setTimeout( r, ms ) );

	const quote = pagename => `"${pagename}"`;

	const OFFICIAL_LANGUAGES = {
		index: {
			'en': true,
			'fr': true,
			'de': true,
			'it': true,
			'pt': true,
			'es': true,
			'ja': true,
			'zh': true,
			'ko': true,
		},
		full: {
			'English': true,
			'French': true,
			'German': true,
			'Italian': true,
			'Portuguese': true,
			'Spanish': true,
			'Japanese': true,
			'Chinese': true,
			'Korean': true,
		},
	};

	const updateTypeParams = function( content ) {
		//^ *\| *type(\d)? *= *(.*?)$\n
		const types = [];

		return content
			.replace( /^\s*\|\s*type(\d)?\s*=\s*(.*?)$\n/gm, ( m, $1, $2 ) => {
				types[ Number( $1 || 1 ) ] = $2;

				return $1 ? '' : '$PLACEHOLDER$\n';
			} )
			.replace(
				/^\$PLACEHOLDER\$$/gm,
				`| types                 = ${types.filter( Boolean ).join( ' / ' )}`
			)
		;
	}

	const updateUnofficial = function( content ) {
		return content
			.replace( /^\|\s+(\w\ww?)_(lore|name)(.+)$\n/gm, ( m, $1, $2, $3 ) => {
				if ( OFFICIAL_LANGUAGES.index[ $1 ] ) {
					return m;
				} else {
					__removedNamesAndLores[ updateContentPages ][ `${$2}s` ].push( {
						language: $1,
						[ $2 ]: $3.replace( /^.*?=\s/m, '' ),
					} );

					return '';
				}
			} )
			.replace( /(\{\{ *Unofficial (?:name|lore)\|)(.*?)(\}\}\s*?$\n)/gm, ( m, $1, $2, $3 ) => {
				const officialLanguages = $2
					.split( /\s*,\s*/ )
					.filter( language => OFFICIAL_LANGUAGES.full[ language ] )
				;

				return officialLanguages.length
					? `${$1}${officialLanguages.join( ', ' )}${$3}`
					: ''
				;
			} )
		;
	}

	const updateContent = ( pagename, content ) => {
		__removedNamesAndLores.push( {
			pagename,
			names: [],
			lores: [],
		} );

		updateContentPages++;

		return updateUnofficial(
			updateTypeParams( content )
		);
	}

	const getMembers = cmcontinue => api.get( {
		action: "query",
		list: "categorymembers",
		cmtitle: "Category:CardTable2 parameter tracking (type)",
		cmlimit: "max",
		format: "json",
		cmcontinue: cmcontinue,
	} );

	const getContent = pagename => api.get( {
		action: "query",
		redirects: false,
		prop: "revisions",
		rvprop: "content",
		format: "json",
		formatversion: 2,
		titles: pagename
	} )
		.then ( data => data.query.pages[ 0 ].revisions[ 0 ].content )
		.catch( console.error.bind( console, "Error fetching content for", pagename ) )
	;

	const edit = ( pagename, content ) => api.postWithToken( "csrf", {
		action: "edit",
		title: pagename,
		nocreate: true,
		text: content,
		summary: "Cleanup: convert each `type\\d` to a single `types`; remove unofficial names and lores.",
		bot: true,
	} )
		.then( data => console.log(
			"Updated!",
			$( "<a>", {
				target: "_blank",
				href: `https://yugipedia.com/index.php?diff=${data.edit.newrevid}`,
				text: data.edit.newrevid
			} ).prop( "outerHTML" ),
		) )
		.catch( console.warn.bind( console, "Error updating:" ) )
	;

	let continueToken = window.START_TOKEN || null;
	let pageCount = 0;
	const START_TIME = window.performance.now();

	loop:
	do {
		console.log( "Starting do-while iteration.", "continueToken:", continueToken );

		const response = await getMembers( continueToken );

		continueToken = ( response.continue || {} ).cmcontinue;

		for ( const { title: pagename } of response.query.categorymembers ) {
			if ( window.STOP_SCRIPT ) {
				break loop;
			}

			pageCount++;

			console.log( "Getting content for", pagename );

			const content = await getContent( pagename );

			if ( !content ) {
				console.warn( "No content for", pagename );

				__errors.push( {
					pagename,
					type: "No content",
				} );

				continue;
			}

			let updatedContent;

			try {
				updatedContent = updateContent( pagename, content );
			} catch ( e ) {
				console.warn( "Failed to convert content for", pagename, e.message );

				window.console.log( "Failed to convert content for", pagename, e );
				window.console.log( content );

				__errors.push( {
					pagename,
					type: "Cannot convert",
				} );

				continue;
			}


			if ( updatedContent === content ) {
				console.warn( "No changes for", pagename );

				window.console.warn( "No changes for", pagename );
				window.console.log( content );

				__errors.push( {
					pagename,
					type: "No changes",
				} );

				continue;
			}

			await edit( pagename, updatedContent );
			window.console.log( pagename, content, updatedContent );

			await sleep( window.LATENCY || 5000 );
		}

		await sleep( 500 );
	} while ( continueToken );

	const END_TIME = window.performance.now();

	window[ `__errors$${Date.now().toString( 36 )}` ] = __errors;

	window[ `__removedNamesAndLores$${Date.now().toString( 36 )}` ] = __removedNamesAndLores;

	console.log( ( window.STOP_SCRIPT || mw.user.isAnon() ) ? "Stopped!" : "All done!" );
	console.log( "Took", END_TIME - START_TIME, "to process", pageCount, "pages." );

} )( window, window.jQuery, window.mediaWiki, ( ( window, $ ) => {
	"use strict";

	const win = window.open();

	const doWrite = ( args, color = "black" ) => win.document.write(
		$( "<pre>", {
			html: args.map( arg => typeof arg !== typeof ""
				? JSON.stringify( arg, null, "  " )
				: arg
			).join( " " )
		} ).css( "color", color ).prop( "outerHTML" )
	);

	return {
		log: ( ...args ) => doWrite( args ),

		warn: ( ...args ) => doWrite( args, "darkorange" ),

		error: ( ...args ) => doWrite( args, "red" ),
	};
} )( window, window.jQuery ) ).catch( window.console.error );
