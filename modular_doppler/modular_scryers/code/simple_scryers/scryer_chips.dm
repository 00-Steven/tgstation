
/obj/item/scryer_chip
	name = "abstract scryerchip"
	desc = ""
	icon = 'icons/obj/devices/circuitry_n_data.dmi'
	icon_state = "component"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	custom_materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT)
	w_class = WEIGHT_CLASS_SMALL
	abstract_type = /obj/item/scryer_chip

	/// The base typepath we can target and turn into a simple scryer.
	var/obj/item/clothing/target_clothing_type
	/// The name we use for the scryer type in the call menu.
	var/scryer_type_name
	/// The MODlink frequency we apply, if any.
	var/starting_frequency
	/// The MODlink label we apply, if any.
	var/starting_label
	/// The type of cell we start with, if any.
	var/obj/item/stock_parts/power_store/starting_cell_type

/obj/item/scryer_chip/Initialize(mapload)
	. = ..()
	register_item_context()

/obj/item/scryer_chip/examine(mob/user)
	. = ..()
	if(starting_frequency)
		. += span_notice("It's linked to the '[starting_frequency]' frequency.")
	if(starting_cell_type)
		. += span_notice("It comes with a [starting_cell_type::name].")

/obj/item/scryer_chip/add_item_context(obj/item/source, list/context, atom/target, mob/living/user)
	if(!istype(target, target_clothing_type))
		return NONE
	context[SCREENTIP_CONTEXT_LMB] = "Insert Scryerchip"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/scryer_chip/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, target_clothing_type))
		return NONE
	playsound(interacting_with, 'sound/machines/click.ogg', 50, vary = TRUE)
	interacting_with.AddComponent(/datum/component/simple_scryer, scryer_type_name, starting_frequency, starting_label, starting_cell_type)
	qdel(src)


/obj/item/scryer_chip/glasses
	name = "glasses scryerchip"
	desc = ""
	target_clothing_type = /obj/item/clothing/glasses
	scryer_type_name = "glasses"

/obj/item/scryer_chip/glasses/loaded
	starting_cell_type = /obj/item/stock_parts/power_store/cell/high

/obj/item/scryer_chip/glasses/loaded/crew
	starting_frequency = MODLINK_FREQ_NANOTRASEN
