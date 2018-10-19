/**
 * Add {{OCG-TCG card image}} (browser).
 */
( async ( window, $, mw, console ) => {
	"use strict";

	const __filesWithContent = [];

	const hasOwnProperty = Object.prototype.hasOwnProperty;

	const SKIP = "[SKIPPING]";

	const api = new mw.Api();

	const sleep = time => new Promise( resolve => window.setTimeout( resolve, time ) );

	const getImages = aicontinue => api.get( {
		action: "query",
		list: "allimages",
		ailimit: "max",
		aiprop: null,
		format: "json",
		aicontinue: aicontinue,
	} );

	const getTrimmedName = filepath => filepath.replace( /^File:/, '' ).split( '-' )[ 0 ];

	const queryName = trimmed => api.get( {
		// https://yugipedia.com/api.php?action=ask&query=[[Card%20image%20name::NirvanaHighPaladin]]&api_version=3
		// https://yugipedia.com/api.php?action=askargs&conditions=Card%20image%20name::NirvanaHighPaladin&api_version=3
		action: "askargs",
		conditions: `Card image name::${trimmed}`,
		api_version: 3,
	} )
		.then( data => {
			const res = data.query.results[ 0 ]; // Shouldn't error...

			for ( let prop in res ) {
				if ( hasOwnProperty.call( res, prop ) ) {
					return prop; // The first one that pops out should be enough.
				}
			}
		} )
		.catch( console.error )
	;

	const addTemplate = ( pagename, name ) => api.postWithToken( "csrf", {
		action: "edit",
		title: pagename,
		createonly: true,
		text: `{{OCG-TCG card image\n| name = ${name}\n}}`,
		summary: "Adding {{OCG-TCG card image}}",
		bot: true,
	} )
		.then( () => console.log( 'Template added!' ) )
		.catch( ( code, err ) => {
			console.warn( "Error adding template.", err );

			if ( code === 'articleexists' ) {
				__filesWithContent.push( { pagename, name, err } );
			}
		} )
	;

	let continueToken = null;
	do {
		console.log( "Starting do-while iteration.", "continueToken:", continueToken );

		console.log( "Getting images." );
		const response = await getImages( continueToken );
		const images = response.query.allimages;

		// Update the continue token:
		continueToken = ( r => {
			// IIFE to deal with exceptions:
			try {
				return r.continue.aicontinue;
			} catch ( e ) {
				console.warn( "Can't fetch aicontinue token! Exception:", e );
				return null;
			}
		} )( response );

		for ( let i = 0, length = images.length; i < length; i+=1 ) {
			console.log( "****FOR START****" );

			const { title: pagename } = images[ i ];

			console.log( "Validating file name..." );
			if ( /-(anime|vg|manga|ow)[-.]/i.test( pagename ) ) {
				console.log( SKIP, pagename, "is a", RegExp.$1, "file." );
				continue;
			}

			console.log( "Getting trimmed name for:", pagename );
			const trimmedName = getTrimmedName( pagename );

			if ( !trimmedName ) {
				console.log( SKIP, "No trimmed name for", pagename, );
				continue;
			}

			console.log( "Querying for", trimmedName );
			const name = await queryName( trimmedName );

			if ( !name ) {
				console.log( SKIP, "Can't get query result for", trimmedName );
				continue;
			}

			console.log( 'Adding template to', pagename, 'with name', name );

			await addTemplate( pagename, name );

			await sleep( 250 );
			console.log( "****FOR END****" );
		}

		await sleep( 250 );
	} while ( continueToken );


	window[ `__filesWithContent$${Date.now().toString( 36 )}` ] = __filesWithContent;

	console.log( "All done!" );

} )( window, window.jQuery, window.mediaWiki, ( window => {
	const win = window.open();

	const doWrite = (args, color = 'black') => win.document.write(
		`<pre style="color: ${color};">${
			args.map( a => typeof a !== typeof '' ? JSON.stringify( a, null, '  ' ) : a ).join( ' ' )
		}</pre>`
	);

	return {
		log: (...args) => {
			doWrite( args )
		},

		warn: (...args) => {
			doWrite( args, 'darkorange' );
		},

		error: (...args) => {
			doWrite( args, 'red' );
		},
	};
} )( window ) ).catch( window.console.error );
