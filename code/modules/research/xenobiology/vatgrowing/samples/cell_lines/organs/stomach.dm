/datum/micro_organism/cell_line/organs/stomach
	desc = "dense stomach tissue"

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue/stomach_lining)

	supplementary_reagents = list(
		/datum/reagent/consumable/nutriment/organ_tissue = 3,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	suppressive_reagents = list(
		/datum/reagent/toxin/mutagen = -2,
	)

	resulting_atom = /obj/item/organ/stomach

/datum/micro_organism/cell_line/organs/stomach/evolved
	desc = "dense evolved stomach tissue"

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue/stomach_lining)

	supplementary_reagents = list(
		/datum/reagent/toxin/mutagen = 4,
		/datum/reagent/consumable/nutriment/organ_tissue = 3,
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/blood = 3,
	)

	resulting_atom = /obj/item/organ/stomach/evolved
