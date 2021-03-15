const { languages } = require( '../constants' );

const { removeWikitextMarkup } = require( '../helpers' );

const { getRawContentValue } = require( './helpers' );

const names = [
	'attribute',
	'types',
	'stars',
	'atk',
	'def',
	'link',
	'link_arrows',
	'pendulum_effect',
	'pendulum_scale',
	...languages.map( language => `${language.index}_pendulum_effect` ),
];

const titles = {
	atk: 'ATK',
	def: 'DEF',
	link: 'Link Rating',
	link_arrows: 'Link Arrows',
	pendulum_effect: 'English Pendulum Effect',
	...languages.reduce( ( all, language ) => ( {
		...all,
		[ `${language.index}_pendulum_effect` ]: `${language.full} Pendulum Effect`,
	} ), {} ),
};

const handlers = {
	stars: ( rawValue, { content } ) => (
		getRawContentValue( content, 'rank' )
		||
		getRawContentValue( content, 'level' )
		||
		rawValue
	),
	link: ( rawValue, { content } ) => {
		const linkArrows = getRawContentValue( content, 'link_arrows' );

		return linkArrows && linkArrows.split( /\s*,\s*/ ).length.toString();
	},
	link_arrows: rawValue => rawValue && rawValue.split( /\s*,\s*/ ),
	pendulum_effect: removeWikitextMarkup,
	...languages.reduce( ( all, language ) => ( {
		...all,
		[ `${language.index}_pendulum_effect` ]: removeWikitextMarkup,
		[ `${language.index}_skill_activation` ]: removeWikitextMarkup,
	} ), {} ),
};

module.exports = {
	names,
	handlers,
	titles,
	addCommons: true,
};
