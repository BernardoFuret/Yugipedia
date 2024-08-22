/**
 * Create a ToC for card galleries (using [[Module:Card gallery]]).
 * @author Becasita
 * @contact [[User:Becasita]]
 */
( function _gadgetCardGalleryToC( window, $, mw, console ) {
	"use strict";

	var LAST_LOG = '~~~~~';

	function generateToC( $content ) {
		var $toc = $content.find( '.card-gallery__toc' ).find( 'ul' );

		$content.find( '.mw-headline' ).each( function( index, element ) {
			var $sectionTitle = $( element );

			var sectionTitleId = $sectionTitle.attr( 'id' );

			var sectionTitleHtml = $sectionTitle.html();

			$toc.append( function() {
				var $currentSectionTitle = $( this ).parent().parent().find( ':header .mw-headline' );

				var currentSectionTitleId = $currentSectionTitle.attr( 'id' );

				return $( '<li>', {
					'class': 'card-gallery__toc__entry',
					html: $( currentSectionTitleId === sectionTitleId ? '<strong>' : '<a>', {
						href: '#' + sectionTitleId,
						html: sectionTitleHtml
					} )
				} );
			} );
		} );
	}

	mw.hook( 'wikipage.content' ).add( generateToC );

	console.log( '[Gadget] CardGalleryToC last updated at', LAST_LOG );

} )( window, window.jQuery, window.mediaWiki, window.console );
