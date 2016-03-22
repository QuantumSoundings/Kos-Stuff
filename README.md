# Kos-Stuff
Scripts for kos

#Gravity.ks Basic usage:
```
copy gravity from 0.
run gravity(250,150,0,0).
```

Explanation of parameters:
- Target apoapsis
- Target periapsis
- Targetted launch ? Set to 1 to launch into the plane of the target.
- Target Inclination. Inclination can only be higher than the latitude of your launchsite. For example if you launch from cape canaveral you can only launch into inclinations from 28-90.

Special options:
- Setting target periapsis to 0 will, once target apoapsis is reached, burn until the current stage is depleted, maximising the apoapsis of the final orbit.

Requirements:
This script only works with a well designed ship. See the RO wiki for details. Specifically you must at least meet the following criteria:
- Your launch thrust-to-weight ratio must be between 1.3 and 1.7 roughly. Any significant deviation from that could throw the calculations off. Second and third stages should be between .7 and 1-ish. Ultra low thrust upper stages such as the saturn V cause problems.
- You need to have launch-clamps, preferably with fuel feed, and a pre-burn stage that happens before they release. For instance the Fasa umbilical towers. They supply LO and LH so your ship will stay fueled while waiting for a launch window. My rockets typically go as follows:
Stage:9 - Fasa umbilical towers
Stage:8 - Engine egnition
Stage:7 - Launch clamps
