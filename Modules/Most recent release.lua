local DATA = require( 'Module:Data' );

local REGIONS = DATA( 'region' );

local MONTHS = {
	january   = 1,
	february  = 2,
	march     = 3,
	april     = 4,
	may       = 5,
	june      = 6,
	july      = 7,
	august    = 8,
	september = 9,
	october   = 10,
	november  = 11,
	december  = 12,
};

local CACHE = {
	medium = {};
};

local mwHtmlCreate = mw.html.create;

local function ask( query )
	query = query or {};

	if not query.mainlabel then
		query.mainlabel = '-';
	end

	local ask = mw.smw.ask( query );

	return ask and ask[ 1 ] or {};
end

local function parseDate( date )
	local day, month, year = date:match( '(%d+)%s*(%a+)%s*(%d+)' );

	if not day then
		month, year = date:match( '(%a+)%s*(%d+)' );
	end

	if not month then
		year = date:match( '(%d+)' );
	end

	return {
		day   = tonumber( day ) or 0,
		month = MONTHS[ (month or ''):lower() ] or 0,
		year  = tonumber( year ),
	};
end

--[[Doc
@description Less than 0 if date1 < date2
]]
local function compareDates( date1, date2 )
	date1 = parseDate( date1 );
	date2 = parseDate( date2 );

	if date1.year < date2.year then return -1 end
	if date1.year > date2.year then return  1 end

	if date1.month < date2.month then return -1 end
	if date1.month > date2.month then return  1 end

	if date1.day < date2.day then return -1 end
	if date1.day > date2.day then return  1 end

	return 0;
end

local function getReleaseDates( set )
	local res = {};

	for _, region in pairs( REGIONS ) do
		local prop = ('%s release date'):format( region.full );

		local dateInfo = ask{
			('[[%s]]'):format( set ),
			table.concat{ '?', prop },
		};

		-- TODO: remove when the sets store the Sneak Peek dates separately.
		local date = type( dateInfo[ prop ] ) == type( {} )
			and dateInfo[ prop ][ 1 ]
			or dateInfo[ prop ]
		;
		res[ region.full ] = date;
	end

	return res;
end

local function getSets( name )
	local res = {};

	local setInfo = ask{
		('[[%s]]'):format( name.page ),
		'?Set information (JSON)',
	};

	local setInfoJSON = type( setInfo[ 'Set information (JSON)' ] ) == type( {} )
		and setInfo[ 'Set information (JSON)' ]
		or { setInfo[ 'Set information (JSON)' ] }
	;

	for index, value in ipairs( setInfoJSON ) do
		for set in value:gmatch( '"name": "(.-)"' ) do
			if not res[ set ] then
				res[ set ] = getReleaseDates( set );
			end
		end
	end

	return res;
end

local function getMostRecentReleases( name )
	local sets = getSets( name );

	local newest = {};

	for set, regions in pairs( sets ) do
		for region, date in pairs( regions ) do
			if not newest[ region ] or compareDates( newest[ region ].date, date ) < 0 then
				newest[ region ] = {
					date = date,
					set = set,
				}
			end

			CACHE.medium[ region ] = CACHE.medium[ region ] or DATA.getMedium( region ).abbr;
			local medium = CACHE.medium[ region ];
			if not newest[ medium ] or compareDates( newest[ medium ].date, date ) < 0 then
				newest[ medium ] = {
					date = date,
					set = set,
				}
			end
		end
	end

	return newest;
end

local function makeNameCell( name )
	return tostring(
		mwHtmlCreate( 'td' )
			:wikitext( ('"[[%s|%s]]"'):format( name.page, name.label ) )
		:done()
	);
end

local function makeDataCell( data )
	return tostring(
		mwHtmlCreate( 'td' )
			:wikitext( data and ("%s<br />(''[[%s]]'')"):format( data.date, data.set ) )
		:done()
	);
end

local function makeRow( name, mostRecentDates )
	local tr = mwHtmlCreate( 'tr' )
		:node( makeNameCell( name ) )
		:node( makeDataCell( mostRecentDates[ 'TCG' ] ) )
		:node( makeDataCell( mostRecentDates[ 'OCG' ] ) )
	;

	-- for _, region in pairs( REGIONS ) do
	-- 	local td = makeCell( mostRecentDates[ region.full ] );

	-- 	tr:node( td );
	-- end

	return tostring( tr:done() );
end

local function getName( name )
	local nameInfo = ask{
		('[[%s]]'):format( (name or ''):gsub( '#', '' ) ),
		'?Page name',
		'?English name',
	};

	return {
		page  = nameInfo[ 'Page name' ],
		label = nameInfo[ 'English name' ] or nameInfo[ 'Page name' ],
	};
end

local function process( name )
	name = getName( name );
	return name.page and makeRow( name, getMostRecentReleases( name ) )
end

local function processAll( data )
	local t = mwHtmlCreate( 'table' )
		:addClass( 'wikitable' )
		:addClass( 'sortable' )
		:addClass( 'most-recent-release-dates' )
		:tag( 'tr' )
			:tag( 'th' ):wikitext( 'Name' ):done()
			:tag( 'th' ):wikitext( "''TCG''" ):done()
			:tag( 'th' ):wikitext( "''OCG''" ):done()
		:done()
	;

	for _, result in ipairs( data ) do
		t:node( process( result[ 'Page name' ] ) );
	end

	return tostring( t:done() );
end

local function exec( limit, offset )
	if not mw.smw then
		return 'SMW is down...'
	end

	query = query or {
		'<q>[[Category:OCG cards]] OR [[Category:TCG cards]]</q>',
		'?Page name',
		'offset=' .. ( offset or 0 ),
		'limit=' .. ( limit or 5 ),
		'mainlabel=-'
	};

	local data = mw.smw.ask( query );

	return processAll( data );
end

return setmetatable(
	{
		main = function( frame )
			local parentArgs  = frame:getParent().args;
			local currentArgs = frame.args;

			local limit  = tonumber( parentArgs[ 1 ] )
				or tonumber( parentArgs[ 'limit' ] )
				or tonumber( currentArgs[ 1 ] )
				or tonumber( currentArgs[ 'limit' ] )
			;
			local offset = tonumber( parentArgs[ 2 ] )
				or tonumber( parentArgs[ 'offset' ] )
				or tonumber( currentArgs[ 2 ] )
				or tonumber( currentArgs[ 'offset' ] )
			;

			return limit
				and exec( limit, offset )
				or ('No valid limit... (%s)'):format( mw.dumpObject( limit ) );
		end
	},
	{
		__call = function( t, ... )
			return exec( ... );
		end
	}
);