/obj/machinery/computer/cargo/express
	name = "express supply console"
	desc = "This console allows the user to purchase a package \
		with 1/40th of the delivery time: made possible by Nanotrasen's new \"1500mm Orbital Railgun\".\
		All sales are near instantaneous - please choose carefully"
	icon_screen = "supply_express"
	circuit = /obj/item/circuitboard/computer/cargo/express
	blockade_warning = "Bluespace instability detected. Delivery impossible."
	req_access = list(ACCESS_CARGO)
	is_express = TRUE
	interface_type = "CargoExpress"

	/// Warning message displayed in our UI.
	var/message
	/// Number of beacons printed. Used to determine beacon names.
	var/printed_beacons = 0
	/// Cached list of available supplypacks.
	var/list/meme_pack_data
	/// The linked supplypod beacon.
	var/obj/item/supplypod_beacon/beacon
	/// where we droppin boys (by default)
	var/area/default_landingzone = /area/station/cargo/storage
	/// Upgrade disk for determining which supplypod type to use.
	var/obj/item/disk/cargo/upgrade_disk
	var/podType = /obj/structure/closet/supplypod
	/// Cooldown between supplypod beacon prints, to prevent spam.
	var/cooldown = 0
	/// Is the console locked? Unlocked with valid ID.
	var/locked = TRUE
	// Are we targeting a beacon with our supplypods?
	var/usingBeacon = FALSE

/obj/machinery/computer/cargo/express/Initialize(mapload)
	. = ..()
	packin_up()

/obj/machinery/computer/cargo/express/on_construction(mob/user)
	. = ..()
	packin_up()

/obj/machinery/computer/cargo/express/process(seconds_per_tick)
	cooldown -= seconds_per_tick

/obj/machinery/computer/cargo/express/Destroy()
	if(beacon)
		beacon.unlink_console()
	return ..()

/obj/machinery/computer/cargo/express/dump_inventory_contents(list/subset)
	upgrade_disk = null
	. = ..()

/obj/machinery/computer/cargo/express/proc/get_pod_type(datum/supply_pack/pack)
	if(pack.special_pod)
		return pack.special_pod
	return upgrade_disk ? upgrade_disk.pod_type : /obj/structure/closet/supplypod

/obj/machinery/computer/cargo/express/proc/get_cost_multiplier() // bulk discount :^)
	return (obj_flags & EMAGGED) ? (0.72 * MAX_EMAG_ROCKETS) : 1

/obj/machinery/computer/cargo/express/proc/get_target_area()
	var/area/target_area_type = (obj_flags & EMAGGED) ? pick(GLOB.the_station_areas) : default_landingzone
	var/area/target_area = GLOB.areas_by_type[target_area_type]
	if(isnull(target_area))
		WARNING("[src] couldnt find [(obj_flags & EMAGGED) ? "any valid" : "a Quartermaster/Storage (aka cargobay)"] area on the station, and as such it has set the supplypod landingzone to the area it resides in.")
		target_area = get_area(src)
	return target_area

/obj/machinery/computer/cargo/express/item_interaction(mob/living/user, obj/item/tool, list/modifiers, is_right_clicking)
	. = ..()
	if(.)
		return .

	if(tool.GetID())
		. = id_act(user, tool)
	else if(istype(tool, /obj/item/disk/cargo))
		. = disk_act(user, tool)
	else if(istype(tool, /obj/item/supplypod_beacon))
		. = beacon_act(user, tool)

	return .

/// Called when we interact with the console with an ID (or item containing one), attempts to toggle the access lock.
/obj/machinery/computer/cargo/express/proc/id_act(mob/living/user, obj/item/card/id/swiped_card)
	if(!check_access(swiped_card))
		balloon_alert(user, "access denied!")
		return ITEM_INTERACT_BLOCKING
	locked = !locked
	to_chat(user, span_notice("You [locked ? "lock" : "unlock"] the interface."))
	return ITEM_INTERACT_SUCCESS

/// Called when we interact with the console with a supplypod upgrade disk, attempts to insert it and swaps out the old one.
/obj/machinery/computer/cargo/express/proc/disk_act(mob/living/user, obj/item/disk/cargo/inserted_disk)
	if(upgrade_disk)
		upgrade_disk.forceMove(drop_location())
	upgrade_disk = inserted_disk
	inserted_disk.forceMove(src)
	to_chat(user, span_notice("You insert the disk into [src], allowing for advanced supply delivery vehicles."))
	return ITEM_INTERACT_SUCCESS

/// Called when we interact with the console with a supplypod beacon, attempts to link it to our console.
/obj/machinery/computer/cargo/express/proc/beacon_act(mob/living/user, obj/item/supplypod_beacon/used_beacon)
	if(used_beacon.express_console == src)
		to_chat(user, span_alert("[src] is already linked to [used_beacon]."))
		return ITEM_INTERACT_BLOCKING
	used_beacon.link_console(src, user)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/computer/cargo/express/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	if(user)
		if(emag_card)
			user.visible_message(span_warning("[user] swipes [emag_card] through [src]!"))
		to_chat(user, span_notice("You change the routing protocols, allowing the Supply Pod to land anywhere on the station."))
	obj_flags |= EMAGGED
	contraband = TRUE
	// This also sets this on the circuit board
	var/obj/item/circuitboard/computer/cargo/board = circuit
	board.obj_flags |= EMAGGED
	board.contraband = TRUE
	packin_up()
	return TRUE

/obj/machinery/computer/cargo/express/proc/packin_up() // oh shit, I'm sorry
	meme_pack_data = list() // sorry for what?
	for(var/pack_id in SSshuttle.supply_packs) // our quartermaster taught us not to be ashamed of our supply packs
		var/datum/supply_pack/pack = SSshuttle.supply_packs[pack_id]  // specially since they're such a good price and all
		if(!meme_pack_data[pack.group]) // yeah, I see that, your quartermaster gave you good advice
			meme_pack_data[pack.group] = list( // it gets cheaper when I return it
				"name" = pack.group, // mmhm
				"packs" = list()  // sometimes, I return it so much, I rip the manifest
			) // see, my quartermaster taught me a few things too
		if((pack.hidden) || (pack.special)) // like, how not to rip the manifest
			continue // by using someone else's crate
		if(pack.contraband && !contraband) // will you show me?
			continue // i'd be right happy to
		meme_pack_data[pack.group]["packs"] += list(list(
			"name" = pack.name,
			"cost" = pack.get_cost() * get_cost_multiplier(),
			"id" = pack_id,
			"desc" = pack.desc || pack.name // If there is a description, use it. Otherwise use the pack's name.
		))

/// Called on ui_act, uses the cargo budget to print a supplypod beacon
/obj/machinery/computer/cargo/express/proc/print_beacon(mob/user)
	var/datum/bank_account/used_account = SSeconomy.get_dep_account(cargo_account)
	if(isnull(used_account))
		return

	if(!used_account.adjust_money(-BEACON_COST))
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		say("ERROR: Insufficient funds to purchase beacon.")
		return

	// A ~ten second cooldown for printing beacons to prevent spam
	COOLDOWN_START(src, cooldown, 10 SECONDS)
	var/obj/item/supplypod_beacon/new_beacon = new /obj/item/supplypod_beacon(drop_location())
	// Rather than in beacon's Initialize(), we can assign the computer to the beacon by reusing this proc
	new_beacon.link_console(src, user)
	// Printed_beacons starts at 0, so the first one out will be called beacon # 1
	printed_beacons++ 
	beacon.name = "Supply Pod Beacon #[printed_beacons]"

/obj/machinery/computer/cargo/express/proc/attempt_order(mob/user, id)
	if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_EXPRESSPOD_CONSOLE))
		say("Railgun recalibrating. Stand by.")
		return
	id = text2path(id) || id
	var/datum/supply_pack/pack = SSshuttle.supply_packs[id]
	if(!istype(pack))
		CRASH("Unknown supply pack id given by express order console ui. ID: [id]")
	var/name = "*None Provided*"
	var/rank = "*None Provided*"
	var/ckey = user.ckey
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		name = human_user.get_authentification_name()
		rank = human_user.get_assignment(hand_first = TRUE)
	else if(HAS_SILICON_ACCESS(user))
		name = user.real_name
		rank = "Silicon"
	var/reason = ""

	if(usingBeacon)
		if(isnull(beacon))
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
			say("BEACON ERROR: Beacon signal unavailable. Recalibrating to default area.")
			usingBeacon = FALSE
			return
		if(!isturf(beacon.loc) && !ismob(beacon.loc))
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
			say("BEACON ERROR: Beacon must be exposed.")
			return

	var/datum/supply_order/new_order = new(pack, name, rank, ckey, reason)
	var/pack_cost = new_order.pack.get_cost() * get_cost_multiplier()
	var/emagged = obj_flags & EMAGGED
	var/pod_count = emagged ? MAX_EMAG_ROCKETS : 1
	var/datum/bank_account/used_account = SSeconomy.get_dep_account(cargo_account)
	if(isnull(used_account))
		return

	if(!used_account.adjust_money(-pack_cost))
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		say("ERROR: Insufficient funds to purchase supply pack.")
		return

	TIMER_COOLDOWN_START(src, COOLDOWN_EXPRESSPOD_CONSOLE, 5 SECONDS)

	// Target priorities: emag > beacon > default > our area
	var/area/target_area
	var/list/empty_turfs
	if(!emagged && usingBeacon)
		LAZYADD(empty_turfs, get_turf(beacon))
		beacon.update_status(SP_LAUNCH)
	else
		target_area = get_target_area()

	if(target_area)
		for(var/turf/open/floor/turf in target_area.get_turfs_from_all_zlevels())
			if(turf.is_blocked_turf())
				continue
			LAZYADD(empty_turfs, turf)
			CHECK_TICK

	if(isnull(empty_turfs) || empty_turfs.len < pod_count)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		say("ERROR: Insufficient space for delivery in target area. Refunding.")
		used_account.adjust_money(pack_cost)
		return

	new_order.generateRequisition(drop_location())
	for(var/i in 1 to pod_count)
		var/landing_zone = pick(empty_turfs)
		LAZYREMOVE(empty_turfs, landing_zone)
		new /obj/effect/pod_landingzone(landing_zone, get_pod_type(new_order.pack), new_order)
		. = TRUE
		update_appearance()
		CHECK_TICK

/obj/machinery/computer/cargo/express/ui_data(mob/user)
	var/canBeacon = beacon && (isturf(beacon.loc) || ismob(beacon.loc))//is the beacon in a valid location?
	var/list/data = list()
	var/datum/bank_account/D = SSeconomy.get_dep_account(cargo_account)
	if(D)
		data["points"] = D.account_balance
	data["locked"] = locked//swipe an ID to unlock
	data["siliconUser"] = HAS_SILICON_ACCESS(user)
	data["beaconzone"] = beacon ? get_area(beacon) : ""//where is the beacon located? outputs in the tgui
	data["usingBeacon"] = usingBeacon //is the mode set to deliver to the beacon or the cargobay?
	data["canBeacon"] = !usingBeacon || canBeacon //is the mode set to beacon delivery, and is the beacon in a valid location?
	var/beacon_cd_finished = COOLDOWN_FINISHED(src, cooldown)
	data["canBuyBeacon"] = beacon_cd_finished && D.account_balance >= BEACON_COST
	data["beaconError"] = usingBeacon && !canBeacon ? "(BEACON ERROR)" : ""//changes button text to include an error alert if necessary
	data["hasBeacon"] = beacon != null//is there a linked beacon?
	data["beaconName"] = beacon ? beacon.name : "No Beacon Found"
	data["printMsg"] = beacon_cd_finished ? "Print Beacon for [BEACON_COST] credits" : "Print Beacon for [BEACON_COST] credits ([DisplayTimeText(COOLDOWN_TIMELEFT(src, cooldown))])" //buttontext for printing beacons
	data["supplies"] = list()
	message = "Sales are near-instantaneous - please choose carefully."
	if(SSshuttle.supply_blocked)
		message = blockade_warning
	if(usingBeacon && !beacon)
		message = "BEACON ERROR: BEACON MISSING"//beacon was destroyed
	else if (usingBeacon && !canBeacon)
		message = "BEACON ERROR: MUST BE EXPOSED"//beacon's loc/user's loc must be a turf
	if(obj_flags & EMAGGED)
		message = "(&!#@ERROR: R0UTING_#PRO7O&OL MALF(*CT#ON. $UG%ESTE@ ACT#0N: !^/PULS3-%E)ET CIR*)ITB%ARD."
	data["message"] = message
	if(!meme_pack_data)
		packin_up()
		stack_trace("There was no pack data for [src]")
	data["supplies"] = meme_pack_data
	return data

/obj/machinery/computer/cargo/express/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("LZCargo")
			usingBeacon = FALSE
			if(beacon)
				beacon.update_status(SP_UNREADY) //ready light on beacon will turn off
		if("LZBeacon")
			usingBeacon = TRUE
			if(beacon)
				beacon.update_status(SP_READY) //turns on the beacon's ready light
		if("printBeacon")
			if(COOLDOWN_FINISHED(src, cooldown)) // We do not trust the client to not try to print anyway.
				print_beacon(ui.user)
		if("add") // Generate Supply Order first
			attempt_order(ui.user, params["id"])
