
/obj/machinery/door/airlock
	var/can_be_access_unlocked = FALSE
	var/access_unlocked = FALSE

/obj/machinery/door/airlock/proc/can_toggle_access_locks(mob/user)
	//if(!can_be_access_unlocked)
	//	return FALSE
	if(machine_stat & BROKEN)
		return FALSE
	if(!requiresID())
		return FALSE
	if(!iscarbon(user))
		return FALSE
	return TRUE

/obj/machinery/door/airlock/proc/toggle_access_locks(mob/user) // TODO: CHECK TELEKINESIS; ALSO MAKE NOT ASS FOR BORGS
	if(user && !allowed(user, TRUE))
		// TODO: balloon alert & sound here
		balloon_alert(user, "lacking access!")
		run_animation(DOOR_DENY_ANIMATION)
		return FALSE
	access_unlocked = !access_unlocked
	update_appearance() // TODO: apply overlays, like emergency but static
	return TRUE

/obj/machinery/door/airlock/proc/set_access_lockability()
	var/static/list/basic_access_list = list(
		ACCESS_BRIG_ENTRANCE,
		ACCESS_ENGINEERING,
		ACCESS_CONSTRUCTION,
		ACCESS_MEDICAL,
		ACCESS_CARGO,
		ACCESS_SCIENCE,
		ACCESS_SERVICE,
	)

	if(length(req_access) == 1)
		// Only one required access, check if it's in our list
		if(req_access[1] in basic_access_list)
			can_be_access_unlocked = TRUE
			access_unlocked = TRUE
		return

	if(!length(req_one_access))
		return

	for(var/checked_access in req_one_access)
		if(checked_access in basic_access_list)
			can_be_access_unlocked = TRUE
			access_unlocked = TRUE
			return

/obj/machinery/door/airlock/maintenance/set_access_lockability()
	return // Don't set this on maintenance doors.


/obj/machinery/door/airlock/examine(mob/user)
	. = ..()
	if(!can_toggle_access_locks(user))
		return
	. += span_notice("Alt-click [src] to [access_unlocked ? "enable" : "disable"] access locks.")

/obj/machinery/door/airlock/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(!can_toggle_access_locks(user))
		return
	context[SCREENTIP_CONTEXT_ALT_LMB] = "[access_unlocked ? "Enable" : "Disable"] access locks"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/door/airlock/click_alt(mob/user)
	if(!can_toggle_access_locks(user))
		return NONE

	return toggle_access_locks(user) ? CLICK_ACTION_SUCCESS : CLICK_ACTION_BLOCKING

/obj/machinery/door/airlock/allowed(mob/user, toggling_access_locks = FALSE)
	if(!toggling_access_locks && access_unlocked)
		return TRUE
	return ..()
