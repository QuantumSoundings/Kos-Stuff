lock tLan to mod( abs((mod((target:orbit:longitudeofascendingnode+360),360)-body:rotationangle)),360).
local shiplon is longitude+360.
Declare function enterwindow{
	local offset is tricalc().
	local difference is 1000.
	until difference<1  {
		if difference>30{set warp to 4.}
		else if difference<50 and difference > 3 {set warp to 3.}
		else if difference <3 and difference> 2 {set warp to 2.}
		else if difference <2 and difference> 1{set warp to 1.}
		set difference to abs(c-(shiplon-tlan)).
		print "Relative LAN to Target: " + difference at (0,12).
		wait .001.
	}
	set warp to 0.
	wait 5.
	return.
}
local c is 0.
declare function tricalc{
	local a is latitude.
	local alpha is target:orbit:inclination.
	local b is 0.
	local bell is 90.
	local gamma is 0.
	if sin(a)*sin(bell)/sin(alpha) >1 {
		set b to 90.
		}
	else{
		set b to arcsin(sin(a)*sin(bell)/sin(alpha)).
	}
	set c to 2*arctan(tan(.5*(a-b))*(sin(.5*(alpha+bell))/sin(.5*(alpha-bell)))).
	return c.
}
