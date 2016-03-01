declare parameter tgtapo.
declare parameter tlaunch.
Declare local cthrust to 0.
declare local twr to 0.
declare local est to 0.
declare local pitch to 90.
declare local pinc to 0.
declare local loop to false.
declare local azimuth to 90.
set cbody to body("Earth").
lock g to earth:mu / (altitude + earth:radius)^2.
lock twr to max(.001, ship:maxthrust/(ship:mass*g)).
declare local status to "Preparing for Launch.".
clearscreen.
copy manu from 0.
run once launchwindow.
run once manu.

declare local angle to 0.
declare local function flightreadout{
	print "===============================" at (0,1).
	print "========Flight Computer========" at (0,2).
	print "===============================" at (0,3).
	print "Vessel Status: " + status + "                             " at (0,4).
	print "Vessel Statistics:"              at (0,5).
	print "Current TWR:    "+ twr             at (0,6).
	print "Current Mass:   "+ ship:mass       at (0,7).
	print "Current Accel:  "+ twr*g       at (0,8).
	print "Heading:        " + azimuth          at (0,9).
	//print "Time to 1000m/s:" + est at (0,10).
	print "Current Vel:    " + ship:airspeed at (0,10).
	if tlaunch=1 {
	print "Relative Inclination: "+ vang(normalvector(ship),normalvector(target)) at (0,11).
	}
	if loop{
	print "P:    " + Pz at (0,12).
	print "Kp:   " + Kp at (0,13).
	print "I:    " + I at (0,14).
	print "Ki:   " + ki at (0,15).
	print "D:    " + D at (0,16).
	print "Kd:   " + kd at (0,17).
	}
}.
declare function prelaunchsetup{
	//Set up triggers for fairing seperation
	list parts in myparts.
	for currentpart in myparts{
		if currentpart:name:contains("fairingbase"){
			global fairingpart is currentpart.
		}
	}.
	when altitude > 140000 then{	
		for child in fairingpart:children{
			if child:name:contains("fairing")
				child:getmodule("ProceduralFairingDecoupler"):doevent("jettison").
		}.
	}
	//Setup triggers for system status
	when ship:airspeed>1 then{ 
		set status to "Lift-off...".
		when ship:airspeed>100 then{
			set status to "Gravity turn to 1000m/s at 45 Degrees.".
			when ship:airspeed>1000 then{
				set status to "Pitching down to 30 Degrees.".
				when pitch=30 then{
					set status to "Raising Apoapsis to target...".
					when apoapsis>=tgtapo then{
						set status to "Entering Closed Loop guidance until orbit.".
					}
				}
			}
		}
	}
	//Other triggers
	when altitude > 100000 then { 
		RCS on.
	}.
	//Setup Targeted Launch
	if tlaunch = 1{
		enterwindow().
		set tempangle to cos(target:orbit:inclination)/cos(ship:latitude).
		if tempangle>1{
			print "Direct Launch Impossible".
		} else {
			set azimuth to arcsin(tempangle).
			local veq is (2*constant:pi*body:radius)/body:rotationperiod.
			local ospeed is sqrt(constant:G*body:mass/(body:radius+tgtapo)).
			local vx is ospeed*sin(azimuth)-veq*cos(latitude).
			local vy is ospeed*cos(azimuth).
			set azimuth to arctan(vx/vy).
			}
		clearscreen.
	
	}
}

declare function flameout{
	LIST ENGINES IN mylist.
	FOR eng IN mylist {
		if eng:flameout{
			local curstage to eng:stage.
			local parentpart to eng:parent.
			
			until not parentpart:hasparent{
				if parentpart:modules:contains("ModuleAnchoredDecoupler") {
					parentpart:getmodule("ModuleAnchoredDecoupler"):doevent("Decouple").
					break.
				}
				else
					set parentpart to parentpart:parent.
			}
		}
	}.
}

declare function countdown{
	print "Lift-off in:".
	from{local x is 10.} until x = 0 step{ set x to x-1.} do{
		print x.
		if x = 5{
			print "Clearing Towers.".
			stage.
		}
		else if x= 2{
			print "Igniting Engines.".
			stage.
		}
		wait 1.
	}
	stage.
	Print "Lift-off. Engaging Auto-Control.".
}
declare function preprogramedguidance{
	set ship:control:mainthrottle to 1.0.
	countdown().
	clearscreen.
	set ship:control:mainthrottle to 1.0.
		
	lock steering to heading(azimuth,pitch).
	until ship:airspeed>1000 {
		flameout().
		if twr<>0{
			set est to floor((1000-ship:airspeed)/(twr*g)).
			if est<>0{
				set pinc to (pitch-45)/est.
			}
			if ship:airspeed >100{
				lock steering to heading(azimuth,pitch-pinc).
				set pitch to pitch-pinc.
			}	
		}
		flightreadout().
		wait 1.
	}
	
	clearscreen.
	lock steering to heading(azimuth,45).
	set pitch to 45.
	until pitch <= 30{
		lock steering to heading(azimuth,pitch-1).
		set pitch to pitch-1.
		flightreadout().
		wait 1.
	}
	lock steering to heading(azimuth,30).
	
	
	when maxthrust = 0 and periapsis <tgtapo and stage:number>2 then { 
		stage.
		preserve.
	}.
	until apoapsis >tgtapo{
		//updatea().
		lock steering to heading(azimuth,30).
		flightreadout().
		wait 1.
	}
}

declare function closedloopguidance{
	local pitch is 30.
	// Set up the pid-loop for final ascent.
	set loop to true.
	
	set ttasetpoint to 1.
	set Pz to ttasetpoint-verticalspeed.
	set I to 0.
	Set D to 0.
	set P0 to Pz.
	set Kp to (.05/twr).
	set Ki to .005.
	set Kd to .1.
	set angold to 0.
	
	lock pchange to Kp*Pz + Ki*I + Kd*D.
	if tlaunch =1
		set tgtnorm to normalvector(target).
	set t0 to time:seconds.
	set oldtime to 0.
	until periapsis > tgtapo-4000{
		//updatea().
		if tlaunch = 1 and mod(floor(time:seconds),5) = 0 and floor(time:seconds)<> oldtime{
			set angle to vang(normalvector(ship),tgtnorm).
			if not (angle > 1){
				set oldtime to floor(time:seconds).
				if vang(tgtnorm, ship:velocity:orbit) <90
					set azimuth to azimuth+angle.
				else
					set azimuth to azimuth-angle.
			}
		}	
		set Kp to (.05/twr).
		set dt to time:seconds - t0.
		if dt>0{
			set I to I + Pz * dt.
			set D to (pz-p0)/dt.
			if pitch + pchange < 0 and D < 0{
				lock steering to heading(azimuth,0).
				set pitch to 0.
				//set D to 0.
				set I to 0.
			} else if pitch + pchange <-5 and d > 0{
				lock steering to heading(azimuth,-5).
				set pitch to -5.
				//set D to 0.
				set I to 0.
			} else if pitch+ pchange> 45 {
				lock steering to heading(azimuth,45).
				set pitch to 45.
			} else {
				lock steering to heading(azimuth,pitch+pchange).
				set pitch to pitch + pchange.
			}
			set p0 to pz.
			set t0 to time:seconds.
		}
		set Pz to ttasetpoint-verticalspeed.
		if i >2 {
			set i to 2.
		}
		else if i<-2{
			set i to -2.
			}
		flightreadout().
		wait 0.001.
	}
	set warp to 0.
	list engines in mylist.
	for eng in mylist{
		if eng:thrust>0{
			eng:shutdown.
		}
	}
	RCS OFF.
	clearscreen.
	wait 2.
}

function main{
	prelaunchsetup().
	preprogramedguidance().
	closedloopguidance().
}
main().
