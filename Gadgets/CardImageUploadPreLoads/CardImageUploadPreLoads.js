/**
 * Automatically fills Special:Upload form for card images.
 * (Achieved by updating the links for missing files on card galleries.)
 * @author Becasita
 * @contact [[User:Becasita]]
 */
( function _gadgetCardImageUploadPreLoads( window, $, mw, console ) {
	"use strict";

	var LAST_LOG = '~~~~~';

	var config = mw.config.get( [
		'wgNamespaceNumber',
		'wgPageName',
		'wgTitle',
		'wgNamespaceIds',
	] );

	var NS = {
		CARD_GALLERY: config.wgNamespaceIds.card_gallery,
		SET_CARD_GALLERIES: config.wgNamespaceIds.set_card_galleries,
	};

	var urlSearchParameter = '__cardName';

	function getCardName( $noFile ) {
		return $noFile.parents( '.gallerybox' )
			.find( '.gallerytext' )
				.children( 'p' ).first()
					.children( 'br' ).first()
						.next( 'a' ).attr( 'title' )
		;
	}

	function updateUploadLinks() {
		$( '.noFile' ).each( function( i, noFile ) {
			var $noFile = $( noFile );

			var cardName = config.wgNamespaceNumber === NS.CARD_GALLERY
				? config.wgTitle
				: getCardName( $noFile )
			;

			$noFile.attr( 'href', function( i, href ) {
				return [
					href,
					[
						urlSearchParameter,
						window.encodeURIComponent( cardName ),
					].join( '=' ),
				].join( '&' );
			} );
		} );
	}

	function fillUploadForm() {
		var name = new URL( window.location.href ).searchParams.get( urlSearchParameter );

		$( '#wpUploadDescription' ).val( // TODO: pre loads for anime / manga /etc..
			name && '{{OCG-TCG card image\n| name = ' + name + '\n}}'
		);
	}

	if ( Object.values( NS ).includes( config.wgNamespaceNumber ) ) {
		mw.hook( 'ext.gadget.LinkMissingGalleryFilesToUpload' ).add( updateUploadLinks );
	}

	if ( config.wgPageName === 'Special:Upload' ) {
		$( fillUploadForm );
	}

	console.log( '[Gadget] CardImageUploadPreLoads last updated at', LAST_LOG );

} )( window, window.jQuery, window.mediaWiki, window.console );
