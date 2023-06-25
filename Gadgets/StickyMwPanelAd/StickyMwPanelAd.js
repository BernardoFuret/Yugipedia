/**
 * To make the MW Panel ad sticky. Using CSS only won't work without
 * a major rearrangement of the elements due to the page layout.
 */
(function _gadgetStickyMwPanelAd() {
	"use strict";

	var LAST_LOG = '~~~~~';

	var mwPanelAdContainerId = '#mw-panel__ad-container';

	var topOffset = 5;

	var mwPanelHeightAboveAds =
		$('#p-logo').outerHeight(true) +
		$('.portal')
			.toArray()
			.reduce(function (acc, el) {
				return acc + $(el).outerHeight(true);
			}, 0);

	var heightToStickMwPanelAds = mwPanelHeightAboveAds - topOffset;

	var $mwPanelAdsContainer = $(mwPanelAdContainerId).css({ top: topOffset + 'px' });

	var $window = $(window);

	$window.on('scroll', function (e) {
		var isPositionFixed = $mwPanelAdsContainer.css('position') === 'fixed';

		var windowScrollTop = $window.scrollTop();

		if (windowScrollTop > heightToStickMwPanelAds && !isPositionFixed) {
			$mwPanelAdsContainer.css({ position: 'fixed' });
		}

		if (windowScrollTop < heightToStickMwPanelAds && isPositionFixed) {
			$mwPanelAdsContainer.css({ position: 'static' });
		}
	});

	console.log('[Gadget] StickyMwPanelAd last updated at', LAST_LOG);
})();
