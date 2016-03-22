local alt is false.
Declare function enterwindow{
	lock tLan to mod((360-target:orbit:lan) + body:rotationangle,360).
	if longitude<0
		set shiplon to abs(longitude).
	else
		set shiplon to 360-longitude.
	
	if target:orbit:inclination<abs(latitude) { //If normal launch is impossible.
		set tgtnormal to normalvector(target).
		set difference to vang(normalvector(ship),tgtnormal).
		set alt to true.
		set min to ship:orbit:inclination-target:orbit:inclination.
	}
	else{//If normal launch is possible.
		set offset to tricalc().
		set min to 0.
	}
	local difference is 1000.
	until difference<min+.2{
		if difference>30{set warp to 4.}
		else if difference<50 and difference > min+6{set warp to 4.}
		else if difference <min+6 and difference> min+1.5{set warp to 3.}
		else if difference <min+1.5 and difference> min+1.0{set warp to 2.}
		else if difference <min+1.0 and difference> min+.2{set warp to 1.}
		if alt{
			set difference to vang(normalvector(ship),normalvector(target)).
			Print "Relative Inclination:   "+ difference at (0,12).
			print "Minimum R. Inclination: "+ min at (0,13).
		}
		else{
			set difference to abs((shiplon+c)-tlan).
			print "Relative LAN to Target: " + difference at (0,12).
		}
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
