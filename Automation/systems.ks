function comms{
	parameter target.
	list parts in mylist.
	for currentpart in mylist{
		if currentpart:name:contains("antenna"){
			if currentpart:getModule("ModuleRTAntenna"):getfield("target"):contains("no-target"){
				currentpart:getModule("ModuleRTAntenna"):setfield("target", "earth").
				currentpart:getModule("ModuleRTAntenna"):doevent("activate").
				break.
			}
		}
	}
}

function solarpanels{
	panels on.
}
