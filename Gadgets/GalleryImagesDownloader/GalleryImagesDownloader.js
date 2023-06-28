/**
 * When on a gallery page (Card Galleries, Set Card Galleries), it enables
 * a button that downloads all images in the gallery.
 */
(function _gadgetGalleryImagesDownloader() {
	'use strict';

	var LAST_LOG = '~~~~~';

	var nsNumber = mw.config.get('wgNamespaceNumber');

	var skin = mw.config.get('skin');

	var fileRedirectPath = 'https://yugipedia.com/wiki/Special:Redirect/file/';

	var disabledStyles = {
		opacity: 0.5,
		'pointer-events': 'none'
	};

	var $body = $('body');

	var $button = $('<li>', {
		id: 'ca-download-gallery-images',
		class: 'collapsible',
		html: $('<span>', {
			html: $('<a>', {
				href: '#',
				title: 'Download gallery images.',
				text: 'Download gallery images'
			})
		})
	});

	function log() {
		var argumentsArray = Array.prototype.slice.call(arguments);

		var decoratedArgumentsArray = ['[Gadget]', '[GalleryImagesDownloader]', '-'].concat(
			argumentsArray
		);

		console.log.apply(null, decoratedArgumentsArray);
	}

	function sleep(ms) {
		return new Promise((resolve) => setTimeout(resolve, ms));
	}

	function downloadImage(imageUrl, fileName) {
		return fetch(imageUrl)
			.then((response) => response.blob())
			.then((blob) => {
				var blobURL = URL.createObjectURL(blob);

				var $link = $('<a>', {
					href: blobURL,
					download: fileName,
					style: { display: 'none' }
				});

				$body.append($link);

				$link[0].click();

				$link.remove();
			});
	}

	function donwloadImages() {
		return $('.gallerybox')
			.find('a.image')
			.toArray()
			.reduce((chain, imageElement, index) => {
				return chain
					.then(() => {
						var imageName = $(imageElement).attr('href').split(':')[1];

						var imageUrl = fileRedirectPath + encodeURIComponent(imageName);

						var fileName = [(index + 1).toString().padStart(3, '0'), imageName].join(' - ');

						return downloadImage(imageUrl, fileName);
					})
					.then(() => sleep(1000));
			}, Promise.resolve());
	}

	function handleClick(e) {
		event.preventDefault();

		log('Started fetching images.');

		$button.off('click').css(disabledStyles);

		donwloadImages().then(() => {
			$button.click(handleClick).removeAttr('style');

			log('Done fetching images.');
		});
	}

	function init() {
		if (nsNumber === 3004 || nsNumber === 3024) {
			$button.click(handleClick);

			if (skin === 'monobook') {
				$('#p-cactions').find('.pBody').find('ul').append($button);
			} else {
				$('#p-cactions').removeClass('emptyPortlet').find('.menu').find('ul').append($button);
			}
		}
	}

	$(init);

	console.log('[Gadget] GalleryImagesDownloader last updated at', LAST_LOG);
})();
