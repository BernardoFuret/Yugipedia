/**
 *  (browser).
 */
( async ( window, $, mw, console ) => {
	"use strict";

	const __errors = [];

	const api = await mw.loader.using( "mediawiki.api" ).then( () => new mw.Api() );

	const sleep = ms => new Promise( r => window.setTimeout( r, ms ) );

	const quote = pagename => `"${pagename}"`;

	class OrderedContainer {
		constructor() {
			this.order = [];
			this.archiver = {};
		}

		add( [ _, number, set, rarity ] ) {
			if ( this.archiver[ set ] == null ) {
				this.archiver[ set ] = this.order.push( {
					set,
					number,
					rarity: [],
				} ) - 1;
			}

			this.order[ this.archiver[ set ] ].rarity.push( rarity );

			return this;
		}

		toString() {
			return this.order
				.map( ( { set, number, rarity } ) => `${number}; ${set}; ${rarity.join( ', ' )}` )
				.join( "\n" )
			;
		}
	}

	const updateContent = content => content.replace(
		/\{\{Card table set\/header.*([\s\S]+?)^.*?footer}}/gm,
		( m, $1 ) => $1.split( /\n/ ).reduce(
			( acc, line ) => line.trim()
				? acc.add( line.match( /{{Card +table +set\|(.*?)\|(.*?)(?:\|(.*?))?}}/i ) )
				: acc
			,
			new OrderedContainer(),
		),
	);

	const getMembers = cmcontinue => api.get( {
		action: "query",
		list: "categorymembers",
		cmtitle: "Category:((CardTable2)) transclusion using old-style (((en sets))) format",
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
		summary: "Updating sets markup.",
		bot: true,
	} )
		.then( data => console.log(
			"Updated sets markup!",
			$( "<a>", {
				target: "_blank",
				href: `https://yugipedia.com/index.php?diff=${data.edit.newrevid}`,
				text: data.edit.newrevid
			} ).prop( "outerHTML" ),
		) )
		.catch( console.warn.bind( console, "Error updating sets markup:" ) )
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
				updatedContent = updateContent( content );
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

			if ( mw.user.isAnon() ) {
				console.warn( "Bot has logged out." );

				break loop;
			}

			await edit( pagename, updatedContent );

			await sleep( window.LATENCY || 5000 );
		}

		await sleep( 500 );
	} while ( continueToken );

	const END_TIME = window.performance.now();

	window[ `__ctsErrors$${Date.now().toString( 36 )}` ] = __errors;

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
