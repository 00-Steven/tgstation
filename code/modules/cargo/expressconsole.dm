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
	/// where we droppin boys
	var/area/landingzone = /area/station/cargo/storage
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

/obj/machinery/computer/cargo/express/Destroy()
	if(beacon)
		beacon.unlink_console()
	return ..()

/obj/machinery/computer/cargo/express/dump_inventory_contents(list/subset)
	upgrade_disk = null
	. = ..()

/obj/machinery/computer/cargo/express/proc/get_pod_type()
	return upgrade_disk ? upgrade_disk.pod_type : /obj/structure/closet/supplypod

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
	for(var/pack in SSshuttle.supply_packs) // our quartermaster taught us not to be ashamed of our supply packs
		var/datum/supply_pack/P = SSshuttle.supply_packs[pack]  // specially since they're such a good price and all
		if(!meme_pack_data[P.group]) // yeah, I see that, your quartermaster gave you good advice
			meme_pack_data[P.group] = list( // it gets cheaper when I return it
				"name" = P.group, // mmhm
				"packs" = list()  // sometimes, I return it so much, I rip the manifest
			) // see, my quartermaster taught me a few things too
		if((P.hidden) || (P.special)) // like, how not to rip the manifest
			continue// by using someone else's crate
		if(P.contraband && !contraband) // will you show me?
			continue // i'd be right happy to
		meme_pack_data[P.group]["packs"] += list(list(
			"name" = P.name,
			"cost" = P.get_cost(),
			"id" = pack,
			"desc" = P.desc || P.name // If there is a description, use it. Otherwise use the pack's name.
		))

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
	data["canBuyBeacon"] = cooldown <= 0 && D.account_balance >= BEACON_COST
	data["beaconError"] = usingBeacon && !canBeacon ? "(BEACON ERROR)" : ""//changes button text to include an error alert if necessary
	data["hasBeacon"] = beacon != null//is there a linked beacon?
	data["beaconName"] = beacon ? beacon.name : "No Beacon Found"
	data["printMsg"] = cooldown > 0 ? "Print Beacon for [BEACON_COST] credits ([cooldown])" : "Print Beacon for [BEACON_COST] credits"//buttontext for printing beacons
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
	if (cooldown > 0)//cooldown used for printing beacons
		cooldown--
	return data

/obj/machinery/computer/cargo/express/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("LZCargo")
			usingBeacon = FALSE
			if (beacon)
				beacon.update_status(SP_UNREADY) //ready light on beacon will turn off
		if("LZBeacon")
			usingBeacon = TRUE
			if (beacon)
				beacon.update_status(SP_READY) //turns on the beacon's ready light
		if("printBeacon")
			var/datum/bank_account/D = SSeconomy.get_dep_account(cargo_account)
			if(D)
				if(D.adjust_money(-BEACON_COST))
					cooldown = 10//a ~ten second cooldown for printing beacons to prevent spam
					var/obj/item/supplypod_beacon/C = new /obj/item/supplypod_beacon(drop_location())
					C.link_console(src, usr)//rather than in beacon's Initialize(), we can assign the computer to the beacon by reusing this proc)
					printed_beacons++//printed_beacons starts at 0, so the first one out will be called beacon # 1
					beacon.name = "Supply Pod Beacon #[printed_beacons]"


		if("add")//Generate Supply Order first
			if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_EXPRESSPOD_CONSOLE))
				say("Railgun recalibrating. Stand by.")
				return
			var/id = params["id"]
			id = text2path(id) || id
			var/datum/supply_pack/pack = SSshuttle.supply_packs[id]
			if(!istype(pack))
				CRASH("Unknown supply pack id given by express order console ui. ID: [params["id"]]")
			var/name = "*None Provided*"
			var/rank = "*None Provided*"
			var/ckey = usr.ckey
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				name = H.get_authentification_name()
				rank = H.get_assignment(hand_first = TRUE)
			else if(HAS_SILICON_ACCESS(usr))
				name = usr.real_name
				rank = "Silicon"
			var/reason = ""
			var/list/empty_turfs
			var/datum/supply_order/SO = new(pack, name, rank, ckey, reason)
			var/points_to_check
			var/datum/bank_account/D = SSeconomy.get_dep_account(cargo_account)
			if(D)
				points_to_check = D.account_balance
			if(!(obj_flags & EMAGGED))
				if(SO.pack.get_cost() <= points_to_check)
					var/LZ
					if (istype(beacon) && usingBeacon)//prioritize beacons over landing in cargobay
						LZ = get_turf(beacon)
						beacon.update_status(SP_LAUNCH)
					else if (!usingBeacon)//find a suitable supplypod landing zone in cargobay
						landingzone = GLOB.areas_by_type[/area/station/cargo/storage]
						if (!landingzone)
							WARNING("[src] couldnt find a Quartermaster/Storage (aka cargobay) area on the station, and as such it has set the supplypod landingzone to the area it resides in.")
							landingzone = get_area(src)
						for(var/turf/open/floor/T in landingzone.get_turfs_from_all_zlevels())//uses default landing zone
							if(T.is_blocked_turf())
								continue
							LAZYADD(empty_turfs, T)
							CHECK_TICK
						if(empty_turfs?.len)
							LZ = pick(empty_turfs)
					if (SO.pack.get_cost() <= points_to_check && LZ)//we need to call the cost check again because of the CHECK_TICK call
						TIMER_COOLDOWN_START(src, COOLDOWN_EXPRESSPOD_CONSOLE, 5 SECONDS)
						D.adjust_money(-SO.pack.get_cost())
						if(pack.special_pod)
							new /obj/effect/pod_landingzone(LZ, pack.special_pod, SO)
						else
							new /obj/effect/pod_landingzone(LZ, get_pod_type(), SO)
						. = TRUE
						update_appearance()
			else
				if(SO.pack.get_cost() * (0.72*MAX_EMAG_ROCKETS) <= points_to_check) // bulk discount :^)
					landingzone = GLOB.areas_by_type[pick(GLOB.the_station_areas)]  //override default landing zone
					for(var/turf/open/floor/T in landingzone.get_turfs_from_all_zlevels())
						if(T.is_blocked_turf())
							continue
						LAZYADD(empty_turfs, T)
						CHECK_TICK
					if(empty_turfs?.len)
						TIMER_COOLDOWN_START(src, COOLDOWN_EXPRESSPOD_CONSOLE, 10 SECONDS)
						D.adjust_money(-(SO.pack.get_cost() * (0.72*MAX_EMAG_ROCKETS)))

						SO.generateRequisition(get_turf(src))
						for(var/i in 1 to MAX_EMAG_ROCKETS)
							var/LZ = pick(empty_turfs)
							LAZYREMOVE(empty_turfs, LZ)
							if(pack.special_pod)
								new /obj/effect/pod_landingzone(LZ, pack.special_pod, SO)
							else
								new /obj/effect/pod_landingzone(LZ, get_pod_type(), SO)
							. = TRUE
							update_appearance()
							CHECK_TICK

