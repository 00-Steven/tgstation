
/// Version of update_holoray that accounts for pixelshifts, for use as a callback.
/obj/machinery/holopad/proc/update_holoray_pixelshift(mob/living/proxy, obj/obj_shifted)
	if(isnull(proxy) || isnull(obj_shifted))
		return
	var/obj/effect/overlay/holo_pad_hologram/hologram = masters[proxy]
	var/obj/effect/overlay/holoray/ray = holorays[proxy]
	var/dist_x = hologram.x - ray.x + (hologram.pixel_w / 32)
	var/dist_y = hologram.y - ray.y + (hologram.pixel_z / 32)
	var/newangle
	if(!dist_y)
		if(dist_x >= 0)
			newangle = 90
		else
			newangle = 270
	else
		newangle = arctan(dist_x / dist_y)
		if(dist_y < 0)
			newangle += 180
		else if(dist_x < 0)
			newangle += 360
	var/matrix/new_matrix = matrix()

	ray.transform = turn(new_matrix.Scale(1, sqrt((dist_x * dist_x) + (dist_y * dist_y))), newangle)
