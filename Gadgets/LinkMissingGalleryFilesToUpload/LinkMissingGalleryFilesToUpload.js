/**
 * Links missing files on galleries to the Special:Upload page.
 * @author Becasita
 * @contact [[User talk:Becasita]]
 */
( function _gadgetLinkMissingGalleryFilesToUpload( window, $, mw, console ) {
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

	var acceptedNamespacesForTemplatePreload = [ NS.CARD_GALLERY, NS.SET_CARD_GALLERIES ];

	function getCardName( $thumb ) {
		return $thumb.siblings( '.gallerytext' )
			.children( 'p' ).first()
				.children( 'br' ).first()
					.next( 'a' ).attr( 'title' );
	}

	function getTemplatePreload( $thumb ) {
		if ( !acceptedNamespacesForTemplatePreload.includes( config.wgNamespaceNumber ) ) {
			return '';
		}

		var cardName = config.wgNamespaceNumber === NS.CARD_GALLERY
			? config.wgTitle
			: getCardName( $thumb );

		// <pre>
		return '{{OCG-TCG card image\n| name = ' + cardName + '\n}}';
		// </pre>
	}

	function linkEmptyGalleries( $content ) {
		$content.find( '.thumb' ).each( function() {
			var $thisThumb = $( this );

			if ( !$thisThumb.children().length ) {
				var missingFileName = $thisThumb.text();

				var queryParams = new URLSearchParams( {
					title: 'Special:Upload',
					wpDestFile: missingFileName,
					wpUploadDescription: getTemplatePreload( $thisThumb ),
				} );

				var $uploadLink = $( '<a>', {
					'class': 'noFile',
					href: '/index.php?' + queryParams.toString(),
					text: missingFileName,
				} );

				$thisThumb.text( '' ).append( $uploadLink );
			}
		} );

		mw.hook( 'ext.gadget.LinkMissingGalleryFilesToUpload' ).fire( $content );
	}

	mw.hook( 'wikipage.content' ).add( linkEmptyGalleries );

	console.log( '[Gadget] LinkMissingGalleryFilesToUpload last updated at', LAST_LOG );

} )( window, window.jQuery, window.mediaWiki, window.console );
