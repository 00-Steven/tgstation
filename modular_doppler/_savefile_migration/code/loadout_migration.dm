
/// Replaces each of the lipstick subtypes with the lipstick parent type, if it's present
/datum/preferences/proc/replace_loadout_lipstick()
	PRIVATE_PROC(TRUE)

	var/static/list/replaced_lipstick_types = list(
		/obj/item/lipstick/green,
		/obj/item/lipstick/white,
		/obj/item/lipstick/blue,
		/obj/item/lipstick/black,
		/obj/item/lipstick/jade,
		/obj/item/lipstick/purple,
	)

	var/list/loadout_list = read_preference(/datum/preference/loadout) || list()
	/// The first lipstick type we found, for replacement
	var/obj/item/lipstick/lipstick_type_found
	/// The data for the first lipstick type we found
	var/list/new_lipstick_data

	// Remove all our old lipsticks.
	for(var/obj/item/lipstick/lipstick_type as anything in replaced_lipstick_types)
		if(!loadout_list[lipstick_type])
			continue
		if(!lipstick_type_found)
			lipstick_type_found = lipstick_type
			var/list/old_data = loadout_list[lipstick_type]
			new_lipstick_data = old_data?.Copy() || list()
			to_chat(parent, span_danger("Savefile update: [lipstick_type::name] replaced in loadout"))
		else
			to_chat(parent, span_danger("Savefile update: [lipstick_type::name] removed from loadout"))
		loadout_list.Remove(lipstick_type)

	if(!lipstick_type_found)
		return // No old lipstick type found, abort.

	// Set the data on our new lipstick.
	new_lipstick_data[INFO_GREYSCALE] = lipstick_type_found::lipstick_color
	loadout_list[/obj/item/lipstick] = new_lipstick_data
	write_preference(GLOB.preference_entries[/datum/preference/loadout], loadout_list)
