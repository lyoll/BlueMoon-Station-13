/obj/item/ammo_box/magazine/internal/shot
	name = "shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag
	caliber = "shotgun"
	max_ammo = 4
	multiload = 0

/obj/item/ammo_box/magazine/internal/shot/ammo_count(countempties = 1)
	if (!countempties)
		var/boolets = 0
		for(var/obj/item/ammo_casing/bullet in stored_ammo)
			if(bullet.BB)
				boolets++
		return boolets
	else
		return ..()

/obj/item/ammo_box/magazine/internal/shot/tube
	name = "dual feed shotgun internal tube"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot
	max_ammo = 4

/obj/item/ammo_box/magazine/internal/shot/lethal
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/magazine/internal/shot/com
	name = "combat shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	max_ammo = 4

/obj/item/ammo_box/magazine/internal/shot/com/compact
	name = "compact combat shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	max_ammo = 4

/obj/item/ammo_box/magazine/internal/shot/dual
	name = "double-barrel shotgun internal magazine"
	max_ammo = 2

/obj/item/ammo_box/magazine/internal/shot/dual/heck
	name = "heckgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/magazine/internal/shot/improvised
	name = "improvised shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/improvised
	max_ammo = 1

/obj/item/ammo_box/magazine/internal/shot/riot
	name = "riot shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/shot/bounty
	name = "triple-barrel shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/incapacitate
	max_ammo = 3

/obj/item/ammo_box/magazine/internal/shot/levergun
	name = "levergun internal magazine"
	ammo_type = /obj/item/ammo_casing/c38 // they're rubber by default, i guess
	caliber = "38"
	max_ammo = 7

/obj/item/ammo_box/magazine/internal/shot/levergun/brush
	name = "brush gun internal magazine"
	ammo_type = /obj/item/ammo_casing/g4570
	caliber = "45-70g" // :^(.
