/datum/micro_organism/cell_line/organs/liver
	desc = "dense liver tissue"

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue)

	supplementary_reagents = list(
		/datum/reagent/iron = 6,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	suppressive_reagents = list(
		/datum/reagent/toxin/mutagen = -2,
	)

	resulting_atom = /obj/item/organ/liver

/datum/micro_organism/cell_line/organs/liver/evolved
	desc = "dense evolved liver tissue"

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue)

	supplementary_reagents = list(
		/datum/reagent/iron = 6,
		/datum/reagent/toxin/mutagen = 4,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	resulting_atom = /obj/item/organ/liver/evolved

/datum/micro_organism/cell_line/organs/liver/bloody
	desc = "spongy liver tissue"

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue, /datum/reagent/blood)

	supplementary_reagents = list(
		/datum/reagent/iron = 6,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	resulting_atom = /obj/item/organ/liver/bloody

/datum/micro_organism/cell_line/organs/liver/distillery
	desc = "alcoholic liver tissue"
	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue, /datum/reagent/consumable/ethanol)

	supplementary_reagents = list(
		/datum/reagent/iron = 6,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	suppressive_reagents = list(
		/datum/reagent/water = -6, //are you trying to poison me or something?
	)

	resulting_atom = /obj/item/organ/liver/distillery
