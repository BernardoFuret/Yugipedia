(function _gadgetFuseAds() {
	"use strict";

	var LAST_LOG = '~~~~~';

	$(function () {
		/**
		 * To make the MW Panel ad sticky.
		 * Set the height of the panel to fill the total height of the document.
		 * The rest is handled via CSS.
		 * Deprecates [[MediaWiki:Gadget-StickyMwPanelAd.js]]
		 */
		document.getElementById('mw-panel').height = document.documentElement.scrollHeight;
	});

	console.log('[Gadget] FuseAds last updated at', LAST_LOG);
})();
