/**
 * Password redirect (browser).
 */
( async ( window, $, mw, console ) => {
	"use strict";

	const api = new mw.Api();

	const sleep = time => new Promise( resolve => window.setTimeout( resolve, time ) );

	const getCategoryPages = cmcontinue => api.get( {
		action: "query",
		list: "categorymembers",
		cmtitle: "Category:Cards needing a password redirect",
		cmlimit: "max",
		cmcontinue: cmcontinue,
	} );

	const getContent = pagename => api.get( {
		action: "query",
		redirects: true,
		prop: "revisions",
		rvprop: "content",
		format: "json",
		formatversion: 2,
		titles: pagename,
	} )
		.then ( data => data.query.pages[ 0 ].revisions[ 0 ].content )
		.catch( console.error )
	;

	const getPassword = content => /\| *pass(?:word|code) *= *(\d+?)$/m.exec( content )[ 1 ];

	const redirect = ( password, pagename ) => api.post( {
		action: "edit",
		title: password,
		createonly: true,
		text: `#REDIRECT [[${pagename}]] {{R from password}}`,
		summary: `Creating redirects: Redirected page to [[${pagename}]].`,
		bot: true,
		token: mw.user.tokens.get( "editToken" ),
	} )
		.then( () => console.log( `Redirected page to [[${pagename}]].` ) )
		.catch( err => console.warn( "Error redirecting:", err ) )
	;

	let continueToken = "0";
	do {
		console.log( "Starting do-while iteration.", "continueToken:", continueToken );

		console.log( "Getting category pages." );
		const response = await getCategoryPages( continueToken );
		const pages = response.query.categorymembers;
		const length = pages.length;

		// Update the continue token:
		continueToken = ( r => {
			// IIFE to deal with exceptions:
			try {
				return r.continue.cmcontinue;
			} catch ( e ) {
				console.warn( "Can't fetch cmcontinue token! Exception:", e );
				return null;
			}
		} )( response );

		for ( let i = 0; i < length; i+=1 ) {
			console.log( "****FOR START****" );
			// Page to get the password from:
			const { title: pagename } = pages[ i ];

			console.log( "Getting raw content for:", pagename );
			const content = await getContent( pagename );

			console.log( "Retrieving password." );
			const password = ( ( pagename, content ) => {
				try {
					return getPassword( content );
				} catch ( e ) {
					console.warn( "Error getting password for", pagename );
					console.log( "Content:", content );
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
			console.log( "Done redirecting." );

			await sleep( 500 );
			console.log( "****FOR END****" );
		}
	} while ( continueToken );

	console.log( "All done!" );

} )( window, window.jQuery, window.mediaWiki, window.console ).catch( window.console.error );