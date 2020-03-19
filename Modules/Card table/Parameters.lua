-- <pre>
--[=[Doc
@module Card table/Parameters
@description Card table parameters.
@author [[User:Deltaneos]]
@author [[User:Dinoguy1000]]
@author [[User:Becasita]]
]=]

local P = {
	main        = true,

	bodyclass   = true,
	bodystyle   = true,
	
	title       = true,
	titleclass  = true,
	titlestyle  = true,

	above       = true,

	above_image = true,
	image       = true,
	image_link  = true,
	image_raw   = true,
	image_right = true,
	image_width = true,
	below_image = true,
	
	below       = true,
	belowclass  = true,

	datastyle   = true,
	labelstyle  = true,
	headerstyle = true,

	defaultsort = true,
}

for n = 1, 20 do
	P['rowclass' .. n]    = true
	P['class' .. n]       = true
	P['header' .. n]      = true
	P['headerstyle' .. n] = true
	P['label' .. n]       = true
	P['labelstyle' .. n]  = true
	P['data' .. n]        = true
	P['datastyle' .. n]   = true
end

return P
-- </pre>
