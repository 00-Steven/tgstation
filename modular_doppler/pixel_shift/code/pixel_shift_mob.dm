/// Adds the fitting pixelshift component on call. Default proc does nothing.
/mob/proc/add_pixel_shift_component()
	return // TODO: First check whether the thing you're pulling wants to apply one

/mob/living/add_pixel_shift_component()
	if(pulling)
		pulling.add_pulled_pixel_shift_component(src)
		return
	AddComponent(/datum/component/pixel_shift)

/mob/living/silicon/ai/add_pixel_shift_component()
	var/obj/machinery/holopad/active_pad = current
	if(istype(active_pad) && active_pad.masters[src])
		var/obj/effect/overlay/holo_pad_hologram/ai_holo = active_pad.masters[src]
		ai_holo.AddComponent(/datum/component/obj_pixel_shift, proxy = src, shift_callback = CALLBACK(active_pad, TYPE_PROC_REF(/obj/machinery/holopad, update_holoray_pixelshift)))
		return
	return ..()


/// Whether this mob can currently use the standard self-pixelshift. Override for special pixelshift behaviours.
/mob/proc/can_pixel_shift_self()
	return TRUE // TODO: send a signal here, and the components hook into it.

/mob/living/can_pixel_shift_self()
	if(pulling)
		return FALSE
	return ..()

/mob/living/silicon/ai/can_pixel_shift_self()
	// Holograms have a special override.
	var/obj/machinery/holopad/active_pad = current
	if(istype(active_pad) && active_pad.masters[src])
		return FALSE
	return ..()
