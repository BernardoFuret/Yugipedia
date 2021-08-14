( async ( window, $, mw, console ) => {

	const __errors = [];

	const config = mw.config.get( [
		'wgPageName',
	] );

	const sleep = ms => new Promise( r => window.setTimeout( r, ms ) );

	const quote = pagename => `"${pagename}"`;

	const api = await mw.loader.using( 'mediawiki.api' ).then( () => new mw.Api() );


	const otcg = config.wgPageName.match( /\(([ot]cg)-/i );

	if ( !otcg ) {
		throw new Error( 'No OCG nor TCG!' );
	}

	const regex = new RegExp(
		`^[ \\t]*\\|[ \\t]*${otcg[ 1 ]}_status[ \\t]*=[ \\t]*Not yet released\\n`,
		'gim'
	);

	const getList = () => api
		.get( {
			action: 'query',
			redirects: true,
			prop: 'revisions',
			rvprop: 'content',
			format: 'json',
			formatversion: 2,
			titles: config.wgPageName,
		} )
		.then( data => data.query.pages[ 0 ].revisions[ 0 ].content )
		.catch( console.error.bind( console, 'Error fetching list for', config.wgPageName ) );

	const updateContent = ( content ) => content.replace( regex, '' );

	const getContent = pagename => api
		.get( {
			action: 'query',
			redirects: false,
			prop: 'revisions',
			rvprop: 'content',
			format: 'json',
			formatversion: 2,
			titles: pagename,
		} )
		.then( data => data.query.pages[ 0 ].revisions[ 0 ].content )
		.catch( console.error.bind( console, 'Error fetching content for', quote( pagename ) ) );

	const edit = ( pagename, content ) => api
		.postWithToken( 'csrf', {
			action: 'edit',
			title: pagename,
			nocreate: true,
			text: content,
			summary: 'Updating F&L status',
			bot: true,
		} )
		.then( data => console.log(
			'Updated',
			quote( pagename ),
			$( '<a>', {
				target: '_blank',
				href: `https://yugipedia.com/index.php?diff=${data.edit.newrevid}`,
				text: data.edit.newrevid,
			} ).prop( 'outerHTML' ),
		) )
		.catch( console.warn.bind( console, 'Error updating', quote( pagename ) ) );

	const getCardList = ( listContent ) => {
		const regex = /^[ \t]*[\d\-\w/]{5,13}[ \t]*;[ \t]*(.*?)[ \t]*(?:;|\/\/|$)/gm;

		const list = [];

		listContent.replace( regex, function( m, $1 ) {
			list.push( $1 );
		} );

		return list;
	};

	const processCard = async ( pagename ) => {
		const content = await getContent( pagename );

		if (!content) {
			return;
		}

		const updatedContent = updateContent( content );

		if ( updatedContent === content ) {
			console.warn( 'No changes for', quote( pagename) );

			window.console.warn( 'No changes for', pagename );
			window.console.log( content );

			__errors.push( {
				pagename,
				type: 'No changes',
				data: content,
			} );

			return;
		}

		await edit( pagename, content );
	};

	const iterate = async ( cardList ) => {
		for ( const card of cardList ) {
			await processCard( card );

			await sleep( window.LATENCY || 1000 );
		}
	};

	const exec = async () => {
		const listContent = await getList();

		if ( !listContent ) {
			return;
		}

		const cardList = getCardList( listContent );

		await iterate( cardList );
	};

	const START_TIME = window.performance.now();

	await exec();

	const END_TIME = window.performance.now();

	window[ `__errors$${Date.now().toString( 36 )}` ] = __errors;

	console.log( ( window.STOP_SCRIPT || mw.user.isAnon() ) ? 'Stopped!' : 'All done!' );
	console.log( 'Took', END_TIME - START_TIME );

} )( window, window.jQuery, window.mediaWiki, ( ( window, $ ) => {
	const win = window.open();

	const doWrite = ( args, color = 'black' ) => win.document.write(
		$( '<pre>', {
			html: args.map( arg => typeof arg !== typeof ''
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