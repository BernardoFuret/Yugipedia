const { regions, languages } = require( '../constants' );

const { removeWikitextMarkup } = require( '../helpers' );

const { getSetsData, getErrataData } = require( './helpers' );

const names = [
	'name',
	'password',
	'lore',
	...languages.flatMap( language => [
		`${language.index}_name`,
		`${language.index}_lore`,
	] ),
	...regions.map( region => `${region.index.toLowerCase()}_sets` ),
	'errata',
];

const titles = {
	name: 'English Name',
	lore: 'English Lore',
	...languages.reduce( ( all, language ) => ( {
		...all,
		[ `${language.index}_name` ]: `${language.full} Name`,
		[ `${language.index}_lore` ]: `${language.full} Lore`,
	} ), {} ),
	...regions.reduce( ( all, region ) => ( {
		...all,
		[ `${region.index.toLowerCase()}_sets` ]: `${region.full} Sets`,
	} ), {} ),
};

const handlers = {
	name: ( rawValue, { title } ) => ( rawValue || title ),
	lore: removeWikitextMarkup,
	...languages.reduce( ( all, language ) => ( {
		...all,
		[ `${language.index}_lore` ]: removeWikitextMarkup,
	} ), {} ),
	...regions.reduce( ( all, region ) => ( {
		...all,
		[ `${region.index.toLowerCase()}_sets` ]: getSetsData( region ),
	} ), {} ),
	errata: async ( rawValue, { title } ) => ( {
		page: encodeURI( `https://yugipedia.com/wiki/Card Errata:${title}` ),
		data: await Promise.all( [ { index: 'en', full: 'English' }, ...languages ].map( async language => ( {
			language: language.full,
			data: await getErrataData( language, title ),
		} ) ) ).then( data => data.filter( d => d.data && Object.keys( d.data ).length ) ),
	} ),
};

module.exports = {
	names,
	handlers,
	titles,
};
