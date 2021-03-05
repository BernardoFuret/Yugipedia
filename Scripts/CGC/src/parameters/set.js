const { regions, languages, editions } = require( '../constants' );

const { getRawContentValue } = require( './helpers' );

const names = [
	'en_name',
	...languages.map( language => `${language.index}_name` ),
	...regions.map( region => `${region.index.toLowerCase()}_release_date` ),
	...editions.map( edition => `${edition.abbr.toLowerCase()}_galleries` ),
];

const handlers = {
	...regions.reduce( ( all, region ) => ( {
		...all,
		[ `${region.index.toLowerCase()}_release_date` ]: rawValue => rawValue && new Date( rawValue ),
	} ), {} ),
	...[ 'fr', 'de', 'it', 'sp' ].reduce( ( all, rIndex ) => ( {
		...all,
		[ `${rIndex}_release_date` ]: ( rawValue, { content } ) => {
			const date = rawValue || getRawContentValue( content, 'fr/de/it/sp_release_date' );

			return date && new Date( date );
		},
	} ), {} ),
	...editions.reduce( ( all, edition ) => ( {
		...all,
		[ `${edition.abbr.toLowerCase()}_galleries` ]: rawValue => (
			rawValue ? rawValue.split( /\s*,\s*/ ) : []
		),
	} ), {} ),
};

module.exports = {
	names,
	handlers,
};
