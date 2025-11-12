
/obj/item/brick_phone_scryer/miniholo
	name = "mini scryerpad"
	desc = "An ancient-looking brick phone, refurbished to turn it into a MODlink-compatible device. It can only do video calls now."

	/// Reference to the person who activated us.
	var/datum/weakref/last_user_ref

/obj/item/brick_phone_scryer/miniholo/get_user()
	var/mob/living/last_user = last_user_ref?.resolve()
	if(last_user)
		return last_user
	last_user = ..()
	if(last_user)
		last_user_ref = WEAKREF(last_user)
	return last_user




/obj/item/brick_phone_scryer/miniholo/get_link_visual(atom/movable/visuals)
	var/mob/living/user = mod_link.get_user()
	playsound(mod_link.holder, 'sound/machines/terminal/terminal_processing.ogg', 50, vary = TRUE)
	//visuals.add_overlay(mutable_appearance('icons/effects/effects.dmi', "static_base", ABOVE_NORMAL_TURF_LAYER))
	//visuals.add_overlay(mutable_appearance('icons/effects/effects.dmi', "modlink", ABOVE_ALL_MOB_LAYER))
	//visuals.add_filter("crop_square", 1, alpha_mask_filter(icon = icon('icons/effects/effects.dmi', "modlink_filter")))
	visuals.maptext_height = 6
	visuals.alpha = 0
	vis_contents += visuals
	visuals.transform = visuals.transform.Scale(0.5)
	visuals.forceMove(user)
	animate(visuals, 0.5 SECONDS, alpha = 255)
	//var/datum/callback/setdir_callback = CALLBACK(mod_link.holder, PROC_REF(on_user_set_dir))
	//setdir_callback.Invoke(user, user.dir, user.dir)
	//mod_link.holder.RegisterSignal(mod_link.holder.loc, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_user_set_dir))
	return visuals


/obj/item/brick_phone_scryer/miniholo/loaded/Initialize(mapload)
	. = ..()
	cell = new /obj/item/stock_parts/power_store/cell/high(src)

/obj/item/brick_phone_scryer/miniholo/loaded/crew
	starting_frequency = MODLINK_FREQ_NANOTRASEN
