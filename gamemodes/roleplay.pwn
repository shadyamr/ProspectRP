/*
*	   _____ _    _          _______     __
*	  / ____| |  | |   /\   |  __ \ \   / /
*	 | (___ | |__| |  /  \  | |  | \ \_/ / 
*	  \___ \|  __  | / /\ \ | |  | |\   /  
*	  ____) | |  | |/ ____ \| |__| | | |   
*	 |_____/|_|  |_/_/    \_\_____/  |_|   
*
*	Shady's Roleplay by Shady Amr (ItzShady)
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
#include <compact>
#include <foreach>
#include <izcmd>
#include <sscanf2>
#include <streamer>

#include "../gamemodes/scripts/server_config.srp"
#include "../gamemodes/scripts/mysql_config.srp"
#include "../gamemodes/scripts/defines_variables_enums.srp"

#include "../gamemodes/scripts/public_functions.srp"
#include "../gamemodes/scripts/stock_functions.srp"

#include "../gamemodes/scripts/maps/city.srp"

#include "../gamemodes/scripts/commands/general.srp"
#include "../gamemodes/scripts/commands/account.srp"

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

	ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
	ShowNameTags(0);

	new hour, seconds, minute;
	gettime(hour, seconds, minute);
	SetWorldTime(hour);

	OneSecondTimer = SetTimer("TIMER_OneSecondTimer", 999, true);
	SetTimer("UpdateNametag", 500, true);

	Load_City();
	return true;
}

public OnGameModeExit()
{
	KillTimer(OneSecondTimer);
	mysql_close(sqlConnection);
	return true;
}

public OnPlayerConnect(playerid)
{
	DefaultPlayerValues(playerid);
	DoesPlayerExist(playerid);
	SetPlayerColor(playerid, 0xAFAFAFFF);
	SetTimerEx("TIMER_SetCameraPos", 1000, false, "i", playerid);
	cNametag[playerid] = CreateDynamic3DTextLabel("Loading nametag...", 0xFFFFFFFF, 0.0, 0.0, 0.1, NT_DISTANCE, .attachedplayer = playerid, .testlos = 1);
	return true;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_REGISTER:
		{
			if(!response) return Kick(playerid);
			if(strlen(inputtext) < 3 || strlen(inputtext) > 30)
			{
				ShowRegisterDialog(playerid, "[Error]:{FFFFFF} Password length must be above 3 characters AND below 30 characters long.");
				return true;
			}
			new query[1000];
			mysql_format(sqlConnection, query, sizeof(query), "INSERT INTO players (Name, Password, RegIP) VALUES ('%e', sha1('%e'), '%e')", GetName(playerid), inputtext, GetIP(playerid));
			mysql_pquery(sqlConnection, query, "SQL_OnAccountRegister", "i", playerid);
		}
		case DIALOG_LOGIN:
		{
			if(!response) return Kick(playerid);
			if(strlen(inputtext) < 3 || strlen(inputtext) > 30)
			{
				ShowLoginDialog(playerid, "[Error]:{FFFFFF} Password length must be above 3 characters AND below 30 characters long.");
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

public OnPlayerDeath(playerid, killerid, reason)
{
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