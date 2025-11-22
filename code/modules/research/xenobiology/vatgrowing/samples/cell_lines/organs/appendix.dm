/datum/micro_organism/cell_line/organs/appendix
	desc = "dense appendix tissue"

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue)

	supplementary_reagents = list(
		/datum/reagent/impurity/ipecacide = 6,
		/datum/reagent/toxin/bad_food = 4,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	resulting_atom = /obj/item/organ/appendix

// These are all intended to exist as opposing lines to the base appendix line,
// where you have to suppress/supplement it to make it grow right.

/datum/micro_organism/cell_line/organs/appendix/evolved
	desc = "dense evolved appendix tissue"
	growth_rate = 0.8 // Grows slow, needs to be supplemented.

	required_reagents = list(
		/datum/reagent/consumable/nutriment/organ_tissue,
		/datum/reagent/consumable/nutriment/vitamin,
	)

	supplementary_reagents = list(
		/datum/reagent/consumable/sol_dry = 6,
		/datum/reagent/toxin/mutagen = 4,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	suppressive_reagents = list(
		/datum/reagent/toxin/bad_food = -2,
	)

	resulting_atom = /obj/item/organ/appendix/evolved

/datum/micro_organism/cell_line/organs/appendix/evolved/mutate_color(atom/beautiful_mutant)
	. = ..()
	var/obj/item/organ/appendix/evolved/tasty_appendix = beautiful_mutant
	// Shiny evolved appendixes are EVEN TASTIER
	var/tastier_food_complexity = initial(tasty_appendix.food_complexity) * .
	tasty_appendix.set_food_complexity(tastier_food_complexity)

/datum/micro_organism/cell_line/organs/appendix/evolved/pickle
	desc = "dense appicklex tissue"
	growth_rate = 0.5 // Grows even slower, needs to be supplemented.

	required_reagents = list(
		/datum/reagent/consumable/nutriment/organ_tissue,
		/datum/reagent/toxin/formaldehyde,
	)

	supplementary_reagents = list(
		/datum/reagent/consumable/pickle = 12,
		/datum/reagent/consumable/vinegar = 8,
		/datum/reagent/cryostylane = 4,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	suppressive_reagents = list(
		/datum/reagent/toxin/bad_food = -4,
	)

	resulting_atom = /obj/item/organ/appendix/evolved/pickle

/datum/micro_organism/cell_line/organs/appendix/evolved/sausage
	desc = "dense sausage appendix tissue"
	growth_rate = 0.5 // Grows even slower, needs to be supplemented.

	required_reagents = list(
		/datum/reagent/consumable/nutriment/organ_tissue,
		/datum/reagent/consumable/nutriment/protein,
		/datum/reagent/consumable/ketchup,
	)

	supplementary_reagents = list(
		/datum/reagent/consumable/secretsauce = 24, // Utterly ridiculous.
		/datum/reagent/consumable/bbqsauce = 6,
		/datum/reagent/consumable/sol_dry = 6,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	suppressive_reagents = list(
		/datum/reagent/toxin/bad_food = -8,
	)

	resulting_atom = /obj/item/organ/appendix/evolved/sausage
