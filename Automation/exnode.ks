function warpto{
	parameter targetTime.
	set targetTime to targetTime+time:seconds.
	lock dif to targetTime-time:seconds.
	until dif < 2 {
		if dif> 10000
			set warp to 4.
		else if dif>1000 and dif<10000
			set warp to 3.
		else if dif> 100 and dif<200
			set warp to 2.
		else if dif>2 and dif < 100
			set warp to 1.
	}
	set warp to 0.
}
declare function executenode{
	set tthrottle to 0.
	lock throttle to tthrottle.
	
	//set ship:control:mainthrottle to 0.
	wait 2.
	
	set nd to nextnode.
	set ship:control:mainthrottle to 0.
	RCS on.
	set ship:control:mainthrottle to 0.
	lock np to lookdirup(nd:deltav, ship:facing:topvector).
	
	lock steering to np.
	set ship:control:mainthrottle to 0.
	wait until abs(np:pitch - facing:pitch) < 0.15 and abs(np:yaw - facing:yaw) < 0.15.
	if ship:maxthrust=0{
		LIST ENGINES IN mylist.
		for eng in mylist{
			if eng:ignition = 0 and eng:stage=stage:number{
				eng:activate.
			}
		}
	}
	wait 3.
	set durationest to nd:deltav:mag/(ship:maxthrust/ship:mass).
	set warp to 0.
	
	
	warpto(nd:eta-durationest/2 - 15).
	LIST ENGINES IN mylist.
	for eng in mylist{
		if eng:ignition = 0 and eng:stage=stage:number{
			eng:activate.
		}
	}
	when nd:eta<=durationest/2 + 10 then{
		set ship:control:mainthrottle to 0.		
		set ship:control:fore to 1.
		set ship:control:mainthrottle to 0.
	}.
	wait until nd:eta <= durationest/2 + 5.
	set warp to 0.
	when ship:maxthrust=0 and nd:deltav:mag >1 then{
		stage.
		preserve.
	}.
	when nd:eta <=durationest/2 then {
		set ship:control:fore to 0.
		set tthrottle to 1.
	}.
	when nd:deltav:mag<1 then {
		set ship:control:mainthrottle to 0.
		for eng in mylist{
			if eng:thrust>0{
				eng:shutdown.
			}	
		}
	}.
	wait until nd:deltav:mag<1.
	unlock steering.
	set tthrottle to 0.
	remove nd.
}

