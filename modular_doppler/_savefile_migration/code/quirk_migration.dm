
/**
 * Migrate ship captain hull prefs from using the shuttle names to their respective paths.
 */
/datum/preferences/proc/migrate_shuttle_names_to_paths(typepath, list/data = list())
	PRIVATE_PROC(TRUE)

	var/currently_chosen_hull = read_preference(/datum/preference/choiced/ship_captain_hull)
	if(isnull(currently_chosen_hull))
		return
	if(currently_chosen_hull == "Random")
		return // TODO: or just set this to a shuttle in get_shuttle_path_by_name. We really don't need a random shuttle pref do we?

	var/new_hull = get_shuttle_path_by_name(currently_chosen_hull)
	write_preference(GLOB.preference_entries[/datum/preference/choiced/ship_captain_hull], new_hull)

/// Helper to convert shuttle names to paths for migration. Hardcoded to avoid breaking.
/datum/preferences/proc/get_shuttle_path_by_name(currently_chosen_hull)
	PRIVATE_PROC(TRUE)
	switch(currently_chosen_hull)
		if("CAS Hafila")
			return "TheCorrectPref" // TODO: fill this in
	return "TheDefaultOption" // TODO: this proc should always default to one of the ships regardless
