
/**
 * HEAD OF STAFF ITEMS
 */

/obj/item/door_remote/research_director
	icon = 'modular_doppler/misc_department_recolor/icons/obj/devices/remote.dmi'

/obj/item/stamp/head/rd
	icon = 'modular_doppler/misc_department_recolor/icons/obj/stamps.dmi'

/**
 * ENCRYPTION KEYS
 */

/obj/item/encryptionkey/heads/rd
	post_init_icon_state = "cypherkey_research"
	greyscale_config = /datum/greyscale_config/encryptionkey_research
	greyscale_colors = "#0F333E#335275"

/obj/item/encryptionkey/headset_sci
	post_init_icon_state = "cypherkey_research"
	greyscale_config = /datum/greyscale_config/encryptionkey_research

	greyscale_colors = "#335275#496F88"

/obj/item/encryptionkey/headset_rob
	post_init_icon_state = "cypherkey_engineering"
	greyscale_config = /datum/greyscale_config/encryptionkey_engineering
	greyscale_colors = "#36353E#496F88"

/**
 * JOB ITEMS
 */

/obj/item/experi_scanner
	icon = 'modular_doppler/misc_department_recolor/icons/obj/devices/scanner.dmi'

/obj/item/slime_scanner
	icon = 'modular_doppler/misc_department_recolor/icons/obj/devices/scanner.dmi'
