
/**
 * NEW ITEMS
 */

// TODO: RD JUMPSUIT
// TODO: SCIENTIST ALT JUMPSUIT (maybe call it med-scientist medical scientist somesuch?)

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
	inhand_icon_state = "b_suit" // TODO: make sure this is the right color
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

// TODO: work out the consequences of teshari stuff
// TODO: change uniforms/vendors to use jackboots. or like recolored workboots? or just black shoes.
// TODO: redesc and rename allat

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
	inhand_icon_state = "b_suit" // TODO: make sure this is the right color
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
	inhand_icon_state = "b_suit" // TODO: make sure this is the right color

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
	inhand_icon_state = "b_suit" // TODO: make sure this is the right color

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
	inhand_icon_state = "b_suit" // TODO: make sure this is the right color

/obj/item/clothing/under/rank/rnd/roboticist/skirt
	name = "roboticist's jumpskirt"
	desc = "It's a slimming black with reinforced seams; great for industrial work."
	icon_state = "jumpsuit_robo_skirt"
	inhand_icon_state = "b_suit" // TODO: make sure this is the right color
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
