/*
*	   _____                           _ _ _       
*	  / ____|                         (_) | |      
*	 | (___   ___ _ __ _ __ __ _ _ __  _| | | __ _ 
*	  \___ \ / _ \ '__| '__/ _` | '_ \| | | |/ _` |
*	  ____) |  __/ |  | | | (_| | | | | | | | (_| |
*	 |_____/ \___|_|  |_|  \__,_|_| |_|_|_|_|\__,_|         
*
*	Project Serranilla Roleplay by Shady Amr (ItzShady)
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
#include <dini>
#include <discord-connector>
#include <foreach>
#include <izcmd>
#include <sscanf2>
#include <streamer>

#include "../gamemodes/scripts/server_config.psrp"
#include "../gamemodes/scripts/mysql_config.psrp"

#include "../gamemodes/scripts/defines_variables_enums.psrp"
#include "../gamemodes/scripts/discord.psrp"
#include "../gamemodes/scripts/public_functions.psrp"
#include "../gamemodes/scripts/stock_functions.psrp"

#include "../gamemodes/scripts/textdraws.psrp"
#include "../gamemodes/scripts/island.psrp"
#include "../gamemodes/scripts/houses.psrp"
#include "../gamemodes/scripts/player_vehicles.psrp"

#include "../gamemodes/scripts/showstats.psrp"
#include "../gamemodes/scripts/commands.psrp"

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
    LoadMOTD();

	EnableStuntBonusForAll(0);
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
	ShowNameTags(0);
	ManualVehicleEngineAndLights();
	DisableInteriorEnterExits();
	UsePlayerPedAnims();
	LimitGlobalChatRadius(15.0);

	new hour, seconds, minute;
	gettime(hour, seconds, minute);
	SetWorldTime(hour);

	OneSecondTimer = SetTimer("TIMER_OneSecondTimer", 999, true);
	SetTimer("UpdateNametag", 500, true);

	Load_Island();
	createLogRegTextdraw();

	DiscordInit();

	/*if(!fexist("hma.cfg"))
	{
		new File:NewFile = fopen("hma.cfg", io_write);
		fwrite(NewFile, "1415.727905\r\n");
		fwrite(NewFile, "-1299.371093\r\n");
		fwrite(NewFile, "15.054657\r\n");
		fwrite(NewFile, "0\r\n");
		fwrite(NewFile, "New Agency!\r");
		fclose(NewFile);
	}
	HMAFile = fopen("hma.cfg", io_readwrite);

	new szTemp[128];
	for(new i = 0; i < 3; i++)
	{
		fread(HMAFile, szTemp, sizeof szTemp);
		fHMASafe_Loc[i] = floatstr(szTemp);
	}
	fread(HMAFile, szTemp, sizeof szTemp);
	iHMASafe_Val = strval(szTemp);
	fread(HMAFile, HMAMOTD, sizeof HMAMOTD);
	iFileLoaded = 1;*/
	return true;
}

public OnGameModeExit()
{
	KillTimer(OneSecondTimer);
	destroyLogRegTextdraw();
	//fclose(HMAFile);
	mysql_close(sqlConnection);
	DiscordExit();
	return true;
}

public OnPlayerConnect(playerid)
{
	new string[512];
	DefaultPlayerValues(playerid);
	SetPlayerColor(playerid, -1);
	cNametag[playerid] = CreateDynamic3DTextLabel("Loading nametag...", 0xFFFFFFFF, 0.0, 0.0, 0.1, NT_DISTANCE, .attachedplayer = playerid, .testlos = 1);
	PlayAudioStreamForPlayer(playerid, "https://prospectrp.eu/prospect-intro.mp3");
	format(string, sizeof(string), "Welcome to Project Serranilla Roleplay, %s {FFFFFF}[Version "SVR_VERSION" | www.ny-rp.eu]", NameRP(playerid));
	SendClientMessage(playerid, COLOR_LIGHTRED, string);

	DoesPlayerExist(playerid);
	SetTimerEx("TIMER_SetCameraPos", 1000, false, "i", playerid);

	// RP Name Checker
	if(!IsRPName(GetName(playerid)))
	{
		SendServerMessage(playerid, "You have been kicked for using a Non-RP name.");
		SendServerMessage(playerid, "Example of correct name is: Firstname_Lastname, McName_Lastname, Firstname_DiCaprio.");
		KickEx(playerid);
		return true;
	}

	if(_:logchannel == 0) logchannel = DCC_FindChannelById("545641478064701440");
	format(string, sizeof(string), "PSRP Local: %s has joined the server (IP: %s || %s)", NameRP(playerid), GetIP(playerid), GetDate());
	DCC_SendChannelMessage(logchannel, string);

	//Login Screen textdraw
	showLogRegTextdraw(playerid);
 	LoginScreen[playerid][0] = CreatePlayerTextDraw(playerid, 256.266052, 61.666633, "Project Serranilla");
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

	TDEditor_TD[1] = TextDrawCreate(250.999969, 55.185157, "Welcome to ~B~Project Serranilla Roleplay~w~!");
	TextDrawLetterSize(TDEditor_TD[1], 0.401333, 1.554370);
	TextDrawAlignment(TDEditor_TD[1], 1);
	TextDrawColor(TDEditor_TD[1], -1);
	TextDrawSetShadow(TDEditor_TD[1], 0);
	TextDrawSetOutline(TDEditor_TD[1], 1);
	TextDrawBackgroundColor(TDEditor_TD[1], 255);
	TextDrawFont(TDEditor_TD[1], 0);
	TextDrawSetProportional(TDEditor_TD[1], 1);
	TextDrawSetShadow(TDEditor_TD[1], 0);

	TDEditor_TD[2] = TextDrawCreate(194.333251, 74.681480, "Project Serranilla_Roleplay_is_a_medium_to_heavy_roleplay_server._We_encourage_players");
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
	SavePlayerToDB(playerid);
	DefaultPlayerValues(playerid);
	if(IsValidDynamic3DTextLabel(cNametag[playerid])) DestroyDynamic3DTextLabel(cNametag[playerid]);

	new szString[64], str[256];
	new szDisconnectReason[3][] =
    {
        "Timeout/Crash",
        "Quit",
        "Kick/Ban"
    };

    format(szString, sizeof szString, "PSRP Local: %s left the server. ({FFFFFF}%s{AFAFAF})", NameRP(playerid), szDisconnectReason[reason]);
    SendLocalMessageEx(playerid, COLOR_GREY, szString, 20.0);
	
	if(_:logchannel == 0) logchannel = DCC_FindChannelById("545641478064701440");
	format(str, sizeof(str), "PSRP Local: %s has left the server (Reason: %s || %s)", NameRP(playerid), szDisconnectReason[reason], GetIP(playerid), GetDate());
	DCC_SendChannelMessage(logchannel, str);
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
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	AddPlayerClass(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	Streamer_Update(playerid);
	ResetDamageData(playerid);
	hideLogRegTextdraw(playerid);
	StopAudioStreamForPlayer(playerid);

	if(Injured[playerid] == 1)
	{
		SetPlayerPos(playerid, InjuredX, InjuredY, InjuredZ);
		SetPlayerFacingAngle(playerid, InjuredA);
		SetPlayerSkin(playerid, InjuredSkin);
		SetCameraBehindPlayer(playerid);
		// to be adjusted
		SendClientMessage(playerid, COLOR_LIGHTRED, "You are injured.");
		SendClientMessage(playerid, COLOR_LIGHTRED, "Either wait for assistance or /acceptdeath.");
		AcceptDeathTimer[playerid] = SetTimer("CanAcceptDeath", 60000, false);
		LoseHealthTimer[playerid] = SetTimer("LoseHealth", 10000, true);
		ApplyAnimation(playerid, "CRACK", "crckdeth2", 4.0, 1, 0, 0, 1, 0, 1);
	}

	if(Hospitalized[playerid] == 1)
	{
		SetTimer("HospitalTimer", 10000, false);
		TogglePlayerControllable(playerid, 0);
		SetPlayerPos(playerid, 1169.9645, -1323.8893, 15.6929);
		SetPlayerCameraPos(playerid, 1201.5150, -1323.3530, 24.7329);
		SetPlayerCameraLookAt(playerid, 1173.2358, -1323.2872, 19.4348);

		new string[100];
		SendClientMessage(playerid, COLOR_RED, "");
		SendClientMessage(playerid, COLOR_RED, "San Andreas Medical Service");
		format(string, sizeof(string), "Patient:{FFFFFF} %s", NameRP(playerid));
		SendClientMessage(playerid, COLOR_RED, string);
		format(string, sizeof(string), "Time of Arrival:{FFFFFF} %s", GetDate());
		SendClientMessage(playerid, COLOR_RED, string);
		SendClientMessage(playerid, COLOR_RED, "Attended by:{FFFFFF} All Saints General Hospital");
		SendClientMessage(playerid, COLOR_RED, "Hospital Bill:{FFFFFF} $100");
		SendClientMessage(playerid, COLOR_RED, "");
	}
	return true;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(Injured[playerid] == 0)
	{
		Injured[playerid] = 1;
		GetPlayerPos(playerid, InjuredX, InjuredY, InjuredZ);
		GetPlayerFacingAngle(playerid, InjuredA);
		InjuredSkin = GetPlayerSkin(playerid);
	}
	else if(Injured[playerid] == 1)
	{
		KillTimer(AcceptDeathTimer[playerid]);
	    KillTimer(LoseHealthTimer[playerid]);
		AcceptDeath[playerid] = 0;
		Injured[playerid] = 0;
		Hospitalized[playerid] = 1;
	}
	return true;
}

public OnPlayerUpdate(playerid)
{
	if(Injured[playerid] == 1 && GetPlayerAnimationIndex(playerid) != 386)
	{
		ApplyAnimation(playerid, "CRACK", "crckdeth2", 4.0, 1, 0, 0, 1, 0, 1);
	}

	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK)
	{
		if(PlayerData[playerid][pAdminLevel] == 0)
		{
			SendServerMessage(playerid, "You have been kicked from the server for attempting to use a jetpack.");
			KickEx(playerid);
		}
	}
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
		//SendErrorMessage(playerid, "Sorry, that command does not exist. /help if you're in need of assistance.");
		new cmdstring[256];
		format(cmdstring, sizeof(cmdstring),"[COMMAND FAILURE]{FFFFFF} The command '{993333}%s{FFFFFF}' does not exist, if you believe this is a bug then please use /bugreport.", cmdtext);
        SendClientMessage(playerid, COLOR_CMDERROR, cmdstring);
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

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerSpawn(playerid);
	return true;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	new playerip[16];
	foreach(new i: Player)
	{
		if(IsPlayerConnected(i))
		{
			GetPlayerIp(i, playerip, 16);
			if(!strcmp(playerip, ip, true))
			{
				if(success) return KickEx(i); 
				else
				{
					printf("FAILED RCON LOGIN BY IP %s USING PASSWORD %s", ip, password);
				}
			}
		}
	}
	return true;
}