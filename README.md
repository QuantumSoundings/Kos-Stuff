# Kos-Stuff
Scripts for kos

#Gravity.ks Basic usage:
```
copy gravity from 0.
run gravity(250,150,0).
```

Explanation of parameters:
- Target apoapsis
- Target periapsis
- Targetted launch ? Set to 1 to launch into the plane of the target.

Special options:
- Setting target periapsis to 0 will, once target apoapsis is reached, burn until the current stage is depleted, maximising the apoapsis of the final orbit.

Requirements:
This script only works with a well designed ship. See the RO wiki for details. Specifically you must at least meet the following criteria:
- Your launch thrust-to-weight ratio must be between 1.3 and 1.7 roughly. Any significant deviation from that could throw the calculations off.
- You need to have launch-clamps, preferably with fuel feed, and a pre-burn stage that happens before they release.
