
/*--------------------------------------------------
-------------------MOB STUFF----------------------
--------------------------------------------------
*/
//I'm sorry, lewd should not have mob procs such as life() and such in it. //NO SHIT IT SHOULDNT I REMOVED THEM

/proc/playlewdinteractionsound(turf/turf_source, soundin, vol as num, vary, extrarange as num, frequency, falloff, channel = 0, pressure_affected = TRUE, sound/S, envwet = -10000, envdry = 0, manual_x, manual_y, list/ignored_mobs)
	var/list/hearing_mobs
	for(var/mob/H in get_hearers_in_view(4, turf_source))
		if(!H.client || (H.client.prefs.toggles & LEWD_VERB_SOUNDS))
			continue
		LAZYADD(hearing_mobs, H)
	if(ignored_mobs?.len)
		LAZYREMOVE(hearing_mobs, ignored_mobs)
	for(var/mob/H in hearing_mobs)
		H.playsound_local(turf_source, soundin, vol, vary, frequency, falloff)

/mob/living
	var/has_penis = FALSE
	var/has_balls = FALSE
	var/has_vagina = FALSE
	var/has_anus = TRUE
	var/has_butt = FALSE
	var/anus_always_accessible = FALSE
	var/has_breasts = FALSE
	var/anus_exposed = FALSE
	var/last_partner
	var/last_orifice
	var/obj/item/organ/last_genital
	var/lastmoan
	var/sexual_potency = 15
	var/lust_tolerance = 100
	var/lastlusttime = 0
	var/lust = 0
	var/multiorgasms = 1
	COOLDOWN_DECLARE(refractory_period)
	COOLDOWN_DECLARE(last_interaction_time)
	var/datum/interaction/lewd/last_lewd_datum	//Recording our last lewd datum allows us to do stuff like custom cum messages.
												//Yes i feel like an idiot writing this.
	var/cleartimer //Timer for clearing the "last_lewd_datum". This prevents some oddities.

/mob/living/proc/clear_lewd_datum()
	last_partner = null
	last_orifice = null
	last_genital = null
	last_lewd_datum = null

/mob/living/Initialize(mapload)
	. = ..()
	sexual_potency = rand(10,25)
	lust_tolerance = rand(75,200)

/mob/living/proc/get_lust_tolerance()
	. = lust_tolerance
	if(has_dna())
		var/mob/living/carbon/user = src
		if(user.dna.features["lust_tolerance"])
			. = user.dna.features["lust_tolerance"]

/mob/living/proc/get_sexual_potency()
	. = sexual_potency
	if(has_dna())
		var/mob/living/carbon/user = src
		if(user.dna.features["sexual_potency"])
			. = user.dna.features["sexual_potency"]

/mob/living/proc/add_lust(add)
	var/cur = get_lust() //GetLust handles per-time lust loss
	if((cur + add) < 0) //in case we retract lust
		lust = 0
	else
		lust = cur + add


/mob/living/proc/get_lust()
	var/curtime = world.time
	var/dif = (curtime - lastlusttime) / 10 //how much lust would we lose over time
	if((lust - dif) < 0)
		lust = 0
	else
		lust = lust - dif

	lastlusttime = world.time
	return lust

/mob/living/proc/set_lust(num)
	lust = num
	lastlusttime = world.time

/mob/living/proc/toggle_anus_always_accessible(accessibility)
	anus_always_accessible = isnull(accessibility) ? !anus_always_accessible : accessibility

/mob/living/proc/has_genital(slot, visibility = REQUIRE_ANY)
	var/mob/living/carbon/C = src
	if(istype(C))
		var/obj/item/organ/genital/genital = C.getorganslot(slot)
		if(genital)
			switch(visibility)
				if(REQUIRE_ANY)
					return TRUE
				if(REQUIRE_EXPOSED)
					return genital.is_exposed() || genital.always_accessible
				if(REQUIRE_UNEXPOSED)
					return !genital.is_exposed()
				else
					return TRUE
	return FALSE

/mob/living/proc/has_penis(visibility = REQUIRE_ANY)
	var/mob/living/carbon/C = src
	if(has_penis && !istype(C))
		return TRUE
	return has_genital(ORGAN_SLOT_PENIS, visibility)

/mob/living/proc/has_strapon(visibility = REQUIRE_ANY)
	var/mob/living/carbon/C = src
	if(istype(C))
		var/obj/item/clothing/underwear/briefs/strapon/strapon = C.get_strapon()
		if(strapon)
			switch(visibility)
				if(REQUIRE_ANY)
					return TRUE
				if(REQUIRE_EXPOSED)
					return strapon.is_exposed()
				if(REQUIRE_UNEXPOSED)
					return !strapon.is_exposed()
				else
					return TRUE
	return FALSE

/mob/living/proc/get_strapon()
	for(var/obj/item/clothing/cloth in get_equipped_items())
		if(istype(cloth, /obj/item/clothing/underwear/briefs/strapon))
			return cloth

	return null

/mob/living/proc/can_penetrating_genital_cum()
	return has_penis()

/mob/living/proc/get_penetrating_genital_name(long = FALSE)
	return has_penis() ? (long ? pick(GLOB.dick_nouns) : pick("член", "пенис")) : pick("страпон")

/mob/living/proc/has_balls(visibility = REQUIRE_ANY)
	var/mob/living/carbon/C = src
	if(has_balls && !istype(C))
		return TRUE
	return has_genital(ORGAN_SLOT_TESTICLES, visibility)

/mob/living/proc/has_vagina(visibility = REQUIRE_ANY)
	var/mob/living/carbon/C = src
	if(has_vagina && !istype(C))
		return TRUE
	return has_genital(ORGAN_SLOT_VAGINA, visibility)

/mob/living/proc/has_breasts(visibility = REQUIRE_ANY)
	var/mob/living/carbon/C = src
	if(has_breasts && !istype(C))
		return TRUE
	return has_genital(ORGAN_SLOT_BREASTS, visibility)

/mob/living/proc/has_anus(visibility = REQUIRE_ANY)
	if(has_anus && !iscarbon(src))
		return TRUE
	switch(visibility)
		if(REQUIRE_ANY)
			return TRUE
		if(REQUIRE_EXPOSED)
			if (has_anus && anus_always_accessible)
				return TRUE
			switch(anus_exposed)
				if(-1)
					return FALSE
				if(1)
					return TRUE
				else
					if(is_bottomless())
						return TRUE
					else
						return FALSE
		if(REQUIRE_UNEXPOSED)
			if(anus_exposed == -1)
				if(!anus_exposed)
					if(!is_bottomless())
						return TRUE
					else
						return FALSE
				else
					return FALSE
			else
				return TRUE
		else
			return TRUE

/mob/living/proc/has_hand(visibility = REQUIRE_ANY)
	if(iscarbon(src))
		var/mob/living/carbon/C = src
		var/handcount = 0
		var/covered = 0
		var/iscovered = FALSE
		for(var/obj/item/bodypart/l_arm/L in C.bodyparts)
			handcount++
		for(var/obj/item/bodypart/r_arm/R in C.bodyparts)
			handcount++
		if(C.get_item_by_slot(ITEM_SLOT_HANDS))
			var/obj/item/clothing/gloves/G = C.get_item_by_slot(ITEM_SLOT_HANDS)
			covered = G.body_parts_covered
		if(covered & HANDS)
			iscovered = TRUE
		switch(visibility)
			if(REQUIRE_ANY)
				return handcount
			if(REQUIRE_EXPOSED)
				if(iscovered)
					return FALSE
				else
					return handcount
			if(REQUIRE_UNEXPOSED)
				if(!iscovered)
					return FALSE
				else
					return handcount
			else
				return handcount
	return FALSE

/mob/living/proc/has_feet(visibility = REQUIRE_ANY)
	if(iscarbon(src))
		var/mob/living/carbon/C = src
		var/feetcount = 0
		var/covered = 0
		var/iscovered = FALSE
		for(var/obj/item/bodypart/l_leg/L in C.bodyparts)
			feetcount++
		for(var/obj/item/bodypart/r_leg/R in C.bodyparts)
			feetcount++
		if(!C.is_barefoot())
			covered = TRUE
		if(covered)
			iscovered = TRUE
		switch(visibility)
			if(REQUIRE_ANY)
				return feetcount
			if(REQUIRE_EXPOSED)
				if(iscovered)
					return FALSE
				else
					return feetcount
			if(REQUIRE_UNEXPOSED)
				if(!iscovered)
					return FALSE
				else
					return feetcount
			else
				return feetcount
	return FALSE

/mob/living/proc/get_num_feet()
	return has_feet(REQUIRE_ANY)

//weird procs go here
/mob/living/proc/has_ears(visibility = REQUIRE_ANY)
	var/mob/living/carbon/C = src
	if(istype(C))
		var/obj/item/organ/peepee = C.getorganslot(ORGAN_SLOT_EARS)
		if(peepee)
			switch(visibility)
				if(REQUIRE_ANY)
					return TRUE
				if(REQUIRE_EXPOSED)
					if(C.get_item_by_slot(ITEM_SLOT_EARS_LEFT) || C.get_item_by_slot(ITEM_SLOT_EARS_RIGHT))
						return FALSE
					else
						return TRUE
				if(REQUIRE_UNEXPOSED)
					if(!C.get_item_by_slot(ITEM_SLOT_EARS_LEFT || C.get_item_by_slot(ITEM_SLOT_EARS_RIGHT)))
						return FALSE
					else
						return TRUE
				else
					return TRUE
	return FALSE

/mob/living/proc/has_earsockets(visibility = REQUIRE_ANY)
	var/mob/living/carbon/C = src
	if(istype(C))
		var/obj/item/organ/peepee = C.getorganslot(ORGAN_SLOT_EARS)
		if(!peepee)
			switch(visibility)
				if(REQUIRE_ANY)
					return TRUE
				if(REQUIRE_EXPOSED)
					if(C.get_item_by_slot(ITEM_SLOT_EARS_LEFT) || C.get_item_by_slot(ITEM_SLOT_EARS_RIGHT))
						return FALSE
					else
						return TRUE
				if(REQUIRE_UNEXPOSED)
					if(!C.get_item_by_slot(ITEM_SLOT_EARS_LEFT) || !C.get_item_by_slot(ITEM_SLOT_EARS_RIGHT))
						return FALSE
					else
						return TRUE
				else
					return TRUE
	return FALSE

/mob/living/proc/has_eyes(visibility = REQUIRE_ANY)
	var/mob/living/carbon/C = src
	if(istype(C))
		var/obj/item/organ/peepee = C.getorganslot(ORGAN_SLOT_EYES)
		if(peepee)
			switch(visibility)
				if(REQUIRE_ANY)
					return TRUE
				if(REQUIRE_EXPOSED)
					if(C.get_item_by_slot(ITEM_SLOT_EYES))
						return FALSE
					else
						return TRUE
				if(REQUIRE_UNEXPOSED)
					if(!C.get_item_by_slot(ITEM_SLOT_EYES))
						return FALSE
					else
						return TRUE
				else
					return TRUE
	return FALSE

/mob/living/proc/has_eyesockets(visibility = REQUIRE_ANY)
	var/mob/living/carbon/C = src
	if(istype(C))
		var/obj/item/organ/peepee = C.getorganslot(ORGAN_SLOT_EYES)
		if(!peepee)
			switch(visibility)
				if(REQUIRE_ANY)
					return TRUE
				if(REQUIRE_EXPOSED)
					if(get_item_by_slot(ITEM_SLOT_EYES))
						return FALSE
					else
						return TRUE
				if(REQUIRE_UNEXPOSED)
					if(!get_item_by_slot(ITEM_SLOT_EYES))
						return FALSE
					else
						return TRUE
				else
					return TRUE
	return FALSE

/mob/living/proc/has_butt(visibility = REQUIRE_ANY)
	var/mob/living/carbon/C = src
	if(has_butt && !istype(C))
		return TRUE
	return has_genital(ORGAN_SLOT_BUTT, visibility)

///Are we wearing something that covers our chest?
/mob/living/proc/is_topless()
	for(var/slot in GLOB.slots)
		var/item_slot = GLOB.slot2slot[slot]
		if(!item_slot) // Safety
			continue
		var/obj/item/clothing = get_item_by_slot(item_slot)
		if(!clothing) // Don't have this slot or not wearing anything in it
			continue
		if(clothing.body_parts_covered & CHEST)
			return FALSE
	// If didn't stop before, then we're topless
	return TRUE

///Are we wearing something that covers our groin?
/mob/living/proc/is_bottomless()
	for(var/slot in GLOB.slots)
		var/item_slot = GLOB.slot2slot[slot]
		if(!item_slot) // Safety
			continue
		var/obj/item/clothing = get_item_by_slot(item_slot)
		if(!clothing) // Don't have this slot or not wearing anything in it
			continue
		if(clothing.body_parts_covered & GROIN)
			return FALSE
	// If didn't stop before, then we're bottomless
	return TRUE

///Are we wearing something that covers our shoes?
/mob/living/proc/is_barefoot()
	for(var/slot in GLOB.slots)
		var/item_slot = GLOB.slot2slot[slot]
		if(!item_slot) // Safety
			continue
		var/obj/item/clothing = get_item_by_slot(item_slot)
		if(!clothing) // Don't have this slot or not wearing anything in it
			continue
		if(clothing.body_parts_covered & FEET)
			return FALSE
	// If didn't stop before, then we're barefoot
	return TRUE

/mob/living/proc/moan()
	if(!(prob(get_lust() / get_lust_tolerance() * 65)))
		return
	var/moan = rand(1, 7)
	if(moan == lastmoan)
		moan--
	if(!is_muzzled())
		visible_message(message = span_lewd("<B>[src]</B> [pick("постанывает", "стонет в удовольствии")]."), ignored_mobs = get_unconsenting())
	if(is_muzzled())//immursion
		audible_message(span_lewd("<B>[src]</B> [pick("имитирует приятный стон", "бесшумно постанывает")]."))
	lastmoan = moan

/mob/living/proc/cum(mob/living/partner, target_orifice, cum_inside = FALSE, anonymous = FALSE)
	if(HAS_TRAIT(src, TRAIT_NEVERBONER))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_MOB_PRE_CAME, target_orifice, partner))
		return FALSE
	var/message
	var/cumin = cum_inside // SPLURT EDIT - defaults to argument `cum_inside` rather than FALSE
	var/partner_carbon_check = FALSE
	var/obj/item/organ/genital/target_gen = null
	var/mob/living/carbon/c_partner = null

	// Do not display to those people as well
	var/list/mob/obscure_to

	//Carbon checks
	if(iscarbon(partner))
		c_partner = partner
		partner_carbon_check = TRUE

	var/partner_name
	if(anonymous)
		partner_name = "<b>НЕИЗВЕСТНЫЙ</b>"
	else
		partner_name = "[partner_name]"

	if(src != partner)
		if(ismob(partner))
			if(!last_genital)
				if(has_penis())
					if(!istype(partner))
						target_orifice = null
					switch(target_orifice)
						if(CUM_TARGET_MOUTH)
							if(partner.has_mouth() && partner.mouth_is_free())
								message = "кончает прямо в ротик [partner_name]."
								cumin = TRUE
							else
								message = "кончает на лицо [partner_name] семенем."
						if(CUM_TARGET_THROAT)
							if(partner.has_mouth() && partner.mouth_is_free())
								message = "входит глубоко в глотку [partner_name] и кончает."
								cumin = TRUE
							else
								message = "кончает на лицо [partner_name] семенем."
						if(CUM_TARGET_VAGINA)
							if(partner.has_vagina(REQUIRE_EXPOSED))
								if(partner_carbon_check)
									target_gen = c_partner.getorganslot(ORGAN_SLOT_VAGINA)
								message = "кончает на киску [partner_name] семенем."
								cumin = TRUE
							else
								message = "кончает на живот [partner_name] семенем."
						if(CUM_TARGET_ANUS)
							if(partner.has_anus(REQUIRE_EXPOSED))
								message = "кончает на попку [partner_name] семенем."
								cumin = TRUE
							else
								message = "кончает на спину [partner_name] семенем."
						if(CUM_TARGET_HAND)
							if(partner.has_hand(REQUIRE_ANY))
								message = "кончает на руку [partner_name] семенем."
							else
								message = "кончает на [partner_name]."
						if(CUM_TARGET_BREASTS)
							var/mob/living/carbon/human/sex
							for(var/obj/item/organ/genital/G in sex.internal_organs)
								var/datum/reagents/fluid_source = G.climaxable(partner)
								if(!fluid_source)
									continue
								sex.do_climax(fluid_source, src, G, TRUE, FALSE)
							if(partner.has_breasts(REQUIRE_EXPOSED))
								message = "кончает на грудь [partner_name]."
							else
								message = "кончает на грудину и торс [partner_name]."
						if(NUTS_TO_FACE)
							if(partner.has_mouth() && partner.mouth_is_free())
								message = "энергично засовывает свои яйца в рот партнёра перед тем, как выпустить густое, липкое семя в глаза и волосы [partner_name]."
						if(THIGH_SMOTHERING)
							var/mob/living/carbon/human/sex
							for(var/obj/item/organ/genital/G in sex.internal_organs)
								var/datum/reagents/fluid_source = G.climaxable(partner)
								if(!fluid_source)
									continue
								sex.do_climax(fluid_source, src, G, TRUE, FALSE)
							if(has_penis(REQUIRE_EXPOSED)) //it already checks for the cock before, why the hell would you do this redundant shit
								message = "держит [partner_name] между бёдрами, пока член пульсирует, по итогу сливая пульсирующую нагрузку в лицо и волосы жертвы."
							else
								message = "достигает пика, фиксирует ноги вокруг головы [partner_name] с особой силой, пока член пульсирует, по итогу сливая пульсирующую нагрузку в лицо и волосы жертвы."
							cumin = TRUE
						if(CUM_TARGET_FEET)
							if(!last_lewd_datum.require_target_num_feet)
								if(partner.has_feet())
									message = "кончает на [partner_name]'s [partner.has_feet() == 1 ? pick("стопу", "ножку") : pick("стопу", "ножку")]."
								else
									message = "кончает под себя!"
							else
								if(partner.has_feet())
									message = "кончает на [partner_name]'s [last_lewd_datum.require_target_feet == 1 ? pick("стопу", "ножку") : pick("стопу", "ножку")]."
								else
									message = "кончает под себя!"
						//weird shit goes here
						if(CUM_TARGET_EARS)
							if(partner.has_ears())
								message = "кончает в \the ухо [partner_name] сквиртом."
							else
								message = "кончает в \the ушную раковину [partner_name] сквиртом."
							cumin = TRUE
						if(CUM_TARGET_EYES)
							if(partner.has_eyes())
								message = "кончает на глаз [partner_name] сквиртом."
							else
								message = "кончает в \the глазницу [partner_name] сквиртом."
							cumin = TRUE
						//
						if(CUM_TARGET_PENIS)
							if(partner.has_penis(REQUIRE_EXPOSED))
								message = "кончает на [partner_name]."
							else
								message = "кончает под себя!"
						else
							message = "кончает под себя!"
				else if(has_vagina())
					if(!istype(partner))
						target_orifice = null

					switch(target_orifice)
						if(CUM_TARGET_MOUTH)
							if(partner.has_mouth() && partner.mouth_is_free())
								message = "кончает прямо в рот [partner_name]."
								cumin = TRUE
							else
								message = "обливает лицо [partner_name] сквиртом."
						if(CUM_TARGET_THROAT)
							if(partner.has_mouth() && partner.mouth_is_free())
								message = "трется своей киской о рот [partner_name] и кончает."
								cumin = TRUE
							else
								message = "обливает лицо [partner_name] сквиртом."
						if(CUM_TARGET_VAGINA)
							if(partner.has_vagina(REQUIRE_EXPOSED))
								message = "обливает киску [partner_name] сквиртом."
								cumin = TRUE
							else
								message = "обливает живот [partner_name] сквиртом."
						if(CUM_TARGET_ANUS)
							if(partner.has_anus(REQUIRE_EXPOSED))
								message = "обливает попку [partner_name] сквиртом."
								cumin = TRUE
							else
								message = "обливает спину [partner_name] сквиртом."
						if(CUM_TARGET_HAND)
							if(partner.has_hand(REQUIRE_ANY))
								message = "обливает руку [partner_name] сквиртом."
							else
								message = "обливает [partner_name]."
						if(CUM_TARGET_BREASTS)
							if(partner.has_breasts(REQUIRE_EXPOSED))
								message = "обливает грудь [partner_name] сквиртом."
							else
								message = "обливает грудину и торс [partner_name] сквиртом."
						if(NUTS_TO_FACE)
							if(partner.has_mouth() && partner.mouth_is_free())
								message = "энергично засовывает свои яйца в рот партнёра перед тем, как выпустить густое, липкое семя в глаза и волосы [partner_name]."
						if(THIGH_SMOTHERING)
							message = "держит [partner_name] между бёдрами, пока киска пульсирует, по итогу сливая пульсирующую нагрузку в лицо и волосы жертвы."
							cumin = TRUE
						if(CUM_TARGET_FEET)
							if(!last_lewd_datum.require_target_num_feet)
								if(partner.has_feet())
									message = "обливает [partner_name]'s [partner.has_feet() == 1 ? pick("стопу", "ножку") : pick("стопу", "ножку")]."
								else
									message = "обливает пространство под собой сквиртом!"
							else
								if(partner.has_feet())
									message = "обливает [partner_name]'s [last_lewd_datum.require_target_feet == 1 ? pick("стопу", "ножку") : pick("стопу", "ножку")]."
								else
									message = "обливает пространство под собой сквиртом!"
						//weird shit goes here
						if(CUM_TARGET_EARS)
							if(partner.has_ears())
								message = "обливает ухо [partner_name] сквиртом."
							else
								message = "обливает ушную раковину [partner_name] сквиртом."
							cumin = TRUE
						if(CUM_TARGET_EYES)
							if(partner.has_eyes())
								message = "обливает глаз [partner_name] сквиртом."
							else
								message = "обливает глазницу [partner_name] сквиртом."
							cumin = TRUE
						//
						if(CUM_TARGET_PENIS)
							if(partner.has_penis(REQUIRE_EXPOSED))
								message = "обливает пенис [partner_name] сквиртом"
							else
								message = "обливает пространство под собой сквиртом!"
						else
							message = "обливает пространство под собой сквиртом!"

				else
					message = pick("orgasms violently!", "twists in orgasm.")
			else
				switch(last_genital.type)
					if(/obj/item/organ/genital/penis)
						if(!istype(partner))
							target_orifice = null

						switch(target_orifice)
							if(CUM_TARGET_MOUTH)
								if(partner.has_mouth() && partner.mouth_is_free())
									message = "кончает прямо в рот [partner_name]."
									cumin = TRUE
								else
									message = "кончает на лицо [partner_name] семенем."
							if(CUM_TARGET_THROAT)
								if(partner.has_mouth() && partner.mouth_is_free())
									message = "входит глубоко в глотку [partner_name] и кончает."
									cumin = TRUE
								else
									message = "кончает на лицо [partner_name] семенем."
							if(CUM_TARGET_VAGINA)
								if(partner.has_vagina(REQUIRE_EXPOSED))
									if(partner_carbon_check)
										target_gen = c_partner.getorganslot(ORGAN_SLOT_VAGINA)
									message = "кончает в киску [partner_name] семенем."
									cumin = TRUE
								else
									message = "кончает на живот [partner_name] семенем."
							if(CUM_TARGET_ANUS)
								if(partner.has_anus(REQUIRE_EXPOSED))
									message = "кончает в попку [partner_name] семенем."
									cumin = TRUE
								else
									message = "кончает на спину [partner_name] семенем."
							if(CUM_TARGET_HAND)
								if(partner.has_hand())
									message = "кончает на руку [partner_name] семенем."
								else
									message = "кончает на [partner_name]."
							if(CUM_TARGET_BREASTS)
								var/mob/living/carbon/human/sex
								for(var/obj/item/organ/genital/G in sex.internal_organs)
									var/datum/reagents/fluid_source = G.climaxable(partner)
									if(!fluid_source)
										continue
									sex.do_climax(fluid_source, src, G, TRUE, FALSE)
								if(partner.is_topless() && partner.has_breasts())
									message = "кончает на грудь [partner_name]."
								else
									message = "кончает на грудину и торс [partner_name]."
							if(NUTS_TO_FACE)
								if(partner.has_mouth() && partner.mouth_is_free())
									message = "энергично засовывает свои яйца в рот партнёра перед тем, как выпустить густое, липкое семя в глаза и волосы [partner_name]."
							if(THIGH_SMOTHERING)
								var/mob/living/carbon/human/sex
								for(var/obj/item/organ/genital/G in sex.internal_organs)
									var/datum/reagents/fluid_source = G.climaxable(partner)
									if(!fluid_source)
										continue
									sex.do_climax(fluid_source, src, G, TRUE, FALSE)
								if(has_penis())
									message = "держит [partner_name] между бёдрами, пока член пульсирует, по итогу сливая пульсирующую нагрузку в лицо и волосы жертвы."
								else
									message = "достигает пика, фиксирует ноги вокруг головы [partner_name] с особой силой, пока член пульсирует, по итогу сливая пульсирующую нагрузку в лицо и волосы жертвы."
								cumin = TRUE
							if(CUM_TARGET_FEET)
								if(!last_lewd_datum || !last_lewd_datum.require_target_num_feet)
									if(partner.has_feet())
										message = "кончает на [partner_name]'s [partner.has_feet() == 1 ? pick("стопу", "ножку") : pick("стопу", "ножку")]."
									else
										message = "кончает под себя!"
								else
									if(partner.has_feet())
										message = "кончает на [partner_name]'s [last_lewd_datum.require_target_feet == 1 ? pick("стопу", "ножку") : pick("стопу", "ножку")]."
									else
										message = "кончает под себя!"
							//weird shit goes here
							if(CUM_TARGET_EARS)
								if(partner.has_ears())
									message = "кончает в \the ухо [partner_name] сквиртом."
								else
									message = "кончает в \the ушную раковину [partner_name] сквиртом."
								cumin = TRUE
							if(CUM_TARGET_EYES)
								if(partner.has_eyes())
									message = "кончает на глаз [partner_name] сквиртом."
								else
									message = "кончает в \the глазницу [partner_name] сквиртом."
								cumin = TRUE
							//
							if(CUM_TARGET_PENIS)
								if(partner.has_penis(REQUIRE_EXPOSED))
									message = "кончает на [partner_name]."
								else
									message = "кончает под себя!"
							else
								message = "кончает под себя!"
					if(/obj/item/organ/genital/vagina)
						if(!istype(partner))
							target_orifice = null

						switch(target_orifice)
							if(CUM_TARGET_MOUTH)
								if(partner.has_mouth() && partner.mouth_is_free())
									message = "кончает прямо в [partner_name]'s mouth."
									cumin = TRUE
								else
									message = "обливает лицо [partner_name] сквиртом."
							if(CUM_TARGET_THROAT)
								if(partner.has_mouth() && partner.mouth_is_free())
									message = "трется своей киской о рот [partner_name] и кончает."
									cumin = TRUE
								else
									message = "обливает лицо [partner_name] сквиртом."
							if(CUM_TARGET_VAGINA)
								if(partner.has_vagina(REQUIRE_EXPOSED))
									message = "обливает киску [partner_name] сквиртом."
									cumin = TRUE
								else
									message = "обливает живот [partner_name] сквиртом."
							if(CUM_TARGET_ANUS)
								if(partner.has_anus(REQUIRE_EXPOSED))
									message = "обливает попку [partner_name] сквиртом."
									cumin = TRUE
								else
									message = "обливает спину [partner_name] сквиртом."
							if(CUM_TARGET_HAND)
								if(partner.has_hand())
									message = "обливает руку [partner_name] сквиртом."
								else
									message = "обливает [partner_name] сквиртом."
							if(CUM_TARGET_BREASTS)
								if(partner.has_breasts(REQUIRE_EXPOSED))
									message = "обливает грудь [partner_name] сквиртом."
								else
									message = "обливает [partner_name]'s chest and neck."
							if(NUTS_TO_FACE)
								if(partner.has_mouth() && partner.mouth_is_free())
									message = "энергично засовывает свои яйца в рот партнёра перед тем, как выпустить густое, липкое семя в глаза и волосы [partner_name]."

							if(THIGH_SMOTHERING)
								message = "держит [partner_name] между бёдрами, пока киска пульсирует, по итогу сливая пульсирующую нагрузку в лицо и волосы жертвы."

							if(CUM_TARGET_FEET)
								if(!last_lewd_datum || !last_lewd_datum.require_target_num_feet)
									if(partner.has_feet())
										message = "обливает [partner_name]'s [partner.has_feet() == 1 ? pick("стопу", "ножку") : pick("стопу", "ножку")]."
									else
										message = "обливает пространство под собой сквиртом!"
								else
									if(partner.has_feet())
										message = "обливает [partner_name]'s [last_lewd_datum.require_target_feet == 1 ? pick("стопу", "ножку") : pick("стопу", "ножку")]."
									else
										message = "обливает пространство под собой сквиртом!"
							//weird shit goes here
							if(CUM_TARGET_EARS)
								if(partner.has_ears())
									message = "обливает ухо [partner_name] сквиртом."
								else
									message = "обливает ушную раковину [partner_name] сквиртом."
								cumin = TRUE
							if(CUM_TARGET_EYES)
								if(partner.has_eyes())
									message = "обливает глаз [partner_name] сквиртом."
								else
									message = "обливает глазницу [partner_name] сквиртом."
								cumin = TRUE
							//
							if(CUM_TARGET_PENIS)
								if(partner.has_penis(REQUIRE_EXPOSED))
									message = "обливает пенис [partner_name] сквиртом"
								else
									message = "обливает пространство под собой сквиртом!"
							else
								message = "обливает пространство под собой сквиртом!"
					else
						message = pick("оргазмирует!", "трясётся в оргазме.", "дрожит от оргазма!")
		else if(istype(partner, /obj/item/reagent_containers))
			var/did_anything = TRUE
			switch(last_genital.type)
				if(/obj/item/organ/genital/penis)
					message = "кончает в [partner_name]!"
				if(/obj/item/organ/genital/vagina)
					message = "обливает [partner_name] горячим сквиртом!"
				else
					did_anything = FALSE
			if(did_anything)
				LAZYADD(obscure_to, src)
	if(partner_carbon_check && cumin)
		switch(target_orifice)
			if(CUM_TARGET_VAGINA)
				target_gen = c_partner.getorganslot(ORGAN_SLOT_VAGINA)
			if(CUM_TARGET_ANUS)
				target_gen = c_partner.getorganslot(ORGAN_SLOT_ANUS)
			if(CUM_TARGET_BREASTS)
				target_gen = c_partner.getorganslot(ORGAN_SLOT_BREASTS)
			if(CUM_TARGET_PENIS)
				target_gen = c_partner.getorganslot(ORGAN_SLOT_PENIS)
	if(gender == MALE)
		playlewdinteractionsound(loc, pick('modular_sand/sound/interactions/final_m1.ogg',
							'modular_sand/sound/interactions/final_m2.ogg',
							'modular_sand/sound/interactions/final_m3.ogg',
							'modular_sand/sound/interactions/final_m4.ogg',
							'modular_sand/sound/interactions/final_m5.ogg'), 90, 1, 0)
	else
		playlewdinteractionsound(loc, pick('modular_sand/sound/interactions/final_f1.ogg',
							'modular_sand/sound/interactions/final_f2.ogg',
							'modular_sand/sound/interactions/final_f3.ogg'), 70, 1, 0)
	if(!message)
		message = pick("оргазмирует!", "трясётся в оргазме.", "дрожит от оргазма!", "кончает на себя!")
	visible_message(message = span_userlove("<b>\The [src]</b> [message]"), ignored_mobs = get_unconsenting(ignored_mobs = obscure_to))
	multiorgasms += 1

	COOLDOWN_START(src, refractory_period, (rand(300, 900) - get_sexual_potency()))//sex cooldown
	if(multiorgasms < get_sexual_potency())
		if(ishuman(src))
			var/mob/living/carbon/human/H = src
			if(!partner)
				H.mob_climax(TRUE, "masturbation", "none")
			else if(istype(partner, /obj/item/reagent_containers))
				H.mob_fill_container(last_genital, partner, 0)
			else
				H.mob_climax(TRUE, "sex", partner, !cumin, target_gen, anonymous)
	set_lust(0)

	SEND_SIGNAL(src, COMSIG_MOB_POST_CAME, target_orifice, partner, cumin, last_genital)

	return TRUE

/mob/living/proc/is_fucking(mob/living/partner, orifice, obj/item/organ/genital/genepool, datum/interaction/lewd/lewd_datum)
	var/failed = FALSE
	if(partner)
		if(partner != last_partner)
			failed++
	if(orifice)
		if(orifice != last_orifice)
			failed++
	if(genepool)
		if(genepool != last_genital)
			failed++
	if(lewd_datum)
		if(lewd_datum != last_lewd_datum)
			failed++
	if(failed)
		return FALSE
	return TRUE

/mob/living/proc/set_is_fucking(mob/living/partner, orifice, obj/item/organ/genital/genepool)
	last_partner = partner
	last_orifice = orifice
	last_genital = genepool

/mob/living/proc/get_shoes(singular = FALSE)
	var/obj/A = get_item_by_slot(ITEM_SLOT_FEET)
	if(A)
		var/txt = A.name
		if(findtext (A.name,"the"))
			txt = copytext(A.name, 5, length(A.name)+1)
			if(singular)
				txt = copytext(A.name, 5, length(A.name))
			return txt
		else
			if(singular)
				txt = copytext(A.name, 1, length(A.name))
			return txt

///Handles the sex, if cumming returns true.
/mob/living/proc/handle_post_sex(amount, orifice, mob/living/partner, organ = null, cum_inside = FALSE, anonymous = FALSE)
	if(stat != CONSCIOUS)
		return FALSE

	if(amount)
		add_lust(amount)
	var/lust = get_lust()
	var/lust_tolerance = get_lust_tolerance()
	if(lust >= lust_tolerance)
		if(prob(10))
			to_chat(src, "<b>Вам трудно удержаться от оргазма!</b>")
			moan()
			return FALSE
		if(lust >= (lust_tolerance * 3))
			if(cum(partner, orifice, cum_inside, anonymous))
				return TRUE
	return FALSE

/mob/living/proc/get_unconsenting(extreme = FALSE, list/ignored_mobs)
	var/list/nope = list()
	nope += ignored_mobs
	for(var/mob/M in range(7, src))
		if(M.client)
			var/client/cli = M.client
			if(!(cli.prefs.toggles & VERB_CONSENT)) //Note: This probably could do with a specific preference
				nope += M
			else if(extreme && (cli.prefs.extremepref == "No"))
				nope += M
		else
			nope += M
	return nope
