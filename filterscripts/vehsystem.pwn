#include <a_samp>
#include <easydb>
#include <sscanf2>
#include <zcmd>
#include <streamer>
#include <dialogs>

#define PLAYER_MAX_VEHICLES 5
#define MAX_DEALERSHIP_VEHICLES 24

new bool:CanSpawnVehicle[MAX_PLAYERS];
new VehicleCheckpoint[MAX_PLAYERS];
new ParkingCheckpoint[MAX_PLAYERS];

#if !defined INFINITY
	#define INFINITY (Float:0x7F800000)
#endif

#if !defined isnull
    #define isnull(%1) ((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
#endif

enum VehicleEnum
{
	vOwner[24],
	dbID,
	vID,
	vModel,
	Float:vPos_X,
	Float:vPos_Y,
	Float:vPos_Z,
	Float:vAngle,
	vPrice
};
new vInfo[MAX_VEHICLES][VehicleEnum];

/* Dealership locations are standing like:

PosX ( Range of point for player to buy car)
PosY
PosZ
___________________________________________

SpawnX ( Positions where cars will spawn after buying )
SpawnY
SpawnZ
___________________________________________

Dealership name (describes itself || MUST BE DEALERSHIP DATABASE NAME!)

*/

enum DealershipInfo
{
	Float:DS_PosX,
	Float:DS_PosY,
	Float:DS_PosZ,
	Float:DS_SpawnX,
	Float:DS_SpawnY,
	Float:DS_SpawnZ,
	DealershipName[36]
}

new DealershipLocations[][DealershipInfo] =
{
	{542.9274,-1292.7112,17.2422, 526.5967,-1284.5935,16.9692, "Grotti"}
};

new vTable;
new dsTable[MAX_PLAYERS];
new dsname[MAX_PLAYERS][36];

// STOCKINGS


stock UpdatePlayerVehicle(playerid, vehicleid)
{
	new query[256], dbid = vInfo[vehicleid][dbID];
	format(query, sizeof query, "UPDATE `Vehicles` SET PosX = '%f', PosY = '%f',PosZ = '%f', Angle='%f' WHERE id='%d'",
	vInfo[vehicleid][vPos_X], vInfo[vehicleid][vPos_Y], vInfo[vehicleid][vPos_Z], vInfo[vehicleid][vAngle], dbid);
	DB::Query(query, false);
	printf("Vehicle ID %d has been saved. [%s vehicle]", vehicleid, GetName(playerid));
	return 1;
}

stock LoadPlayerVehicle(playerid, vid)
{
	new query[200];
    format(query, sizeof(query), "SELECT * FROM `Vehicles` WHERE `id`='%d' LIMIT 1", vid);
    new DBResult:results = DB::Query(query, false);

    if(db_num_rows(results))
    {
        new vehOwner[24];
		db_get_field(results, 1, vehOwner, 24);

		if(!strcmp(vehOwner, GetName(playerid), true))
		{
		    if(CanSpawnVehicle[playerid] == true)
		    {
		        new dbid[10], id;
		        db_get_field(results, 0, dbid, 10);
				id=strval(dbid);

		        new vehiclemodel[50], model;
		        db_get_field(results, 2, vehiclemodel, 50);
				model=strval(vehiclemodel);

		        new vehposx[50], Float:PosX;
		        db_get_field(results, 3, vehposx, 50);
				PosX=strval(vehposx);

		        new vehposy[50], Float:PosY;
		        db_get_field(results, 4, vehposy, 50);
				PosY=strval(vehposy);

		        new vehposz[50], Float:PosZ;
		        db_get_field(results, 5, vehposz, 50);
				PosZ=strval(vehposz);

				new vprice = db_get_field_int(results, 7);

				new Float:angle = db_get_field_float(results, 6);

				new vehicleid = CreateVehicle(model, PosX, PosY, PosZ, angle, 0, 0, -1);

				vInfo[vehicleid][vID] = vehicleid;
				vInfo[vehicleid][dbID] = id;
				vInfo[vehicleid][vPos_X] = PosX;
				vInfo[vehicleid][vPos_Y] = PosY;
				vInfo[vehicleid][vPos_Z] = PosZ;
				vInfo[vehicleid][vAngle] = angle;

				vInfo[vehicleid][vPrice] = vprice;

				format(vInfo[vehicleid][vOwner], MAX_PLAYER_NAME, "%s", GetName(playerid));
				
		        CanSpawnVehicle[playerid] = false;

		        VehicleCheckpoint[playerid] = CreateDynamicCP(PosX, PosY, PosZ, 6.25, 0, 0, playerid, -1);

				new string[128];
		        format(string, sizeof string, "{FF0000}[VEHICLE SPAWN] {FFFFFF}Your %s has been spawned and marked on the minimap", GetVehicleModelName(model));
				SendClientMessage(playerid, -1, string);
			}
			else SendClientMessage(playerid, -1, "{FF0000}Another vehicle is already spawned!");
		}
		else SendClientMessage(playerid, -1, "{FF0000}This vehicle ID does not belong to you!");
    }
	return 1;
}

stock GiveVehicle(playerid, model, price)
{
    new Float:Veh_SpawnPos[4];
    
	for(new i; i < sizeof DealershipLocations; i++)
	{
	    if(!strcmp(DealershipLocations[i][DealershipName], dsname[playerid], true))
	    {
	        Veh_SpawnPos[0] = DealershipLocations[i][DS_SpawnX];
	        Veh_SpawnPos[1] = DealershipLocations[i][DS_SpawnY];
	        Veh_SpawnPos[2] = DealershipLocations[i][DS_SpawnZ];
	        break;
		}
	}
	
	if(GetPlayerMoney(playerid) >= price)
	{
		GivePlayerMoney(playerid, -price);
		new carid = CreateVehicle(model, Veh_SpawnPos[0],Veh_SpawnPos[1],Veh_SpawnPos[2],0, 0, 0, -1, 1);
		PutPlayerInVehicle(playerid, carid, 0);


		vInfo[carid][vID] = carid;
		vInfo[carid][vModel] = model;
		vInfo[carid][vPos_X] = Veh_SpawnPos[0];
		vInfo[carid][vPos_Y] = Veh_SpawnPos[1];
		vInfo[carid][vPos_Z] = Veh_SpawnPos[2];
		vInfo[carid][vAngle] = 238.2809;
		vInfo[carid][vPrice] = price;
		format(vInfo[carid][vOwner], MAX_PLAYER_NAME, GetName(playerid));
		print(vInfo[carid][vOwner]);
		vInfo[carid][dbID] = DB::RetrieveLastKey(vTable, _, _, "Owner", GetName(playerid));
		DB::CreateRow(vTable, "Owner", GetName(playerid));

		DB::SetLastIntEntry(vTable, "Model", model, GetName(playerid));
		DB::SetLastFloatEntry(vTable, "PosX", Veh_SpawnPos[0], GetName(playerid));
		DB::SetLastFloatEntry(vTable, "PosY", Veh_SpawnPos[1], GetName(playerid));
		DB::SetLastFloatEntry(vTable, "PosZ", Veh_SpawnPos[3], GetName(playerid));
		DB::SetLastFloatEntry(vTable, "Angle", 238.2809, GetName(playerid));
		DB::SetLastIntEntry(vTable, "Price", price, GetName(playerid));
	}
	else SendClientMessage(playerid, -1, "{FF0000}[ERROR]: {FFFFFF}You don't have enough money!");
	return 1;
}

new VehiclesNames[212][] = {
        {"Landstalker"},{"Bravura"},{"Buffalo"},{"Linerunner"},{"Perrenial"},{"Sentinel"},
        {"Dumper"},{"Firetruck"},{"Trashmaster"},{"Stretch"},{"Manana"},{"Infernus"},{"Voodoo"},
        {"Pony"},{"Mule"},{"Cheetah"},{"Ambulance"},{"Leviathan"},{"Moonbeam"},{"Esperanto"},{"Taxi"},
        {"Washington"},{"Bobcat"},{"Mr. Whoopee"},{"BF. Injection"},{"Hunter"},{"Premier"},{"Enforcer"},
        {"Securicar"},{"Banshee"},{"Predator"},{"Bus"},{"Rhino"},{"Barracks"},{"Hotknife"},{"Article Trailer"},
        {"Previon"},{"Coach"},{"Cabbie"},{"Stallion"},{"Rumpo"},{"RC Bandit"},{"Romero"},{"Packer"},{"Monster"},
        {"Admiral"},{"Squalo"},{"Seasparrow"},{"Pizzaboy"},{"Tram"},{"Article Trailer 2"},{"Turismo"},{"Speeder"},
        {"Reefer"},{"Tropic"},{"Flatbed"},{"Yankee"},{"Caddy"},{"Solair"},{"Berkley's RC Van"},{"Skimmer"},
        {"PCJ-600"},{"Faggio"},{"Freeway"},{"RC Baron"},{"RC Raider"},{"Glendale"},{"Oceanic"},{"Sanchez"},
        {"Sparrow"},{"Patriot"},{"Quad"},{"Coastguard"},{"Dinghy"},{"Hermes"},{"Sabre"},{"Rustler"},{"ZR-350"},
        {"Walton"},{"Regina"},{"Comet"},{"BMX"},{"Burrito"},{"Camper"},{"Marquis"},{"Baggage"},{"Dozer"},
        {"Maverick"},{"News Chopper"},{"Rancher"},{"FBI Rancher"},{"Virgo"},{"Greenwood"},{"Jetmax"},{"Hotring"},
        {"Sandking"},{"Blista Compact"},{"Police Maverick"},{"Boxville"},{"Benson"},{"Mesa"},{"RC Goblin"},
        {"Hotring Racer A"},{"Hotring Racer B"},{"Bloodring Banger"},{"Rancher"},{"Super GT"},{"Elegant"},
        {"Journey"},{"Bike"},{"Mountain Bike"},{"Beagle"},{"Cropdust"},{"Stunt"},{"Tanker"},{"Roadtrain"},
        {"Nebula"},{"Majestic"},{"Buccaneer"},{"Shamal"},{"Hydra"},{"FCR-900"},{"NRG-500"},{"HPV1000"},
        {"Cement Truck"},{"Tow Truck"},{"Fortune"},{"Cadrona"},{"FBI Truck"},{"Willard"},{"Forklift"},
        {"Tractor"},{"Combine"},{"Feltzer"},{"Remington"},{"Slamvan"},{"Blade"},{"Freight"},{"Streak"},
        {"Vortex"},{"Vincent"},{"Bullet"},{"Clover"},{"Sadler"},{"Firetruck LA"},{"Hustler"},{"Intruder"},
        {"Primo"},{"Cargobob"},{"Tampa"},{"Sunrise"},{"Merit"},{"Utility"},{"Nevada"},{"Yosemite"},{"Windsor"},
        {"Monster A"},{"Monster B"},{"Uranus"},{"Jester"},{"Sultan"},{"Stratum"},{"Elegy"},{"Raindance"},
        {"RC Tiger"},{"Flash"},{"Tahoma"},{"Savanna"},{"Bandito"},{"Freight Flat"},{"Streak Carriage"},
        {"Kart"},{"Mower"},{"Dunerider"},{"Sweeper"},{"Broadway"},{"Tornado"},{"AT-400"},{"DFT-30"},{"Huntley"},
        {"Stafford"},{"BF-400"},{"Newsvan"},{"Tug"},{"Article Trailer 3"},{"Emperor"},{"Wayfarer"},{"Euros"},{"Mobile Hotdog"},
        {"Club"},{"Freight Carriage"},{"Trailer 3"},{"Andromada"},{"Dodo"},{"RC Cam"},{"Launch"},{"Police Car (LSPD)"},
        {"Police Car (SFPD)"},{"Police Car (LVPD)"},{"Police Ranger"},{"Picador"},{"S.W.A.T Van"},{"Alpha"},
        {"Phoenix"},{"Glendale"},{"Sadler"},{"Luggage Trailer A"},{"Luggage Trailer B"},{"Stair Trailer"},
        {"Boxville"},{"Farm Plow"},{"Utility Trailer"}
};

stock GetVehicleModelName(vehicleid)
{
    new GVFNstring[56];
    format(GVFNstring, sizeof(GVFNstring), VehiclesNames[vehicleid-400]);
    return GVFNstring;
}

stock GetName(playerid)
{
	new name[24];
	GetPlayerName(playerid, name, sizeof(name));
	return name;
}

public OnFilterScriptInit()
{
	DB::Open("Vehicles.db");
	
	vTable = DB::VerifyTable("Vehicles", "id");
	
	DB::VerifyColumn(vTable, "Owner", DB::TYPE_STRING, "");
	DB::VerifyColumn(vTable, "Model", DB::TYPE_STRING, "");
	DB::VerifyColumn(vTable, "PosX", DB::TYPE_FLOAT, 0);
	DB::VerifyColumn(vTable, "PosY", DB::TYPE_FLOAT, 0);
	DB::VerifyColumn(vTable, "PosZ", DB::TYPE_FLOAT, 0);
	DB::VerifyColumn(vTable, "Angle", DB::TYPE_FLOAT, 0);
	return 1;
	
}
public OnFilterScriptExit()
{
	DB::Close();
	return 1;
}

public OnPlayerConnect(playerid)
{
	/* DEBUG - REPLACE IF WANTED
	
    new query[200];
    format(query, sizeof(query), "SELECT * FROM `Vehicles` WHERE `Owner`='%s' LIMIT 1", GetName(playerid));
    new DBResult:results = DB::Query(query, false);
    
    if(!db_num_rows(results)) printf("No vehicles were found under the name of: %s", GetName(playerid)); */
    
    CanSpawnVehicle[playerid] = true;
    VehicleCheckpoint[playerid] = -1;
    ParkingCheckpoint[playerid] = -1;
    dsTable[playerid] = -1;
    dsname[playerid] = "";
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(CanSpawnVehicle[playerid] == false)
	{
	    for(new i; i < MAX_VEHICLES; i++)
	    {
			if(!strcmp(GetName(playerid), vInfo[i][vOwner], true))
			{
			    UpdatePlayerVehicle(playerid, i);
			    DestroyVehicle(i);
			    break;
			}
		}
	}
	dsTable[playerid] = -1;
	CanSpawnVehicle[playerid] = true;
	VehicleCheckpoint[playerid] = -1;
	ParkingCheckpoint[playerid] = -1;
	dsname[playerid] = "";
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

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

CMD:mycars(playerid, params[])
{
    new keys[PLAYER_MAX_VEHICLES];
    DB::RetrieveKey(vTable, keys, _, "Owner", GetName(playerid));
    new modelid;
	new string[512];
    for (new i, j = sizeof(keys); i < j; i++)
    {
        if (keys[i] != DB::INVALID_KEY)
        {
        	modelid = DB::GetIntEntry(vTable, keys[i], "Model");
        	format(string, sizeof (string), "%s%d\n%s\n", string, modelid, GetVehicleModelName(modelid));
 		}
	}
	ShowPlayerDialog(playerid, 6969, DIALOG_STYLE_PREVMODEL, "Vehicle's list", string, "Spawn", "Close");
	return 1;
}

public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
	if(checkpointid == VehicleCheckpoint[playerid])
	{
		DestroyDynamicCP(VehicleCheckpoint[playerid]);
	}
	if(checkpointid == ParkingCheckpoint[playerid])
	{
	    if(CanSpawnVehicle[playerid] == false)
		{
		    if(IsPlayerInAnyVehicle(playerid))
			{
			    new vid = GetPlayerVehicleID(playerid);
			    new owner[36];
			    format(owner, sizeof owner, vInfo[vid][vOwner]);

			    if(!isnull(owner) && !strcmp(owner, GetName(playerid)))
			    {
				    UpdatePlayerVehicle(playerid, vid);
				    DestroyVehicle(vid);
				    CanSpawnVehicle[playerid] = true;
				    DestroyDynamicCP(ParkingCheckpoint[playerid]);
				}
			}
		}
	}
	return 1;
}

CMD:createdealership(playerid, params[])
{
	if(IsPlayerAdmin(playerid))
	{
		new dname[36];
		if(sscanf(params, "s[36]", dname)) return SendClientMessage(playerid, -1, "{FF0000}[SYNTAX]: {FFFFFF}/createdealership [name]");

		dsTable[playerid] = DB::VerifyTable(dname, "id");

		DB::VerifyColumn(dsTable[playerid], "Model", DB::TYPE_STRING, "");
		DB::VerifyColumn(dsTable[playerid], "Price", DB::TYPE_STRING, "");
		DB::VerifyColumn(dsTable[playerid], "Reference", DB::TYPE_STRING, "Reference");
	}
	else SendClientMessage(playerid, -1, "{FF0000}You do not have access to this command.");
	return 1;
}

CMD:addvehicle(playerid, params[])
{
	if(IsPlayerAdmin(playerid))
	{
		new dname[36], model, price, query[200];
		if(sscanf(params, "dds[36]", model, price, dname)) return SendClientMessage(playerid, -1, "{FF0000}[SYNTAX]: {FFFFFF}/addvehicle [model] [price] [dealership name]");

		format(query, sizeof query, "SELECT * FROM %s", dname);
		new DBResult:results = DB::Query(query, false);
		if(db_num_rows(results) < 25)
		{
		    format(query, sizeof query, "SELECT * FROM %s WHERE `Model` = '%d'", dname, model);
			results = DB::Query(query, false);
			
			if(db_num_rows(results) == 0)
			{
				format(query, sizeof query, "INSERT INTO %s (Model, Price, Reference) VALUES ('%d', '%d', 'Reference')", dname, model, price);
				DB::Query(query, false);
				format(query, sizeof query, "%s [Model: %d] has been added into dealership named as: %s (Price: $%d)", GetVehicleModelName(model), model, dname, price);
			}
		    else SendClientMessage(playerid, -1, "{FF0000}[ERROR]: {FFFFFF}There's already another vehicle with such ID in this dealership!");
		}
		
	}
	else SendClientMessage(playerid, -1, "{FF0000}You do not have access to this command.");
	return 1;
}

CMD:dealershipcars(playerid, params[])
{
    if(IsPlayerAdmin(playerid))
	{
	    new dealership[36];
	    if(sscanf(params, "s[36]", dealership)) return SendClientMessage(playerid, -1, "{FF0000}[SYNTAX]: {FFFFFF}/dealershipcars [dealership name]");
		new query[200], string[1000], hstring[100];
	    format(query, sizeof(query), "SELECT * FROM `%s`", dealership);
	    new DBResult:results = DB::Query(query, false);

	    if(db_num_rows(results))
	    {
	        new id, model, price;
			new count = 0;
			for(new i; i < db_num_rows(results); i++)
			{
		    	count++;
		    	id = db_get_field_int(results, 0);
		    	model = db_get_field_int(results, 1);
		    	price = db_get_field_int(results, 2);
		    	
				format(hstring, sizeof(hstring), "{FFD64F}%d) {FFFFFF}%s (ID: %d | Model: %d) - Price: %d\n\n", count, GetVehicleModelName(model), id, model, price);

				db_next_row(results);

				strcat(string, hstring, sizeof(string));
			}
		}
		ShowPlayerDialog(playerid, 6969, DIALOG_STYLE_MSGBOX, "Dealership Vehicles", string, "Okay", "");
	}
	else SendClientMessage(playerid, -1, "{FF0000}You do not have access to this command.");
	return 1;
}

CMD:deletevehicle(playerid, params[])
{
	if(IsPlayerAdmin(playerid))
	{
		new model, query[200], dealership[36];
		if(sscanf(params, "ds[36]", model, dealership)) return SendClientMessage(playerid, -1, "{FF0000}[SYNTAX]: {FFFFFF}/deletevehicle [model] [dealership name]");

		format(query, sizeof query, "SELECT * FROM %s WHERE `Model` = '%d'", dealership, model);
		new DBResult:results = DB::Query(query, false);
		if(db_num_rows(results) > 0)
		{
			format(query, sizeof query, "DELETE FROM %s WHERE `Model`='%d'", dealership, model);
			results = DB::Query(query, false);
		}
		else SendClientMessage(playerid, -1, "{FF0000}[ERROR]: {FFFFFF}There are no vehicles with such ID in this dealership!");
	}
	else SendClientMessage(playerid, -1, "{FF0000}You do not have access to this command.");
	return 1;
}

CMD:park(playerid, params[])
{
    if(IsPlayerInAnyVehicle(playerid))
	{
	    new vid = GetPlayerVehicleID(playerid);
	    new owner[36];
	    format(owner, sizeof owner, vInfo[vid][vOwner]);
	    if(!isnull(owner) && !strcmp(owner, GetName(playerid)))
	    {
	        ParkingCheckpoint[playerid] = CreateDynamicCP(vInfo[vid][vPos_X], vInfo[vid][vPos_Y], vInfo[vid][vPos_Z], 6.25, 0, 0, playerid, -1);

	        SendClientMessage(playerid, -1, "{FF0000}Vehicle's parking checkpoint has been shown in the minimap!");
		}
		else SendClientMessage(playerid, -1, "{FF0000}[ERROR]: {FFFFFF}This vehicle isn't owned by you.");
	}
	else SendClientMessage(playerid, -1, "{FF0000}[ERROR]: {FFFFFF}You must be in a vehicle in order to use this.");
	return 1;
}

CMD:buypark(playerid, params[])
{
	if(IsPlayerInAnyVehicle(playerid))
	{
	    new vid = GetPlayerVehicleID(playerid);
	    new owner[36];
	    format(owner, sizeof owner, vInfo[vid][vOwner]);
	    
	    if(!isnull(owner) && !strcmp(owner, GetName(playerid)))
	    {
	        printf("%s %s", owner, GetName(playerid));
	        new Float:vCPos[4];
	        GetVehiclePos(vid, vCPos[0], vCPos[1], vCPos[2]);
	        GetVehicleZAngle(vid, vCPos[3]);
	        vInfo[vid][vPos_X] = vCPos[0];
	        vInfo[vid][vPos_Y] = vCPos[1];
	        vInfo[vid][vPos_Z] = vCPos[2];
	        vInfo[vid][vAngle] = vCPos[3];
	        UpdatePlayerVehicle(playerid, vid);
	        SendClientMessage(playerid, -1, "{FF0000}Your vehicle has been parked!");
		}
		else SendClientMessage(playerid, -1, "{FF0000}[ERROR]: {FFFFFF}This vehicle isn't owned by you."), printf("%d %s", vid, GetName(playerid));
	}
	else SendClientMessage(playerid, -1, "{FF0000}[ERROR]: {FFFFFF}This must be in a vehicle in order to use this.");
	return 1;
}

CMD:buycar(playerid, params[])
{
    if(CanSpawnVehicle[playerid] == true)
    {
		new query[150];
		for(new i; i < sizeof DealershipLocations; i++)
		{
		    if(IsPlayerInRangeOfPoint(playerid, 5, DealershipLocations[i][DS_PosX], DealershipLocations[i][DS_PosY], DealershipLocations[i][DS_PosZ]))
		    {
		        format(dsname[playerid], sizeof dsname, DealershipLocations[i][DealershipName]);
		        break;
			}
		}

		if(!isnull(dsname[playerid]))
		{
			dsTable[playerid] = DB::VerifyTable(dsname[playerid], "id");

		    format(query, sizeof(query), "SELECT * FROM `Vehicles` WHERE `Owner`='%s'", GetName(playerid));
		    new DBResult:results = DB::Query(query, false);

			if(db_num_rows(results) < PLAYER_MAX_VEHICLES)
			{
				new keys[MAX_DEALERSHIP_VEHICLES];
			    DB::RetrieveKey(dsTable[playerid], keys, _, "Reference", "Reference");

			    new modelid;
				new string[512];
			    for (new i, j = sizeof(keys); i < j; i++)
			    {
			        if (keys[i] != DB::INVALID_KEY)
			        {
			        	modelid = DB::GetIntEntry(dsTable[playerid], keys[i], "Model");
			        	printf("%d", modelid);
			        	format(string, sizeof (string), "%s%d\n%s\n", string, modelid, GetVehicleModelName(modelid));
			 		}
				}
				ShowPlayerDialog(playerid, 6968, DIALOG_STYLE_PREVMODEL, "Vehicle's list", string, "Buy", "Close");
			}
			else SendClientMessage(playerid, -1, "You have already reached the maximum of cars you can buy!");
		}
		else SendClientMessage(playerid, -1, "{FF0000}[ERROR]: {FFFFFF}You are not in range of any dealership!");
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if (dialogid == 6969)
	{
		if (response)
		{
			new key[PLAYER_MAX_VEHICLES];
 	  		DB::RetrieveKey(vTable, key, _, "Owner", GetName(playerid));

			for (new i, j = sizeof (key); i < j; i++)
   			{
      			if (i == listitem)
         		{
         			LoadPlayerVehicle(playerid, key[i]);
					break;
				}
   			}
		}
		return 1;
	}
	if (dialogid == 6968)
	{
		if (response)
		{
			new key[MAX_DEALERSHIP_VEHICLES];
 	  		DB::RetrieveKey(dsTable[playerid], key, _, "Reference", "Reference");

			for (new i, j = sizeof (key); i < j; i++)
   			{
      			if (i == listitem)
         		{
         		    new modelid = DB::GetIntEntry(dsTable[playerid], key[i], "Model");
         		    new price = DB::GetIntEntry(dsTable[playerid], key[i], "Price");
         			GiveVehicle(playerid, modelid, price);
					break;
				}
   			}
		}
		return 1;
	}
	return 1;
}
CMD:kill(playerid)
{
	SetPlayerHealth(playerid, 0);
	return 1;
}
CMD:spawnvcar(playerid)
{
	new Float:PlayerCPos[3];
	GetPlayerPos(playerid, PlayerCPos[0], PlayerCPos[1], PlayerCPos[2]);
	new carid = CreateVehicle(411, PlayerCPos[0], PlayerCPos[1], PlayerCPos[2], 0, 0, 0, -1, 1);
	PutPlayerInVehicle(playerid, carid, 0);
	return 1;
}

