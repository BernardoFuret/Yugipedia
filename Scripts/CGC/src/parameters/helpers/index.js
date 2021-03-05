function getRawContentValue( content, parameter ) {
	const regex = new RegExp(
		`^[ \\t]*\\|[ \\t]*${parameter}[ \\t]*=(?:[ \\t]*\\n?(.*?)\\s*)(?=^[ \\t]*(?:\\||}}\\s*$))`,
		'ims',
	);

	return ( regex.exec( content ) || {} )[ 1 ] || '';
}

module.exports = {
	getRawContentValue,
	getSetsData: require( './getSetsData' ),
	getErrataData: require( './getErrataData' ),
};
