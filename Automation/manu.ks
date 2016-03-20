//CheckList
// Change Apo / Peri
// Circularize
// Change Inclination
// Match Planes with target.



declare function instantvelatalt{
	parameter altitude.
	parameter sma.
	if sma=0 { set sma to ship:orbit:semimajoraxis.}
	local v is sqrt(Body:MU*((2/(altitude+body:radius))-(1/sma))).
	return v.
}
declare function speedforcirorb{
	parameter altitude.
	return sqrt((constant:g*body:mass)/(altitude+body:radius)).
}
declare function changeapo{
	parameter tgtapo.
	//print orbit:semimajoraxis.
	//print (periapsis+(body:radius*2)+apoapsis)/2.
	set newsma to (periapsis+(body:radius*2)+tgtapo)/2.
	set dv to instantvelatalt(periapsis,newsma)-instantvelatalt(periapsis,0).
	print dv.
	set myNode to node(time:seconds+eta:periapsis,0,0,dv).
	add myNode.
}
declare function changeper{
	parameter tgtper.
	set newsma to (tgtper+(body:radius*2)+apoapsis)/2.
	set dv to instantvelatalt(apoapsis,newsma)-instantvelatalt(apoapsis,0).
	set myNode to node(time:seconds+eta:apoapsis,0,0,dv).
	add myNode.
}
declare function normalvector{
	parameter ves.
	set vel to velocityat(ves,time:seconds):orbit.
	set norm to vcrs(vel,ves:up:vector).
	return norm:normalized.
}
declare function ANTA{
	parameter orb1.
	parameter orb2.
	set van to vcrs(normalvector(orb1),normalvector(orb2)).
	return TAFV(van).
}
function TAFV{
	parameter vec.
	set orbnorm to normalvector(ship).
	set proj to vxcl(orbnorm,vec).
	set vtop to positionat(ship,time:seconds+eta:periapsis)-ship:body:position.
	set angle to vang(vtop,proj).
	//print abs(vang(proj,vcrs(orbnorm,vtop))).
	if abs(vang(proj,vcrs(orbnorm,vtop))) < 90 {
		return 360-angle.
	}
	else{
		return angle.
	}
}
function matchplanes{
	set timetob to timetonextnode(ANTA(ship,target)).
	set test to (positionat(ship,time:seconds+timetob)-ship:body:position):normalized.
	set dhor to -vcrs(normalvector(target),test).
	set ahorv to vxcl(test,velocityat(ship,timetob+time:seconds):orbit).
	set dhorv to ahorv:mag*dhor.
	set dif to dhorv-ahorv.
	set a2 to normalvector(ship).
	set mynode to node(time:seconds+timetob,vdot(dif,test),vdot(dif,a2),vdot(dif,velocityat(ship,timetob+time:seconds):orbit:normalized)).
	add mynode.
}
declare function changeinclination{
	parameter newinclination.
	set surfangle to cos(newinclination)/cos(0).
	if surfangle<1 {
		set angle to arccos(surfangle).
		if angle<0 { set angle to angle*(-1).}
		set angle to 90-angle.
	}
	
	set timenode to timetonextnode(360-orbit:argumentofperiapsis).
	if timenode+time:seconds< time:seconds
		set timenode to timenode+orbit:period.
	set vorb to velocityat(ship,time:seconds+timenode):orbit.
	set test to (positionat(ship,time:seconds+timenode)-ship:body:position):normalized.
	set northvec to vxcl(-test,(-body:angularvel*body:radius)+test):normalized.
	set hv to vxcl(test, vorb).
	set nc to hv:mag * cos(angle) * northvec.
	set ec to hv:mag * sin(angle) * vcrs(test,northvec).
	if vdot(hv,nc)<0 {set nc to nc*-1.}
	set dif to ((ec+nc)-hv).
	set a1 to vdot(dif,hv:normalized)*hv:normalized.
	set a2 to dif-a1.
	set a1 to vdot(a2,test)*test.
	set a2 to a2-a1.
	set norm to normalvector(ship).
	if newinclination> orbit:inclination {
	set mynode to node(time:seconds+timenode,vdot(dif,test:normalized),a2:mag,vdot(dif,hv:normalized)).
	} else{
		set mynode to node(time:seconds+timenode,vdot(dif,test:normalized),vdot(dif,norm),vdot(dif,hv:normalized)).
	}
	add mynode.
}
	
declare function circularize{
	parameter where.
	if where:contains("periapsis") {
		set myNode to node(time:seconds+eta:periapsis,0,0,speedforcirorb(ship:orbit:periapsis)-instantvelatalt(ship:orbit:periapsis,orbit:semimajoraxis)).
		add myNode.
	}
	else if where:contains("apoapsis") {
		set myNode to node(time:seconds+eta:apoapsis,0,0,speedforcirorb(ship:orbit:apoapsis)-instantvelatalt(ship:orbit:apoapsis,orbit:semimajoraxis)).
		add myNode.
	}
}
declare function hohmann{
	print (positionat(ship,time:seconds)-ship:body:position):mag-body:radius.
	set newsma to (periapsis+(body:radius*2)+target:altitude)/2.
	set temperiod to 2*constant:pi*sqrt((newsma*newsma*newsma)/body:mu).
	set halfp to temperiod/2.
	set posv to positionat(target,time:seconds+halfp)-target:body:position.
	set temp to halfp/(360/target:orbit:period).
	set tempt to time:seconds.
	until tempt>time:seconds+ship:orbit:period{
		set shippos to positionat(ship,tempt)-ship:body:position.
		if ( vang(shippos,posv)>179)
			break.
		else
			set tempt to tempt+10.
	}
	print positionat(ship,tempt):mag.
	set dv to instantvelatalt((positionat(ship,tempt)-ship:body:position):mag-body:radius,newsma)-instantvelatalt((positionat(ship,tempt)-ship:body:position):mag-body:radius,0).
	print dv.
	set myNode to node(tempt,0,0,dv).
	add mynode.
}

declare function correction{

}
	
declare function debug{
	clearscreen.
	
	until false{
	clearscreen.
	print orbit:argumentofperiapsis at (0,4).
	print orbit:trueanomaly at (0,5).
	wait .5.
	}
	//until false{	
	//	//wait 1.
	////}
}
declare function secformat{
		parameter sec.
		set sec to floor(sec).
		set hour to floor(sec/3600).
		set min to floor(mod(floor(sec/60),60)).
		set sec to mod(sec,60).
		return hour+"H " + min+ "M "+ sec+"S".
}
declare function makeNode{
	parameter velvector.
	parameter time.
	parameter ves.
	
	
}
declare function timetonextnode{
	parameter nodeta.
	set cose to (orbit:eccentricity+cos(nodeta)/(1+(orbit:eccentricity*cos(nodeta)))).
	set sine to (sqrt(1-(cose*cose))).
	if nodeta>180 {set sine to sine*-1.}
	set eano to arctan2(sine,cose).
	set anma to eano-(orbit:eccentricity*sin(eano)).
	set n to (360)/orbit:period.
	set timenode to anma/n.
	return eta:periapsis+timenode.
}
