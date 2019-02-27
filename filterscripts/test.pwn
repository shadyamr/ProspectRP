#include <a_samp>
#include <core>
#include <compat>
#include <float>
#include <sscanf2>
#include <sampvoice>

#include "../include/gl_common.inc"

main() {}

new SV_DLSTREAM:pstream[MAX_PLAYERS] = SV_NULL;

public SV_BOOL:OnPlayerVoice(SV_UINT:playerid, SV_PACKET:packet, SV_UINT:volume) 
{
	if (pstream[playerid]) sv_send_packet(packet, pstream[playerid]);
	return SV_TRUE;
}

public OnPlayerConnect(playerid)
{
	if (sv_get_version(playerid) == SV_NULL) SendClientMessage(playerid, -1, "You don't have our addon installed");
	else if (sv_get_version(playerid) < SV_VERSION) SendClientMessage(playerid, -1, "You've an outdated version of the addon.");
	else
	{
	    if (!sv_has_micro(playerid)) SendClientMessage(playerid, -1, "You do not have a microphone installed on your computer.");
	    else 
	    {
			sv_set_key(playerid, 0x42);
			pstream[playerid] = sv_dlstream_create_at_player(playerid);
			SendClientMessage(playerid, -1, "Press B.");
		}
	}
 	return true;
	
}

public OnPlayerDisconnect(playerid, reason)
{
	if (pstream[playerid]) sv_stream_delete(pstream[playerid]);
 	return true;
}

public OnGameModeInit()
{
	SetGameModeText("Shady's Test Server");
	sv_init(6000, SV_FREQUENCY_VERY_HIGH, SV_VOICE_RATE_100MS, 1.0, 1.0, 1.0);
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
	ShowNameTags(1);
	SetNameTagDrawDistance(40.0);
	EnableStuntBonusForAll(0);
	DisableInteriorEnterExits();
	SetWeather(2);
	SetWorldTime(11);
	AddPlayerClass(0,2495.3438,-1686.2836,13.5140,358.8068,0,0,0,0,0,0);
	AddPlayerClass(270,2517.7124,-1661.4698,14.2494,101.8945,0,0,0,0,0,0);
	AddPlayerClass(269,2498.7837,-1647.8068,13.5532,169.2618,0,0,0,0,0,0);
	AddPlayerClass(107,2486.7397,-1647.0914,14.0703,185.5319,0,0,0,0,0,0);
	AddPlayerClass(271,2465.4194,-1687.7552,13.5140,282.6660,0,0,0,0,0,0);
	AddPlayerClass(106,2498.7837,-1647.8068,13.5532,169.2618,0,0,0,0,0,0);
	AddPlayerClass(105,2498.7837,-1647.8068,13.5532,169.2618,0,0,0,0,0,0);
	LoadStaticVehiclesFromFile("vehicles/trains.txt");
	LoadStaticVehiclesFromFile("vehicles/pilots.txt");
	LoadStaticVehiclesFromFile("vehicles/lv_law.txt");
	LoadStaticVehiclesFromFile("vehicles/lv_airport.txt");
	LoadStaticVehiclesFromFile("vehicles/lv_gen.txt");
	LoadStaticVehiclesFromFile("vehicles/sf_law.txt");
	LoadStaticVehiclesFromFile("vehicles/sf_airport.txt");
	LoadStaticVehiclesFromFile("vehicles/sf_gen.txt");
	LoadStaticVehiclesFromFile("vehicles/ls_law.txt");
	LoadStaticVehiclesFromFile("vehicles/ls_airport.txt");
	LoadStaticVehiclesFromFile("vehicles/ls_gen_inner.txt");
	LoadStaticVehiclesFromFile("vehicles/ls_gen_outer.txt");
	LoadStaticVehiclesFromFile("vehicles/whetstone.txt");
	LoadStaticVehiclesFromFile("vehicles/bone.txt");
	LoadStaticVehiclesFromFile("vehicles/flint.txt");
	LoadStaticVehiclesFromFile("vehicles/tierra.txt");
	LoadStaticVehiclesFromFile("vehicles/red_county.txt");
	return true;
}