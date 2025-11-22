/// Cell lines for organ cytology, letting you duplicate or grow new mutant strains!
/datum/micro_organism/cell_line/organs
	desc = "dense tissue"
	growth_rate = 1
	consumption_rate = REAGENTS_METABOLISM

/datum/micro_organism/cell_line/organs/mutate_color(atom/beautiful_mutant)
	. = ..()
	if(!isorgan(beautiful_mutant))
		return
	var/obj/item/organ/organ = beautiful_mutant
	// Rare affix organs get more health
	organ.maxHealth *= .
