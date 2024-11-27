
state("ETHERLORDS2", "v1.03 (Steam)")
{
	// Module size: 8146944, hash FD4D837F33556EA47ADCB669F886278A
	// Default state

	string128 path : 0x005D1B3C;
	byte IGT : 0x005C43F4;
	//byte load : 0x005D13D4;
	//string11 mission : 0x005D1B59;	//obsolete because this would be dependent on the path length
}

state("ETHERLORDS2", "v1.01 (GOG)")	
{
	// Module size: 4911104, hash FEC7C378B1C2CF545F6A4E7E91B9998
	
	string64 path : 0x00445F14;
	byte IGT : 0x00437EAC;
}

state("ETHERLORDS2", "v1.00 (retail)")	
{
	// Module size: 6135808, hash A5F9E8F389771FE5B99A7971E660B44E
	
	string64 path : 0x005BD1FC;
	byte IGT : 0x005AFF8C;
}

startup
{
	// to lower CPU usage
	refreshRate = 30;
	//settings.Add("nosplit", false, "No split usage");
	vars.mission = "e2mission00";
	vars.oldmission = "e2mission00";
	
	Func<ProcessModuleWow64Safe, string> CalcModuleHash = (module) => {
		byte[] exeHashBytes = new byte[0];
		using (var sha = System.Security.Cryptography.MD5.Create())
		{
			using (var s = File.Open(module.FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
			{
				exeHashBytes = sha.ComputeHash(s);
			}
		}
		var hash = exeHashBytes.Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
		return hash;
	};
	vars.CalcModuleHash = CalcModuleHash;
}

init
{
	//if (timer.IsGameTimePaused == true) timer.IsGameTimePaused = false;
	var module = modules.Single(x => String.Equals(x.ModuleName, "ETHERLORDS2.exe", StringComparison.OrdinalIgnoreCase));
	var moduleSize = module.ModuleMemorySize;
	var hash = vars.CalcModuleHash(module);
	
	if (hash == "2FEC7C378B1C2CF545F6A4E7E91B9998")
	{
		// Module Size: 4911104
		version = "v1.01 (GOG)";
	}
	else if (hash == "A5F9E8F389771FE5B99A7971E660B44E")
	{
		// Module Size: 6135808
		version = "v1.00 (retail)";
	}
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
		vars.mission.Contains("e2mission31") ||		// && !old.mission.Equals("e2mission31") ||
		vars.mission.Contains("e2tutorial"))
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
	// so when both the Save happened (save_after_mission) and the mission variable changed		// this part is for Allcampaign% run
	if (current.path.Contains("e2mission") && (old.path.Contains("Save") || (vars.mission.Contains("e2mission11") || vars.mission.Contains("e2mission21")))
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
