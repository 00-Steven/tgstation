/datum/micro_organism/cell_line/organs/lungs
	desc = "dense lung tissue"

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue)

	supplementary_reagents = list(
		/datum/reagent/medicine/salbutamol = 6,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	suppressive_reagents = list(
		/datum/reagent/toxin/mutagen = -2,
	)

	resulting_atom = /obj/item/organ/lungs

/datum/micro_organism/cell_line/organs/lungs/evolved
	desc = "dense evolved lung tissue"

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue)

	supplementary_reagents = list(
		/datum/reagent/medicine/salbutamol = 6,
		/datum/reagent/toxin/mutagen = 4,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	resulting_atom = /obj/item/organ/lungs/evolved
