/*
*	  _   ___     _______  _____  
*	 | \ | \ \   / /  __ \|  __ \` 
*	 |  \| |\ \_/ /| |__) | |__) |
*	 |     | \   / |  _  /|  ___/ 
*	 | |\  |  | |  | | \ \| |     
*	 |_| \_|  |_|  |_|  \_\_|           
*
*	New York Roleplay by Shady Amr (ItzShady)
*	https://forum.sa-mp.com/member.php?u=240484
*	https://github.com/shadyamr
*
*	Script begun: January 9th, 2019
*
*	Copyright © 2019 by Shady Amr, All rights reserved. 
*	No part of this publication may be reproduced, distributed, or transmitted in any form or by any means, including
*	photocopying, recording, or other electronic or mechanical methods, without the prior written permission of the publisher, 
*	except in the case of brief quotations embodied in critical reviews and certain other noncommercial uses permitted by copyright law.
*	For permission requests, write to the publisher, addressed “Attention: Permissions Coordinator,” at the address below.
*
*/

#include <a_samp>
#include <a_mysql>
#include <compat>
#include <crashdetect>
#include <foreach>
#include <izcmd>
#include <sscanf2>
#include <streamer>

#include "../gamemodes/scripts/server_config.nyrp"
#include "../gamemodes/scripts/mysql_config.nyrp"

#include "../gamemodes/scripts/defines_variables_enums.nyrp"
#include "../gamemodes/scripts/public_functions.nyrp"
#include "../gamemodes/scripts/stock_functions.nyrp"

#include "../gamemodes/scripts/textdraws.nyrp"
#include "../gamemodes/scripts/maps.nyrp"
#include "../gamemodes/scripts/houses.nyrp"

#include "../gamemodes/scripts/showstats.nyrp"
#include "../gamemodes/scripts/commands.nyrp"

main(){}

public OnGameModeInit()
{
	SendRconCommand("hostname "SVR_NAME"");
    SendRconCommand("rcon_password "SVR_RCON"");
    SendRconCommand("weburl "SVR_WEBSITE"");
    SendRconCommand("mapname "SVR_LOCATION"");
    SendRconCommand("language "SVR_LANGUAGE"");
    SendRconCommand("password "SVR_PASSWORD"");
	SetGameModeText(SVR_GMTEXT);

	mysql_log(LOG_ERROR | LOG_WARNING, LOG_TYPE_HTML);
	sqlConnection = mysql_connect(SQL_HOSTNAME, SQL_USERNAME, SQL_DATABASE, SQL_PASSWORD);

    LoadServerHouses();

	EnableStuntBonusForAll(0);
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
	ShowNameTags(0);
	ManualVehicleEngineAndLights();
	DisableInteriorEnterExits();

	new hour, seconds, minute;
	gettime(hour, seconds, minute);
	SetWorldTime(hour);

	OneSecondTimer = SetTimer("TIMER_OneSecondTimer", 999, true);
	SetTimer("UpdateNametag", 500, true);

	Load_City();
	createLogRegTextdraw();
	return true;
}

public OnGameModeExit()
{
	KillTimer(OneSecondTimer);
	destroyLogRegTextdraw();
	mysql_close(sqlConnection);
	return true;
}

public OnPlayerConnect(playerid)
{
	new string[256];
	DefaultPlayerValues(playerid);
	SetPlayerColor(playerid, 0xAFAFAFFF);
	cNametag[playerid] = CreateDynamic3DTextLabel("Loading nametag...", 0xFFFFFFFF, 0.0, 0.0, 0.1, NT_DISTANCE, .attachedplayer = playerid, .testlos = 1);
	PlayAudioStreamForPlayer(playerid, "https://prospectrp.eu/prospect-intro.mp3");
	format(string, sizeof(string), "Welcome to New York Roleplay, %s {FFFFFF}[Version "SVR_VERSION" | www.ny-rp.eu]", NameRP(playerid));
	SendClientMessage(playerid, COLOR_LIGHTRED, string);

	// RP Name Checker
	if(!IsRPName(GetName(playerid)))
	{
		SendServerMessage(playerid, "You have been kicked for using a Non-RP name.");
		SendServerMessage(playerid, "Example of correct name is: Firstname_Lastname, McName_Lastname, Firstname_DiCaprio.");
		KickEx(playerid);
		return true;
	}

	DoesPlayerExist(playerid);
	SetTimerEx("TIMER_SetCameraPos", 1000, false, "i", playerid);

	//Login Screen textdraw
	showLogRegTextdraw(playerid);
 	LoginScreen[playerid][0] = CreatePlayerTextDraw(playerid, 256.266052, 61.666633, "New York");
	PlayerTextDrawLetterSize(playerid, LoginScreen[playerid][0], 0.899999, 3.599999);
	PlayerTextDrawTextSize(playerid, LoginScreen[playerid][0], 93.000000, 1288.000000);
	PlayerTextDrawAlignment(playerid, LoginScreen[playerid][0], 1);
	PlayerTextDrawColor(playerid, LoginScreen[playerid][0], -1);
	PlayerTextDrawSetShadow(playerid, LoginScreen[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, LoginScreen[playerid][0], 1);
	PlayerTextDrawBackgroundColor(playerid, LoginScreen[playerid][0], 255);
	PlayerTextDrawFont(playerid, LoginScreen[playerid][0], 3);
	PlayerTextDrawSetProportional(playerid, LoginScreen[playerid][0], 1);

	LoginScreen[playerid][1] = CreatePlayerTextDraw(playerid, 285.314544, 79.166656, "Roleplay~n~");
	PlayerTextDrawLetterSize(playerid, LoginScreen[playerid][1], 0.899999, 3.599999);
	PlayerTextDrawTextSize(playerid, LoginScreen[playerid][1], 180.000000, 180.000000);
	PlayerTextDrawAlignment(playerid, LoginScreen[playerid][1], 1);
	PlayerTextDrawColor(playerid, LoginScreen[playerid][1], 255);
	PlayerTextDrawSetShadow(playerid, LoginScreen[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, LoginScreen[playerid][1], 1);
	PlayerTextDrawBackgroundColor(playerid, LoginScreen[playerid][1], -1);
	PlayerTextDrawFont(playerid, LoginScreen[playerid][1], 0);
	PlayerTextDrawSetProportional(playerid, LoginScreen[playerid][1], 1);

	LoginScreen[playerid][2] = CreatePlayerTextDraw(playerid, 323.733642, 43.583335, "Welcome_to");
	PlayerTextDrawLetterSize(playerid, LoginScreen[playerid][2], 0.400000, 1.600000);
	PlayerTextDrawTextSize(playerid, LoginScreen[playerid][2], 0.000000, 788.000000);
	PlayerTextDrawAlignment(playerid, LoginScreen[playerid][2], 2);
	PlayerTextDrawColor(playerid, LoginScreen[playerid][2], -1);
	PlayerTextDrawUseBox(playerid, LoginScreen[playerid][2], 1);
	PlayerTextDrawBoxColor(playerid, LoginScreen[playerid][2], -2139062017);
	PlayerTextDrawSetShadow(playerid, LoginScreen[playerid][2], 1);
	PlayerTextDrawBackgroundColor(playerid, LoginScreen[playerid][2], 255);
	PlayerTextDrawFont(playerid, LoginScreen[playerid][2], 2);
	PlayerTextDrawSetProportional(playerid, LoginScreen[playerid][2], 1);

	TDEditor_TD[0] = TextDrawCreate(193.000000, 64.725906, "box");
	TextDrawLetterSize(TDEditor_TD[0], 0.000000, 18.366691);
	TextDrawTextSize(TDEditor_TD[0], 454.333221, 0.000000);
	TextDrawAlignment(TDEditor_TD[0], 1);
	TextDrawColor(TDEditor_TD[0], -1);
	TextDrawUseBox(TDEditor_TD[0], 1);
	TextDrawBoxColor(TDEditor_TD[0], 181);
	TextDrawSetShadow(TDEditor_TD[0], 0);
	TextDrawSetOutline(TDEditor_TD[0], 0);
	TextDrawBackgroundColor(TDEditor_TD[0], 54);
	TextDrawFont(TDEditor_TD[0], 1);
	TextDrawSetProportional(TDEditor_TD[0], 1);
	TextDrawSetShadow(TDEditor_TD[0], 0);

	TDEditor_TD[1] = TextDrawCreate(250.999969, 55.185157, "Welcome to ~B~New York Roleplay~w~!");
	TextDrawLetterSize(TDEditor_TD[1], 0.401333, 1.554370);
	TextDrawAlignment(TDEditor_TD[1], 1);
	TextDrawColor(TDEditor_TD[1], -1);
	TextDrawSetShadow(TDEditor_TD[1], 0);
	TextDrawSetOutline(TDEditor_TD[1], 1);
	TextDrawBackgroundColor(TDEditor_TD[1], 255);
	TextDrawFont(TDEditor_TD[1], 0);
	TextDrawSetProportional(TDEditor_TD[1], 1);
	TextDrawSetShadow(TDEditor_TD[1], 0);

	TDEditor_TD[2] = TextDrawCreate(194.333251, 74.681480, "New York_Roleplay_is_a_medium_to_heavy_roleplay_server._We_encourage_players");
	TextDrawLetterSize(TDEditor_TD[2], 0.202666, 0.857481);
	TextDrawAlignment(TDEditor_TD[2], 1);
	TextDrawColor(TDEditor_TD[2], -1);
	TextDrawSetShadow(TDEditor_TD[2], 0);
	TextDrawSetOutline(TDEditor_TD[2], 0);
	TextDrawBackgroundColor(TDEditor_TD[2], 255);
	TextDrawFont(TDEditor_TD[2], 1);
	TextDrawSetProportional(TDEditor_TD[2], 1);
	TextDrawSetShadow(TDEditor_TD[2], 0);

	TDEditor_TD[3] = TextDrawCreate(194.333251, 81.281379, "to develop their characters and to try to set goals to reach on the server.");
	TextDrawLetterSize(TDEditor_TD[3], 0.202666, 0.857481);
	TextDrawAlignment(TDEditor_TD[3], 1);
	TextDrawColor(TDEditor_TD[3], -1);
	TextDrawSetShadow(TDEditor_TD[3], 0);
	TextDrawSetOutline(TDEditor_TD[3], 0);
	TextDrawBackgroundColor(TDEditor_TD[3], 255);
	TextDrawFont(TDEditor_TD[3], 1);
	TextDrawSetProportional(TDEditor_TD[3], 1);
	TextDrawSetShadow(TDEditor_TD[3], 0);

	TDEditor_TD[4] = TextDrawCreate(194.333251, 87.981277, "The server's limitations are your imagination. If you think something ~n~could be added, suggest it. As a player you make_our_community.");
	TextDrawLetterSize(TDEditor_TD[4], 0.203333, 0.803555);
	TextDrawAlignment(TDEditor_TD[4], 1);
	TextDrawColor(TDEditor_TD[4], -1);
	TextDrawSetShadow(TDEditor_TD[4], 0);
	TextDrawSetOutline(TDEditor_TD[4], 0);
	TextDrawBackgroundColor(TDEditor_TD[4], 255);
	TextDrawFont(TDEditor_TD[4], 1);
	TextDrawSetProportional(TDEditor_TD[4], 1);
	TextDrawSetShadow(TDEditor_TD[4], 0);

	TDEditor_TD[5] = TextDrawCreate(212.333312, 135.659225, "~r~Things to remember:");
	TextDrawLetterSize(TDEditor_TD[5], 0.281999, 0.965333);
	TextDrawAlignment(TDEditor_TD[5], 1);
	TextDrawColor(TDEditor_TD[5], -1);
	TextDrawSetShadow(TDEditor_TD[5], 0);
	TextDrawSetOutline(TDEditor_TD[5], 1);
	TextDrawBackgroundColor(TDEditor_TD[5], 255);
	TextDrawFont(TDEditor_TD[5], 1);
	TextDrawSetProportional(TDEditor_TD[5], 1);
	TextDrawSetShadow(TDEditor_TD[5], 0);

	TDEditor_TD[6] = TextDrawCreate(215.333389, 149.348159, "-_Rule_breaking_is_not_tolerated,_you_will_be_banned.");
	TextDrawLetterSize(TDEditor_TD[6], 0.207000, 0.923851);
	TextDrawAlignment(TDEditor_TD[6], 1);
	TextDrawColor(TDEditor_TD[6], -1);
	TextDrawSetShadow(TDEditor_TD[6], 0);
	TextDrawSetOutline(TDEditor_TD[6], 1);
	TextDrawBackgroundColor(TDEditor_TD[6], 255);
	TextDrawFont(TDEditor_TD[6], 1);
	TextDrawSetProportional(TDEditor_TD[6], 1);
	TextDrawSetShadow(TDEditor_TD[6], 0);

	TDEditor_TD[7] = TextDrawCreate(215.366760, 157.763458, "- Trolling is a banable offence.");
	TextDrawLetterSize(TDEditor_TD[7], 0.207000, 0.923851);
	TextDrawAlignment(TDEditor_TD[7], 1);
	TextDrawColor(TDEditor_TD[7], -1);
	TextDrawSetShadow(TDEditor_TD[7], 0);
	TextDrawSetOutline(TDEditor_TD[7], 1);
	TextDrawBackgroundColor(TDEditor_TD[7], 255);
	TextDrawFont(TDEditor_TD[7], 1);
	TextDrawSetProportional(TDEditor_TD[7], 1);
	TextDrawSetShadow(TDEditor_TD[7], 0);

	TDEditor_TD[8] = TextDrawCreate(215.366760, 165.963958, "- Using third party modifications will result in an unappealable ban.");
	TextDrawLetterSize(TDEditor_TD[8], 0.199000, 0.923851);
	TextDrawAlignment(TDEditor_TD[8], 1);
	TextDrawColor(TDEditor_TD[8], -1);
	TextDrawSetShadow(TDEditor_TD[8], 0);
	TextDrawSetOutline(TDEditor_TD[8], 1);
	TextDrawBackgroundColor(TDEditor_TD[8], 255);
	TextDrawFont(TDEditor_TD[8], 1);
	TextDrawSetProportional(TDEditor_TD[8], 1);
	TextDrawSetShadow(TDEditor_TD[8], 0);
	return true;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_REGISTER:
		{
			if(!response)
			{
				SendServerMessage(playerid, "You were kicked for not registering.");
				return Kick(playerid);
			}
			if(strlen(inputtext) < 3 || strlen(inputtext) > 30)
			{
				ShowRegisterDialog(playerid, "[ERROR]:{FFFFFF} Password length must be above 3 characters AND below 30 characters long.");
				return true;
			}
			new query[1000];
			new year, month, day;
    		getdate(year, month, day);
    		format(PlayerData[playerid][pRegisterDate], 16, "%02d/%02d/%d", day, month, year);
			mysql_format(sqlConnection, query, sizeof(query), "INSERT INTO players (Name, Password, RegIP, RegDate) VALUES ('%e', sha1('%e'), '%e', '%e')", GetName(playerid), inputtext, GetIP(playerid), PlayerData[playerid][pRegisterDate]);
			mysql_pquery(sqlConnection, query, "SQL_OnAccountRegister", "i", playerid);
		}
		case DIALOG_LOGIN:
		{
			if(!response) return Kick(playerid);
			if(strlen(inputtext) < 3 || strlen(inputtext) > 30)
			{
				ShowLoginDialog(playerid, "[ERROR]:{FFFFFF} Password length must be above 3 characters AND below 30 characters long.");
				return true;
			}

			new query[1000];
			mysql_format(sqlConnection, query, sizeof(query), "SELECT id FROM players WHERE Name = '%e' AND Password = sha1('%e') LIMIT 1", GetName(playerid), inputtext);
			mysql_pquery(sqlConnection, query, "SQL_OnAccountLogin", "i", playerid);
		}
	}
	return false;
}

public OnPlayerDisconnect(playerid, reason)
{
	DefaultPlayerValues(playerid);
	if(IsValidDynamic3DTextLabel(cNametag[playerid])) DestroyDynamic3DTextLabel(cNametag[playerid]); 
	return true;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	if(issuerid != INVALID_PLAYER_ID)
	SaveDamageData(playerid, weaponid, bodypart, amount);
	return true;
}

public OnPlayerSpawn(playerid)
{
	ResetDamageData(playerid);
	hideLogRegTextdraw(playerid);
	StopAudioStreamForPlayer(playerid);
	return true;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	// TESTING PURPOSES
	SetPlayerPos(playerid, -88.9697, 1225.39, 19.7422);
	SetPlayerFacingAngle(playerid, 178.881);
	return true;
}

public OnPlayerUpdate(playerid)
{
	return true;
}

public OnPlayerText(playerid, text[]) 
{
    new msg[128];
    format(msg, sizeof(msg), "%s says: %s", NameRP(playerid), text);
    SendLocalMessage(playerid, COLOR_WHITE, msg);
    return false;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
	if(!success)
	{
		if(strlen(cmdtext) > 28) // Preventing long bad commands from returning default message;
			SendErrorMessage(playerid, "Sorry, that command doesn't exist. Use /help if you need assistance.");

		else
			SendErrorMessage(playerid, "Sorry, the command doesn't exist. Use /help if you need assistance.");
	}
	else return true;
	return true;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(oldstate == PLAYER_STATE_ONFOOT && newstate == PLAYER_STATE_DRIVER)
    {
        new vehicleid = GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective;
        GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
        if(engine == VEHICLE_PARAMS_OFF) SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_ON, lights, alarm, doors, bonnet, boot, objective);
    }
    else if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT)
    {
        new vehicleid = GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective;
        GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
        if(engine == VEHICLE_PARAMS_ON) SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_OFF, lights, alarm, doors, bonnet, boot, objective);
    }
    return true;
}
