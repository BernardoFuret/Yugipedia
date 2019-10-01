/**
 * Category pages mass null edit.
 * Null edits all pages in a category.
 * Change global variable `MASS_NULL_EDIT_DELAY`
 * to change the delay between null edits.
 * @author [[User:Becasita]]
 */
( function _gadgetMassNullEdit( window, $, mw, console ) {
	"use strict";

	var LAST_LOG = '~~~~~';

	var config = mw.config.get( [
		'wgNamespaceNumber',
		'wgPageName'
	] );

	var api;

	var editedPages = 0;

	function getCategoryMembers( cmcontinue ) {
		return api.get( {
			action: 'query',
			list: 'categorymembers',
			cmtitle: config.wgPageName,
			cmlimit: 'max',
			cmprop: 'title',
			cmcontinue: cmcontinue,
			format: 'json',
		} );
	}

	function requestCategoryMembers( cmcontinue ) {
		console.log(
			'[Gadget][MassNullEdit] - Requesting members from',
			cmcontinue || 'the start'
		);

		return getCategoryMembers( cmcontinue )
			.done( nullEditAll )
			.fail(
				console.error.bind(
					console,
					'[Gadget][MassNullEdit] - Error fetching category members.'
				)
			)
		;
	}

	function nullEdit( pagename ) {
		editedPages++;

		return api
			.postWithToken( 'csrf', {
				action: 'edit',
				title: pagename,
				nocreate: true,
				summary: 'Something bad happened! This was supposed to be a null edit!',
				prependtext: '',
			} )
			.done( function() {
				console.log(
					'[Gadget][MassNullEdit] - Null edited',
					pagename,
					'(page number',
					String( editedPages ).concat( ')' )
				);
			} )
			.fail(
				console.error.bind(
					console,
					'[Gadget][MassNullEdit] - Error null editing',
					pagename,
					'(page number',
					String( editedPages ).concat( ')' )
				)
			)
		;
	}

	function nullEditAll( data ) {
		var pages = ( function() {
			try {
				return data.query.categorymembers.map( function( item ) {
					return item.title;
				} );
			} catch( e ) {
				console[ data.warnings ? 'warn' : 'error' ](
					'[Gadget][MassNullEdit] - Could not find pages to null edit.',
					data.warnings || e
				);

				return null;
			}
		} )();

		if ( !pages ) {
			return;
		}

		var chain = Promise.resolve();

		for ( var i = 0, length = pages.length; i < length; i++ ) {
			( function( pagename ) {
				chain = chain.then( function() {
					return new Promise( function( resolve ) {
						nullEdit( pagename ).always( resolve );
					} );
				} );

				chain = chain.then( function() {
					return new Promise( function( resolve ) {
						window.setTimeout( resolve, window.MASS_NULL_EDIT_DELAY || 1000 );
					} );
				} );
			} )( pages[ i ] );
		}

		var continueToken = ( function() {
			try {
				return data[ 'continue' ].cmcontinue;
			} catch ( e ) {
				return null;
			}
		} )();

		if ( continueToken !== null ) {
			chain = chain.then( function() {
				return new Promise( function( resolve ) {
					requestCategoryMembers( continueToken ).always( resolve );
				} );
			} );
		} else {
			chain.then( function() {
				var message = 'All done! ('.concat(
					editedPages,
					' page',
					editedPages === 1 ? '' : 's',
					')'
				);

				console.log( '[Gadget][MassNullEdit] -', message );

				return mw.notify( message, {
					title: 'Mass null edit',
					tag: 'mass_null_edit',
				} );
			} );
		}
	}

	function onMassNullEditClick( e ) {
		e.preventDefault();

		editedPages = 0;

		requestCategoryMembers( null );
	}

	function init() {
		if ( config.wgNamespaceNumber === 14 ) {
			var $button = $( '<li>', {
				id: 'ca-massNullEdit',
				html: $( '<a>', {
					href: '#',
					title: 'Null edit all pages in this category.',
					text: 'Mass null edit',
				} ),
				click: function( e ) {
					e.preventDefault();

					console.error( '[Gadget][MassNullEdit] - Waiting for mediawiki.api and mediawiki.notify modules to load.' );
				},
			} );

			$( '#p-cactions' )
				.removeClass( 'emptyPortlet' )
				.find( '.menu' )
					.find( 'ul' )
						.append( $button )
			;

			mw.loader.using( [ 'mediawiki.api', 'mediawiki.notify' ] ).done( function() {
				api = new mw.Api();

				$button
					.off( 'click' ) // Remove fallback click.
					.click( onMassNullEditClick )
				;
			} );
		}
	}

	$( init );

	console.log( '[Gadget] MassNullEdit last updated at', LAST_LOG );

} )( window, window.jQuery, window.mediaWiki, window.console );
