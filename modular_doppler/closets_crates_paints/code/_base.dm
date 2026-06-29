

/obj/structure/closet
	// The icon to default to for any paint jobs.
	var/paint_job_default_icon = 'icons/obj/storage/closet.dmi'

/// Gets any modular paint jobs used for this type.
/obj/structure/closet/proc/get_modular_paint_jobs()
	return list(
		"Science Base" = list(
			"icon_override" = 'modular_doppler/misc_department_recolor/icons/obj/storage/sci_closets.dmi',
			"icon_state" = "generic",
		),
		"Research Director" = list(
			"icon_override" = 'modular_doppler/misc_department_recolor/icons/obj/storage/sci_closets.dmi',
			"icon_state" = "rd",
		),
		"Science" = list(
			"icon_override" = 'modular_doppler/misc_department_recolor/icons/obj/storage/sci_closets.dmi',
			"icon_state" = "striped",
		),
		"Medical Science" = list(
			"icon_override" = 'modular_doppler/misc_department_recolor/icons/obj/storage/sci_closets.dmi',
			"icon_door" = "striped_med",
		),
		"Science Biohazard" = list(
			"icon_override" = 'modular_doppler/misc_department_recolor/icons/obj/storage/sci_closets.dmi',
			"icon_state" = "bio",
		),
		"Scientist Wardrobe" = list(
			"icon_override" = 'modular_doppler/misc_department_recolor/icons/obj/storage/sci_closets.dmi',
			"icon_state" = "wardrobe",
			"icon_door" = "sci_wardrobe",
		),
		"Roboticist Wardrobe" = list(
			"icon_override" = 'modular_doppler/misc_department_recolor/icons/obj/storage/sci_closets.dmi',
			"icon_state" = "wardrobe",
			"icon_door" = "robo_wardrobe",
		),
		"Geneticist Wardrobe" = list(
			"icon_override" = 'modular_doppler/misc_department_recolor/icons/obj/storage/sci_closets.dmi',
			"icon_state" = "wardrobe",
			"icon_door" = "gene_wardrobe",
		),
	)


/obj/structure/closet/crate
	paint_job_default_icon = 'icons/obj/storage/crates.dmi'

/obj/structure/closet/crate/get_modular_paint_jobs(list/base_paint_jobs)
	return list()

