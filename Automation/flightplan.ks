set target to vessel("GeoSat 4").
copy gravity from 0.
copy systems from 0.
copy launchwindow from 0.
run gravity(250,250,1).//1 is for targeted launch, 0 is for untargeted.
run once systems.
comms("earth").
solarpanels().
wait 30.
delete gravity.
delete launchwindow.
copy manu from 0.

copy exnode from 0.
run once manu.
run once exnode.
//Raise apo to geo
changeapo(35786000).
wait 5.
executeNode().
wait 5.
circularize("apoapsis").
wait 5.
executeNode().
wait 5.
matchplanes().
wait 5.
executenode().
