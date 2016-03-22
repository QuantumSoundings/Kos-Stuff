declare parameter tgtapom.
declare local tgtapo to tgtapom*1000.
declare parameter tgtpem.
declare local tgtpe to tgtpem*1000.
declare parameter tlaunch.
declare parameter inclinedlaunch.
Declare local cthrust to 0.
declare local twr to 0.
declare local pitch to 90.
declare local est to 0.
declare local pitch to 90.
declare local pinc to 0.
declare local loop to false.
declare local azimuth to 90.
declare local timetotargetapo to 0.
set cbody to body("Earth").
lock g to earth:mu / (altitude + earth:radius)^2.
lock twr to max(.001, ship:maxthrust/(ship:mass*g)).
lock progradeheading to headingfromvector(prograde:vector).
declare local status to "Preparing for Launch.".
clearscreen.
copy manu from 0.
copy launchwindow from 0.
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
	print "Time to TGTAPO: " + timetotargetapo at (0,20).
	print "PROGRADE HEADING: " + headingfromvector(prograde:vector) at (0,21).
	print "PROGRADE PITCH: " + pitchfromvector(srfprograde:vector) at (0,22).
	if loop{
	print "P:    " + Pz at (0,12).
	print "Kp:   " + Kp at (0,13).
	print "I:    " + I at (0,14).
	print "Ki:   " + ki at (0,15).
	print "D:    " + D at (0,16).
	print "Kd:   " + kd at (0,17).
	}
}.

declare function headingfromvector{
	parameter vector.
	set a1 to vdot(ship:up:vector,vector)*vector:normalized.
	set a2 to vector-a1.
	return vang(ship:north:vector,a2).
}
declare function pitchfromvector{
	parameter vector.
	return 90-vang(ship:up:vector,vector).
}

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
	when abs(progradeheading-inclinedlaunch)<.5 then{
		set azimuth to progradeheading.
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
	if tlaunch=0 {
		if inclinedlaunch <latitude{
			print "ERROR INCLINATION CANNOT BE LOWER THAN LATITUDE".
			set breaker to 0/0.
		}
		set tempangle to cos(inclinedlaunch)/cos(ship:latitude).
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
		if x = 6{
			print "Preburning.".
			stage.
		}
		else if x= 3{
		print "Releasing clamps".
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
	lock progradepitch to pitchfromvector(srfprograde:vector).
	set ship:control:mainthrottle to 1.0.
	if twr>1.7
		set pitchstart to 50.
	else if twr<1.7 and twr>1.4
		set pitchstart to 75.
	else
		set pitchstart to 100.
	lock steering to heading(azimuth,pitch).
	when airspeed>= pitchstart then{
		lock steering to heading(azimuth,85).
	}.
	when progradepitch<=85 and airspeed>=pitchstart then{
		lock steering to heading(azimuth,progradepitch).
	}.
	until ship:airspeed>1000 {
		flameout().
		if twr<>0{
			set est to floor((1000-ship:airspeed)/(twr*g)).
			if est<>0{
				set pinc to (pitch-45)/est.
				if altitude<8000
					set pinc to pinc*.5.
				else if altitude>8000 and altitude<11000
					set pinc to pinc*.9.
				else if altitude>11000 and altitude<16000
					set pinc to pinc*1.1.
				
			}
			//if ship:airspeed >pitchstart{
			//	lock steering to heading(azimuth,pitch-pinc).
			//	set pitch to pitch-pinc.
			//}
			if altitude>20000{
				lock steering to heading(azimuth,pitch-pinc).
				set pitch to pitch-pinc.
			}
			else if airspeed>=progradepitch
				set pitch to progradepitch.
				
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
	
	
	
	when maxthrust = 0 and periapsis <tgtapo and stage:number>2 then { 
		stage.
		preserve.
	}.
	set oldt to time:seconds.
	set oldapo to apoapsis.
	set timetotargetapo to 50.
	set p1 to true.
	set p2 to false.
	set p3 to false.
	when progradepitch<=30 then {
		lock steering to heading(azimuth,progradepitch).
	}
	
	until apoapsis >tgtapo{
		
		if oldt<>time:seconds{
			set deltaapo to (apoapsis-oldapo)/(time:seconds-oldt).
			set timetotargetapo to (tgtapo-apoapsis)/deltaapo.
		}
		if timetotargetapo>50 and p1 = true
			lock steering to heading(azimuth,30).
		if (timetotargetapo<50 and timetotargetapo>20) or p2= true{
			lock steering to heading(azimuth,15).
			set p1 to false.
			set p2 to true.
		}
		if (timetotargetapo<20 and timetotargetapo>0) or p3= true {
			lock steering to heading(azimuth,0).
			set p2 to false.
			set p3 to true.
		}
		flightreadout().
		wait .001.
	}
}

declare function closedloopguidance{
	local pitch is 0.
	lock progradeheading to headingfromvector(prograde:vector).
	// Set up the pid-loop for final ascent.
	set loop to true.
	
	set ttasetpoint to 0.
	set Pz to ttasetpoint-verticalspeed.
	set I to 0.
	Set D to 0.
	set P0 to Pz.
	set Kp to (.05/twr).
	set Ki to .005.
	set Kd to .1.
	set angold to 0.
	
	set pitchmin to -5.
	
	lock pchange to Kp*Pz + Ki*I + Kd*D.
	if tlaunch =1
		set tgtnorm to normalvector(target).
	set t0 to time:seconds.
	set oldtime to 0.
	until periapsis > tgtapo-2000{
		if apoapsis < tgtapo+200
			set pitchmin to 0.
		else
			set pitchmin to -5.
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
			} else if pitch + pchange <pitchmin and d > 0{
				lock steering to heading(azimuth,pitchmin).
				set pitch to pitchmin.
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
set ship:control:pilotmainthrottle to 0.