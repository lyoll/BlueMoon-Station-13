/datum/interaction/handshake
	description = "Пожать руку."
	simple_message = "USER пожимает руку TARGET."
	interaction_sound = 'sound/weapons/thudswoosh.ogg'
	require_user_hands = TRUE
	needs_physical_contact = TRUE

/datum/interaction/pat
	description = "Похлопать по плечу."
	simple_message = "USER похлопал по плечу TARGET."
	interaction_sound = 'sound/weapons/thudswoosh.ogg'
	require_user_hands = TRUE
	needs_physical_contact = TRUE

/datum/interaction/cheer
	description = "Подбодрить!"
	require_user_mouth = TRUE
	simple_message = "USER подбадривает TARGET радостными выкриками!"

/datum/interaction/highfive
	description = "Дать пять!"
	require_user_mouth = TRUE
	simple_message = "USER даёт пять TARGET!"
	interaction_sound = 'modular_sand/sound/interactions/slap.ogg'
	needs_physical_contact = TRUE

/datum/interaction/headpat
	description = "Погладить по голове."
	require_user_hands = TRUE
	simple_message = "USER гладит TARGET по макушке головы!"
	needs_physical_contact = TRUE
	interaction_sound = 'sound/weapons/thudswoosh.ogg'

/datum/interaction/salute
	description = "Исполнить Воинское Приветствие!"
	require_user_hands = TRUE
	simple_message = "USER исполняет воинское приветствие при виде TARGET!"
	interaction_sound = 'sound/voice/salute.ogg'
	max_distance = 25

/datum/interaction/fistbump
	description = "Удариться кулачками!"
	require_user_hands = TRUE
	simple_message = "USER бьётся кулачком о кулачком TARGET! О да!"
	needs_physical_contact = TRUE

/datum/interaction/pinkypromise
	description = "Пообещать что-то на мизинчиках."
	require_user_hands = TRUE
	simple_message = "USER хватается своим мизинчиком за мизинчик TARGET! Клятва Мизинчиками! Давно пора!"
	needs_physical_contact = TRUE

/datum/interaction/bird
	description = "Показать Средний Палец"
	require_user_hands = TRUE
	simple_message = "USER демонстрирует TARGET средний палец! Туда его!!"
	max_distance = 25

/datum/interaction/holdhand
	description = "Взяться за руку."
	require_user_hands = TRUE
	simple_message = "USER хватается за руку TARGET."
	interaction_sound = 'sound/weapons/thudswoosh.ogg'
	needs_physical_contact = TRUE
	max_distance = 1
