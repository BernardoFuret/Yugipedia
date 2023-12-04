/**
 * (browser)
 */
(async (window, $, mw, console) => {
	'use strict';

	const __errors = [];

	let processedPages = 0;

	const SET_CARD_GALLERY_NS_NUMBER = 3024;

	const ACCEPTED_NS_NUMBERS = [SET_CARD_GALLERY_NS_NUMBER];

	const api = await mw.loader.using('mediawiki.api').then(() => new mw.Api());

	class DataError extends Error {
		#data;

		constructor(message, data, options) {
			super(message, options);

			this.#data = data;
		}

		get data() {
			return this.#data;
		}
	}

	const sleep = (ms) => new Promise((r) => window.setTimeout(r, ms));

	const quote = (pagename) => `"${pagename.replace('"', '\\"')}"`;

	const link = (pagename, label = pagename) => {
		return $('<a>', {
			target: '_blank',
			href: `https://yugipedia.com/wiki/${encodeURIComponent(pagename)}`,
			text: label,
		}).prop('outerHTML');
	};

	const linkDiff = (diffId, label = `(${diffId})`) => {
		return $('<a>', {
			target: '_blank',
			href: `https://yugipedia.com/index.php?diff=${diffId}`,
			text: label,
		}).prop('outerHTML');
	};

	const getCategoryMembers = (cmcontinue) => {
		return api.get({
			action: 'query',
			list: 'categorymembers',
			cmtitle: 'Category:Set gallery/list needing updated format',
			cmlimit: 'max',
			cmcontinue: cmcontinue,
		});
	};

	const getContent = (pagename) => {
		return api
			.get({
				action: 'query',
				redirects: false,
				prop: 'revisions',
				rvprop: 'content',
				format: 'json',
				formatversion: 2,
				titles: pagename,
			})
			.then((data) => ({
				content: data.query.pages[0].revisions[0].content,
				data,
			}))

			.catch((error) => ({ error }));
	};

	const convertHeader = (oldContent) => {
		// Header pointing to a different page: https://yugipedia.com/wiki/Set_Card_Galleries:Structure_Deck:_Marik_(TCG-EN-1E)

		const [wholeMatch, pageLinkMatch] =
			/<div.*120.*?'{3,5}\[\[(.*?)\]\]'{3,5}.*$/m.exec(oldContent) || [];

		if (!wholeMatch) {
			throw new DataError('Could not find header', { oldContent });
		}

		const hasLabel = /\|/.test(pageLinkMatch);

		const setPagename = hasLabel ? pageLinkMatch.split(/\|/)[0] : '';

		return `{{Set page header${setPagename ? `|set=${setPagename}` : ''}}}`;
	};

	const parseFilename = (filename, lacksEdition) => {
		// DododoWarrior-ZTIN-DE-SR-1E.png
		// ChaosEmperorDragonEnvoyoftheEnd-BPT-JP-UtR.png
		// MonsterReborn-YGLD-IT-C-1E-B.png
		// CyberStein-SJC-EN-UR-LE-GC.jpg

		const [filenameWithoutExtension, extension] = filename.split('.');

		const fileParts = filenameWithoutExtension.split('-');

		const rarity = fileParts.at(3);

		if (!rarity) {
			throw new DataError('Could not find rarity on filename', {
				filename,
				lacksEdition,
			});
		}

		const alt = fileParts.at(lacksEdition ? 4 : 5) || '';

		return { rarity, alt, extension };
	};

	const parseRest = (rest = '') => {
		if (!rest) {
			return {
				description: '',
				printedName: '',
			};
		}

		const { descriptionParts, printedName } = rest
			.split(/<br *\/?>/g)
			.filter((part) => !/{{ *card name/i.test(part))
			.reduce(
				(acc, part) => {
					const oldNameDescriptionRegex = /\(as "(.*?)"/;
					if (oldNameDescriptionRegex.test(part)) {
						if (acc.printedName) {
							throw new DataError(
								'Found multiple old printed names descriptions',
								{
									previousFinding: acc.printedName,
									part,
									rest,
								},
							);
						}

						return {
							...acc,
							printedName: oldNameDescriptionRegex.exec(part)[1],
						};
					}

					return {
						...acc,
						descriptionParts: [...acc.descriptionParts, part],
					};
				},
				{ printedName: '', descriptionParts: [] },
			);

		return {
			description: descriptionParts.join('<br />'),
			printedName,
		};
	};

	const buildGalleryEntry = ({
		cardNumber,
		pagename,
		rarity,
		alt,
		extension,
		printedName,
		description,
	}) => {
		const entry = [cardNumber, pagename, rarity, ...(alt ? [alt] : [])].join(
			'; ',
		);

		const options = [
			...(extension !== 'png' ? [`extension::${extension}`] : []),
			...(printedName ? [`printed-name::${printedName}`] : []),
			...(description ? [`description::${description}`] : []),
		].join('; ');

		return [entry, ...(options ? [options] : [])].join(' // ');
	};

	const printGallerySection = (title, galleryEntries) => {
		return [
			...(title ? [`== ${title} ==`] : []),
			`{{Set gallery|`,
			...galleryEntries,
			'}}',
		].join('\n');
	};

	const convertGallerySection = (oldGallerySection, context) => {
		const { title, galleryEntries } = oldGallerySection.split('\n').reduce(
			(acc, line, lineIndex) => {
				const entryMatchRegex =
					// /^(.*?)\|.*?\[\[(.*?)\].*?\[\[(.*?)\].*?\[\[(.*?(\|(.*?))?)(\|.*?)?\].*$/m;
					// /^ *(?<filename>\S.*?) *\|.*?\[\[(?<cardNumber>.+?)\].*?\[\[(?<rarity>.+?)\].*?\[\[(?:(?<pagename>.+?)(?:\|(?<cardName>.+?))?)\].*$/m;
					// /^ *(?<filename>\S.*?) *\|.*?\[\[(?<cardNumber>.+?)\].*?\[\[(?<rarity>.+?)\].*?(?:\[\[(?:(?<pagename>.+?)(?:\|(?<cardName>.+?))?)\]|{{Gallery card names\|(?<pagename2>.+?)\|\w\w}}).*$/mi
					/^ *(?<filename>\S.*?) *\|.*?\[\[(?<cardNumber>.+?)\].*?\[\[(?<rarity>.+?)\].*?(?:\[\[(?:(?<pagename>.+?)(?:\|(?<cardName>.+?))?)\]\]|{{Gallery card names\|(?<pagename2>.+?)\|\w\w}})(?:<br *\/?>(?<rest>.*))?$/im;

				/*
					! Yuya Deck
					|-
					|
					<gallery widths="175px">
					  | [[YS15-SPY00]] ([[UR]])<br />[[Odd-Eyes Saber Dragon]]<br />{{Card name|Odd-Eyes Saber Dragon|es}}
					   OddEyesSaberDragon-YS15-SP-UR-1E.png  | [[YS15-SPY00]] ([[UR]])<br />[[Odd-Eyes Saber Dragon]]<br />{{Card name|Odd-Eyes Saber Dragon|es}}<br />{{Card name|Odd-Eyes Saber Dragon|es}}
					AlexandriteDragon-YS15-SP-C-1E.png    | [[YS15-SPY01]] ([[C]])<br />[[Alexandrite Dragon]]<br />{{Card name|Alexandrite Dragon|es}}
					MysticalElf-YS15-SP-C-1E.png          | [[YS15-SPY02]] ([[C]])<br />[[Mystical Elf|Alt name]]<br />{{Card name|Mystical Elf|es}}
					AvengingKnightParshath-TDGS-FR-SR-LE.png           | [[TDGS-FRSP1]] ([[SR]])<br />[[Avenging Knight Parshath]]<br />{{Card name|Avenging Knight Parshath|fr}}<br />''[[The Duelist Genesis]]''
					ElementalHERONeos-DP03-IT-C-1E.jpg              | [[DP03-IT001]] ([[C]])<br />{{Gallery card names|Elemental HERO Neos|it}}<br />(as "Neos Eroe Elementale")
					</gallery>
				 */

				const titleMatchRegex = /^ *! *(\S.*?) *$/m;

				switch (true) {
					case entryMatchRegex.test(line): {
						// Examples to be careful with:
						// Previous name note (with {{Gallery card names}}:
						//   https://yugipedia.com/wiki/Set_Card_Galleries:Duelist_Pack:_Jaden_Yuki_2_(TCG-IT-1E)
						// Description/Extra caption:
						//   https://yugipedia.com/wiki/Set_Card_Galleries:Sneak_Peek_Participation_Cards:_Series_4_(TCG-FR-LE)

						const {
							groups: {
								filename,
								cardNumber,
								rarity,
								pagename,
								cardName,
								pagename2,
								rest,
							},
						} = entryMatchRegex.exec(line);

						const {
							rarity: fileRarity,
							alt,
							extension,
						} = parseFilename(filename, context.lacksEdition);

						const { description, printedName } = parseRest(rest);

						const isGiantCard = /giant card/i.test(rarity);

						const galleryEntry = buildGalleryEntry({
							cardNumber,
							pagename: pagename || pagename2,
							rarity: isGiantCard ? fileRarity : rarity,
							alt,
							extension,
							printedName,
							description: description || (isGiantCard ? '[[Giant Card]]' : ''),
						});

						return {
							...acc,
							galleryEntries: [...acc.galleryEntries, galleryEntry],
						};
					}
					case titleMatchRegex.test(line): {
						if (acc.title) {
							throw new DataError(
								'Unexpectedly found a second gallery header',
								{ oldGallerySection, line },
							);
						}

						const title = titleMatchRegex.exec(line)[1];

						if (!title) {
							throw new DataError('Failed to grab expected gallery header', {
								oldGallerySection,
								line,
							});
						}

						return {
							...acc,
							title,
						};
					}
				}

				return acc;
			},
			{ title: '', galleryEntries: [] },
		);

		if (!galleryEntries.length) {
			throw new DataError('Emtpy gallery section', {
				title,
				galleryEntries,
				oldGallerySection,
				context,
			});
		}

		return printGallerySection(title, galleryEntries);
	};

	const printAllGallerySections = (newGallerySections) => {
		return newGallerySections.join('\n\n');
	};

	const convertGalleries = (oldContent, pagename) => {
		// Multi sections: https://yugipedia.com/wiki/Set_Card_Galleries:2-Player_Starter_Deck:_Yuya_%26_Declan_(TCG-SP-1E)

		const lacksEdition = !pagename.match(/\((.*?)\)/)[1].split('-')[2];

		const context = { pagename, lacksEdition };

		const [oldGalleriesMatch] = /^{\|.*?^\|}$/gms.exec(oldContent) || [];

		if (!oldGalleriesMatch) {
			throw new DataError('Could not find galleries', { oldContent });
		}

		const gallerySectionsRegex = /\|-(.*?<\/gallery>)/gms;

		const gallerySectionsMatch =
			gallerySectionsRegex.test(oldGalleriesMatch) || [];

		if (!gallerySectionsMatch) {
			throw new DataError('Could not find gallery sections', { oldContent });
		}

		gallerySectionsRegex.lastIndex = 0;

		const newGallerySections = [];

		let regexMatch;

		while (
			(regexMatch = gallerySectionsRegex.exec(oldGalleriesMatch)) != null
		) {
			const oldGallerySection = regexMatch[1];

			newGallerySections.push(
				convertGallerySection(oldGallerySection, context),
			);
		}

		return printAllGallerySections(newGallerySections);
	};

	const printNewContent = (header, galleries) => {
		return [header, galleries].join('\n\n');
	};

	const convertContent = (oldContent, pagename) => {
		// https://yugipedia.com/wiki/User:Becasita/SubPages/Regex#Galleries
		try {
			const header = convertHeader(oldContent, pagename);

			const galleries = convertGalleries(oldContent, pagename);

			const newContent = printNewContent(header, galleries);
			return { newContent };
		} catch (error) {
			return { error };
		}
	};

	const edit = (pagename, content) => {
		// TODO
		// return Promise.resolve({ data: { edit: { newrevid: 1 } } });
		return api
			.postWithToken('csrf', {
				action: 'edit',
				title: pagename,
				nocreate: true,
				text: content,
				summary: 'Convert to {{[[Template:Set gallery|Set gallery]]}}.',
				bot: true,
			})
			.then((data) => ({ data }))
			.catch((error) => ({ error }));
	};

	window.DEBUG = true;

	const START_TIME = window.performance.now();

	let continueToken = window.START_TOKEN;

	try {
		outerLoop: do {
			const cmResponse = await getCategoryMembers(continueToken);

			// Update the continue token:
			continueToken = cmResponse.continue?.cmcontinue;

			console.log('Next batch will start on:', continueToken);

			const { categorymembers } = cmResponse.query;

			for (const categoryMember of categorymembers) {
				if (window.STOP_SCRIPT) {
					console.log('Halt!', `(when starting ${link(categoryMember.title)})`);

					break outerLoop;
				}

				processedPages += 1;

				console.log(
					`[${processedPages}]`,
					`[${new Date().toISOString().replace('T', ', ')}]`,
					`NS:${categoryMember.ns}`,
					`ID: ${categoryMember.pageid}`,
					link(categoryMember.title),
				);

				if (!ACCEPTED_NS_NUMBERS.includes(categoryMember.ns)) {
					console.warn(
						'\tWarning: Page namespace',
						categoryMember.ns,
						'not belonging to accepted namespaces:',
						ACCEPTED_NS_NUMBERS,
					);

					__errors.push({
						data: { categoryMember },
						type: '01-invalid-ns',
					});

					continue;
				}

				try {
					const { error: getContentError, content } = await getContent(
						categoryMember.title,
					);

					if (getContentError) {
						console.warn(
							'\tWarning: Error getting content for page',
							link(categoryMember.title),
							getContentError?.message || getContentError,
						);

						__errors.push({
							data: { categoryMember, getContentError },
							type: '02-get-content-error',
						});

						continue;
					}

					const { error: convertContentError, newContent } = convertContent(
						content,
						categoryMember.title,
					);

					if (convertContentError) {
						console.warn(
							'\tWarning: Error converting content for page',
							link(categoryMember.title),
							convertContentError?.message || convertContentError,
						);

						__errors.push({
							data: { categoryMember, convertContentError },
							type: '03-convert-content-error',
						});

						continue;
					}

					const { error: editError, data: editData } = await edit(
						categoryMember.title,
						newContent,
					);

					if (editError) {
						console.warn(
							'\tWarning: Error editing page',
							link(categoryMember.title),
							editError?.message || editError,
						);

						__errors.push({
							data: { categoryMember, error: editError },
							type: '04-edit-error',
						});

						continue;
					}

					console.log(
						'\tUpdated',
						link(categoryMember.title),
						linkDiff(editData.edit.newrevid),
					);
				} finally {
					await sleep(window.SCRIPT_LATENCY || 1000);
				}
			}
		} while (continueToken);
	} catch (err) {
		console.error('Error: Something wrong happened:', err.message, err);

		__errors.push({ data: err, type: 'XX-unknown' });
	}

	const END_TIME = window.performance.now();

	const __errorsVarName = `__errors$${Date.now().toString(36)}`;

	window[__errorsVarName] = __errors;

	window.DEBUG = true;

	console.log(window.STOP_SCRIPT ? 'Stopped!' : 'All done!');

	console.log('Took', END_TIME - START_TIME);

	console.log('Processed', processedPages, 'pages');

	window.console.log(__errorsVarName, __errors);
})(
	window,
	window.jQuery,
	window.mediaWiki,
	((window, $) => {
		'use strict';

		const win = window.open();

		const doWrite = (args, color = 'black') =>
			window.DEBUG &&
			win.document.write(
				$('<pre>', {
					html: args
						.map((arg) =>
							typeof arg !== 'string' ? JSON.stringify(arg, null, '  ') : arg,
						)
						.join(' '),
				})
					.css('color', color)
					.prop('outerHTML'),
			);

		return {
			log: (...args) => doWrite(args),

			warn: (...args) => doWrite(args, 'darkorange'),

			error: (...args) => doWrite(args, 'red'),
		};
	})(window, window.jQuery),
).catch(window.console.error);
