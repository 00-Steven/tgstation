
/mob/living/verb/set_object_temporary_flavor()
	set category = "IC"
	set name = "Set Object Temporary Flavor Text"
	set desc = "Allows you to set the temporary flavor text for some other object."

	if(stat != CONSCIOUS)
		to_chat(usr, span_warning("You can't set your temporary flavor text now..."))
		return

	var/msg = tgui_input_text(usr, "Set the temporary flavor text in your 'examine' verb. This is for describing what people can tell by looking at your character.", "Temporary Flavor Text", temporary_flavor_text, max_length = 4096, multiline = TRUE)
	if(msg == null)
		return

	// Turn empty input into no flavor text
	var/result = msg || null
	temporary_flavor_text = result
	update_appearance(UPDATE_ICON|UPDATE_OVERLAYS)
	update_holder_appearance()
