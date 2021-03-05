// TODO: name, lore, pendulum_effect and skill_activation need to be an array of the errata

const groups = [
	'misc',

	'monster',
	'spell',
	'trap',
	'skill',

	'set',
];

function toTitle( name ) {
	return name
		.replace( /_/g, ' ' )
		.replace( /(^| )(\w)/g, m => m.toUpperCase() )
	;
}

function defaultHandler( rawValue ) {
	return rawValue;
}

function bind( { names, handlers = {}, titles = {} } ) {
	return names.reduce( ( all, p ) => ( {
		...all,
		[ p ]: {
			// name: p,
			title: titles[ p ] || toTitle( p ),
			handler: handlers[ p ] || defaultHandler,
		},
	} ), {} );
}

const boundCommons = bind( require( './common' ) );

module.exports = groups.reduce( ( all, group ) => {
	const definition = require( `./${group}` );

	return {
		...all,
		[ group ]: {
			...( definition.addCommons && boundCommons ),
			...bind( definition ),
		},
	};
}, {} );
