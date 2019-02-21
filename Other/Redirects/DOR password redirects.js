/**
 * Passcode redirect (browser).
 */
( async ( window, $, mw, console ) => {
	"use strict";

	const __pagesWithoutPassword = [];

	const api = new mw.Api();

	const sleep = time => new Promise( resolve => window.setTimeout( resolve, time ) );

	const getCategoryPages = cmcontinue => api.get( {
		action: "query",
		list: "categorymembers",
		cmtitle: "Category:Yu-Gi-Oh! The Duelists of the Roses cards",
		cmlimit: "max",
		cmcontinue: cmcontinue
	} );

	const getContent = pagename => api.get( {
		action: "query",
		redirects: true,
		prop: "revisions",
		rvprop: "content",
		format: "json",
		formatversion: 2,
		titles: pagename
	} )
		.then( data => data.query.pages[ 0 ].revisions[ 0 ].content )
		.catch( console.error.bind( console, "Error fetching content for", pagename ) )
	;

	const getPasscode = content => /\| *passcode *= *(\w+)/.exec( content )[ 1 ];

	const getPassword = content => /\| *password *= *(\w+)/.exec( content )[ 1 ];

	const edit = ( pagename, content ) => api.postWithToken( "csrf", {
		action: "edit",
		title: pagename,
		nocreate: true,
		text: content,
		summary: "Updating parameters: `passcode` → `password`.",
		bot: true,
	} )
		.then( data => console.log(
			"Updated parameter!",
			$( "<a>", {
				target: "_blank",
				href: `https://yugipedia.com/index.php?diff=${data.edit.newrevid}`,
				text: data.edit.newrevid
			} ).prop( "outerHTML" ),
		) )
		.catch( console.warn.bind( console, "Error updating parameter:" ) )
	;

	const redirect = ( password, pagename ) => api.postWithToken( "csrf", {
		action: "edit",
		title: password,
		createonly: true,
		text: `#REDIRECT [[${pagename}]] {{R from password}}`,
		summary: `Creating redirects: Redirected page to [[${pagename}]].`,
		bot: true,
	} )
		.then( console.log.bind( console, "Redirected page to", pagename ) )
		.catch( console.warn.bind( console, "Error redirecting:" ) )
	;

	let continueToken = window.START_TOKEN || null;
	let updatedParameterCount = 0; // TODO: check
	let redirectCount = 0; // TODO: check
	const START_TIME = window.performance.now();

	loop:
	do {
		console.log( "Starting do-while iteration.", "continueToken:", continueToken );

		console.log( "Getting category pages." );
		const response = await getCategoryPages( continueToken );
		const pages = response.query.categorymembers;

		// Update the continue token:
		continueToken = ( r => {
			// IIFE to deal with exceptions:
			try {
				return r.continue.cmcontinue;
			} catch ( e ) {
				console.warn( "Cannot fetch cmcontinue token! Exception:", e );

				return null;
			}
		} )( response );

		for ( let i = 0, length = pages.length; i < length; i += 1 ) {
			console.log( "****FOR START****" );

			// Page to get the passcode from:
			const { title: pagename } = pages[ i ];

			console.log( "Getting raw content for:", pagename );
			const content = await getContent( pagename );

			if ( !content ) {
				console.log( "No content found. Skipping." );

				continue;
			}

			console.log( "Checking for passcode." );
			const passcode = ( ( pagename, content ) => {
				try {
					return getPasscode( content );
				} catch ( e ) {
					console.warn( "No passcode for", pagename );
					
					return null;
				}
			} )( pagename, content );

			if ( passcode ) {
				console.log( "Passcode found! Updating page." );

				await edit(
					pagename,
					content.replace( /(\| *)passcode( *= )/g, "$1password$2" ),
				);
			}

			console.log( "Checking for password." );
			const password = passcode || ( ( pagename, content ) => {
				try {
					return getPassword( content );
				} catch ( e ) {
					console.warn( "No password for", pagename );
					
					__pagesWithoutPassword.push( {
						pagename,
						content,
					} );
					
					console.warn( "Exception:", e );
					
					return null;
				}
			} )( pagename, content );

			if ( !password ) {
				console.log( "Skipping." );

				continue;
			}

			console.log( "Redirecting", password, "to", pagename );
			await redirect( password, pagename );

			await sleep( 500 );

			console.log( "****FOR END****" );
		}

		await sleep( 500 );

	} while ( continueToken );

	const END_TIME = window.performance.now();

	window[ `__pagesWithoutPassword$${Date.now().toString( 36 )}` ] = __pagesWithoutPassword;

	console.log( window.STOP_SCRIPT ? "Stopped!" : "All done!" );
	console.log( "Took", END_TIME - START_TIME, "to redirect", redirectCount, "passwords and update",  updatedParameterCount, "pages." );

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