/*
CONTAINS:
BEDSHEETS
LINEN BINS
*/

/obj/item/bedsheet
	name = "bedsheet"
	desc = "A surprisingly soft linen bedsheet."
	icon = 'icons/obj/bedsheets.dmi'
	lefthand_file = 'icons/mob/inhands/items/bedsheet_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/bedsheet_righthand.dmi'
	icon_state = "sheetwhite"
	inhand_icon_state = "sheetwhite"
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound = 'sound/items/handling/cloth_pickup.ogg'
	slot_flags = ITEM_SLOT_NECK
	layer = BELOW_MOB_LAYER
	throwforce = 0
	throw_speed = 1
	throw_range = 2
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	dying_key = DYE_REGISTRY_BEDSHEET
	interaction_flags_click = NEED_DEXTERITY|ALLOW_RESTING

	dog_fashion = /datum/dog_fashion/head/ghost
	/// Custom nouns to act as the subject of dreams
	var/list/dream_messages = list("white")
	/// Cutting it up will yield this.
	var/stack_type = /obj/item/stack/sheet/cloth
	/// The number of sheets dropped by this bedsheet when cut
	var/stack_amount = 3
	/// Denotes if the bedsheet is a single, double, or other kind of bedsheet
	var/bedsheet_type = BEDSHEET_SINGLE
	/// Keeps track of the sheets we've precariously piled on top of each other
	var/list/stacked_sheets = list()
	var/datum/weakref/signal_sleeper //this is our goldylocks

/obj/item/bedsheet/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/surgery_initiator)
	AddElement(/datum/element/bed_tuckable, mapload, 0, 0, 0)
	if(bedsheet_type == BEDSHEET_DOUBLE)
		stack_amount *= 2
		dying_key = DYE_REGISTRY_DOUBLE_BEDSHEET
	register_context()
	register_item_context()

/obj/item/bedsheet/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(istype(held_item) && (held_item.tool_behaviour == TOOL_WIRECUTTER || held_item.get_sharpness()))
		context[SCREENTIP_CONTEXT_LMB] = "Shred into cloth"

	context[SCREENTIP_CONTEXT_ALT_LMB] = "Rotate"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/bedsheet/add_item_context(datum/source, list/context, mob/living/target)
	if(isliving(target) && target.body_position == LYING_DOWN)
		context[SCREENTIP_CONTEXT_RMB] = "Cover"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/obj/item/bedsheet/update_overlays()
	. = ..()

	var/sheet_offset = 0
	for(var/obj/item/bedsheet/stacked_sheet in stacked_sheets)
		sheet_offset += 3
		var/mutable_appearance/sheet_overlay = mutable_appearance(stacked_sheet.icon, stacked_sheet.icon_state, layer = layer + (sheet_offset * 0.01))
		sheet_overlay.pixel_y = sheet_offset
		. += sheet_overlay

/obj/item/bedsheet/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with))
		return NONE
	var/mob/living/to_cover = interacting_with
	if(to_cover.body_position != LYING_DOWN)
		return ITEM_INTERACT_BLOCKING

	// If there's an existing sheet stack, stack further
	var/obj/item/bedsheet/found_sheet_stack = find_existing_stack(user)
	if(found_sheet_stack)
		return found_sheet_stack.bedsheet_stack_act(user, src)

	// Otherwise, continue to covering
	if(!user.dropItemToGround(src))
		return ITEM_INTERACT_BLOCKING

	forceMove(get_turf(to_cover))
	balloon_alert(user, "covered")
	coverup(to_cover)
	add_fingerprint(user)

	return ITEM_INTERACT_SUCCESS

/obj/item/bedsheet/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/bedsheet))
		return bedsheet_stack_act(user, tool)

	// Handle wirecutters here so we still tear it up in combat mode
	if(tool.tool_behaviour != TOOL_WIRECUTTER && !tool.get_sharpness())
		return NONE

	// We cannot get free cloth from holograms
	if(flags_1 & HOLOGRAM_1)
		return ITEM_INTERACT_BLOCKING

	var/obj/item/stack/shreds = new stack_type(get_turf(src), stack_amount)
	if(!QDELETED(shreds)) // Stacks merged
		transfer_fingerprints_to(shreds)
		shreds.add_fingerprint(user)
	to_chat(user, span_notice("You tear [src] up."))
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/item/bedsheet/proc/bedsheet_stack_act(mob/living/user, obj/item/bedsheet/new_bedsheet)
	if(!isturf(loc))
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(new_bedsheet, src, silent = FALSE))
		return ITEM_INTERACT_BLOCKING
	stacked_sheets += new_bedsheet
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/item/bedsheet/proc/find_existing_stack(mob/living/sleeper)
	// First check for existing sheets to stack onto
	for(var/obj/item/bedsheet/possible_sheet in sleeper.loc?.contents)
		if(!istype(possible_sheet))
			continue
		var/mob/living/found_sleeper = possible_sheet.signal_sleeper?.resolve()
		if(sleeper == found_sleeper)
			return possible_sheet

/obj/item/bedsheet/attempt_pickup(mob/user, skip_grav)
	if(!stacked_sheets.len)
		return ..()
	var/obj/item/bedsheet/top_sheet = stacked_sheets[length(stacked_sheets)]
	top_sheet.attempt_pickup(user, skip_grav)
	if(!(top_sheet in contents))
		stacked_sheets -= top_sheet
		update_appearance()

/obj/item/bedsheet/attack_self(mob/living/user)
	if(!user.CanReach(src)) //No telekinetic grabbing.
		return
	if(user.body_position != LYING_DOWN)
		return
	if(!user.dropItemToGround(src))
		return

	var/obj/item/bedsheet/found_sheet_stack = find_existing_stack(user)
	if(found_sheet_stack) // If there's an existing sheet stack, stack further
		found_sheet_stack.bedsheet_stack_act(user, src)
	else // Otherwise, continue to covering
		coverup(user)
	add_fingerprint(user)

/obj/item/bedsheet/click_alt(mob/living/user)
	setDir(REVERSE_DIR(dir))
	return CLICK_ACTION_SUCCESS

///obj/item/bedsheet/CanAllowThrough(atom/movable/mover, border_dir)
//	. = ..()
//	message_admins("on_attempted_pass -<br>mover: [mover]<br>border_dir: [border_dir]<br>src: [src]")
//	if(!stacked_sheets.len)
//		message_admins("on_attempted_pass - first_if")
//		return .
//	if(signal_sleeper?.resolve() != mover)
//		message_admins("on_attempted_pass - second_if")
//		return .
//
//	var/stuck_prob = min(10 + stacked_sheets.len * 10, 100)
//	message_admins("on_attempted_pass - stuck_prob: [stuck_prob]")
//	if(!prob(stuck_prob))
//		message_admins("on_attempted_pass - prob_if")
//		return .
//
//	src.balloon_alert(mover, "stuck in bed!")
//	mover.Shake(duration = 0.1 SECONDS)
//	return FALSE

/obj/item/bedsheet/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	attempt_disperse_bedsheets()

/obj/item/bedsheet/proc/attempt_disperse_bedsheets()
	if(!stacked_sheets.len)
		return

	visible_message(span_warning("The bedsheets fall everywhere!"))
	var/stack_height = 1
	for(var/obj/item/bedsheet/stacked_sheet in stacked_sheets)
		var/fall_dir = pick(GLOB.alldirs)
		step(stacked_sheet, fall_dir)

		if(prob(10 * stack_height - 10)) // Sometimes move further, based on height
			step(stacked_sheet, fall_dir)

		stacked_sheet.do_tumble_effects(x, y, fall_dir, stack_height)
		stack_height++
		stacked_sheets -= stacked_sheet
	update_appearance()

/obj/item/bedsheet/proc/do_tumble_effects(origin_x, origin_y, fall_dir, stack_height)
	var/old_pixel_x = pixel_x
	var/old_pixel_y = pixel_y
	if(!(item_flags & NO_PIXEL_RANDOM_DROP))
		old_pixel_x = base_pixel_x + rand(-6, 6)
		old_pixel_y = base_pixel_y + rand(-6, 6)

	pixel_x = base_pixel_x + (origin_x * 32) - (x * 32)
	pixel_y = base_pixel_y + (origin_y * 32) - (y * 32) + stack_height * 3

	animate(
		src,
		pixel_x = old_pixel_x,
		pixel_y = old_pixel_y,
		time = 0.5 SECONDS,
		easing = CUBIC_EASING|EASE_OUT,
		flags = ANIMATION_PARALLEL,
	)
	SpinAnimation(0.5 SECONDS, 1, fall_dir & EAST)
	playsound(src, drop_sound, DROP_SOUND_VOLUME, ignore_walls = FALSE)

/obj/item/bedsheet/proc/coverup(mob/living/sleeper)
	layer = ABOVE_MOB_LAYER
	pixel_x = 0
	pixel_y = 0
	pixel_z = sleeper.pixel_z // Account for possible mob elevation
	update_appearance()
	balloon_alert(sleeper, "covered")
	var/angle = sleeper.lying_prev
	dir = angle2dir(angle + 180) // 180 flips it to be the same direction as the mob

	signal_sleeper = WEAKREF(sleeper)
	RegisterSignal(src, COMSIG_ITEM_PICKUP, PROC_REF(on_pickup))
	//RegisterSignal(src, COMSIG_ATOM_TRIED_PASS, PROC_REF(on_attempted_pass))
	RegisterSignal(src, COMSIG_ATOM_EXIT, PROC_REF(on_attempted_exit))
	RegisterSignal(sleeper, COMSIG_MOVABLE_MOVED, PROC_REF(smooth_sheets))
	RegisterSignal(sleeper, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(smooth_sheets))
	RegisterSignal(sleeper, COMSIG_QDELETING, PROC_REF(smooth_sheets))

	var/static/list/loc_connections = list(
			COMSIG_ATOM_EXIT = PROC_REF(on_attempted_exit),
		)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/bedsheet/proc/on_attempted_exit(datum/source, atom/movable/leaving, direction)
	message_admins("on_attempted_pass -<br>leaving: [leaving]<br>source: [source]<br>src: [src]")
	if(!stacked_sheets.len)
		message_admins("on_attempted_pass - first_if")
		return
	var/mob/living/sleeper = signal_sleeper?.resolve()
	if(sleeper != leaving)
		message_admins("on_attempted_pass - second_if")
		return

	var/stuck_prob = min(10 + stacked_sheets.len * 10, 100)
	message_admins("on_attempted_pass - stuck_prob: [stuck_prob]")
	if(!prob(stuck_prob))
		message_admins("on_attempted_pass - prob_if")
		return

	src.balloon_alert(sleeper, "stuck in bed!")
	sleeper.set_lying_angle(dir2angle(dir) - 180)
	sleeper.Shake(duration = 0.1 SECONDS)
	return COMPONENT_ATOM_BLOCK_EXIT

/obj/item/bedsheet/proc/on_attempted_pass(datum/source, mob/living/sleeper, border_dir)
	message_admins("on_attempted_pass -<br>sleeper: [sleeper]<br>source: [source]<br>src: [src]")
	if(!stacked_sheets.len)
		message_admins("on_attempted_pass - first_if")
		return COMSIG_COMPONENT_PERMIT_PASSAGE
	if(signal_sleeper?.resolve() != sleeper)
		message_admins("on_attempted_pass - second_if")
		return COMSIG_COMPONENT_PERMIT_PASSAGE

	var/stuck_prob = min(10 + stacked_sheets.len * 10, 100)
	message_admins("on_attempted_pass - stuck_prob: [stuck_prob]")
	if(!prob(stuck_prob))
		message_admins("on_attempted_pass - prob_if")
		return COMSIG_COMPONENT_PERMIT_PASSAGE

	src.balloon_alert(sleeper, "stuck in bed!")
	sleeper.Shake(duration = 0.1 SECONDS)
	return COMSIG_COMPONENT_REFUSE_PASSAGE

/obj/item/bedsheet/proc/smooth_sheets(mob/living/sleeper)
	SIGNAL_HANDLER

	UnregisterSignal(src, COMSIG_ITEM_PICKUP)
	//UnregisterSignal(src, COMSIG_ATOM_TRIED_PASS)
	UnregisterSignal(sleeper, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(sleeper, COMSIG_LIVING_SET_BODY_POSITION)
	UnregisterSignal(sleeper, COMSIG_QDELETING)
	RemoveElement(/datum/element/connect_loc)
	balloon_alert(sleeper, stacked_sheets.len ? "freedom!": "smoothed sheets")
	layer = initial(layer)
	SET_PLANE_IMPLICIT(src, initial(plane))
	pixel_z = 0
	update_appearance()
	signal_sleeper = null
	attempt_disperse_bedsheets()

// We need to do this in case someone picks up a bedsheet while a mob is covered up
// otherwise the bedsheet will disappear while in our hands if the sleeper signals get activated by moving
/obj/item/bedsheet/proc/on_pickup(datum/source, mob/grabber)
	SIGNAL_HANDLER

	var/mob/living/sleeper = signal_sleeper?.resolve()

	UnregisterSignal(src, COMSIG_ITEM_PICKUP)
	UnregisterSignal(src, COMSIG_ATOM_TRIED_PASS)
	UnregisterSignal(sleeper, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(sleeper, COMSIG_LIVING_SET_BODY_POSITION)
	UnregisterSignal(sleeper, COMSIG_QDELETING)
	RemoveElement(/datum/element/connect_loc)
	pixel_z = 0
	signal_sleeper = null

/obj/item/bedsheet/blue
	icon_state = "sheetblue"
	inhand_icon_state = "sheetblue"
	dream_messages = list("blue")

/obj/item/bedsheet/green
	icon_state = "sheetgreen"
	inhand_icon_state = "sheetgreen"
	dream_messages = list("green")

/obj/item/bedsheet/grey
	icon_state = "sheetgrey"
	inhand_icon_state = "sheetgrey"
	dream_messages = list("grey")

/obj/item/bedsheet/orange
	icon_state = "sheetorange"
	inhand_icon_state = "sheetorange"
	dream_messages = list("orange")

/obj/item/bedsheet/purple
	icon_state = "sheetpurple"
	inhand_icon_state = "sheetpurple"
	dream_messages = list("purple")

/obj/item/bedsheet/patriot
	name = "patriotic bedsheet"
	desc = "You've never felt more free than when sleeping on this."
	icon_state = "sheetUSA"
	inhand_icon_state = "sheetUSA"
	dream_messages = list("America", "freedom", "fireworks", "bald eagles")

/obj/item/bedsheet/rainbow
	name = "rainbow bedsheet"
	desc = "A multicolored blanket. It's actually several different sheets cut up and sewn together."
	icon_state = "sheetrainbow"
	inhand_icon_state = "sheetrainbow"
	dream_messages = list("red", "orange", "yellow", "green", "blue", "purple", "a rainbow")

/obj/item/bedsheet/red
	icon_state = "sheetred"
	inhand_icon_state = "sheetred"
	dream_messages = list("red")

/obj/item/bedsheet/yellow
	icon_state = "sheetyellow"
	inhand_icon_state = "sheetyellow"
	dream_messages = list("yellow")

/obj/item/bedsheet/mime
	name = "mime's blanket"
	desc = "A very soothing striped blanket.  All the noise just seems to fade out when you're under the covers in this."
	icon_state = "sheetmime"
	inhand_icon_state = "sheetmime"
	dream_messages = list("silence", "gestures", "a pale face", "a gaping mouth", "the mime")

/obj/item/bedsheet/clown
	name = "clown's blanket"
	desc = "A rainbow blanket with a clown mask woven in. It smells faintly of bananas."
	icon_state = "sheetclown"
	inhand_icon_state = "sheetrainbow"
	dream_messages = list("honk", "laughter", "a prank", "a joke", "a smiling face", "the clown")

/obj/item/bedsheet/captain
	name = "captain's bedsheet"
	desc = "It has a Nanotrasen symbol on it, and was woven with a revolutionary new kind of thread guaranteed to have 0.01% permeability for most non-chemical substances, popular among most modern captains."
	icon_state = "sheetcaptain"
	inhand_icon_state = "sheetcaptain"
	dream_messages = list("authority", "a golden ID", "sunglasses", "a green disc", "an antique gun", "the captain")

/obj/item/bedsheet/rd
	name = "research director's bedsheet"
	desc = "It appears to have a beaker emblem, and is made out of fire-resistant material, although it probably won't protect you in the event of fires you're familiar with every day."
	icon_state = "sheetrd"
	inhand_icon_state = "sheetrd"
	dream_messages = list("authority", "a silvery ID", "a bomb", "a mech", "a facehugger", "maniacal laughter", "the research director")

// for Free Golems.
/obj/item/bedsheet/rd/royal_cape
	name = "Royal Cape of the Liberator"
	desc = "Majestic."
	dream_messages = list("mining", "stone", "a golem", "freedom", "doing whatever")

/obj/item/bedsheet/medical
	name = "medical blanket"
	desc = "It's a 'sterilized' blanket commonly used in the Medbay."
	icon_state = "sheetmedical"
	inhand_icon_state = "sheetmedical"
	dream_messages = list("healing", "life", "surgery", "a doctor")

/obj/item/bedsheet/cmo
	name = "chief medical officer's bedsheet"
	desc = "It's a sterilized blanket that has a cross emblem. There's some cat fur on it, likely from Runtime."
	icon_state = "sheetcmo"
	inhand_icon_state = "sheetcmo"
	dream_messages = list("authority", "a silvery ID", "healing", "life", "surgery", "a cat", "the chief medical officer")

/obj/item/bedsheet/hos
	name = "head of security's bedsheet"
	desc = "It is decorated with a shield emblem. While crime doesn't sleep, you do, but you are still THE LAW!"
	icon_state = "sheethos"
	inhand_icon_state = "sheethos"
	dream_messages = list("authority", "a silvery ID", "handcuffs", "a baton", "a flashbang", "sunglasses", "the head of security")

/obj/item/bedsheet/hop
	name = "head of personnel's bedsheet"
	desc = "It is decorated with a key emblem. For those rare moments when you can rest and cuddle with Ian without someone screaming for you over the radio."
	icon_state = "sheethop"
	inhand_icon_state = "sheethop"
	dream_messages = list("authority", "a silvery ID", "obligation", "a computer", "an ID", "a corgi", "the head of personnel")

/obj/item/bedsheet/ce
	name = "chief engineer's bedsheet"
	desc = "It is decorated with a wrench emblem. It's highly reflective and stain resistant, so you don't need to worry about ruining it with oil."
	icon_state = "sheetce"
	inhand_icon_state = "sheetce"
	dream_messages = list("authority", "a silvery ID", "the engine", "power tools", "an APC", "a parrot", "the chief engineer")

/obj/item/bedsheet/qm
	name = "quartermaster's bedsheet"
	desc = "It is decorated with a crate emblem in silver lining.  It's rather tough, and just the thing to lie on after a hard day of pushing paper."
	icon_state = "sheetqm"
	inhand_icon_state = "sheetqm"
	dream_messages = list("authority", "a silvery ID", "a shuttle", "a crate", "a sloth", "the quartermaster")

/obj/item/bedsheet/chaplain
	name = "chaplain's blanket"
	desc = "A blanket woven with the hearts of gods themselves... Wait, that's just linen."
	icon_state = "sheetchap"
	inhand_icon_state = "sheetchap"
	dream_messages = list("a grey ID", "the gods", "a fulfilled prayer", "a cult", "the chaplain")

/obj/item/bedsheet/brown
	icon_state = "sheetbrown"
	inhand_icon_state = "sheetbrown"
	dream_messages = list("brown")

/obj/item/bedsheet/black
	icon_state = "sheetblack"
	inhand_icon_state = "sheetblack"
	dream_messages = list("black")

/obj/item/bedsheet/centcom
	name = "\improper CentCom bedsheet"
	desc = "Woven with advanced nanothread for warmth as well as being very decorated, essential for all officials."
	icon_state = "sheetcentcom"
	inhand_icon_state = "sheetcentcom"
	dream_messages = list("a unique ID", "authority", "artillery", "an ending")

/obj/item/bedsheet/syndie
	name = "syndicate bedsheet"
	desc = "It has a syndicate emblem and it has an aura of evil."
	icon_state = "sheetsyndie"
	inhand_icon_state = "sheetsyndie"
	dream_messages = list("a green disc", "a red crystal", "a glowing blade", "a wire-covered ID")

/obj/item/bedsheet/cult
	name = "cultist's bedsheet"
	desc = "You might dream of Nar'Sie if you sleep with this. It seems rather tattered and glows of an eldritch presence."
	icon_state = "sheetcult"
	inhand_icon_state = "sheetcult"
	dream_messages = list("a tome", "a floating red crystal", "a glowing sword", "a bloody symbol", "a massive humanoid figure")

/obj/item/bedsheet/wiz
	name = "wizard's bedsheet"
	desc = "A special fabric enchanted with magic so you can have an enchanted night. It even glows!"
	icon_state = "sheetwiz"
	inhand_icon_state = "sheetwiz"
	dream_messages = list("a book", "an explosion", "lightning", "a staff", "a skeleton", "a robe", "magic")

/obj/item/bedsheet/rev
	name = "revolutionary's bedsheet"
	desc = "A bedsheet stolen from a Central Command official's bedroom, used a symbol of triumph against Nanotrasen's tyranny. The golden emblem on the front has been scribbled out."
	icon_state = "sheetrev"
	inhand_icon_state = "sheetrev"
	dream_messages = list(
		"the people",
		"liberation",
		"collaboration",
		"heads rolling",
		"so, so many baseball bats",
		"blinding light",
		"your brothers in arms"
	)

/obj/item/bedsheet/nanotrasen
	name = "\improper Nanotrasen bedsheet"
	desc = "It has the Nanotrasen logo on it and has an aura of duty."
	icon_state = "sheetNT"
	inhand_icon_state = "sheetNT"
	dream_messages = list("authority", "an ending")

/obj/item/bedsheet/ian
	icon_state = "sheetian"
	inhand_icon_state = "sheetian"
	dream_messages = list("a dog", "a corgi", "woof", "bark", "arf")

/obj/item/bedsheet/runtime
	icon_state = "sheetruntime"
	inhand_icon_state = "sheetruntime"
	dream_messages = list("a kitty", "a cat", "meow", "purr", "nya~")

/obj/item/bedsheet/pirate
	name = "pirate's bedsheet"
	desc = "It has a Jolly Roger emblem on it and has a faint scent of grog."
	icon_state = "sheetpirate"
	inhand_icon_state = "sheetpirate"
	dream_messages = list(
		"a buried treasure",
		"an island",
		"a monkey",
		"a parrot",
		"a swashbuckler",
		"a talking skull",
		"avast",
		"being a pirate",
		"'cause a pirate is free",
		"doing whatever you want",
		"gold",
		"landlubbers",
		"stealing",
		"sailing the Seven Seas",
		"yarr",
	)

/obj/item/bedsheet/gondola
	name = "gondola bedsheet"
	desc = "A precious bedsheet made from the hide of a endangered and peculiar critter."
	icon_state = "sheetgondola"
	inhand_icon_state = "sheetgondola"
	dream_messages = list("peace", "comfiness", "a rare critter", "a harmless creature")
	stack_type = /obj/item/stack/sheet/animalhide/gondola
	stack_amount = 1
	///one of four icon states that represent its mouth
	var/gondola_mouth
	///one of four icon states that represent its eyes
	var/gondola_eyes

/obj/item/bedsheet/gondola/Initialize(mapload)
	. = ..()
	gondola_mouth = "sheetgondola_mouth[rand(1, 4)]"
	gondola_eyes = "sheetgondola_eyes[rand(1, 4)]"
	add_overlay(gondola_mouth)
	add_overlay(gondola_eyes)

/obj/item/bedsheet/gondola/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += mutable_appearance(icon_file, gondola_mouth)
		. += mutable_appearance(icon_file, gondola_eyes)

/obj/item/bedsheet/cosmos
	name = "cosmic space bedsheet"
	desc = "Made from the dreams of those who wonder at the stars."
	icon_state = "sheetcosmos"
	inhand_icon_state = "sheetcosmos"
	dream_messages = list("the infinite cosmos", "Hans Zimmer music", "a flight through space", "the galaxy", "being fabulous", "shooting stars")
	light_power = 2
	light_range = 1.4

/obj/item/bedsheet/double
	icon_state = "double_sheetwhite"
	worn_icon_state = "sheetwhite"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/blue/double
	icon_state = "double_sheetblue"
	worn_icon_state = "sheetblue"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/green/double
	icon_state = "double_sheetgreen"
	worn_icon_state = "sheetgreen"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/grey/double
	icon_state = "double_sheetgrey"
	worn_icon_state = "sheetgrey"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/orange/double
	icon_state = "double_sheetorange"
	worn_icon_state = "sheetorange"
	dying_key = DYE_REGISTRY_DOUBLE_BEDSHEET
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/purple/double
	icon_state = "double_sheetpurple"
	worn_icon_state = "sheetpurple"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/patriot/double
	icon_state = "double_sheetUSA"
	worn_icon_state = "sheetUSA"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/rainbow/double
	icon_state = "double_sheetrainbow"
	worn_icon_state = "sheetrainbow"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/red/double
	icon_state = "double_sheetred"
	worn_icon_state = "sheetred"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/yellow/double
	icon_state = "double_sheetyellow"
	worn_icon_state = "sheetyellow"
	dying_key = DYE_REGISTRY_DOUBLE_BEDSHEET
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/mime/double
	icon_state = "double_sheetmime"
	worn_icon_state = "sheetmime"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/clown/double
	icon_state = "double_sheetclown"
	worn_icon_state = "sheetclown"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/captain/double
	icon_state = "double_sheetcaptain"
	worn_icon_state = "sheetcaptain"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/rd/double
	icon_state = "double_sheetrd"
	worn_icon_state = "sheetrd"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/medical/double
	icon_state = "double_sheetmedical"
	worn_icon_state = "sheetmedical"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/cmo/double
	icon_state = "double_sheetcmo"
	worn_icon_state = "sheetcmo"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/hos/double
	icon_state = "double_sheethos"
	worn_icon_state = "sheethos"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/hop/double
	icon_state = "double_sheethop"
	worn_icon_state = "sheethop"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/ce/double
	icon_state = "double_sheetce"
	worn_icon_state = "sheetce"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/qm/double
	icon_state = "double_sheetqm"
	worn_icon_state = "sheetqm"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/chaplain/double
	icon_state = "double_sheetchap"
	worn_icon_state = "sheetchap"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/brown/double
	icon_state = "double_sheetbrown"
	worn_icon_state = "sheetbrown"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/black/double
	icon_state = "double_sheetblack"
	worn_icon_state = "sheetblack"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/centcom/double
	icon_state = "double_sheetcentcom"
	worn_icon_state = "sheetcentcom"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/syndie/double
	icon_state = "double_sheetsyndie"
	worn_icon_state = "sheetsyndie"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/cult/double
	icon_state = "double_sheetcult"
	worn_icon_state = "sheetcult"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/wiz/double
	icon_state = "double_sheetwiz"
	worn_icon_state = "sheetwiz"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/rev/double
	icon_state = "double_sheetrev"
	worn_icon_state = "sheetrev"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/nanotrasen/double
	icon_state = "double_sheetNT"
	worn_icon_state = "sheetNT"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/ian/double
	icon_state = "double_sheetian"
	worn_icon_state = "sheetian"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/runtime/double
	icon_state = "double_sheetruntime"
	worn_icon_state = "sheetruntime"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/cosmos/double
	icon_state = "double_sheetcosmos"
	worn_icon_state = "sheetcosmos"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/structure/bedsheetbin
	name = "linen bin"
	desc = "It looks rather cosy."
	icon = 'icons/obj/structures.dmi'
	icon_state = "linenbin-full"
	base_icon_state = "linenbin"
	anchored = TRUE
	pass_flags = PASSTABLE
	resistance_flags = FLAMMABLE
	max_integrity = 70
	anchored_tabletop_offset = 6
	/// The number of bedsheets in the bin
	var/amount = 10
	/// A list of actual sheets within the bin
	var/list/sheets = list()
	/// The object hiddin within the bedsheet bin
	var/obj/item/hidden = null

/obj/structure/bedsheetbin/empty
	amount = 0
	icon_state = "linenbin-empty"
	anchored = FALSE


/obj/structure/bedsheetbin/Initialize(mapload)
	. = ..()
	register_context()

/obj/structure/bedsheetbin/examine(mob/user)
	. = ..()
	if(amount < 1)
		. += "There are no bed sheets in the bin."
	else if(amount == 1)
		. += "There is one bed sheet in the bin."
	else
		. += "There are [amount] bed sheets in the bin."

/obj/structure/bedsheetbin/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(isnull(held_item))
		if(amount)
			context[SCREENTIP_CONTEXT_LMB] = "Take bedsheet"
			return CONTEXTUAL_SCREENTIP_SET
		return

	if(istype(held_item, /obj/item/bedsheet))
		context[SCREENTIP_CONTEXT_LMB] = "Put in"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_RMB] = "Disassemble"
		. = CONTEXTUAL_SCREENTIP_SET
	else if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_RMB] = "[anchored ? "Una" : "A"]nchor"
		. = CONTEXTUAL_SCREENTIP_SET

	if(amount && held_item.w_class < WEIGHT_CLASS_BULKY)
		context[SCREENTIP_CONTEXT_LMB] = "Hide item in"
		. = CONTEXTUAL_SCREENTIP_SET
	return .

/obj/structure/bedsheetbin/update_icon_state()
	switch(amount)
		if(0)
			icon_state = "[base_icon_state]-empty"
		if(1 to 5)
			icon_state = "[base_icon_state]-half"
		else
			icon_state = "[base_icon_state]-full"
	return ..()

/obj/structure/bedsheetbin/fire_act(exposed_temperature, exposed_volume)
	if(amount)
		amount = 0
		update_appearance()
	..()

/obj/structure/bedsheetbin/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	if(amount)
		to_chat(user, span_warning("The [src] must be empty first!"))
		return ITEM_INTERACT_SUCCESS
	if(tool.use_tool(src, user, 0.5 SECONDS, volume=50))
		to_chat(user, span_notice("You disassemble the [src]."))
		new /obj/item/stack/rods(loc, 2)
		qdel(src)
		return ITEM_INTERACT_SUCCESS

/obj/structure/bedsheetbin/wrench_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool, time = 0.5 SECONDS)
	return ITEM_INTERACT_SUCCESS

/obj/structure/bedsheetbin/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/bedsheet))
		return bedsheet_act(user, tool)

	// Everything else we try to hide
	return hide_item_act(user, tool)

/obj/structure/bedsheetbin/proc/bedsheet_act(mob/living/user, obj/item/tool)
	if(!user.transferItemToLoc(tool, src, silent = FALSE))
		return ITEM_INTERACT_BLOCKING
	sheets.Add(tool)
	amount++
	to_chat(user, span_notice("You put [tool] in [src]."))
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/structure/bedsheetbin/proc/hide_item_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return NONE
	if(tool.w_class >= WEIGHT_CLASS_BULKY)
		balloon_alert(user, "too big!")
		return ITEM_INTERACT_BLOCKING
	if(!amount)
		balloon_alert(user, "nothing to hide under!")
		return ITEM_INTERACT_BLOCKING
	if(hidden)
		balloon_alert(user, "already something there!")
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(tool, src, silent = FALSE))
		to_chat(user, span_warning("\The [tool] is stuck to your hand, you cannot hide it among the sheets!"))
		return ITEM_INTERACT_BLOCKING
	hidden = tool
	to_chat(user, span_notice("You hide [tool] among the sheets."))
	return ITEM_INTERACT_SUCCESS

/obj/structure/bedsheetbin/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/bedsheetbin/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(isliving(user))
		var/mob/living/L = user
		if(!(L.mobility_flags & MOBILITY_PICKUP))
			return
	if(amount >= 1)
		amount--

		var/obj/item/bedsheet/B
		if(sheets.len > 0)
			B = sheets[sheets.len]
			sheets.Remove(B)

		else
			B = new /obj/item/bedsheet(loc)

		B.forceMove(drop_location())
		user.put_in_hands(B)
		to_chat(user, span_notice("You take [B] out of [src]."))
		update_appearance()

		if(hidden)
			hidden.forceMove(drop_location())
			to_chat(user, span_notice("[hidden] falls out of [B]!"))
			hidden = null

	add_fingerprint(user)


/obj/structure/bedsheetbin/attack_tk(mob/user)
	if(amount >= 1)
		amount--

		var/obj/item/bedsheet/B
		if(sheets.len > 0)
			B = sheets[sheets.len]
			sheets.Remove(B)

		else
			B = new /obj/item/bedsheet(loc)

		B.forceMove(drop_location())
		to_chat(user, span_notice("You telekinetically remove [B] from [src]."))
		update_appearance()

		if(hidden)
			hidden.forceMove(drop_location())
			hidden = null

	add_fingerprint(user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/structure/bedsheetbin/basket
	name = "linen basket"
	icon_state = "linenbasket-full"
	base_icon_state = "linenbasket"

/obj/structure/bedsheetbin/empty/basket
	name = "linen basket"
	icon_state = "linenbasket-empty"
	base_icon_state = "linenbasket"
