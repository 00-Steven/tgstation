
/**
 * NEW ITEMS
 */

/obj/item/clothing/under/rank/rnd/scientist_med
	name = "medical scientist's jumpsuit"
	desc = "It's made of a special fiber that provides minor protection against explosives. It has markings that denote the wearer as a scientist."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/under/sci_under.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/under/sci_under.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	supported_bodyshapes = list(BODYSHAPE_HUMANOID, BODYSHAPE_DIGITIGRADE)
	bodyshape_icon_files = list(
		BODYSHAPE_HUMANOID_T = 'modular_doppler/modular_cosmetics/icons/mob/under/sci_under.dmi',
		BODYSHAPE_DIGITIGRADE_T = 'modular_doppler/modular_cosmetics/icons/mob/under/sci_under_digi.dmi',
	)
	icon_state = "jumpsuit_sci_alt"
	inhand_icon_state = "b_suit"
	armor_type = /datum/armor/clothing_under/science

/obj/item/clothing/under/rank/rnd/scientist_med/skirt
	name = "medical scientist's jumpskirt"
	icon_state = "jumpsuit_sci_alt_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/rnd/research_director/jumpsuit
	name = "research director's jumpsuit"
	desc = "A Nanotrasen-purple turtleneck and black jeans, for a director with a superior sense of style."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/under/sci_under.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/under/sci_under.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	supported_bodyshapes = list(BODYSHAPE_HUMANOID, BODYSHAPE_DIGITIGRADE)
	bodyshape_icon_files = list(
		BODYSHAPE_HUMANOID_T = 'modular_doppler/modular_cosmetics/icons/mob/under/sci_under.dmi',
		BODYSHAPE_DIGITIGRADE_T = 'modular_doppler/modular_cosmetics/icons/mob/under/sci_under_digi.dmi',
	)
	icon_state = "jumpsuit_rd"
	inhand_icon_state = "b_suit"
	can_adjust = TRUE
	alt_covers_chest = FALSE

/obj/item/clothing/under/rank/rnd/research_director/jumpsuit/skirt
	name = "research director's jumpskirt"
	desc = "A Nanotrasen-purple turtleneck and a black skirt, for a director with a superior sense of style."
	icon_state = "jumpsuit_rd_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION


/**
 * OVERRIDES
 */

// DONE:
// TODO: techfabs & circuitss
// TODO: recolour PDAs
// TODO: recolour experi-scanner
// TODO: slime scanner
// TODO: recolour sci IDs
// TODO: recolour sci ID trims
// TODO: recolour sci job icons if at all possible
// TODO: recolour slime processor
// TODO: recolour monkey recycler
// TODO: add fancy science beret to vendors?
// TODO: recolour sci vendor
// TODO: recolour robo vendor
// TODO: recolour gene vendor
// TODO: recolour sci command hardhat
// TODO: recolour sci command beret
// TODO: recolour sci command mantle
// TODO: recolour sci bandana
// TODO: recolour robo beret
// TODO: recolour cytopro vendor
// TODO: recolour sci/RD encryption keys
// TODO: recolour quantum keycard
// TODO: change channel colour (like examining headsets)
// TODO: change telecomms colour
// TODO: change job prefs menu colour
// TODO: change latejoin menu colour
// TODO: change uniforms/vendors to use black shoes.
// TODO: check crew monitor/records...?
// TODO: change tgui colour (like when you use the radio on tgui say)
// TODO: change manifest colour

// TEST:
// TODO: recolor tram control
// TODO: orbit color....? you can sort by departments
// TODO: rename RD's beret
// TODO: recolour job straps
// TODO: recolour RD stamp

// DOING:
// TODO: recolour RD locker

// DO:
// TODO: work out the consequences of teshari stuff
// TODO: redesc and rename allat
// TODO: recolour sci/robo/gene/rd headset
// TODO: recolour RD stamp on tg paperwork (/obj/item/paperwork/research)
// TODO: recolour sci department jacket
// TODO: recolour sci crates?
// TODO: recolour robo crates?
// TODO: recolour science bag (use genetics colors?)
// TODO: recolour bio hood/suit (use genetics colors)
// TODO: recolour sci doors?
// TODO: recolour sci consoles
// TODO: recolour sci director's cloak
// TODO: recolour flesh reshaper? (use genetics colors?)
// TODO: recolour biohazard lockers (use genetics colors)
// TODO: recolour sci lockers (/obj/structure/closet/secure_closet/cytology)
// TODO: sprite backpack onmobs
// TODO: resprite backpacks
// TODO: gene backpack recolored
// TODO: remove custom backpacks from robo vendor, add sci backpacks to robo vendor
// TODO: ordnance data disk
// TODO: recolour various hud glasses/implants
// TODO: consider changing the tile colours with a doppler edit
// TODO: change COLOR_JOB_SCI_GENERIC (used for loadout auto-job-colouring)
// TODO: check which items have weird digi sprites
// TODO: research director modsuit
// TODO: add robotics coveralls/such to wardrobes


/obj/item/clothing/under/rank/rnd/research_director/turtleneck
	name = "research director's turtleneck"
	desc = "A Nanotrasen-purple turtleneck and black jeans, for a director with a superior sense of style."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/under/sci_under.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/under/sci_under.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	supported_bodyshapes = list(BODYSHAPE_HUMANOID, BODYSHAPE_DIGITIGRADE)
	bodyshape_icon_files = list(
		BODYSHAPE_HUMANOID_T = 'modular_doppler/modular_cosmetics/icons/mob/under/sci_under.dmi',
		BODYSHAPE_DIGITIGRADE_T = 'modular_doppler/modular_cosmetics/icons/mob/under/sci_under_digi.dmi',
	)
	icon_state = "turtleneck_rd"
	inhand_icon_state = "b_suit"
	can_adjust = TRUE
	alt_covers_chest = FALSE

/obj/item/clothing/under/rank/rnd/research_director/turtleneck/skirt
	name = "research director's turtleneck skirt"
	desc = "A Nanotrasen-purple turtleneck and a black skirt, for a director with a superior sense of style."
	icon_state = "turtleneck_rd_skirt"
	dying_key = DYE_REGISTRY_JUMPSKIRT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION


/obj/item/clothing/under/rank/rnd/scientist
	name = "scientist's jumpsuit"
	desc = "It's made of a special fiber that provides minor protection against explosives. It has markings that denote the wearer as a scientist."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/under/sci_under.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/under/sci_under.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	supported_bodyshapes = list(BODYSHAPE_HUMANOID, BODYSHAPE_DIGITIGRADE)
	bodyshape_icon_files = list(
		BODYSHAPE_HUMANOID_T = 'modular_doppler/modular_cosmetics/icons/mob/under/sci_under.dmi',
		BODYSHAPE_DIGITIGRADE_T = 'modular_doppler/modular_cosmetics/icons/mob/under/sci_under_digi.dmi',
	)
	icon_state = "jumpsuit_sci"
	inhand_icon_state = "b_suit"

/obj/item/clothing/under/rank/rnd/scientist/skirt
	name = "scientist's jumpskirt"
	icon_state = "jumpsuit_sci_skirt"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION


/obj/item/clothing/under/rank/rnd/geneticist
	name = "geneticist's jumpsuit"
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a genetics rank stripe on it."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/under/sci_under.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/under/sci_under.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	supported_bodyshapes = list(BODYSHAPE_HUMANOID, BODYSHAPE_DIGITIGRADE)
	bodyshape_icon_files = list(
		BODYSHAPE_HUMANOID_T = 'modular_doppler/modular_cosmetics/icons/mob/under/sci_under.dmi',
		BODYSHAPE_DIGITIGRADE_T = 'modular_doppler/modular_cosmetics/icons/mob/under/sci_under_digi.dmi',
	)
	icon_state = "jumpsuit_gene"
	inhand_icon_state = "b_suit"

/obj/item/clothing/under/rank/rnd/geneticist/skirt
	name = "geneticist's jumpskirt"
	icon_state = "jumpsuit_gene_skirt"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION


/obj/item/clothing/under/rank/rnd/roboticist
	desc = "It's a slimming black with reinforced seams; great for industrial work."
	name = "roboticist's jumpsuit"
	icon = 'modular_doppler/modular_cosmetics/icons/obj/under/sci_under.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/under/sci_under.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	supported_bodyshapes = list(BODYSHAPE_HUMANOID, BODYSHAPE_DIGITIGRADE)
	bodyshape_icon_files = list(
		BODYSHAPE_HUMANOID_T = 'modular_doppler/modular_cosmetics/icons/mob/under/sci_under.dmi',
		BODYSHAPE_DIGITIGRADE_T = 'modular_doppler/modular_cosmetics/icons/mob/under/sci_under_digi.dmi',
	)
	icon_state = "jumpsuit_robo"
	inhand_icon_state = "b_suit"

/obj/item/clothing/under/rank/rnd/roboticist/skirt
	name = "roboticist's jumpskirt"
	desc = "It's a slimming black with reinforced seams; great for industrial work."
	icon_state = "jumpsuit_robo_skirt"
	inhand_icon_state = "b_suit" // TODO: make sure this is the right color
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
