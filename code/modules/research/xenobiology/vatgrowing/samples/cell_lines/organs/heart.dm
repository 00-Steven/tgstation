/datum/micro_organism/cell_line/organs/heart
	desc = "dense heart tissue"

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue)

	supplementary_reagents = list(
		/datum/reagent/love = 6,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	suppressive_reagents = list(
		/datum/reagent/toxin/mutagen = -2,
	)

	resulting_atom = /obj/item/organ/heart

/datum/micro_organism/cell_line/organs/heart/evolved
	desc = "dense evolved heart tissue"

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue)

	supplementary_reagents = list(
		/datum/reagent/love = 6,
		/datum/reagent/toxin/mutagen = 4,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	resulting_atom = /obj/item/organ/heart/evolved

/datum/micro_organism/cell_line/organs/heart/sacred
	desc = "dense sacred heart tissue"
	growth_rate = parent_type::growth_rate * 0.5

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue, /datum/reagent/water/holywater)

	supplementary_reagents = list(
		/datum/reagent/love = 6,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	resulting_atom = /obj/item/organ/heart/evolved/sacred

/datum/micro_organism/cell_line/organs/heart/corrupt
	desc = "dense corrupted heart tissue"

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue)

	supplementary_reagents = list(
		/datum/reagent/hellwater = 6,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	suppressive_reagents = list(
		/datum/reagent/water/holywater = -3,
	)

	resulting_atom = /obj/item/organ/heart/corrupt
