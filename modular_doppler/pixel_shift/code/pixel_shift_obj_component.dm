/datum/component/obj_pixel_shift
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Holder for how the obj is shifted on the z/y axis
	var/pixel_shift_vertical = 0
	/// holder for how the obj is shifted on the w/x axis
	var/pixel_shift_horizontal = 0
	/// Whether the obj is pixel shifted or not
	var/is_shifted = FALSE
	/// If we are in the shifting setting.
	var/shifting = TRUE
	/// Takes the four cardinal direction defines. Any atoms moving into this atom's tile will be allowed to from the added directions.
	var/passthroughable = NONE
	/// The maximum amount of pixels allowed to move in the turf.
	var/maximum_pixel_shift = 16
	/// The amount of pixel shift required to make the parent passthroughable.
	var/passable_shift_threshold = 8
	
	/// The proxy that controls our offsets.
	var/mob/living/proxy
	/// Whether we use pixel_x and pixel_y instead of pixel_z and pixel_w.
	var/use_xy = FALSE
	/// Whether we can exist independently from our proxy.
	var/removed_on_proxyloss = TRUE
	/// Whether we change proxy on pull.
	var/change_proxy_on_pull = TRUE
	/// Whether we remove our pixelshift and component when we move.
	var/remove_shift_on_move = TRUE
	/// Whether we reset our pixelshift when we lose our proxy.
	var/reset_shift_on_proxyloss = TRUE
	/// The callback called after pixel shifting.
	var/datum/callback/shift_callback

/datum/component/obj_pixel_shift/Initialize(
	mob/living/proxy,
	use_xy = FALSE,
	maximum_pixel_shift = 16,
	removed_on_proxyloss = TRUE,
	change_proxy_on_pull = TRUE,
	remove_shift_on_move = TRUE,
	reset_shift_on_proxyloss = TRUE,
	datum/callback/shift_callback,
)
	. = ..()
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

	src.proxy = proxy
	src.use_xy = use_xy
	src.maximum_pixel_shift = maximum_pixel_shift
	src.removed_on_proxyloss = removed_on_proxyloss
	src.change_proxy_on_pull = change_proxy_on_pull
	src.remove_shift_on_move = remove_shift_on_move
	src.reset_shift_on_proxyloss = reset_shift_on_proxyloss
	src.shift_callback = shift_callback
	// TODO: let it change proxy when pulled?
	// TODO: var for whether it's hard-locked to the proxy or changes proxy on pull

/datum/component/obj_pixel_shift/Destroy()
	shift_callback = null
	return ..()

/datum/component/obj_pixel_shift/RegisterWithParent()
	RegisterSignal(proxy, COMSIG_KB_MOB_PIXEL_SHIFT_DOWN, PROC_REF(pixel_shift_down))
	RegisterSignal(proxy, COMSIG_KB_MOB_PIXEL_SHIFT_UP, PROC_REF(pixel_shift_up))
	RegisterSignal(proxy, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, PROC_REF(pre_move_check))

	if(change_proxy_on_pull)
		RegisterSignal(parent, COMSIG_ATOM_NO_LONGER_PULLED, PROC_REF(on_stop_pull))
		// TODO: register getting new proxy on pull?
	if(removed_on_proxyloss)
		RegisterSignal(proxy, COMSIG_QDELETING, PROC_REF(on_proxy_delete))
	if(remove_shift_on_move)
		RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(unpixel_shift))
	RegisterSignal(parent, COMSIG_LIVING_CAN_ALLOW_THROUGH, PROC_REF(check_passable))

	var/obj/obj_parent = parent
	if(use_xy)
		pixel_shift_horizontal = obj_parent.pixel_x - obj_parent.base_pixel_x
		pixel_shift_vertical = obj_parent.pixel_y - obj_parent.base_pixel_y
	else
		pixel_shift_horizontal = obj_parent.pixel_w - obj_parent.base_pixel_w
		pixel_shift_vertical = obj_parent.pixel_z - obj_parent.base_pixel_z

/datum/component/obj_pixel_shift/UnregisterFromParent()
	unregister_proxy()

	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(parent, COMSIG_LIVING_CAN_ALLOW_THROUGH)

/// Unregisters our proxy.
/datum/component/obj_pixel_shift/proc/unregister_proxy()
	if(isnull(proxy))
		return
	UnregisterSignal(proxy, COMSIG_QDELETING)
	UnregisterSignal(proxy, COMSIG_KB_MOB_PIXEL_SHIFT_DOWN)
	UnregisterSignal(proxy, COMSIG_KB_MOB_PIXEL_SHIFT_UP)
	UnregisterSignal(proxy, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE)
	proxy = null

/// If the proxy shifting us goes away, makes sure we clean up after ourselves.
/datum/component/obj_pixel_shift/proc/on_proxy_delete(datum/source)
	SIGNAL_HANDLER
	unregister_proxy()
	if(reset_shift_on_proxyloss)
		reset_offsets()
	qdel(src)

/// Overrides Move to Pixel Shift.
/datum/component/obj_pixel_shift/proc/pre_move_check(mob/source, new_loc, direct)
	SIGNAL_HANDLER
	if(!shifting)
		return NONE
	pixel_shift(source, direct)
	return COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE

/datum/component/obj_pixel_shift/proc/on_stop_pull(datum/source, atom/movable/was_pulling)
	SIGNAL_HANDLER
	unregister_proxy()
	if(!removed_on_proxyloss)
		return
	if(reset_shift_on_proxyloss)
		reset_offsets()
	qdel(src)

/// Checks if the parent is considered passthroughable from a direction. Projectiles will ignore the check and hit.
/datum/component/obj_pixel_shift/proc/check_passable(mob/source, atom/movable/mover, border_dir)
	SIGNAL_HANDLER
	if(!isprojectile(mover) && !mover.throwing && passthroughable & border_dir)
		return COMPONENT_LIVING_PASSABLE

/// Activates Pixel Shift on Keybind down. Only Pixel Shift movement will be allowed.
/datum/component/obj_pixel_shift/proc/pixel_shift_down()
	SIGNAL_HANDLER
	shifting = TRUE
	return COMSIG_KB_ACTIVATED

/// Disables Pixel Shift on Keybind up. Allows to Move.
/datum/component/obj_pixel_shift/proc/pixel_shift_up()
	SIGNAL_HANDLER
	shifting = FALSE

/// Sets parent pixel offsets to default and deletes the component.
/datum/component/obj_pixel_shift/proc/unpixel_shift()
	SIGNAL_HANDLER
	reset_offsets()
	qdel(src)

/// In-turf pixel movement which can allow things to pass through if the threshold is met.
/datum/component/obj_pixel_shift/proc/pixel_shift(mob/source, direct)
	passthroughable = NONE
	var/obj/obj_parent = parent
	var/max_horizontal_shift = maximum_pixel_shift + (use_xy ? obj_parent.base_pixel_x : obj_parent.base_pixel_w)
	var/max_vertical_shift = maximum_pixel_shift + (use_xy ? obj_parent.base_pixel_y : obj_parent.base_pixel_z)
	// TODO: make it so items with relative_to_initial_offset still can't exceed the tile?
	switch(direct)
		if(NORTH)
			if(pixel_shift_vertical <= max_vertical_shift)
				pixel_shift_vertical++
		if(EAST)
			if(pixel_shift_horizontal <= max_horizontal_shift)
				pixel_shift_horizontal++
		if(SOUTH)
			if(pixel_shift_vertical >= -max_vertical_shift)
				pixel_shift_vertical--
		if(WEST)
			if(pixel_shift_horizontal >= -max_horizontal_shift)
				pixel_shift_horizontal--

	is_shifted = TRUE
	update_offsets()

	// Yes, I know this sets it to true for everything if more than one is matched.
	// Movement doesn't check diagonals, and instead just checks EAST or WEST, depending on where you are for those.
	if(pixel_shift_vertical > passable_shift_threshold)
		passthroughable |= EAST | SOUTH | WEST
	else if(pixel_shift_vertical < -passable_shift_threshold)
		passthroughable |= NORTH | EAST | WEST
	if(pixel_shift_horizontal > passable_shift_threshold)
		passthroughable |= NORTH | SOUTH | WEST
	else if(pixel_shift_horizontal < -passable_shift_threshold)
		passthroughable |= NORTH | EAST | SOUTH

/// Resets our pixel offsets.
/datum/component/obj_pixel_shift/proc/reset_offsets()
	if(!is_shifted)
		return
	pixel_shift_horizontal = 0
	pixel_shift_vertical = 0
	update_offsets(animate = TRUE)

/// Sets our pixel offsets, accounting for use_xy.
/datum/component/obj_pixel_shift/proc/update_offsets(animate = FALSE)
	var/obj/obj_parent = parent
	var/new_x = obj_parent.pixel_x
	var/new_y = obj_parent.pixel_y
	var/new_w = obj_parent.pixel_w
	var/new_z = obj_parent.pixel_z

	if(use_xy)
		new_x = pixel_shift_horizontal + obj_parent.base_pixel_x
		new_y = pixel_shift_vertical + obj_parent.base_pixel_y
	else
		new_w = pixel_shift_horizontal + obj_parent.base_pixel_w
		new_z = pixel_shift_vertical + obj_parent.base_pixel_x

	if(animate)
		// ensures the floating animation doesn't mess with our animation
		if(HAS_TRAIT(obj_parent, TRAIT_MOVE_FLOATING))
			ADD_TRAIT(obj_parent, TRAIT_NO_FLOATING_ANIM, UPDATE_OFFSET_TRAIT)
			addtimer(TRAIT_CALLBACK_REMOVE(obj_parent, TRAIT_NO_FLOATING_ANIM, UPDATE_OFFSET_TRAIT), 0.3 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)
		animate(obj_parent,
			pixel_w = new_w,
			pixel_x = new_x,
			pixel_y = new_y,
			pixel_z = new_z,
			flags = ANIMATION_PARALLEL,
			time = UPDATE_TRANSFORM_ANIMATION_TIME,
		)
	else
		obj_parent.pixel_x = new_x
		obj_parent.pixel_y = new_y
		obj_parent.pixel_w = new_w
		obj_parent.pixel_z = new_z

	shift_callback?.Invoke(proxy, obj_parent)
