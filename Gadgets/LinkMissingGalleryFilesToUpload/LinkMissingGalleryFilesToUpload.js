/**
 * Links missing files on galleries to the Special:Upload page.
 * @author Becasita
 * @contact [[User talk:Becasita]]
 */
( function _gadgetLinkMissingGalleryFilesToUpload( window, $, mw, console ) {
	"use strict";

	var LAST_LOG = '~~~~~';

	function linkEmptyGalleries( $content ) {
		$content.find( '.thumb' ).each( function() {
			var $this = $( this );

			if ( !$this.children().length ) {
				// Is an empty gallery box.
				var missingFileName = $this.text();
				
				$this.text( '' ).append(
					$( '<a>', {
						'class': 'noFile',
						href: '/index.php?title=Special:Upload&wpDestFile=' + missingFileName,
						text: missingFileName
					} )
				);
			}
		} );

		window.requestAnimationFrame( function() {
			mw.hook( 'ext.gadget.LinkMissingGalleryFilesToUpload' ).fire();
		} );
	}

	mw.hook( 'wikipage.content' ).add( linkEmptyGalleries );

	console.log( '[Gadget] LinkMissingGalleryFilesToUpload last updated at', LAST_LOG );

} )( window, window.jQuery, window.mediaWiki, window.console );
