return PlaceObj('ModDef', {
	'title', "More_Location_Bonuses",
	'description', "This mod is designed to ADD up to 5 Dome Bonus areas to a map, (it also puts these areas on the Mod Editor Map). Should be savegame compatible.\n\nThe extra Vista locations now have a chance to offer a range of comfort to nearby domes ranging from -10 !! to +30 !!, the infopanel names and display update acordingly.\n\nNo changes were made to the Research locations, you just get 5 more.\n\nThe mod adds an entire new Map Bonus Location called the TriboElectric Field. This works exactly like a TriboElectric Scrubber, however it cannot be range adjusted or moved/placed by the player. The field also doesn't affect drones and rovers. Natural TriboElectric Fields require no maintenance and do not need power, they just clean stuff within their range periodically... a powerful addition for free at map start? Maybe, if you get lucky with where they spawn and the size. 1 Field will be revealed on the map at game start. Upto 9 more can be revealed by standard sector scanning.\n\nTriboElectric Fields have an infopanel option to show on select, lock and hide the range rings heavily inspired by Toggle Work Zones by SkiRich.\n\nAll these bonus spots appear at complete random on each map on each restart of a new game, so even for your favorite co-ordinates they will be different.\n\nThe mod includes NEW coloured icons for Vista's and Research locations, these can be returned to the default mono option if you desire, and I included a mono option for the new TriboElectric Field too.\n\nPossible future expansions/updates will contain more Bonus Location types and possibly Mod Option support for number of Locations to spawn.\n\n\nMany Thanks to::\nChoGGi for code tweaks, bugfixing, code help and mod support, the initial idea coming from his Martian Carwash (which you'll want to clean your RC's too)\nEagleScout93 for modding support\nSkiRich for allowing me to utilise code from his Toggle Work Zone mod and major assistance with my own infopanel setup, I also adapted his UI icons to fit my purposes.\n\nChoGGi's Martian Carwash:: https://steamcommunity.com/sharedfiles/filedetails/?id=1411110474 \nSkiRich's Toggle Work Zone:: https://steamcommunity.com/sharedfiles/filedetails/?id=1436876229 \n\nThis mod is a replacement to my own Coloured Dome Bonus mod:: https://steamcommunity.com/sharedfiles/filedetails/?id=1582890631 \nHaving both should create no concflicts, but any further updates will likely be done here.\n\n No known conflicts with any other mod, but as always us modders cannot predict or account for mod compatibilty with all the mods out there. Enjoy !!",
	'last_changes', "v1 Initial release",
	'id', "KOdrW8",
	'pops_desktop_uuid', "d095cd1b-a4b5-4faa-b92f-14671bd3b7a4",
	'pops_any_uuid', "6ac59e5c-9c67-47fa-8a65-06fde9dc0210",
	'author', "RustyDios",
	'version', 188,
	'lua_revision', 233360,
	'saved_with_revision', 245618,
	'code', {
		"Code/AddEntities.lua",
		"Code/Anomalies.lua",
		"Code/BoostedVistaDeposit.lua",
		"Code/Script.lua",
		"Code/TriboEffectDeposit.lua",
		"Code/RD_Override_ConstructionStatus.lua",
		"Code/RandomPerSector.lua",
	},
	'saved', 1560048939,
	'TagGameplay', true,
	'TagTools', true,
	'TagOther', true,
})