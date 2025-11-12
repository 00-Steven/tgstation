/// Trait origin for traits applied by this component.
#define SIMPLE_SCRYER_TRAIT "simple_scryer"
/// Range for messages sent through simple scryers.
#define SIMPLE_SCRYER_MESSAGE_RANGE 3

/datum/action/item_action/call_link/simple_scryer
	name = "Call MODlink"

/// Simple scryer component, intended for turning equippable items into simple scryers.
/datum/component/simple_scryer
	dupe_mode = COMPONENT_DUPE_UNIQUE
	can_transfer = TRUE

	/// The installed power cell.
	var/obj/item/stock_parts/power_store/cell
	/// The MODlink datum we operate.
	var/datum/mod_link/mod_link
	/// An additional name tag for the scryer, seen as "[label] - ([scryer_type_name])"
	var/label
	/// The name for the scryer type, seen as "[label] - ([scryer_type_name])" or "Unlabeled [scryer_type_name]"
	var/scryer_type_name = "Scryer"

/datum/component/simple_scryer/Initialize(
	scryer_type_name,
	starting_frequency,
	starting_label,
	starting_cell_type,
)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/parent_item = parent

	mod_link = new(
		parent,
		starting_frequency,
		CALLBACK(src, PROC_REF(get_user)),
		CALLBACK(src, PROC_REF(can_call)),
		CALLBACK(src, PROC_REF(make_link_visual)),
		CALLBACK(src, PROC_REF(get_link_visual)),
		CALLBACK(src, PROC_REF(delete_link_visual))
	)

	if(scryer_type_name)
		src.scryer_type_name = scryer_type_name
	if(starting_cell_type)
		cell = new starting_cell_type(parent_item)
	set_label(starting_label)

	RegisterSignal(parent_item, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent_item, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(parent_item, COMSIG_MOVABLE_HEAR, PROC_REF(on_hear))
	var/datum/action/item_action/call_action = parent_item.add_item_action(/datum/action/item_action/call_link/simple_scryer)
	RegisterSignal(call_action, COMSIG_ACTION_TRIGGER, PROC_REF(on_action_trigger))
	// TODO: ADD EXAMINE
	// TODO: ADD CELL REMOVAL
	// TODO: ADD FREQUENCY CHANGE/COPY
	// TODO: ADD LABEL CHANGING

	START_PROCESSING(SSobj, src)
	parent_item.become_hearing_sensitive(SIMPLE_SCRYER_TRAIT)

/datum/component/simple_scryer/Destroy(force)
	QDEL_NULL(cell)
	QDEL_NULL(mod_link)
	STOP_PROCESSING(SSobj, src)
	REMOVE_TRAIT(parent, TRAIT_HEARING_SENSITIVE, SIMPLE_SCRYER_TRAIT)
	var/obj/item/parent_item = parent
	var/datum/action/item_action/call_action = locate(/datum/action/item_action/call_link/simple_scryer) in parent_item.actions
	parent_item.remove_item_action(call_action)
	return ..()

/datum/component/simple_scryer/process(seconds_per_tick)
	if(isnull(mod_link.link_call))
		return
	cell.use(MODLINK_STANDARD_DISCHARGE_RATE * seconds_per_tick, force = TRUE)


/datum/component/simple_scryer/proc/on_equip(atom/movable/source, mob/equipper, slot)
	SIGNAL_HANDLER
	var/obj/item/parent_item = parent
	if(!(parent_item.slot_flags & slot))
		mod_link?.end_call()

/datum/component/simple_scryer/proc/on_drop(atom/movable/source, mob/user)
	SIGNAL_HANDLER
	mod_link?.end_call()

/datum/component/simple_scryer/proc/on_hear(mob/living/owner, list/hearing_args)
	SIGNAL_HANDLER
	var/atom/movable/speaker = hearing_args[HEARING_SPEAKER]
	var/obj/item/parent_item = parent
	if(speaker != parent_item.loc)
		return
	mod_link.visual.say(hearing_args[HEARING_RAW_MESSAGE], spans = hearing_args[HEARING_SPANS], sanitize = FALSE, language = hearing_args[HEARING_LANGUAGE], message_range = SIMPLE_SCRYER_MESSAGE_RANGE, message_mods = hearing_args[HEARING_MESSAGE_MODE])

/datum/component/simple_scryer/proc/on_action_trigger(datum/action/source)
	SIGNAL_HANDLER
	if(mod_link.link_call)
		mod_link.end_call()
		return

	var/mob/living/user = get_user()
	if(isnull(user))
		return
	if(QDELETED(cell))
		user.balloon_alert(user, "no cell installed!")
		return
	if(!cell.charge)
		user.balloon_alert(user, "no charge!")
		return
	call_link(user, mod_link)


/datum/component/simple_scryer/proc/set_label(new_label)
	label = new_label
	mod_link.visual_name = label ? "[label] (Scryer)" : "Unlabeled Scryer"

/datum/component/simple_scryer/proc/get_user()
	var/obj/item/parent_item = parent
	if(!isliving(parent_item.loc))
		return null
	var/mob/living/user = parent_item.loc
	if(!(parent_item.slot_flags & user.get_slot_by_item(parent_item)))
		return null
	return user

/datum/component/simple_scryer/proc/can_call()
	var/obj/item/parent_item = parent
	if(isnull(cell))
		return FALSE
	if(!cell.charge)
		return FALSE
	if(!isliving(parent_item.loc))
		return FALSE
	var/mob/living/user = parent_item.loc
	if(user.stat >= DEAD)
		return FALSE
	return TRUE

/datum/component/simple_scryer/proc/make_link_visual()
	return make_link_visual_generic(mod_link, PROC_REF(on_overlay_change))

/datum/component/simple_scryer/proc/get_link_visual(atom/movable/visuals)
	return get_link_visual_simple(mod_link, visuals)

/datum/component/simple_scryer/proc/delete_link_visual(mob/living/old_user)
	return delete_link_visual_generic(mod_link, old_user)

/datum/component/simple_scryer/proc/on_overlay_change(atom/source, cache_index, overlay)
	SIGNAL_HANDLER
	addtimer(CALLBACK(src, PROC_REF(update_link_visual)), 1 TICKS, TIMER_UNIQUE)

/datum/component/simple_scryer/proc/update_link_visual()
	if(QDELETED(mod_link.link_call))
		return
	var/obj/item/parent_item = parent
	var/mob/living/user = parent_item.loc
	mod_link.visual.cut_overlay(mod_link.visual_overlays)
	mod_link.visual_overlays = user.overlays - user.active_thinking_indicator
	mod_link.visual.add_overlay(mod_link.visual_overlays)

/datum/component/simple_scryer/proc/on_user_set_dir(atom/source, dir, newdir)
	SIGNAL_HANDLER
	on_user_set_dir_generic(mod_link, newdir || SOUTH)


/// Custom get_link_visual implementation that registers its signals on us
/datum/component/simple_scryer/proc/get_link_visual_simple(datum/mod_link/mod_link, atom/movable/visuals)
	var/mob/living/user = mod_link.get_user_callback.Invoke()
	playsound(mod_link.holder, 'sound/machines/terminal/terminal_processing.ogg', 50, vary = TRUE)
	visuals.add_overlay(mutable_appearance('icons/effects/effects.dmi', "static_base", ABOVE_NORMAL_TURF_LAYER))
	visuals.add_overlay(mutable_appearance('icons/effects/effects.dmi', "modlink", ABOVE_ALL_MOB_LAYER))
	visuals.add_filter("crop_square", 1, alpha_mask_filter(icon = icon('icons/effects/effects.dmi', "modlink_filter")))
	visuals.maptext_height = 6
	visuals.alpha = 0
	user.vis_contents += visuals
	visuals.forceMove(user)
	animate(visuals, 0.5 SECONDS, alpha = 255)
	var/datum/callback/setdir_callback = CALLBACK(src, PROC_REF(on_user_set_dir))
	setdir_callback.Invoke(user, user.dir, user.dir)
	RegisterSignal(user, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_user_set_dir))

#undef SIMPLE_SCRYER_TRAIT
#undef SIMPLE_SCRYER_MESSAGE_RANGE