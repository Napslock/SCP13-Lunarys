/datum/event/prison_break
	startWhen		= 5
	announceWhen	= 75

	var/releaseWhen = 60
	var/list/area/areas = list()		//List of areas to affect. Filled by start()

	var/eventDept = "Security"			//Department name in announcement
	var/list/areaName = list("D-Class Rehabilitation")	//Names of areas mentioned in AI and Engineering announcements
	var/list/areaType = list(/area/site53/llcz/dclass)	//Area types to include.
	var/list/areaNotType = list()		//Area types to specifically exclude.

/datum/event/prison_break/setup()
	announceWhen = rand(75, 105)
	releaseWhen = rand(60, 90)

	src.endWhen = src.releaseWhen+2

/datum/event/prison_break/announce()
	if(areas && areas.len > 0)
		command_announcement.Announce("[location_name()] airlock contact sensors have been open too long. Secure any compromised areas immediately.", "[eventDept] Alert", zlevels = affecting_z)


/datum/event/prison_break/start()
	for(var/area in GLOB.areas)
		var/area/A = area
		if(is_type_in_list(A,areaType) && !is_type_in_list(A,areaNotType))
			areas += A

	if(areas && areas.len > 0)
		var/my_department = "[location_name()] firewall subroutines"
		var/rc_message = "An unknown malicious program has been detected in the [english_list(areaName)] lighting and airlock control systems at [stationtime2text()]. Systems will be fully compromised within approximately three minutes. Direct intervention is required immediately.<br>"
		for(var/obj/machinery/message_server/MS in SSmachines.all_machinery)
			MS.send_rc_message("Engineering", my_department, rc_message, "", "", 2)
		for(var/mob/living/silicon/ai/A in GLOB.player_list)
			to_chat(A, "<span class='danger'>Malicious program detected in the [english_list(areaName)] lighting and airlock control systems by [my_department].</span>")

	else
		WRITE_LOG(world.log, "ERROR: Could not initate orange-tide. Unable to find suitable containment area.")
		kill()

/datum/event/prison_break/tick()
	if(activeFor == releaseWhen)
		if(areas && areas.len > 0)
			var/obj/machinery/power/apc/theAPC = null
			for(var/area/A in areas)
				theAPC = A.get_apc()
				if(theAPC && theAPC.operating)	//If the apc's off, it's a little hard to overload the lights.
					for(var/obj/machinery/light/L in A)
						L.flicker(10)


/datum/event/prison_break/end()
	for(var/area/A in shuffle(areas))
		A.prison_break()