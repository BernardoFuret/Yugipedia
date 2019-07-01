/**
 * Prettifies template transclusions and gallery tags.
 * Original author is Deltaneos.
 * Adapted to gadget by Becasita.
 * @author Deltaneos, Becasita
 * @contact [[User:Becasita]]
 */
( function _gadgetMarkupFormatting( window, $, mw, console ) {
	"use strict";

	var LAST_LOG = '~~~~~';

	/**
	 * By Deltaneos
	 */
	function align( text ) {
		// Get the selected text or all text
		var selected_text = (window.getSelection().toString()) ? window.getSelection().toString() : text;
		var cleaned_text  = '';
		var pos           = 0;
		var max_pos       = 0;
		var diff          = 0;
		var j             = 0;
		var space         = '';

		// Reduce the spacing around the "=" in each parameter to a single space on either side.
		// Put each line in an array
		var lines         = selected_text.replace(/\t/, ' ').replace(/^[ \t]*\|\s*([^\s=]+)\s*/gm, '| $1 ').split('\n');

		// Loop through each line to find the furthest out "=".
		for (var i = 0; i < lines.length; i++)
		{
			pos = (lines[i].indexOf('|') === 0) ? lines[i].indexOf('=') : -1;
			if (pos > max_pos) max_pos = pos;
		}

		// Loop through each line again
		for (i = 0; i < lines.length; i++)
		{
			// Get the number of spaces to add
			pos     = (lines[i].indexOf('|') === 0) ? lines[i].indexOf('=') : -1;
			diff    = max_pos - pos;
			space   = '';
			// Add the spaces
			if (String.prototype.repeat) // ES6; not supported in IE
			{
				space = ' '.repeat(diff);
			}
			else
			{
				space = Array(diff + 1).join(' ');
			}
			// Append the reformatted line into a new string for the reformatted text
			cleaned_text += (lines[i].indexOf('|') === 0) ? lines[i].replace('=', space+'=') : lines[i];
			if (i != lines.length - 1) cleaned_text += '\n'; // add a line break, unless this is the last line
		}

		// Get the text inside each set of gallery tags
		var galleries = cleaned_text.match(/<gallery[^>]*>(\n(.*))*?<\/gallery>/g);
		var gallery_lines;
		var cleaned_gallery_text;
		galleries = galleries ? galleries : [];

		for (i = 0; i < galleries.length; i++)
		{
			// Reset some values lingering from previous iterations
			cleaned_gallery_text = '';
			pos = max_pos = 0;

			// Reduce the spacing around the "|" in each line to a single space.
			// Put each line in an array.
			gallery_lines = galleries[i].replace(/\t/, ' ').replace(/^([^\|]*[^ ])\s*\|\s*/gm, '$1 \| ').split('\n');

			// Loop through each line to find the furthest out "|"
			for (j = 0; j < gallery_lines.length; j++)
			{
				pos = gallery_lines[j].indexOf('|');
				if (pos > max_pos) max_pos = pos;
			}

			// Loop through each line again
			for (j = 0; j < gallery_lines.length; j++)
			{
				// Get the amount of space to add
				pos     = gallery_lines[j].indexOf('|');
				diff    = max_pos - pos;
				space   = '';
				if (String.prototype.repeat) // ES6; not supported in IE
				{
					space = ' '.repeat(diff);
				}
				else
				{
					space = Array(diff + 1).join(' ');
				}

				// Append the reformatted line into a new string for the reformatted text
				cleaned_gallery_text += gallery_lines[j].indexOf('|') ? gallery_lines[j].replace('|', space+'|') : gallery_lines[j];
				if (j != gallery_lines.length - 1) cleaned_gallery_text += '\n'; // add a line break, unless this is the last line
			}

			cleaned_text = cleaned_text.replace(galleries[i], cleaned_gallery_text);
		}

		// Replace the old text with the new text
		return text.replace(selected_text, cleaned_text);
	}

	function doAlign( $textBox ) {
		$textBox.val( function( index, text ) {
			return align( text );
		} );
	}

	function init() {
		var $editBox = $( '#wpTextbox1' );

		if ( !$editBox.length ) {
			window.MARKUP_FORMATTING_ONKEYDOWN_SET = function() {
				// Nothing, just to prevent errors.
			};

			return;
		}

		var $button = $( '<span>', {
			id: 'ca-alignText',
			'class': 'tab',
			html: $( '<a>', {
				href: '#',
				title: 'Align text.',
				text: 'Align text',
			} ),
			click: function( e ) {
				e.preventDefault();

				doAlign( $editBox );
			},
		} );

		if ( mw.user.options.get( 'usebetatoolbar' ) == 1 ) {
			// Enhanced edit toolbar:
			$( '#wikiEditor-ui-toolbar' )
				.find( '.tabs' )
					.append( $button )
			;
		} else {
			// Classic toolbar:
			$( '#toolbar' ).append(
				$( '<div>' )
					.addClass( 'mw-toolbar-editbutton' )
					.addClass( 'mw-toolbar-editbutton--custom' )
					.append( $button )
			);
		}

		/**
		 * To add a keyboard shortcut, add the following to Special:MyPage/common.js
		 * ```
		 *	mw.loader.using( 'ext.gadget.MarkupFormatting' ).then( function() {
		 *		window.MARKUP_FORMATTING_ONKEYDOWN_SET( function( e ) {
		 *			return // predicate.
		 *		} );
		 *	} );
		 * ```
		 * @param {function} keysPredicate Callback that receives
		 * an onKeydown event and returns a boolean indicating
		 * when the keydown listeners should be triggered.
		 */
		window.MARKUP_FORMATTING_ONKEYDOWN_SET = function( keysPredicate ) {
			$editBox.keydown( function( e ) {
				if ( keysPredicate( e ) ) {
					doAlign( $editBox );
				}
			} );
		};
	}

	mw.hook( 'wikipage.editform' ).add( function() {
		mw.loader.using( 'mediawiki.toolbar' ).then( init );
	} );

	console.log( '[Gadget] MarkupFormatting last updated at', LAST_LOG );

} )( window, window.jQuery, window.mediaWiki, window.console );

/**
 * TODO: check...
 * To use, add
 * ```
 * 	mw.loader.using( 'ext.gadget.MarkupFormatting' ).then( function( loadedModules ) {
 * 		loadedModules( 'ext.gadget.MarkupFormatting' ).setOnKeydown( function( e ) {
 * 			// Predicate.
 * 		} );
 *  } );
 * ```
 */