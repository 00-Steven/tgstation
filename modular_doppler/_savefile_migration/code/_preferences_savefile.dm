/**
 * Simplified copy of the base TG savefile updating system,
 * to ensure our modular prefs don't get blown up on the regular.
 */
#define DOPPLER_SAVEFILE_VERSION_MAX 1

#define VERSION_LOADOUT_POCKETS_CLEANUP 1

#define SHOULD_UPDATE_DOPPLER_DATA(version) (version < DOPPLER_SAVEFILE_VERSION_MAX)

/// Gets our current savefile version.
/datum/preferences/proc/get_savefile_version(list/save_data)
	var/savefile_version = save_data["doppler_version"]
	return savefile_version

/// Checks whether we need to update our character save data, and does so if needed.
/datum/preferences/proc/check_doppler_character_savefile(list/save_data)
	if(isnull(save_data))
		save_data = list()
	var/current_version = get_savefile_version(save_data)
	if(!SHOULD_UPDATE_DOPPLER_DATA(current_version))
		return
	update_character_doppler(current_version, save_data)
	save_doppler_version(save_data)

/// Updates our character save data.
/datum/preferences/proc/update_character_doppler(current_version, list/save_data)
	if(current_version < VERSION_LOADOUT_POCKETS_CLEANUP)
		replace_loadout_lipstick()

/datum/preferences/proc/save_doppler_version(list/save_data)
	// load_character will sanitize any bad data, so assume up-to-date.
	save_data["version"] = DOPPLER_SAVEFILE_VERSION_MAX


#undef DOPPLER_SAVEFILE_VERSION_MAX
#undef VERSION_LOADOUT_POCKETS_CLEANUP
#undef SHOULD_UPDATE_DOPPLER_DATA