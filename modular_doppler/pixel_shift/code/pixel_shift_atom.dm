
/// Adds the pixelshift component for when this is pulled.
/atom/movable/proc/add_pulled_pixel_shift_component(mob/living/puller_proxy)
	return

/mob/living/add_pulled_pixel_shift_component(puller_proxy)
	AddComponent(/datum/component/pixel_shift, puller_proxy)

/obj/item/add_pulled_pixel_shift_component(puller_proxy)
	AddComponent( \
		/datum/component/obj_pixel_shift, \
		proxy = puller_proxy, \
		use_xy = TRUE, \
		removed_on_proxyloss = TRUE, \
		remove_shift_on_move = FALSE, \
		reset_shift_on_proxyloss = FALSE, \
	)

/obj/machinery/add_pulled_pixel_shift_component(puller_proxy)
	AddComponent( \
		/datum/component/obj_pixel_shift, \
		proxy = puller_proxy, \
		remove_shift_on_move = FALSE, \
		reset_shift_on_proxyloss = FALSE, \
	)

/obj/structure/desk_bell/add_pulled_pixel_shift_component(puller_proxy)
	AddComponent( \
		/datum/component/obj_pixel_shift, \
		proxy = puller_proxy, \
		remove_shift_on_move = FALSE, \
		reset_shift_on_proxyloss = FALSE, \
	)
