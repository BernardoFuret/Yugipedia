/**
 * Automatically fills Special:Upload form for card images.
 * (Achieved by updating the links for missing files on card galleries.)
 * @author Becasita
 * @contact [[User:Becasita]]
 */
// TODO: pre loads for anime / manga / etc..
( function _gadgetCardImageUploadPreLoads( window, $, mw, console ) {
	"use strict";

	var LAST_LOG = '~~~~~';

	var config = mw.config.get( [
		'wgNamespaceNumber',
		'wgTitle',
		'wgNamespaceIds',
	] );

	var NS = {
		CARD_GALLERY: config.wgNamespaceIds.card_gallery,
		SET_CARD_GALLERIES: config.wgNamespaceIds.set_card_galleries,
	};

	function getCardName( $noFile ) {
		return $noFile.parents( '.gallerybox' )
			.find( '.gallerytext' )
				.children( 'p' ).first()
					.children( 'br' ).first()
						.next( 'a' ).attr( 'title' )
		;
	}

	function updateUploadLinks( $content ) {
		$content.find( '.noFile' ).each( function() {
			var $thisNoFile = $( this );

			var cardName = config.wgNamespaceNumber === NS.CARD_GALLERY
				? config.wgTitle
				: getCardName( $thisNoFile )
			;

			if ( cardName ) {
				$thisNoFile.attr( 'href', function( i, href ) {
					return [
						href,
						[
							'wpUploadDescription', // <pre>
							window.encodeURIComponent( '{{OCG-TCG card image\n| name = ' + cardName + '\n}}' ),
						].join( '=' ), // </pre>
					].join( '&' );
				} );
			}
		} );
	}

	if ( Object.values( NS ).includes( config.wgNamespaceNumber ) ) {
		mw.hook( 'ext.gadget.LinkMissingGalleryFilesToUpload' ).add( updateUploadLinks );
	}

	console.log( '[Gadget] CardImageUploadPreLoads last updated at', LAST_LOG );

} )( window, window.jQuery, window.mediaWiki, window.console );
