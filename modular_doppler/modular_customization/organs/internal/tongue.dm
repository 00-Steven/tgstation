/// Bug tongue
//
/obj/item/organ/tongue/bug
	name = "bug tongue"
	desc = "A fleshy muscle mostly used for chittering."
	icon = 'icons/obj/medical/organs/fly_organs.dmi'
	say_mod = "chitters"

/// Cat tongue
//
/obj/item/organ/tongue/cat/Insert(mob/living/carbon/signer, special = FALSE, movement_flags = DELETE_IF_REPLACED)
	. = ..()
	signer.verb_ask = "mrrps"
	signer.verb_exclaim = "mrrowls"
	signer.verb_whisper = "purrs"
	signer.verb_yell = "yowls"

/obj/item/organ/tongue/cat/Remove(mob/living/carbon/speaker, special = FALSE, movement_flags)
	. = ..()
	speaker.verb_ask = initial(verb_ask)
	speaker.verb_exclaim = initial(verb_exclaim)
	speaker.verb_whisper = initial(verb_whisper)
	speaker.verb_yell = initial(verb_yell)

/// Dog tongue
//
/obj/item/organ/tongue/dog
	name = "dog tongue"
	desc = "A fleshy muscle mostly used for barking."
	say_mod = "woofs"

/obj/item/organ/tongue/dog/Insert(mob/living/carbon/signer, special = FALSE, movement_flags = DELETE_IF_REPLACED)
	. = ..()
	signer.verb_ask = "arfs"
	signer.verb_exclaim = "wans"
	signer.verb_whisper = "whimpers"
	signer.verb_yell = "barks"

/obj/item/organ/tongue/dog/Remove(mob/living/carbon/speaker, special = FALSE, movement_flags)
	. = ..()
	speaker.verb_ask = initial(verb_ask)
	speaker.verb_exclaim = initial(verb_exclaim)
	speaker.verb_whisper = initial(verb_whisper)
	speaker.verb_yell = initial(verb_yell)

/// Bird tongue
//
/obj/item/organ/tongue/bird
	name = "bird tongue"
	desc = "A fleshy muscle mostly used for chirping."
	say_mod = "chirps"

/obj/item/organ/tongue/bird/Insert(mob/living/carbon/speaker, special = FALSE, movement_flags = DELETE_IF_REPLACED)
	. = ..()
	speaker.verb_ask = "peeps"
	speaker.verb_exclaim = "squawks"
	speaker.verb_whisper = "murmurs"
	speaker.verb_yell = "shrieks"

/obj/item/organ/tongue/bird/Remove(mob/living/carbon/speaker, special = FALSE, movement_flags)
	. = ..()
	speaker.verb_ask = initial(verb_ask)
	speaker.verb_exclaim = initial(verb_exclaim)
	speaker.verb_whisper = initial(verb_whisper)
	speaker.verb_yell = initial(verb_yell)

/// Mouse tongue
//
/obj/item/organ/tongue/mouse
	name = "mouse tongue"
	desc = "A fleshy muscle mostly used for squeaking."
	say_mod = "squeaks"

/// Fish tongue
//
/obj/item/organ/tongue/fish
	name = "fish tongue"
	desc = "A fleshy muscle mostly used for gnashing."
	say_mod = "gnashes"

/// Frog tongue
//
/obj/item/organ/tongue/frog
	name = "frog tongue"
	desc = "A fleshy muscle mostly used for ribbiting."
	say_mod = "ribbits"
	actions_types = list(/datum/action/item_action/organ_action/toggle/frog_tongue)

	/// Our current fishing rod. Path put here gets initialized as an item.
	var/obj/item/fishing_rod/fishing_tongue = /obj/item/fishing_rod/frog_tongue
	/// Sound played when extending
	var/extend_sound = 'sound/vehicles/mecha/mechmove03.ogg'
	/// Sound played when retracting
	var/retract_sound = 'sound/vehicles/mecha/mechmove03.ogg'

/datum/action/item_action/organ_action/toggle/frog_tongue
	desc = "Extend your frog tongue and invoke your latent fishing powers."

/obj/item/organ/tongue/frog/Initialize(mapload)
	. = ..()

	fishing_tongue = new fishing_tongue(src)

/obj/item/organ/tongue/frog/ui_action_click()
	if((organ_flags & ORGAN_FAILING) || isnull(fishing_tongue))
		to_chat(owner, span_warning("The implant doesn't respond. It seems to be broken..."))
		return

	if(fishing_tongue in src)
		Extend()
	else
		Retract()

/obj/item/organ/tongue/frog/proc/Retract()
	if(isnull(fishing_tongue) || (fishing_tongue in src))
		return FALSE
	fishing_tongue.resistance_flags = fishing_tongue::resistance_flags
	if(owner)
		owner.visible_message(
			span_notice("[owner] retracts [owner.p_their()] tongue back into [owner.p_their()] mouth."),
			span_notice("Your tongue snaps back into your mouth."),
			span_hear("You hear a short slimy smack."),
		)

		owner.transferItemToLoc(fishing_tongue, src, TRUE)
	else
		fishing_tongue.forceMove(src)

	//UnregisterSignal(active_item, COMSIG_ITEM_ATTACK_SELF)
	//UnregisterSignal(active_item, COMSIG_ITEM_ATTACK_SELF_SECONDARY)
	playsound(get_turf(owner), retract_sound, 50, TRUE) // CHANGE SOUND
	return TRUE

/obj/item/organ/tongue/frog/proc/Extend()
	if(!(fishing_tongue in src))
		return FALSE

	fishing_tongue.resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	ADD_TRAIT(fishing_tongue, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	fishing_tongue.slot_flags = null
	//fishing_tongue.set_custom_materials(null) // this'd be funny though

	var/success = owner.put_in_active_hand(fishing_tongue, forced = TRUE)

	if(!success)
		var/obj/item/held_item = owner.get_active_held_item()
		to_chat(owner, span_warning("Your [held_item] interferes with [src]!"))
		return FALSE

	owner.visible_message(span_notice("[owner] extends [owner.p_their()] tongue from [owner.p_their()] mouth."),
		span_notice("You extend your tongue from your mouth."),
		span_hear("You hear a short slimy smack."))
	playsound(get_turf(owner), extend_sound, 50, TRUE)

	//if(length(items_list) > 1)
	//	RegisterSignals(active_item, list(COMSIG_ITEM_ATTACK_SELF, COMSIG_ITEM_ATTACK_SELF_SECONDARY), PROC_REF(swap_tools)) // secondary for welders
	return TRUE

/obj/item/fishing_rod/frog_tongue
	name = "extended frog tongue"
	desc = "A humble rod, made with whatever happened to be on hand."
	ui_description = "The tongue of an oversized frog."
	icon_state = "fishing_rod_bone"
	reel_overlay = "reel_bone"
	default_line_color = "red"
	line = /obj/item/fishing_line/auto_reel
	hook = /obj/item/fishing_hook/bone

/obj/item/fishing_rod/frog_tongue/hook_item(mob/user, atom/target_atom)
	. = ..()
	if(isnull(target_atom?.reagents))
		return
	var/mob/living/living_user = user
	if(!istype(user))
		return

	living_user.taste_container(target_atom.reagents)

