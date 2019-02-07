#include <a_samp>
#include <easydb2>
#include <zcmd>
#include <sscanf2>
#include <dialogs>
#include <streamer>

/*======== Database structure ========

Main table - factions

Table name: Factions
Table structure:
1. Faction name - String
2. Faction type - integer
3. Faction locker coordinations - Split in X/Y/Z coords - Float
4. Creation date
5. Faction members limit

======== End Of Database structure ========*/

/*======== Database components ========*/

new FactionTable;
new PlayerTable;

/*======== Other components ========*/

// Global string for skins

new sString[1000];

// SKIN & WEAPON CONFIGURATIONS

enum FactionWeapons {
	wid,
	weaponid,
	wammo,
	wep_name[36]
}

enum FactionSkins {
	sid,
	skinID,
	skinName[36],
	skinGender[10]
}

new LawSkins[][FactionSkins] =
{
	{0, 284, "LSPD", "Male"},
	{1, 285, "LSPD", "Male"}
};

new FireSkins[][FactionSkins] =
{
	{0, 274, "Fire", "Male"},
	{1, 308, "Fire", "Female"}
};

new GovSkins[][FactionSkins] =
{
	{0, 165, "Gov", "Male"},
	{1, 211, "Gov", "Female"}
};

new LawWeaps[][FactionWeapons] =
{
	{0, 3, 1, "Nightstick"},
	{1, 24, 100, "Desert Eagle"},
	{2, 25, 100, "Shotgun"},
	{3, 29, 200, "MP5"},
	{4, 31, 300, "M4"},
	{5, 34, 50, "Sniper"}
};

new FireWeaps[][FactionWeapons] =
{
	{0, 3, 1, "Nightstick"},
	{1, 42, 100, "Fire Extinguisher"},
	{2, 43, 100, "Camera"}
};

new GovWeaps[][FactionWeapons] =
{
	{0, 3, 1, "Nightstick"},
	{1, 24, 100, "Desert Eagle"}
};

// FACTION TYPE CONFIGURATION

#define LAW 1
#define FIRE 2
#define GOV 3

// DEBUG_MODE ACTIVATION - COMMENT IF YOU DO NOT WANT DEBUGGING

#define DEBUG_MODE

#define MAX_FACTIONS 10
#define FACTION_RANKS 10
#define MAX_FACTION_RANK_NAME 36

enum FactionComponents
{
	fID,
	dbID,
	fName[36],
	fType,
	Float:fX,
	Float:fY,
	Float:fZ,
	date[36],
	fMembers,
	Text3D:fLabel,
	fLimit
}

new FactionInfo[MAX_FACTIONS][FactionComponents];
new FactionRanks[MAX_FACTIONS][FACTION_RANKS][MAX_FACTION_RANK_NAME];

enum PlayerInformation
{
	pID,
	pName[MAX_PLAYER_NAME],
	pFaction,
	pRank
}

new PlayerInfo[MAX_PLAYERS][PlayerInformation];

/*======== Functions ========*/

stock WeaponToModel(wepid)
{
     switch(wepid)
     {
	     case 1: return 331;
	     case 2: return 333;
	     case 3: return 334;
	     case 4: return 335;
	     case 5: return 336;
	     case 6: return 337;
	     case 7: return 338;
	     case 8: return 339;
	     case 9: return 341;
	     case 10: return 321;
	     case 11: return 322;
	     case 12: return 323;
	     case 13: return 324;
	     case 14: return 325;
	     case 15: return 326;
	     case 16: return 342;
	     case 17: return 343;
	     case 18: return 344;
	     case 22: return 346;
	     case 23: return 347;
	     case 24: return 348;
	     case 25: return 349;
	     case 26: return 350;
	     case 27: return 351;
	     case 28: return 352;
	     case 29: return 353;
	     case 30: return 355;
	     case 31: return 356;
	     case 32: return 372;
	     case 33: return 357;
	     case 34: return 358;
	     case 35: return 359;
	     case 36: return 360;
	     case 37: return 361;
	     case 38: return 362;
	     case 39: return 363;
	     case 40: return 364;
	     case 41: return 365;
	     case 42: return 366;
	     case 43: return 367;
	     case 44: return 368;
	     case 45: return 369;
	     case 46: return 371;
     }
     return 0;
}

stock ReturnFactionSkin(playerid)
{
	new facID = PlayerInfo[playerid][pFaction];
	new _temp[100];

	if(FactionInfo[facID][fType] == LAW)
	{
	    sString = "";
		for(new i; i < sizeof LawSkins; i ++)
		{

		    format(_temp, sizeof _temp, "%d\n%s (%s)\n", LawSkins[i][skinID], LawSkins[i][skinName], LawSkins[i][skinGender]);
		    strcat(sString, _temp, sizeof sString);
		}
	}
	else if(FactionInfo[facID][fType] == FIRE)
	{
	    sString = "";
		for(new i; i < sizeof LawSkins; i ++)
		{
		    format(_temp, sizeof _temp, "%d\n%s (%s)\n", FireSkins[i][skinID], FireSkins[i][skinName], FireSkins[i][skinGender]);
		    strcat(sString, _temp, sizeof sString);
		}
	}
	else if(FactionInfo[facID][fType] == GOV)
	{
	    sString = "";
		for(new i; i < sizeof LawSkins; i ++)
		{
		    format(_temp, sizeof _temp, "%d\n%s (%s)\n", GovSkins[i][skinID], GovSkins[i][skinName], GovSkins[i][skinGender]);
		    strcat(sString, _temp, sizeof sString);
		}
	}
	return sString;
}

stock ReturnFactionWeapons(playerid)
{
	new facID = PlayerInfo[playerid][pFaction];
	new _temp[100];

	if(FactionInfo[facID][fType] == LAW)
	{
	    sString = "";
		for(new i; i < sizeof LawWeaps; i ++)
		{

		    format(_temp, sizeof _temp, "%d\n%s (Ammo: %d)\n", WeaponToModel(LawWeaps[i][weaponid]), LawWeaps[i][wep_name], LawWeaps[i][wammo]);
		    strcat(sString, _temp, sizeof sString);
		}
	}
	else if(FactionInfo[facID][fType] == FIRE)
	{
	    sString = "";
		for(new i; i < sizeof FireWeaps; i ++)
		{
		    format(_temp, sizeof _temp, "%d\n%s (%s)\n", WeaponToModel(FireWeaps[i][weaponid]), FireWeaps[i][wep_name], FireWeaps[i][wammo]);
		    strcat(sString, _temp, sizeof sString);
		}
	}
	else if(FactionInfo[facID][fType] == GOV)
	{
	    sString = "";
		for(new i; i < sizeof GovWeaps; i ++)
		{
		    format(_temp, sizeof _temp, "%d\n%s (%s)\n", WeaponToModel(GovWeaps[i][weaponid]), GovWeaps[i][wep_name], GovWeaps[i][wammo]);
		    strcat(sString, _temp, sizeof sString);
		}
	}
	return sString;
}
/*
stock ReturnGovSkins()
{
	sString = "";
	for(new i; i < sizeof LawSkins; i ++)
	{
	    new _temp[100];
	    format(_temp, sizeof _temp, "%d\n%s (%s)\n", GovSkins[i][skinID], GovSkins[i][skinName], GovSkins[i][skinGender]);
	    strcat(sString, _temp, sizeof sString);
	}
	return sString;
}

stock ReturnFireSkins()
{
    sString = "";
	for(new i; i < sizeof LawSkins; i ++)
	{
	    new _temp[100];
	    format(_temp, sizeof _temp, "%d\n%s (%s)\n", FireSkins[i][skinID], FireSkins[i][skinName], FireSkins[i][skinGender]);
	    strcat(sString, _temp, sizeof sString);
	}
	return sString;
}

stock ReturnLawSkins()
{
	sString = "";
	for(new i; i < sizeof LawSkins; i ++)
	{
	    new _temp[100];
	    format(_temp, sizeof _temp, "%d\n%s (%s)\n", LawSkins[i][skinID], LawSkins[i][skinName], LawSkins[i][skinGender]);
	    strcat(sString, _temp, sizeof sString);
	}
	return sString;
}
*/
stock GiveFactionSkin(playerid, skinid)
{
	new facID = PlayerInfo[playerid][pFaction];
	if(FactionInfo[facID][fType] == LAW)
	{
		SetPlayerSkin(playerid, LawSkins[skinid][skinID]);
	}
	else if(FactionInfo[facID][fType] == FIRE)
	{
	    SetPlayerSkin(playerid, FireSkins[skinid][skinID]);
	}
	else if(FactionInfo[facID][fType] == GOV)
	{
	    SetPlayerSkin(playerid, GovSkins[skinid][skinID]);
	}
	return 1;
}

stock GiveFactionWeapon(playerid, wepid)
{
	new facID = PlayerInfo[playerid][pFaction];
	if(FactionInfo[facID][fType] == LAW)
	{
		GivePlayerWeapon(playerid, LawWeaps[wepid][weaponid], LawWeaps[wepid][wammo]);
	}
	else if(FactionInfo[facID][fType] == FIRE)
	{
	    GivePlayerWeapon(playerid, FireWeaps[wepid][weaponid], FireWeaps[wepid][wammo]);
	}
	else if(FactionInfo[facID][fType] == GOV)
	{
	    GivePlayerWeapon(playerid, GovWeaps[wepid][weaponid], GovWeaps[wepid][wammo]);
	}
	return 1;
}

stock ReturnDBID(facid)
{
	if(IsValidFactionID(facid)) return FactionInfo[facid][dbID];
	return 0;
}

stock ReturnFactionID(dbid)
{
	for(new i; i < MAX_FACTIONS; i ++)
	{
	    if(FactionInfo[i][dbID] == dbid)
	    {
	        return i;
		}
	}
	return 0;
}

stock GetRankName(factionid, rank)
{
	new _rname[36];
	if(IsValidFactionID(factionid))
	{
	    if(rank < FACTION_RANKS)
		{
			format(_rname, sizeof _rname, FactionRanks[factionid][rank]);
		}
	}
	return _rname;
}

stock IsPlayerInAFaction(playerid)
{
	if(PlayerInfo[playerid][pFaction] != -1)
	{
	    return 1;
	}
	else return 0;
}

stock IsValidFactionID(id)
{
	if(FactionInfo[id][dbID] != 0)
	{
	    return 1;
	}
	else return 0;
}

stock CheckFactionsDB()
{
    // Assigning our table the ID for further usage

    FactionTable = DB::VerifyTable("Factions", "id");

	// Checking if table data exists (Factions table)

	DB::VerifyColumn(FactionTable, "FactionName", DB::TYPE_STRING, "N/A");
	DB::VerifyColumn(FactionTable, "fType", DB::TYPE_STRING, "0");
	DB::VerifyColumn(FactionTable, "LockerX", DB::TYPE_FLOAT, 0);
	DB::VerifyColumn(FactionTable, "LockerY", DB::TYPE_FLOAT, 0);
	DB::VerifyColumn(FactionTable, "LockerZ", DB::TYPE_FLOAT, 0);
	DB::VerifyColumn(FactionTable, "CreationDate", DB::TYPE_STRING, "");
	DB::VerifyColumn(FactionTable, "FactionLimit", DB::TYPE_STRING, "10");
	DB::VerifyColumn(FactionTable, "FactionMembers", DB::TYPE_STRING, "0");
	DB::VerifyColumn(FactionTable, "Reference", DB::TYPE_STRING, "Reference");

	new string[35], _loopcount = 0;

	for( new i ; i < FACTION_RANKS; i ++)
	{
	    format(string, sizeof string, "FactionRank%d", _loopcount);
		DB::VerifyColumn(FactionTable, string, DB::TYPE_STRING, "");
		_loopcount++;
	}
	return 1;
}

stock CheckPlayersDB()
{
	PlayerTable = DB::VerifyTable("Players", "id");

	DB::VerifyColumn(PlayerTable, "PlayerName", DB::TYPE_STRING, "null");
	DB::VerifyColumn(PlayerTable, "FactionID", DB::TYPE_STRING, "-1");
	DB::VerifyColumn(PlayerTable, "PlayerRank", DB::TYPE_STRING, "-1");
	return 1;
}

stock ResetPlayerVariables(playerid)
{
	PlayerInfo[playerid][pID] = -1;
	format(PlayerInfo[playerid][pName], MAX_PLAYER_NAME, "");
	PlayerInfo[playerid][pFaction] = -1;
	PlayerInfo[playerid][pRank] = -1;
	return 1;
}

stock SavePlayer(playerid)
{
	DB::MultiSet(PlayerTable, PlayerInfo[playerid][pID], "sii",
	"PlayerName", PlayerInfo[playerid][pName],
	"FactionID", FactionInfo[PlayerInfo[playerid][pFaction]][dbID],
	"PlayerRank", PlayerInfo[playerid][pRank]);
	return 1;
}

stock CreatePlayer(playerid)
{
    new playername[MAX_PLAYER_NAME];
	GetPlayerName(playerid, playername, MAX_PLAYER_NAME);

    DB::CreateRow(PlayerTable, "PlayerName", playername);

    new pid = DB::RetrieveKey(PlayerTable, _, _, "PlayerName", playername);

	DB::SetIntEntry(PlayerTable, pid, "FactionID", 0);
	DB::SetIntEntry(PlayerTable, pid, "PlayerRank", -1);

	#if defined DEBUG_MODE
	    printf("[PLAYER CREATION] %s with ID %d", playername, pid);
	#endif
	return 1;
}

stock CheckPlayer(playerid)
{
    new playername[MAX_PLAYER_NAME];
	GetPlayerName(playerid, playername, MAX_PLAYER_NAME);

	new id = DB::RetrieveKey(PlayerTable, _, _, "PlayerName", playername);

	if(id != DB::INVALID_KEY) LoadPlayer(playerid);
	else CreatePlayer(playerid);
	return 1;
}

stock LoadPlayer(playerid)
{
	new playername[MAX_PLAYER_NAME];
	GetPlayerName(playerid, playername, MAX_PLAYER_NAME);

	new id = DB::RetrieveKey(PlayerTable, _, _, "PlayerName", playername);

	DB::MultiGet(PlayerTable, id, "isii",
	"id", PlayerInfo[playerid][pID],
	"PlayerName", PlayerInfo[playerid][pName],
	"FactionID", PlayerInfo[playerid][pFaction],
	"PlayerRank", PlayerInfo[playerid][pRank]);

	PlayerInfo[playerid][pFaction] = ReturnFactionID(PlayerInfo[playerid][pFaction]);

	#if defined DEBUG_MODE
	    printf("[PLAYER LOADED] %s with Faction ID [%d] and Player Rank [%d]", PlayerInfo[playerid][pName], PlayerInfo[playerid][pFaction], PlayerInfo[playerid][pRank]);
	#endif
	return 1;
}

stock ReturnLastKey()
{
	return DB::GetRowsPoolSize(FactionTable);
}

stock GetAvailableRankID(factionid)
{
	for(new i; i < FACTION_RANKS; i++)
	{
		if(isnull(FactionRanks[factionid][i]))
		{
		    return i;
		}
	}
	return 0;
}

stock GetAvailableFactionID()
{
	new id;
	for(new i; i < MAX_FACTIONS; i++)
	{
	    if(FactionInfo[i][dbID] == 0)
		{
	        id = i;
	        break;
		}
	}
	return id;
}

stock UnloadFactions()
{
	new count;

	for(new i=0; i < MAX_FACTIONS;i ++)
	{
	    if(FactionInfo[i][dbID] != 0)
	    {
			count++;
	        FactionInfo[i][dbID] = 0;
	        DestroyDynamic3DTextLabel(FactionInfo[i][fLabel]);
		}
	}
	printf("%d factions cleared!", count);
	return 1;
}

stock LoadFactions()
{
	new FactionDBID[MAX_FACTIONS], string[45];
	new factionID, fcount;

	UnloadFactions();

    DB::RetrieveKey(FactionTable, FactionDBID, _, "Reference", "Reference");

	for(new i=0; i < MAX_FACTIONS; i++)
	{
		if(FactionDBID[i] != DB::INVALID_KEY)
		{
		    new franks = 0;

		    factionID = GetAvailableFactionID();

		    fcount++;

		    FactionInfo[factionID][fID] = factionID;
		    FactionInfo[factionID][dbID] = DB::GetIntEntry(FactionTable, FactionDBID[i], "id");
		    FactionInfo[factionID][fLimit] = DB::GetIntEntry(FactionTable, FactionDBID[i], "FactionLimit");
		    FactionInfo[factionID][fX] = DB::GetFloatEntry(FactionTable, FactionDBID[i], "LockerX");
		    FactionInfo[factionID][fY] = DB::GetFloatEntry(FactionTable, FactionDBID[i], "LockerY");
		    FactionInfo[factionID][fZ] = DB::GetFloatEntry(FactionTable, FactionDBID[i], "LockerZ");

		    FactionInfo[factionID][fType] = DB::GetIntEntry(FactionTable, FactionDBID[i], "fType");

		    FactionInfo[factionID][fMembers] = DB::GetIntEntry(FactionTable, FactionDBID[i], "FactionMembers");

		    DB::GetStringEntry(FactionTable, FactionDBID[i], "FactionName", FactionInfo[factionID][fName], 36);
		    DB::GetStringEntry(FactionTable, FactionDBID[i], "CreationDate", FactionInfo[factionID][date], 36);

		    for(new y; y < FACTION_RANKS; y++)
		    {
		        format(string, sizeof string, "FactionRank%d", franks);
		        DB::GetStringEntry(FactionTable, FactionDBID[i], string, FactionRanks[factionID][y], MAX_FACTION_RANK_NAME);

		        #if defined DEBUG_MODE
		            printf("Faction rank loaded: %s under slot %d", FactionRanks[factionID][y], franks);
				#endif
				franks++;
			}
			#if defined DEBUG_MODE
		    	printf("__________________________________________________________");
		    	printf("[FACTION LOADED] %s has been created under in-game id of %d and DB ID of %d", FactionInfo[factionID][fName], factionID, FactionInfo[factionID][dbID]);
			#endif

			format(string, sizeof string, "[%s lockers]", FactionInfo[factionID][fName]);
		    FactionInfo[factionID][fLabel] = CreateDynamic3DTextLabel(string, -1, FactionInfo[factionID][fX], FactionInfo[factionID][fY], FactionInfo[factionID][fZ], 30, INVALID_PLAYER_ID, INVALID_VEHICLE_ID);
		}
	}
    printf("__________________________________________________________");
    printf("[FACTION LOAD] A total of %d faction/s has been loaded!", fcount);
	return 1;
}

stock SaveFaction(facid)
{
	new _temp, _stemp[40], string[45];
	new dbid = FactionInfo[facid][dbID];

    DestroyDynamic3DTextLabel(FactionInfo[facid][fLabel]);
    
    DB::MultiSet(FactionTable, dbid, "sifffsi",
    "FactionName", FactionInfo[facid][fName],
    "fType", FactionInfo[facid][fType],
    "LockerX", FactionInfo[facid][fX],
    "LockerY", FactionInfo[facid][fY],
    "LockerZ", FactionInfo[facid][fZ],
    "CreationDate", FactionInfo[facid][date],
    "FactionMembers", FactionInfo[facid][fMembers]);

    for(new i; i < FACTION_RANKS;i++)
    {
        format(_stemp, sizeof _stemp, "FactionRank%d", _temp);
        DB::SetStringEntry(FactionTable, dbid, _stemp, FactionRanks[facid][i]);

        _temp++;
	}
	
	format(string, sizeof string, "[%s lockers]", FactionInfo[facid][fName]);
	FactionInfo[facid][fLabel] = CreateDynamic3DTextLabel(string, -1, FactionInfo[facid][fX], FactionInfo[facid][fY], FactionInfo[facid][fZ], 30, INVALID_PLAYER_ID, INVALID_VEHICLE_ID);
	
    return 1;
}

stock CreateFaction(fname[], Float:PlayerPosX, Float:PlayerPosY, Float:PlayerPosZ, ftype)
{
    DB::CreateRow(FactionTable, "FactionName", fname);

	new year, month, day;

	getdate(year, month, day);

    new fcID = GetAvailableFactionID();

    FactionInfo[fcID][dbID] = ReturnLastKey();
	FactionInfo[fcID][fID] = fcID;

	FactionInfo[fcID][fType] = ftype;
	FactionInfo[fcID][fX] = PlayerPosX;
	FactionInfo[fcID][fY] = PlayerPosY;
	FactionInfo[fcID][fZ] = PlayerPosZ;

	new cdate[30];
	format(cdate, sizeof cdate, "%02d/%02d/%d", day, month, year);

	DB::SetLastIntEntry(FactionTable, "fType", ftype, "Reference");
	DB::SetLastFloatEntry(FactionTable, "LockerX", PlayerPosX, "Reference");
	DB::SetLastFloatEntry(FactionTable, "LockerY", PlayerPosY, "Reference");
	DB::SetLastFloatEntry(FactionTable, "LockerZ", PlayerPosZ, "Reference");
	DB::SetLastStringEntry(FactionTable, "CreationDate", cdate, "Reference");

	LoadFactions();

	#if defined DEBUG_MODE
	    printf("[FACTION CREATION] %s has been created today (%s). [IG ID: %d | SQL ID: %d]", fname, cdate, fcID, FactionInfo[fcID][dbID]);
	#endif
	return 1;
}

/*======== Commands ========*/

CMD:factions(playerid, params[])
{
	new fString[2000], _temp[200];

	for(new i; i < MAX_FACTIONS ; i++)
	{
	    if(IsValidFactionID(i))
	    {
	    	format(_temp, sizeof _temp, "[%s]\t%s [%d/%d]\n", FactionInfo[i][date], FactionInfo[i][fName], FactionInfo[i][fMembers], FactionInfo[i][fLimit]);
	    	strcat(fString, _temp, sizeof fString);
		}
	}
	ShowPlayerDialog(playerid, 3252, DIALOG_STYLE_LIST, "Factions", fString, "Okay", "Close");
	return 1;
}

CMD:reloadfacs(playerid, params[])
{
	if(IsPlayerAdmin(playerid))
	{
		LoadFactions();
	}
	return 1;
}

CMD:setfacranks(playerid, params[])
{
	new frank, rname[MAX_FACTION_RANK_NAME];

	if(IsValidFactionID(PlayerInfo[playerid][pFaction]) && PlayerInfo[playerid][pRank] == FACTION_RANKS - 1)
	{
		if(sscanf(params, "ds[36]", frank, rname)) return SendClientMessage(playerid, -1, "{FF0000}[SYNTAX] {FFFFFF}/setfacranks [rankid] [rank name]");
		if(frank < FACTION_RANKS)
		{
			format(FactionRanks[PlayerInfo[playerid][pFaction]][frank], sizeof rname, rname);
		}
		SaveFaction(PlayerInfo[playerid][pFaction]);
	}
	return 1;
}

CMD:savefactions(playerid, params[])
{
	if(IsPlayerAdmin(playerid))
	{
		for(new i; i < MAX_FACTIONS ; i ++)
		{
			if(IsValidFactionID(i))
			{
				SaveFaction(i);
			}
		}
	}
	return 1;
}

CMD:lockers(playerid, params[])
{
	new input[20], facID = PlayerInfo[playerid][pFaction];

	if(IsValidFactionID(facID) && IsPlayerInAFaction(playerid))
	{
    	if(IsPlayerInRangeOfPoint(playerid, 2, FactionInfo[facID][fX], FactionInfo[facID][fY], FactionInfo[facID][fZ]))
    	{
    	    if(sscanf(params, "s[20]", input)) return SendClientMessage(playerid, -1, "{FF0000}[SYNTAX] {FFFFFF}/lockers [weapons / clothes / heal]");

			if(!strcmp(input, "clothes", true))
			{
				ShowPlayerDialog(playerid, 7777, DIALOG_STYLE_PREVMODEL_LIST, "Clothes menu", ReturnFactionSkin(playerid), "Wear", "Close");
			}
			else if(!strcmp(input, "heal", true))
			{
			    SetPlayerHealth(playerid, 100);
			    SetPlayerArmour(playerid, 100);
			}
			else if(!strcmp(input, "weapons", true))
			{
			    ShowPlayerDialog(playerid, 7778, DIALOG_STYLE_PREVMODEL_LIST, "Weapons menu", ReturnFactionWeapons(playerid), "Wear", "Close");
			}
            else SendClientMessage(playerid, -1, "{FF0000}Invalid parameter. Please put a valid option!");
		}
		else SendClientMessage(playerid, -1, "{FF0000}You are not in range of your faction locker.");
	}
	else SendClientMessage(playerid, -1, "{FF0000}You are not in a valid faction.");
	return 1;
}

CMD:fkick(playerid, params[])
{
	if(PlayerInfo[playerid][pRank] == FACTION_RANKS - 1 && IsValidFactionID(PlayerInfo[playerid][pFaction]) && IsPlayerInAFaction(playerid))
	{
	    new targetid;

	    if(sscanf(params, "d", targetid)) return SendClientMessage(playerid, -1, "{FF0000}[SYNTAX]: {FFFFFF}/fkick [targetid]");

		if(IsPlayerConnected(targetid) && PlayerInfo[targetid][pFaction] == PlayerInfo[playerid][pFaction])
		{
		    PlayerInfo[targetid][pRank] = -1;
		    PlayerInfo[targetid][pFaction] = -1;
		    FactionInfo[PlayerInfo[playerid][pFaction]][fMembers]--;
		    SendClientMessage(playerid, -1, "{B3B3B3}* You have been kicked from your faction.");
		    SaveFaction(PlayerInfo[playerid][pFaction]);
		}
		else SendClientMessage(playerid, -1, "{FF0000}[ERROR] {FFFFFF}Player is not connected or is not in the same faction as you!");
	}
	else SendClientMessage(playerid, -1, "{FF0000}[ERROR] {FFFFFF}You are not in a valid faction!");

	return 1;
}

CMD:finvite(playerid, params[])
{
	new string[128];

	if(PlayerInfo[playerid][pRank] == FACTION_RANKS - 1 && IsValidFactionID(PlayerInfo[playerid][pFaction]) && IsPlayerInAFaction(playerid))
	{
	    new targetid;
	    if(sscanf(params, "d", targetid)) return SendClientMessage(playerid, -1, "{FF0000}[SYNTAX]: {FFFFFF}/finvite [targetid]");

		if(IsPlayerConnected(targetid) && PlayerInfo[targetid][pFaction] != -1)
		{
		    new facID = PlayerInfo[playerid][pFaction];

		    if(FactionInfo[facID][fMembers] < FactionInfo[facID][fLimit])
		    {
			    PlayerInfo[targetid][pRank] = 0;
			    PlayerInfo[targetid][pFaction] = facID;
			    FactionInfo[facID][fMembers]++;
			    format(string, sizeof string, "{B3B3B3}* You have been invited to %s. Current rank: %s", FactionInfo[facID][fName], GetRankName(facID, 0));
				SendClientMessage(playerid, -1, string);
				SaveFaction(facID);
			}
			else SendClientMessage(playerid, -1, "{FF0000}[ERROR] {FFFFFF}Players limit exceed!");
		}
		else SendClientMessage(playerid, -1, "{FF0000}[ERROR] {FFFFFF}Player is not connected or is already in a faction!");
	}
    else SendClientMessage(playerid, -1, "{FF0000}[ERROR] {FFFFFF}You are not in a valid faction!");

	return 1;
}

CMD:updateflockers(playerid, params[])
{
	if(IsPlayerAdmin(playerid))
	{
	    new factionid;

	    if(sscanf(params, "d", factionid)) return SendClientMessage(playerid, -1, "{FF0000}[SYNTAX]: {FFFFFF}/updateflockers [factionid]");

		if(IsValidFactionID(factionid))
		{
		    new Float:CPos[3];
		    
		    GetPlayerPos(playerid, CPos[0], CPos[1], CPos[2]);
		    
		    FactionInfo[factionid][fX] = CPos[0];
		    FactionInfo[factionid][fY] = CPos[1];
		    FactionInfo[factionid][fZ] = CPos[2];
		    
			SendClientMessage(playerid, -1, "{B3B3B3}* Faction lockers have been updated and changed to your current location.");

			SaveFaction(factionid);
		}
		else SendClientMessage(playerid, -1, "{FF0000}[ERROR] {FFFFFF}Invalid faction ID");
	}
	return 1;
}

CMD:setflimit(playerid, params[])
{
	if(IsPlayerAdmin(playerid))
	{
	    new factionid, limit, string[128];

	    if(sscanf(params, "dd", factionid, limit)) return SendClientMessage(playerid, -1, "{FF0000}[SYNTAX]: {FFFFFF}/setflimit [factionid] [limit]");

		if(IsValidFactionID(factionid))
		{
			FactionInfo[factionid][fLimit] = limit;
			
			format(string, sizeof string, "{B3B3B3}* You have been changed %s's faction slot limit to %d.", FactionInfo[factionid][fName], limit);
			SendClientMessage(playerid, -1, string);

			SaveFaction(factionid);
		}
		else SendClientMessage(playerid, -1, "{FF0000}[ERROR] {FFFFFF}Invalid faction ID");
	}
	return 1;
}

CMD:setfaction(playerid, params[])
{
	if(IsPlayerAdmin(playerid))
	{
	    new targetid, factionid, rank, string[128];

	    if(sscanf(params, "ddd", targetid, factionid, rank)) return SendClientMessage(playerid, -1, "{FF0000}[SYNTAX]: {FFFFFF}/setfaction [targetid] [factionid] [rank]");

		if(IsValidFactionID(factionid) && rank < FACTION_RANKS)
		{
		    if(FactionInfo[factionid][fMembers] < FactionInfo[factionid][fLimit])
		    {
		        if(PlayerInfo[targetid][pFaction] != -1) FactionInfo[PlayerInfo[playerid][pFaction]][fMembers]--;
		        
				PlayerInfo[targetid][pRank] = rank;
				PlayerInfo[targetid][pFaction] = factionid;
				FactionInfo[factionid][fMembers]++;
				format(string, sizeof string, "{B3B3B3}* You have been invited to %s. Current rank: %s", FactionInfo[factionid][fName], GetRankName(factionid, rank));
				SendClientMessage(playerid, -1, string);
				SaveFaction(factionid);
			}
			else SendClientMessage(playerid, -1, "{FF0000}[ERROR] {FFFFFF}Players limit exceed!");
		}
		else SendClientMessage(playerid, -1, "{FF0000}[ERROR] {FFFFFF}Invalid faction ID");
	}
	return 1;
}

CMD:setrank(playerid, params[])
{
    new targetid, rank, string[128];

	if(PlayerInfo[playerid][pRank] == FACTION_RANKS-1)
	{
    	if(sscanf(params, "dd", targetid, rank)) return SendClientMessage(playerid, -1, "{FF0000}[SYNTAX]: {FFFFFF}/setfaction [targetid] [rank]");

	    if(PlayerInfo[playerid][pFaction] == PlayerInfo[targetid][pFaction])
	    {
			PlayerInfo[targetid][pRank] = rank;
			format(string, sizeof string, "{B3B3B3}* You have had your rank changed to: %s", GetRankName(PlayerInfo[playerid][pFaction], rank));
			SendClientMessage(playerid, -1, string);
		}
	}
	return 1;
}

CMD:createfaction(playerid, params[])
{
	if(IsPlayerAdmin(playerid))
	{
		new fname[36], type, Float:PlayerPos[3];

		if(sscanf(params, "ds[36]", type, fname)) return SendClientMessage(playerid, -1, "{FF0000}[SYNTAX]: {FFFFFF}/createfaction [type] [faction name]");

		GetPlayerPos(playerid, PlayerPos[0], PlayerPos[1], PlayerPos[2]);

		CreateFaction(fname, PlayerPos[0], PlayerPos[1], PlayerPos[2], type);
	}
	else SendClientMessage(playerid, -1, "{FF0000}You do not have access to this command.");
	return 1;
}

public OnFilterScriptInit()
{
	// Loading the database

	DB::Open("Factions.db");

	CheckFactionsDB();
	CheckPlayersDB();

	LoadFactions();
	print("• Dynamic Faction FilterScript status: LOADED •");
	print("• _______ CREATOR: ____Private200____________ •");
	print("• ________PLEASE_DO_NOT_REMOVE_CREDITS_______ •");
	return 1;
}

public OnFilterScriptExit()
{
    print("• Dynamic Faction FilterScript status: UNLOADED •");

    for(new i; i < MAX_PLAYERS; i ++)
    {
        if(IsPlayerConnected(i))
		{
		    SavePlayer(i);
    		ResetPlayerVariables(i);
		}
	}

	return 1;
}

public OnPlayerConnect(playerid)
{
    ResetPlayerVariables(playerid);
    CheckPlayer(playerid);
    return 1;
}

public OnPlayerDisconnect(playerid)
{
    SavePlayer(playerid);
    ResetPlayerVariables(playerid);
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == 7777)
    {
        if(response)
        {
        	GiveFactionSkin(playerid, listitem);
		}
		return 1;
	}
	if(dialogid == 7778)
    {
        if(response)
        {
        	GiveFactionWeapon(playerid, listitem);
		}
		return 1;
	}
    return 1;
}
