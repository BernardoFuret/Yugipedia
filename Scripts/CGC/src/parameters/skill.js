const { languages } = require( '../constants' );

const names = [
	'skill_activation',
	...languages.map( language => `${language.index}_skill_activation` ),
];

const titles = {
	skill_activation: 'English Skill Activation',
	...languages.reduce( ( all, language ) => ( {
		...all,
		[ `${language.index}_skill_activation` ]: `${language.full} Skill Activation`,
	} ), {} ),
};

module.exports = {
	names,
	titles,
	addCommons: true,
};
