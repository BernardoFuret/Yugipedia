/**
 * Create a ToC for set galleries (using [[Module:Card collection/modules/Set gallery]]).
 * @author Becasita
 * @contact [[User:Becasita]]
 * TODO: CSS may be unified with version from Card gallery ToC gadget.
 */
( function _gadgetSetGalleryToC( window, $, mw, console ) {
	"use strict";

	var LAST_LOG = '~~~~~';

	function generateToC( $content ) {
		var $tocPlaceholder = $content.find( '.set-gallery__toc' );

		var $contentSectionHeaders = $content.find( '.mw-headline' );

		if ( $contentSectionHeaders.length >= 3 ) { // TODO: make configurable per user?
			var $tocContainer = $( '<div>', {
				'class': 'set-gallery__toc__container'
			} ).appendTo( $tocPlaceholder );

			var $tocList = $( '<ul>' ).appendTo( $tocContainer );

			$contentSectionHeaders.each( function( index, element ) {
				var $sectionTitle = $( element );

				var sectionTitleId = $sectionTitle.attr( 'id' );

				var sectionTitleHtml = $sectionTitle.html();

				$tocList.append( function() {
					var $currentSectionTitle = $( this )
						.parents( '.set-gallery' )
						.prevAll( ':header' )
						.first()
						.find( '.mw-headline' );

					var currentSectionTitleId = $currentSectionTitle.attr( 'id' );

					return $( '<li>', {
						'class': 'set-gallery__toc__entry',
						html: $( currentSectionTitleId === sectionTitleId ? '<strong>' : '<a>', {
							href: '#' + sectionTitleId,
							html: sectionTitleHtml
						} )
					} );
				} );
			} );
		} else {
			$tocPlaceholder.remove();
		}
	}

	mw.hook( 'wikipage.content' ).add( generateToC );

	console.log( '[Gadget] SetGalleryToC last updated at', LAST_LOG );

} )( window, window.jQuery, window.mediaWiki, window.console );
