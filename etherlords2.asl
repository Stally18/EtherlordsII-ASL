
state("ETHERLORDS2", "v1.03")
{
	string64 path : 0x005D1B3C;
	byte IGT : 0x005C43F4;
	//byte load : 0x005D13D4;
	//string11 mission : 0x005D1B59;	//obsolete because this would be dependent on the path length
}

startup
{
	// to lower CPU usage
	refreshRate = 30;
	//settings.Add("nosplit", false, "No split usage");
	vars.mission = "e2mission00";
	vars.oldmission = "e2mission00";
}

init
{
	//if (timer.IsGameTimePaused == true) timer.IsGameTimePaused = false;
}

exit
{
	// pausing igt for Glitched category
	timer.IsGameTimePaused = true;
}

update
{
	// we need to know first if the mission changed
	if (current.path.Contains("e2")) vars.mission = current.path.Substring(current.path.IndexOf("e2"));
}

start
{
	if  ((vars.mission.Contains("e2mission11") || 	// !old.mission.Equals("e2mission11") || 
		vars.mission.Contains("e2mission21") || 	// !old.mission.Equals("e2mission21") || 
		vars.mission.Contains("e2mission31")) 		// && !old.mission.Equals("e2mission31"))
		&&
		(current.IGT == 3 && old.IGT == 0))
		{	
			vars.oldmission = vars.mission;
			return true;
		}
}

split
{
	// We only want to split when we progress the campaign
	// so when both the Save happened (save_after_mission) and the mission variable changed
	if (current.path.Contains("e2mission") && old.path.Contains("Save")
		&& vars.mission != vars.oldmission)
		{
			// So split wont happen when we quicksave/load (no mission change)
			// And wont happen when we restart game (mission changed but no Save)
			vars.oldmission = vars.mission;
			return true;
		}
}

reset 
{
	// Never using that because of Glitched category
}

isLoading 
{
	return !Convert.ToBoolean(current.IGT);
}