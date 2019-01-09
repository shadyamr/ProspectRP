/*
*
*	Shady's Roleplay by Shady Amr (ItzShady)
*	https://forum.sa-mp.com/member.php?u=240484
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
#include <foreach>
#include <izcmd>
#include <sscanf2>
#include <streamer>

enum PLAYER_DATA
{
	pSQL,
	pAdmin
}

#include "../gamemodes/scripts/server_config.srp"
#include "../gamemodes/scripts/mysql_config.srp"

new bool:LoggedIn[MAX_PLAYERS], PlayerData[MAX_PLAYERS][PLAYER_DATA];

main()
{
	print("\n-------------------------------------------------------");
	print("Shady's Roleplay has been sucessfully loaded!");
	print("-------------------------------------------------------\n");
}

public OnGameModeInit()
{
    SendRconCommand("hostname "SVR_NAME"");
    SendRconCommand("rcon_password "SVR_RCON"");
    SendRconCommand("weburl "SVR_WEBSITE"");
    SendRconCommand("mapname "SVR_LOCATION"");
    SendRconCommand("language "SVR_LANGUAGE"");
    SendRconCommand("password "SVR_PASSWORD"");
	SetGameModeText(SVR_VERSION);

	sqlConnection = mysql_connect(SQL_HOSTNAME, SQL_USERNAME, SQL_DATABASE, SQL_PASSWORD, SQL_PORT, SQL_AUTORECONNECT, SQL_GAMEPOOLSIZE);
	mysql_log(LOG_ERROR | LOG_WARNING, LOG_TYPE_HTML);
	return 1;
}

public OnGameModeExit()
{
	mysql_close(sqlConnection);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	return 1;
}

public OnPlayerConnect(playerid)
{
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

public OnPlayerSpawn(playerid)
{
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}