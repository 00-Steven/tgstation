
/**
 * NEW ITEMS
 */

/obj/item/clothing/head/beret/science/fancy
	name = "badged science beret"
	desc = "A science-blue beret for our hardworking scientists. This one comes with a fancy badge!"
	icon_state = "/obj/item/clothing/head/beret/science/fancy"
	post_init_icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#335275#8f8383"

/obj/item/clothing/head/beret/science/fancy/robo
	name = "robotics beret"
	desc = "A sleek black beret designed with high-durability nano-mesh fiber - or so the roboticists claim."
	icon_state = "/obj/item/clothing/head/beret/science/fancy/robo"
	greyscale_colors = "#36353E#496F88"

/**
 * OVERRIDES
 */

/obj/item/clothing/head/beret/science
	name = "science beret"
	desc = "A science-blue beret for our hardworking scientists."
	greyscale_colors = "#335275"

/obj/item/clothing/head/beret/science/rd
	name = "research director's beret"
	desc = "A science-blue beret with the insignia of the Research Director attached. For the paper-shuffler in you!"
	greyscale_colors = "#335275#8f8383"
