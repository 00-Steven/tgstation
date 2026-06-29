
/**
 * NEW ITEMS
 */

// TODO: ROBO COAT
// TODO: ROBO WORKCOAT
// TODO: make these available in vendor/garment bag
// TODO: Maybe make robotics get these two as new items, and a regular labcoat as well

/obj/item/clothing/suit/toggle/labcoat/robotics_coat
	name = "roboticist's coat"
	desc = "More like an eccentric coat than a labcoat. Helps pass off bloodstains as part of the aesthetic. Comes with red shoulder pads."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/suit/sci_suits.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/suit/sci_suits.dmi'
	icon_state = "coat_robo"

/obj/item/clothing/suit/toggle/labcoat/robotics_workcoat
	name = "roboticist's coveralls"
	desc = "More like an eccentric coat than a labcoat. Helps pass off bloodstains as part of the aesthetic. Comes with red shoulder pads."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/suit/sci_suits.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/suit/sci_suits.dmi'
	icon_state = "workcoat_robo"

/obj/item/clothing/suit/toggle/labcoat/robotics_workcoat/Initialize(mapload)
	. = ..()
	allowed += list( // TODO: maybe let this hold tools?
		/obj/item/storage/bag/xeno,
		/obj/item/melee/baton/telescopic,
	)


/**
 * OVERRIDES
 */

// TODO: work out the consequences of teshari stuff
// TODO: work out whether to let you alt-click reskin the RD/gene ones to blank?
// TODO: recolor and rename

/obj/item/clothing/suit/toggle/labcoat/research_director
	name = "research director's coat"
	desc = "A mix between a labcoat and just a regular coat. It's made out of a special antibacterial, anti-acidic, and anti-biohazardous synthetic fabric."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/suit/sci_suits.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/suit/sci_suits.dmi'
	icon_state = "labcoat_rd"

/obj/item/clothing/suit/toggle/labcoat/science
	name = "scientist's labcoat"
	desc = "A suit that protects against minor chemical spills. Has a purple stripe on the shoulder."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/suit/sci_suits.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/suit/sci_suits.dmi'
	icon_state = "labcoat_sci_1"
	post_init_icon_state = null
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_colors = null

/obj/item/clothing/suit/toggle/labcoat/roboticist
	name = "roboticist's labcoat"
	desc = "More like an eccentric coat than a labcoat. Helps pass off bloodstains as part of the aesthetic. Comes with red shoulder pads."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/suit/sci_suits.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/suit/sci_suits.dmi'
	icon_state = "labcoat_sci_2"
	post_init_icon_state = null
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_colors = null

/obj/item/clothing/suit/toggle/labcoat/genetics
	name = "geneticist's labcoat"
	desc = "A suit that protects against minor chemical spills. Has a blue stripe on the shoulder."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/suit/sci_suits.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/suit/sci_suits.dmi'
	icon_state = "labcoat_gene"
	post_init_icon_state = null
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_colors = null
