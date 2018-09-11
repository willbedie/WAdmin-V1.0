// WADMIN

/*NOTE:
This filterscript uses my BAN System which can be found here: http://forum.sa-mp.com/showthread.php?t=658383*/

#define FILTERSCRIPT
#if defined FILTERSCRIPT

#include <a_samp>
#include <a_mysql>
#include <sscanf2>
#include <zcmd>
#include <foreach>
#include <easyDialog>
#include <YSI/y_timers.inc>

#include "colors.inc"
#include "colors2.inc"

#define MYSQL_HOSTNAME      "localhost"
#define MYSQL_USERNAME      "root"
#define MYSQL_DATABASE      "wadmin"
#define MYSQL_PASSWORD      ""

#define SendServerMessage(%0,%1) \
	SendClientMessageEx(%0, COLOR_SERVER, "[SERVER]:{FFFFFF} "%1)

#define SendUsageMessage(%0,%1) \
	SendClientMessageEx(%0, COLOR_USAGE, "[USAGE]:{FFFFFF} "%1) // COLOR_YELLOW

#define SendErrorMessage(%0,%1) \
	SendClientMessageEx(%0, COLOR_TOMATO, "[ERROR]:{FFFFFF} "%1)

#define SendAdminAction(%0,%1) \
	SendClientMessageEx(%0, COLOR_CLIENT, "[ADMIN]:{FFFFFF} "%1) // COLOR_YELLOW


new MySQL: Database;
new PMToggled[MAX_PLAYERS];
new Text:WAdmin1[1];

new bool:AChatToggle = false;
new bool:BanToggle = false;
new bool:RestartToggle = false;
new bool:KickToggle = false;
new bool:RacismToggle = false;
	
enum PlayerStats
{
	pAdmin,
	pWarns,
	pMuted,
	pMutedTime,
	pJailed,
	pJailedTime
};
new PlayerInfo[MAX_PLAYERS][PlayerStats];


public OnFilterScriptInit()
{
	//Load the textdraws:
	WAdmin1[0] = TextDrawCreate(93.989837, 40.666690, "mdl-2005:WAdminmsg");
	TextDrawTextSize(WAdmin1[0], 444.000000, 348.000000);
	TextDrawAlignment(WAdmin1[0], 1);
	TextDrawColor(WAdmin1[0], -1);
	TextDrawSetShadow(WAdmin1[0], 0);
	TextDrawBackgroundColor(WAdmin1[0], 255);
	TextDrawFont(WAdmin1[0], 4);
	TextDrawSetProportional(WAdmin1[0], 0);
	TextDrawSetSelectable(WAdmin1[0], true);
	
	new MySQLOpt: option_id = mysql_init_options();
	mysql_set_option(option_id, AUTO_RECONNECT, true);
	Database = mysql_connect(MYSQL_HOSTNAME, MYSQL_USERNAME, MYSQL_DATABASE, MYSQL_PASSWORD, option_id);
	if(Database == MYSQL_INVALID_HANDLE || mysql_errno(Database) != 0)
	{
		print("Connection to MySQL database has failed! Shutting down the server.");
		printf("[DEBUG] Host: %s, User: %s, Password: %s, Database: %s", MYSQL_HOSTNAME, MYSQL_USERNAME, MYSQL_DATABASE, MYSQL_PASSWORD);
		SendRconCommand("exit");
		return 1;
	}
	else
		print("Connection to MySQL database was successful.");
		
	print("\n--------------------------------------");
	print("WAdmin System by willbedie");
	print("--------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	mysql_close(Database);
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
    new query[100];
    mysql_format(Database, query, sizeof(query), "SELECT * FROM `bans` WHERE `Username` = '%e';", GetName(playerid));
    mysql_tquery(Database, query, "CheckPlayer", "d", playerid); // Check if the player is banned
    
	PlayerInfo[playerid][pAdmin] = 0;
	PlayerInfo[playerid][pWarns] = 0;
	PlayerInfo[playerid][pMuted] = 0;
	PlayerInfo[playerid][pMutedTime] = 0;
	PlayerInfo[playerid][pJailed] = 0;
	PlayerInfo[playerid][pJailedTime] = 0;
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(PlayerInfo[playerid][pMuted])
	{
		SendClientMessageEx(playerid, COLOR_TOMATO, "You are currently muted. You have %i minutes left for your mute to be gone.", PlayerInfo[playerid][pMutedTime] / 60);
	}
	if(PlayerInfo[playerid][pJailed])
	{
		SendClientMessageEx(playerid, COLOR_TOMATO, "You are currently jailed. You have %i minutes left for you to be released.", PlayerInfo[playerid][pJailedTime] / 60);
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
    if(PlayerInfo[playerid][pMuted])
	{
		SendClientMessageEx(playerid, COLOR_YELLOW, "AdmWarn: You can't talk or use commands when you are muted, you have %i minutes (%d seconds) left to get unmuted.", PlayerInfo[playerid][pMutedTime] / 60, PlayerInfo[playerid][pMutedTime]);
		return 0;
	}
	if(RacismToggle == true)
	{
		new string[300];
	    if(strfind(text, "nigger", true) != -1)
		{
		    SendErrorMessage(playerid, "You are not allowed to say that!");
		    format(string, sizeof(string), "(ADMIN): %s has tried to say the word %s.", GetName(playerid), text);
		    SendAdminMessage(COLOR_TOMATO, string);
		    return 0;
		}
		else if(strfind(text, "paki", true) != -1)
		{
		    SendErrorMessage(playerid, "You are not allowed to say that!");
		    format(string, sizeof(string), "(ADMIN): %s has tried to say the word %s.", GetName(playerid), text);
		    SendAdminMessage(COLOR_TOMATO, string);
		    return 0;
		}
		else if(strfind(text, "nigga", true) != -1)
		{
		    SendErrorMessage(playerid, "You are not allowed to say that!");
		    format(string, sizeof(string), "(ADMIN): %s has tried to say the word %s.", GetName(playerid), text);
		    SendAdminMessage(COLOR_TOMATO, string);
		    return 0;
		}
	}
	else
		return 1;
		
	return 1;
}

Dialog:DIALOG_CONFIG(playerid, response, listitem, inputtext[])
{
	if(response)
	{
	    switch(listitem)
	    {
	        case 0: AChatToggle = !AChatToggle;
	        case 1: BanToggle = !BanToggle;
	        case 2: RestartToggle = !RestartToggle;
			case 3: KickToggle = !KickToggle;
			case 4: RacismToggle = !RacismToggle;
		}
		ShowConfig(playerid);
	}
	return true;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(Text:INVALID_TEXT_DRAW == clickedid)//textdraw is invalid (clicked ESC)
	{
	    TextDrawHideForPlayer(playerid, WAdmin1[0]);
 	}
 	else
	{
	    CancelSelectTextDraw(playerid);
	    TextDrawHideForPlayer(playerid, WAdmin1[0]);
 		new ahelp[3000];
		if(PlayerInfo[playerid][pAdmin] >= 1)
		{
			strcat(ahelp, "{049ED1}Junior Administrator (Level 1):\n\n{FFFFFF}");
			strcat(ahelp, "{009DFF}/kick - {FFFFFF}[playerid] [reason] - Kick a player with a optional reason\n");
			strcat(ahelp, "{009DFF}/warn - {FFFFFF}[playerid] [reason] - Warn a player with a optional reason\n");
			strcat(ahelp, "{009DFF}/removewarns - {FFFFFF}[playerid] - Remove every warning of a player\n");
			strcat(ahelp, "{009DFF}/ban - {FFFFFF}[playerid] [reason] - Ban a player with an optional reason\n");
			strcat(ahelp, "{009DFF}/unban - {FFFFFF}[username] - Remove a BAN from a player from the database\n");
			strcat(ahelp, "{009DFF}/oban - {FFFFFF}[username] [reason] - Offline ban a player\n");
			strcat(ahelp, "{009DFF}/baninfo - {FFFFFF}[username] - Check the ban information of any player\n");
			strcat(ahelp, "{009DFF}/mute - {FFFFFF}[playerid] [time] [reason] - Mute a player for an amount of time (in minutes) with an optional reason\n");
			strcat(ahelp, "{009DFF}/unmute - {FFFFFF}[playerid] - Unmute a player\n");
			strcat(ahelp, "{009DFF}/jail - {FFFFFF}[playerid] [time] [reason] - Jail a player for an amount of time (in minutes) with an optional reason\n");
			strcat(ahelp, "{009DFF}/unjail - {FFFFFF}[playerid] - Unjail a player\n");
			strcat(ahelp, "{009DFF}/goto - {FFFFFF}[playerid] - Teleport to a player\n");
			strcat(ahelp, "{009DFF}/get - {FFFFFF}[playerid] - Teleport a player to you\n");
			strcat(ahelp, "{009DFF}(/a)dmin - {FFFFFF}[text] - Send a message to all administrators online\n");
		}
	 	if(PlayerInfo[playerid][pAdmin] >= 2)
		{
			strcat(ahelp, "{049ED1}\nGeneral Administrator (Level 2):\n\n{FFFFFF}");
			strcat(ahelp, "{009DFF}/announce - {FFFFFF}[text] - Send an announcement to all online players\n");
			strcat(ahelp, "{009DFF}/jetpack - {FFFFFF}Give yourself a jetpack\n");
			strcat(ahelp, "{009DFF}/sethealth - {FFFFFF}[playerid] [amount] - Set an amount of health to a player\n");
			strcat(ahelp, "{009DFF}/setarmour - {FFFFFF}[playerid] [amount] - Set an amount of armour to a player\n");
			strcat(ahelp, "{009DFF}/setskin - {FFFFFF}[playerid] [skinid] - Change the skin of a player\n");
			strcat(ahelp, "{009DFF}/setinterior - {FFFFFF}[playerid] [interior] - Change the interior of a player\n");
			strcat(ahelp, "{009DFF}/setworld - {FFFFFF}[playerid] [world] - Change the world of a player\n");
			strcat(ahelp, "{009DFF}/removeweps - {FFFFFF}[playerid] - Remove weapons from any player\n");
			strcat(ahelp, "{009DFF}/akill - {FFFFFF}[playerid] - Kill a player without them noticing it.\n");
		}
	 	if(PlayerInfo[playerid][pAdmin] >= 3)
		{
			strcat(ahelp, "{049ED1}\nSenior Administrator (Level 3):\n\n{FFFFFF}");
			strcat(ahelp, "{009DFF}/freeze - {FFFFFF}[playerid] - Freeze a player\n");
			strcat(ahelp, "{009DFF}/unfreeze - {FFFFFF}[playerid] - Unfreeze a player\n");
			strcat(ahelp, "{009DFF}/givegun - {FFFFFF}[playerid] [weaponid] [ammo] - Give a gun to a player with an amount of ammo\n");
			strcat(ahelp, "{009DFF}/givecash - {FFFFFF}[playerid] [amount] - Give cash to a player\n");
			strcat(ahelp, "{009DFF}/setscore - {FFFFFF}[playerid] [score] - Set an amount of score to a player\n");
		}
	 	if(PlayerInfo[playerid][pAdmin] >= 4)
		{
			strcat(ahelp, "{049ED1}\nLead Administrator (Level 4):\n\n{FFFFFF}");
			strcat(ahelp, "{009DFF}/config - {FFFFFF}A fancy dialog will pop up and you will be able to manage in-game configs(settings)\n");
			strcat(ahelp, "{009DFF}/fakechat - {FFFFFF}[playerid] [chat] - Send a fake chat in someone else's name\n");
			strcat(ahelp, "{009DFF}/setadmin - {FFFFFF}[playerid] [level] - Make a player an administrator\n");
			strcat(ahelp, "{009DFF}/giveallwep - {FFFFFF}[weaponid] [ammo] - Give a weapon to all players with an amount of ammo\n");
			strcat(ahelp, "{009DFF}/giveallscore - {FFFFFF}[amount] - Set an amount of score to every player online\n");
			strcat(ahelp, "{009DFF}/settime - {FFFFFF}[time] - Change the time of the server\n");
			strcat(ahelp, "{009DFF}/setweather - {FFFFFF}[weatherid] - Change the weather of the server\n");
			strcat(ahelp, "{009DFF}/lockserver - {FFFFFF}[password] - Lock the server with the specified password\n");
			strcat(ahelp, "{009DFF}/restartserver - {FFFFFF}Restart the server.\n");
		}
		Dialog_Show(playerid, DIALOG_AHELP, DIALOG_STYLE_MSGBOX, "{FFFFFF}Administrator Commands Help", ahelp, "OK", "");
	}
	return 1;
}

stock AChatToggleStatus()
{
	new status[100];
	if(AChatToggle == true) { status = "{00F500}Activated\t{AFAFAF}Players won't be able to type anything on the admin chat"; }
	else { status = "{FF6347}Deactivated\t{AFAFAF}Players will be able to type on the admin chat"; }
	return status;
}

stock BanCommandStatus()
{
	new status[100];
	if(BanToggle == true) { status = "{00F500}Activated\t{AFAFAF}Admins won't be able to ban anyone"; }
	else { status = "{FF6347}Deactivated\t{AFAFAF}Admins will be able to ban anyone"; }
	return status;
}

stock RestartStatus()
{
	new status[100];
	if(RestartToggle == true) { status = "{00F500}Activated\t{AFAFAF}Lead Admins won't be able to restart the server"; }
	else { status = "{FF6347}Deactivated\t{AFAFAF}Lead Admins will be able to restart the server"; }
	return status;
}

stock KickCommandStatus()
{
	new status[100];
	if(KickToggle == true) { status = "{00F500}Activated\t{AFAFAF}Admins won't be able to kick anyone"; }
	else { status = "{FF6347}Deactivated\t{AFAFAF}Admins will be able to kick anyone"; }
	return status;
}

stock RacismStatus()
{
	new status[100];
	if(RacismToggle == true) { status = "{00F500}Activated\t{AFAFAF}Players won't be able to say racist words on the chat"; }
	else { status = "{FF6347}Deactivated\t{AFAFAF}Players will be able to say racist words on the chat"; }
	return status;
}

stock ShowConfig(playerid)
{
    new string[1000], config[1000];
	strcat(config, "{FFFFFF}Config\t{FFFFFF}Status\t{FFFFFF}Information\t{FFFFFF}Extra Info.\n");
	format(string, sizeof(string), "Admin Chat\t%s\t{AFAFAF}[E: {00F500}Recommended{AFAFAF}]\n", AChatToggleStatus()); strcat(config, string);
	format(string, sizeof(string), "Ban Command\t%s\t{AFAFAF}[E: {FF6347}Not Recommended{AFAFAF}]\n", BanCommandStatus()); strcat(config, string);
	format(string, sizeof(string), "Restart Server\t%s\t{AFAFAF}[E: {00F500}Recommended{AFAFAF}]\n", RestartStatus()); strcat(config, string);
	format(string, sizeof(string), "Kick Command\t%s\t{AFAFAF}[E: {FF6347}Not Recommended{AFAFAF}]\n", KickCommandStatus()); strcat(config, string);
	format(string, sizeof(string), "Racism\t%s\t{AFAFAF}[E: {00F500}Recommended{AFAFAF}]\n", RacismStatus()); strcat(config, string);
	Dialog_Show(playerid, DIALOG_CONFIG, DIALOG_STYLE_TABLIST_HEADERS, "Server Config", config, "Config", "Cancel");
	return 1;
}

stock GetName(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    return name;
}

Timer:PlayerChecker[1000]()
{
    foreach(new i: Player)
	{
		if(PlayerInfo[i][pMuted])
		{
			PlayerInfo[i][pMutedTime]--;
			if(PlayerInfo[i][pMutedTime] < 1)
			{
				PlayerInfo[i][pMuted] = false;
				PlayerInfo[i][pMutedTime] = 0;
				SendClientMessage(i, COLOR_YELLOW, "AdmCmd: You have been automatically unmuted after serving the mute-time.");
				new string[150];
				format(string, sizeof(string), "AdmWarn: {FF0000}%s has been automatically unmuted after serving his mute-time", GetName(i));
				SendAdminMessage(COLOR_ORANGE, string);
			}
		}
		if(PlayerInfo[i][pJailed])
		{
			PlayerInfo[i][pJailedTime]--;
			if(PlayerInfo[i][pJailedTime] < 1)
			{
				PlayerInfo[i][pJailed] = false;
				PlayerInfo[i][pJailedTime] = 0;
				SendClientMessage(i, COLOR_YELLOW, "AdmCmd: You have been automatically unjailed after serving the jail-time.");
				new string[150];
				format(string, sizeof(string), "AdmWarn: {FF0000}%s has been automatically unjailed after serving his jail-time", GetName(i));
				SendAdminMessage(COLOR_ORANGE, string);
			}
		}
	}
	return 1;
}

forward CheckPlayer(playerid); // We are going to check the player who is logging in
public CheckPlayer(playerid)
{
    if(cache_num_rows() != 0) // If the player is currently banned.
    {
        new Username[24], BannedBy[24], BanReason[128], Date[20];
        cache_get_value_name(0, "Username", Username); // Retreive the username from the mysql database
        cache_get_value_name(0, "BannedBy", BannedBy); // Retreive the admin's name from the mysql database
        cache_get_value_name(0, "BanReason", BanReason); // Retreive the ban reason from the mysql database
        cache_get_value_name(0, "Date", Date);

        SendClientMessage(playerid, -1, "{D93D3D}You are banned from this server."); // Send a message to the player to tell him he's banned
        new string[500];
        format(string, sizeof(string), "{FFFFFF}You are banned from this server\n{D93D3D}Username: {FFFFFF}%s\n{D93D3D}Banned by: {FFFFFF}%s\n{D93D3D}Ban Reason: {FFFFFF}%s\n{D93D3D}Date: {FFFFFF}%s", Username, BannedBy, BanReason, Date);
        Dialog_Show(playerid, DIALOG_BANNED, DIALOG_STYLE_MSGBOX, "Ban Info", string, "Close", "");  // Show this dialog to the player.
        SetTimerEx("SendToKick", 400, false, "i", playerid); // Kick the player in 400 miliseconds.
    }
    else
    {
        //Log the player in here
    }
    return 1;
}

forward SendToKick(playerid);
public SendToKick(playerid)
{
    Kick(playerid);
    return 1;
}

stock ReturnDate()
{
    new sendString[90], MonthStr[40], month, day, year;
    new hour, minute, second;

    gettime(hour, minute, second);
    getdate(year, month, day);
    switch(month)
    {
        case 1:  MonthStr = "January";
        case 2:  MonthStr = "February";
        case 3:  MonthStr = "March";
        case 4:  MonthStr = "April";
        case 5:  MonthStr = "May";
        case 6:  MonthStr = "June";
        case 7:  MonthStr = "July";
        case 8:  MonthStr = "August";
        case 9:  MonthStr = "September";
        case 10: MonthStr = "October";
        case 11: MonthStr = "November";
        case 12: MonthStr = "December";
    }

    format(sendString, 90, "%s %d, %d %02d:%02d:%02d", MonthStr, day, year, hour, minute, second);
    return sendString;
}

stock SendAdminMessage(color, string[])
{
	foreach(new i : Player)
	{
		if(PlayerInfo[i][pAdmin] >= 1)
		{
		    SendClientMessage(i, color, string);
		}
	}
}

stock SendClientMessageEx(playerid, color, const text[], {Float, _}:...)
{
	static
	    args,
	    str[144];
	if ((args = numargs()) == 3)
	{
	    SendClientMessage(playerid, color, text);
	}
	else
	{
		while (--args >= 3)
		{
			#emit LCTRL 5
			#emit LOAD.alt args
			#emit SHL.C.alt 2
			#emit ADD.C 12
			#emit ADD
			#emit LOAD.I
			#emit PUSH.pri
		}
		#emit PUSH.S text
		#emit PUSH.C 144
		#emit PUSH.C str
		#emit PUSH.S 8
		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

		SendClientMessage(playerid, color, str);

		#emit RETN
	}
	return 1;
}

stock SendClientMessageToAllEx(color, const str[], {Float,_}:...)
{
	static
	    args,
	    start,
	    end,
	    string[144]
	;
	#emit LOAD.S.pri 8
	#emit STOR.pri args

	if (args > 8)
	{
		#emit ADDR.pri str
		#emit STOR.pri start

	    for (end = start + (args - 8); end > start; end -= 4)
		{
	        #emit LREF.pri end
	        #emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 144
		#emit PUSH.C string

		#emit LOAD.pri args
		#emit ADD.C 4
		#emit PUSH.pri
		#emit SYSREQ.C format

        #emit LCTRL 5
		#emit SCTRL 4

		foreach (new i : Player) {
			SendClientMessage(i, color, string);
		}
		return 1;
	}
	return SendClientMessageToAll(color, str);
}

// Player Commands// Player Commands// Player Commands// Player Commands// Player Commands// Player Commands// Player Commands
CMD:togglepm(playerid, params[])
{
	if(PMToggled[playerid])
	{
	    PMToggled[playerid] = 0;
	    SendServerMessage(playerid, "You have disabled your private message, no one will be able to PM you.");
	}
	else
	{
	    PMToggled[playerid] = 1;
	    SendServerMessage(playerid, "You have enabled your private message, anyone will be able to PM you.");
	}
	return 1;
}

CMD:pm(playerid, params[])
{
	new targetid, text[128];
	if(sscanf(params, "us[128]", targetid, text)) return SendUsageMessage(playerid, "/pm [targetid] [text]");
	if(!IsPlayerConnected(targetid)) return SendErrorMessage(playerid, "That player is not connected.");
	if(PMToggled[targetid]) return SendErrorMessage(playerid, "That player has disabled their PMs.");
	
	SendClientMessageEx(targetid, COLOR_YELLOW, "Private Message from %s(%d): %s", GetName(playerid), playerid, text);
	SendClientMessageEx(playerid, COLOR_YELLOW, "Private Message to %s(%d): %s", GetName(targetid), targetid, text);
	return 1;
}

CMD:id(playerid, params[])
{
	new targetid, string[150];
	if(sscanf(params, "u", targetid)) return SendUsageMessage(playerid, "/id [playername/playerid]");
	if(!IsPlayerConnected(targetid)) return SendErrorMessage(playerid, "That player is not connected.");

	format(string, sizeof(string), "(ID: %d) %s", targetid, GetName(targetid));
	SendClientMessage(playerid, COLOR_YELLOW, string);
	return 1;
}

CMD:ah(playerid, params[]) return cmd_ahelp(playerid, params);
//Level 1 Admin Commands
CMD:ahelp(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1) return SendErrorMessage(playerid, "You are not authorized to use that command.");
	TextDrawShowForPlayer(playerid, WAdmin1[0]);
    SelectTextDraw(playerid, 0xFFFFFFAA);
	return 1;
}
CMD:kick(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1) return SendErrorMessage(playerid, "You are not authorized to use that command.");
	if(KickToggle) return SendErrorMessage(playerid, "That command is currently disabled, contact a level 4 to enable it.");
	new targetid, reason[128], string[200];
	if(sscanf(params, "us[128]", targetid, reason)) return SendUsageMessage(playerid, "/kick [playername/playerid] [reason]");
	if(!IsPlayerConnected(targetid)) return SendErrorMessage(playerid, "That player is not connected.");
	
	format(string, sizeof(string), "AdmCmd: %s(%d) has been kicked by %s(%d), Reason: %s", GetName(targetid), targetid, GetName(playerid), playerid, reason);
	SendClientMessageToAll(COLOR_TOMATO, string);
	SetTimerEx("SendToKick", 400, false, "i", playerid);
	return 1;
}
CMD:warn(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1) return SendErrorMessage(playerid, "You are not authorized to use that command.");
	new targetid, reason[128], string[200];
	if(sscanf(params, "us[128]", targetid, reason)) return SendUsageMessage(playerid, "/warn [playername/playerid] [reason]");
	if(!IsPlayerConnected(targetid)) return SendErrorMessage(playerid, "That player is not connected.");

	format(string, sizeof(string), "%s(%d) has been warned by %s(%d), Reason: %s", GetName(targetid), targetid, GetName(playerid), playerid, reason);
	SendClientMessageToAll(COLOR_TOMATO, string);
	PlayerInfo[targetid][pWarns]++;
	return 1;
}
CMD:removewarns(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1) return SendErrorMessage(playerid, "You are not authorized to use that command.");
	new targetid, string[200];
	if(sscanf(params, "u", targetid)) return SendUsageMessage(playerid, "/removewarn [playername/playerid]");
	if(!PlayerInfo[targetid][pWarns]) return SendErrorMessage(playerid, "That player does not have any warning.");
	if(!IsPlayerConnected(targetid)) return SendErrorMessage(playerid, "That player is not connected.");
	
	format(string, sizeof(string), "AdmWarn: %s(%d) has removed all of %s(%d)'s warnings.", GetName(playerid), playerid, GetName(targetid), targetid);
	SendAdminMessage(COLOR_CLIENT, string);
	PlayerInfo[targetid][pWarns] = 0;
	
	return 1;
}
CMD:ban(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, -1, "SERVER: You are not authorized to use that command."); // If the player is not logged into rcon
 	if(BanToggle) return SendErrorMessage(playerid, "That command is currently disabled, contact a level 4 to enable it.");

    new PlayerIP[17];
    new giveplayerid, reason[128], string[150], query[150];
    GetPlayerIp(giveplayerid, PlayerIP, sizeof(PlayerIP)); // We are going to get the target's IP with this.

    if(sscanf(params, "us[128]", giveplayerid, reason)) return SendClientMessage(playerid, -1, "USAGE: /ban [playerid] [reason]"); // This will show the usage of the command after the player types /ban
    if(!IsPlayerConnected(giveplayerid)) return SendClientMessage(playerid, -1, "That player is not connected"); // If the target is not connected.

    mysql_format(Database, query, sizeof(query), "INSERT INTO `bans` (`Username`, `BannedBy`, `BanReason`, `IpAddress`, `Date`) VALUES ('%e', '%e', '%e', '%e', '%e')", GetName(giveplayerid), GetName(playerid), reason, PlayerIP, ReturnDate());
    mysql_tquery(Database, query, "", ""); // This will insert the information into the bans table.

    format(string, sizeof(string), "SERVER: %s[%d] was banned by %s, Reason: %s", GetName(giveplayerid), giveplayerid, GetName(playerid), reason); // This message will be sent to every player online.
    SendClientMessageToAll(-1, string);
    SetTimerEx("SendToKick", 500, false, "d", giveplayerid); // Kicks the player in 500 miliseconds.
    return 1;
}

CMD:unban(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, -1, "SERVER: You are not authorized to use that command.");

    new name[MAX_PLAYER_NAME], query[150], string[150], rows;
    if(sscanf(params, "s[128]", name)) return SendClientMessage(playerid, -1, "USAGE: /unban [name]"); // This will show the usage of the command if the player types only /unban.
    mysql_format(Database, query, sizeof(query), "SELECT * FROM `bans` WHERE `Username` = '%e' LIMIT 0, 1", name);
    new Cache:result = mysql_query(Database, query);
    cache_get_row_count(rows);

    if(!rows)
    {
        SendClientMessage(playerid, -1, "SERVER: That name does not exist or there is no ban under that name.");
    }

    for (new i = 0; i < rows; i ++)
    {
        mysql_format(Database, query, sizeof(query), "DELETE FROM `bans` WHERE Username = '%e'", name);
        mysql_tquery(Database, query);
        for(new x; x < MAX_PLAYERS; x++)
        {
            if(IsPlayerAdmin(x))
            {
                format(string, sizeof(string), "AdminWarn: %s(%d) has unbanned %s", GetName(playerid), name);
                SendClientMessage(x, -1, string);
            }
        }
    }
    cache_delete(result);
    return 1;
}
CMD:oban(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, -1, "SERVER: You are not authorized to use that command.");
    new name[MAX_PLAYER_NAME], reason[128], query[300], string[100], rows;
    if(sscanf(params, "s[24]s[128]", name, reason)) return SendClientMessage(playerid, -1, "USAGE: /oban [username] [reason]");
    mysql_format(Database, query, sizeof(query), "SELECT `Username` FROM `users` WHERE `Username` = '%e' LIMIT 0,1", name);
    new Cache:result = mysql_query(Database, query);
    cache_get_row_count(rows);

    if(!rows)
    {
        SendClientMessage(playerid, -1, "SERVER: That name does not exist.");
    }

    for (new i = 0; i < rows; i ++)
    {
        mysql_format(Database, query, sizeof(query), "INSERT INTO `bans` (`Username`, `BannedBy`, `BanReason`, `Date`) VALUES ('%e', '%e', '%e', '%e')", name, GetName(playerid), reason, ReturnDate());
        mysql_tquery(Database, query);
        format(string, sizeof(string), "AdmCmd: {FF0000}%s has been offline-banned by %s, Reason: %s", name, GetName(playerid), reason);
        SendClientMessageToAll(-1, string);
    }
    cache_delete(result);
    return 1;
}
CMD:baninfo(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, -1, "SERVER: You are not authorized to use that command.");
    new name[MAX_PLAYER_NAME], query[300], rows;
    if(sscanf(params, "s[24]", name)) return SendClientMessage(playerid, -1, "USAGE: /baninfo [username]");
    mysql_format(Database, query, sizeof(query), "SELECT * FROM `bans` where `Username` = '%e' LIMIT 0, 1", name);
    new Cache:result = mysql_query(Database, query);
    cache_get_row_count(rows);

    if(!rows)
    {
        SendClientMessage(playerid, -1, "SERVER: That name does not exist or there is no ban under that name.");
    }

    for (new i = 0; i < rows; i ++)
    {
        new Username[24], BannedBy[24], BanReason[24], BanID, Date[30];
        cache_get_value_name(0, "Username", Username);
        cache_get_value_name(0, "BannedBy", BannedBy);
        cache_get_value_name(0, "BanReason", BanReason);
        cache_get_value_name_int(0, "BanID", BanID);
        cache_get_value_name(0, "Date", Date);

        new string[500];
        format(string, sizeof(string), "{FFFFFF}Checking ban information on user: {9D00AB}%s\n\n{FFFFFF}Username: {9D00AB}%s\n{FFFFFF}Banned By: {9D00AB}%s\n{FFFFFF}Ban Reason: {9D00AB}%s\n{FFFFFF}Ban ID: {9D00AB}%i\n{FFFFFF}Date: {9D00AB}%s\n\n{FFFFFF}Type /unban [name] if you want to unban this user.", name, Username, BannedBy, BanReason, BanID, Date);
        Dialog_Show(playerid, DIALOG_BANCHECK, DIALOG_STYLE_MSGBOX, "{FFFFFF}Ban Information", string, "Close", "");
    }
    cache_delete(result);
    return 1;
}
CMD:mute(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1) return SendErrorMessage(playerid, "You are not authorized to use that command.");
	new targetid, time, reason[128];
	if(sscanf(params, "uds[128]", targetid, time, reason)) return SendUsageMessage(playerid, "/mute [playername/playerid] [time] [reason]");
	if(!IsPlayerConnected(targetid)) return SendErrorMessage(playerid, "That player is not connected.");
	
	if(time < 1) return SendErrorMessage(playerid, "You can't mute a player for under 1 minute.");
	if(strlen(reason) > 45)
	{
	    SendClientMessageToAllEx(COLOR_KHAKI, "AdmCmd: %s has muted %s(%d) for %d minutes, Reason: %.56s", GetName(playerid), GetName(targetid), targetid, time, reason);
	    SendClientMessageToAllEx(COLOR_KHAKI, "AdmCmd: ...%s", reason[45]);
	}
	else SendClientMessageToAllEx(COLOR_KHAKI, "AdmCmd: %s has muted %s(%d) for %d minutes, Reason: %s", GetName(playerid), GetName(targetid), targetid, time, reason);
	
	PlayerInfo[targetid][pMuted] = true;
	PlayerInfo[targetid][pMutedTime] = time * 60;
	return 1;
}
CMD:unmute(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin]< 1) return SendErrorMessage(playerid, "You are not authorized to use that command.");

	new targetid;
	if(sscanf(params, "u", targetid)) return SendUsageMessage(playerid, "/unmute [playername/playerid]");
	if(!IsPlayerConnected(targetid)) return SendErrorMessage(playerid, "That player is not connected.");
	if(!PlayerInfo[targetid][pMuted]) return SendErrorMessage(playerid, "That player is not muted.");

	PlayerInfo[targetid][pMuted] = false;
	PlayerInfo[targetid][pMutedTime] = 0;

	SendClientMessageToAllEx(COLOR_ORANGE, "AdmCmd: %s has unmuted %s(%d)", GetName(playerid), GetName(targetid), targetid);
	return 1;
}
CMD:jail(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1) return SendErrorMessage(playerid, "You are not authorized to use that command.");

	new targetid, time, reason[100];
	if(sscanf(params, "uds[100]", targetid, time, reason)) return SendUsageMessage(playerid, "/jail [playername/playerid] [time] [reason]");
	if(!IsPlayerConnected(targetid)) return SendErrorMessage(playerid, "That player is not connected.");

	if(time < 1) return SendErrorMessage(playerid, "You can't jail a player for under 1 minute.");

	if(strlen(reason) > 45)
	{
		SendClientMessageToAllEx(COLOR_ORANGE, "AdmCmd(1): %s has jailed %s(%d) for %d minutes, Reason: %.56s", GetName(playerid), GetName(targetid), targetid, time, reason);
		SendClientMessageToAllEx(COLOR_ORANGE, "AdmCmd(1): ...%s", reason[56]);
	}
	else SendClientMessageToAllEx(COLOR_ORANGE, "AdmCmd(1): %s has jailed %s(%d) for %d minutes, Reason: %s", GetName(playerid), GetName(targetid), targetid, time, reason);

	ClearAnimations(targetid);
	SetPlayerPos(targetid, 2687.3630, 2705.2537, 22.9472);
	SetPlayerInterior(targetid, 0); SetPlayerVirtualWorld(targetid, 1338);

	PlayerInfo[targetid][pJailed] = true;
	PlayerInfo[targetid][pJailedTime] = time * 60;
	return 1;
}
CMD:unjail(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin]< 1)
			return SendErrorMessage(playerid, "You are not authorized to use this command");

	new targetid;
	if(sscanf(params, "u", targetid)) return SendUsageMessage(playerid, "/unjail [playerid].");
	if(!IsPlayerConnected(targetid)) return SendErrorMessage(playerid, "That player is not connected.");
	if(!PlayerInfo[targetid][pJailed]) return SendErrorMessage(playerid, "That player is not jailed.");

	SetPlayerVirtualWorld(targetid, 0); SetPlayerInterior(targetid, 0);

	PlayerInfo[targetid][pJailed] = false;
	PlayerInfo[targetid][pJailedTime] = 0;

	SendClientMessageToAllEx(COLOR_ORANGE, "AdmCmd: %s has unjailed %s(%d)", GetName(playerid), GetName(targetid), targetid);
	return 1;
}
CMD:goto(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 1) return SendErrorMessage(playerid, "You are not authorized to use that command.");
	new targetid, string[200], Float: TargetPos[3];
	GetPlayerPos(targetid, TargetPos[0], TargetPos[1], TargetPos[2]);
	if(sscanf(params, "u", targetid)) return SendUsageMessage(playerid, "/goto [playername/playerid]");
	if(!IsPlayerConnected(targetid)) return SendErrorMessage(playerid, "That player is not connected.");
	
	SetPlayerPos(playerid, TargetPos[0], TargetPos[1] + 2.0, TargetPos[2]);
	format(string, sizeof(string), "You have been teleported to %s(%d)'s position.", GetName(targetid), targetid);
	SendClientMessage(playerid, COLOR_CLIENT, string);
	format(string, sizeof(string), "%s(%d) has been teleported to your position.", GetName(playerid), playerid);
	SendClientMessage(targetid, COLOR_CLIENT, string);
	return 1;
}
CMD:get(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 1) return SendErrorMessage(playerid, "You are not authorized to use that command.");
	new targetid, string[200], Float: PlayerPos[3];
	GetPlayerPos(playerid, PlayerPos[0], PlayerPos[1], PlayerPos[2]);
	if(sscanf(params, "u", targetid)) return SendUsageMessage(playerid, "/get [playername/playerid]");
	if(!IsPlayerConnected(targetid)) return SendErrorMessage(playerid, "That player is not connected.");

	SetPlayerPos(targetid, PlayerPos[0], PlayerPos[1] + 2.0, PlayerPos[2]);
	format(string, sizeof(string), "You have teleported %s(%d)'s to your position.", GetName(targetid), targetid);
	SendClientMessage(playerid, COLOR_CLIENT, string);
	format(string, sizeof(string), "%s(%d) has teleported you to their position.", GetName(playerid), playerid);
	SendClientMessage(targetid, COLOR_CLIENT, string);
	return 1;
}
CMD:a(playerid, params[]) return cmd_admin(playerid, params);
CMD:admin(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1) return SendErrorMessage(playerid, "You are not authorized to use that command.");
	if(AChatToggle) return SendErrorMessage(playerid, "Admin chat is currently disabled, tell a level 4+ to enable it.");
	new text[130], string[300];
	if(sscanf(params, "s[130]", text)) return SendUsageMessage(playerid, "/(a)dmin [text]");
	
	if(PlayerInfo[playerid][pAdmin] == 1)
	{
		format(string, sizeof(string), "** Junior Administrator %s says: %s", GetName(playerid), text);
		SendAdminMessage(COLOR_LIGHTGREEN, string);
	}
 	else if(PlayerInfo[playerid][pAdmin] == 2)
	{
		format(string, sizeof(string), "** General Administrator %s says: %s", GetName(playerid), text);
		SendAdminMessage(COLOR_LIGHTGREEN, string);
	}
 	else if(PlayerInfo[playerid][pAdmin] == 3)
	{
		format(string, sizeof(string), "** Senior Administrator %s says: %s", GetName(playerid), text);
		SendAdminMessage(COLOR_LIGHTGREEN, string);
	}
	else if(PlayerInfo[playerid][pAdmin] == 4)
	{
		format(string, sizeof(string), "** Lead Administrator %s says: %s", GetName(playerid), text);
  		SendAdminMessage(COLOR_LIGHTGREEN, string);
	}
	return 1;
}

// Level 2 Admin Commands
CMD:announce(playerid, params[])
{
	new text[130], string[300];
	if(PlayerInfo[playerid][pAdmin] < 2) return SendErrorMessage(playerid, "You are not authorized to use that command.");
	if(sscanf(params, "s[130]", text)) return SendUsageMessage(playerid, "/announce [text]");
	format(string, sizeof(string), "[Announcement]: %s (%s)", text, GetName(playerid));
	SendClientMessageToAll(COLOR_ORANGE, string);
	return 1;
}
CMD:jetpack(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2) return SendErrorMessage(playerid, "You are not authorized to use that command.");
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
    SendClientMessage(playerid, COLOR_TOMATO, "You gave yourself a jetpack.");
	return 1;
}
CMD:sethealth(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2) return SendErrorMessage(playerid, "You are not authorized to use that command.");
	new targetid, amount;
	if(sscanf(params, "ud", targetid, amount)) return SendUsageMessage(playerid, "/sethealth [playername/playerid] [amount]");
	if(!IsPlayerConnected(targetid)) return SendErrorMessage(playerid, "That player is not connected.");
	SetPlayerHealth(targetid, amount);
	SendClientMessageEx(targetid, COLOR_KHAKI, "%s(%d) has set your health to %d", GetName(playerid), playerid, amount);
	SendClientMessageEx(playerid, COLOR_YELLOW, "AdmCmd: You have set %s(%d)'s health to %d", GetName(targetid), targetid, amount);
	return 1;
}
CMD:setarmour(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2) return SendErrorMessage(playerid, "You are not authorized to use that command.");
	new targetid, amount;
	if(sscanf(params, "ud", targetid, amount)) return SendUsageMessage(playerid, "/setarmour [playername/playerid] [amount]");
	if(!IsPlayerConnected(targetid)) return SendErrorMessage(playerid, "That player is not connected.");
	SetPlayerArmour(targetid, amount);
	SendClientMessageEx(targetid, COLOR_KHAKI, "%s(%d) has set your armour to %d", GetName(playerid), playerid, amount);
	SendClientMessageEx(playerid, COLOR_YELLOW, "AdmCmd: You have set %s(%d)'s armour to %d", GetName(targetid), targetid, amount);
	return 1;
}
CMD:setskin(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2) return SendErrorMessage(playerid, "You are not authorized to use that command.");
	new targetid, skin;
	if(sscanf(params, "ud", targetid, skin)) return SendUsageMessage(playerid, "/setskin [playername/playerid] [skinid]");
	if(!IsPlayerConnected(targetid)) return SendErrorMessage(playerid, "That player is not connected.");
	SetPlayerSkin(targetid, skin);
	SendClientMessageEx(targetid, COLOR_KHAKI, "%s(%d) has set your skin to %d", GetName(playerid), playerid, skin);
	SendClientMessageEx(playerid, COLOR_YELLOW, "AdmCmd: You have set %s(%d)'s skin to %d", GetName(targetid), targetid, skin);
	return 1;
}
CMD:setinterior(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2) return SendErrorMessage(playerid, "You are not authorized to use that command.");
	new targetid, interior;
	if(sscanf(params, "ud", targetid, interior)) return SendUsageMessage(playerid, "/setinterior [playername/playerid] [interior]");
	if(!IsPlayerConnected(targetid)) return SendErrorMessage(playerid, "That player is not connected.");
	SetPlayerInterior(targetid, interior);
	SendClientMessageEx(targetid, COLOR_KHAKI, "%s(%d) has set your interior to %d", GetName(playerid), playerid, interior);
	SendClientMessageEx(playerid, COLOR_YELLOW, "AdmCmd: You have set %s(%d)'s interior to %d", GetName(targetid), targetid, interior);
	return 1;
}
CMD:setworld(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2) return SendErrorMessage(playerid, "You are not authorized to use that command.");
	new targetid, world;
	if(sscanf(params, "ud", targetid, world)) return SendUsageMessage(playerid, "/setworld [playername/playerid] [world]");
	if(!IsPlayerConnected(targetid)) return SendErrorMessage(playerid, "That player is not connected.");
	SetPlayerVirtualWorld(targetid, world);
	SendClientMessageEx(targetid, COLOR_KHAKI, "%s(%d) has set your world to %d", GetName(playerid), playerid, world);
	SendClientMessageEx(playerid, COLOR_YELLOW, "AdmCmd: You have set %s(%d)'s world to %d", GetName(targetid), targetid, world);
	return 1;
}
CMD:removeweps(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2) return SendErrorMessage(playerid, "You are not authorized to use that command.");
	new targetid;
	if(sscanf(params, "u", targetid)) return SendUsageMessage(playerid, "/removeweps [playername/playerid]");
	if(!IsPlayerConnected(targetid)) return SendErrorMessage(playerid, "That player is not connected.");
	ResetPlayerWeapons(targetid);
	SendClientMessageEx(playerid, COLOR_YELLOW, "AdmCmd: You have removed %s(%d)'s weapons.", GetName(targetid), targetid);
	return 1;
}
CMD:akill(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2) return SendErrorMessage(playerid, "You are not authorized to use that command.");
	new targetid;
	if(sscanf(params, "u", targetid)) return SendUsageMessage(playerid, "/akill [playername/playerid]");
	if(!IsPlayerConnected(targetid)) return SendErrorMessage(playerid, "That player is not connected.");
	SetPlayerHealth(targetid, 0);
	SetPlayerArmour(targetid, 0);
	SendClientMessageEx(playerid, COLOR_YELLOW, "You have killed %s(%d)", GetName(targetid), targetid);
	return 1;
}

//Level 3 Admin Commands
CMD:freeze(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 3) return SendErrorMessage(playerid, "You are not authorized to use that command.");
    new targetid;
    if(sscanf(params, "u", targetid)) return SendUsageMessage(playerid, "/freeze [playername/playerid]");
    if(!IsPlayerConnected(targetid)) return SendErrorMessage(playerid, "That player is not connected.");
    TogglePlayerControllable(targetid, 0);
    SendClientMessageEx(playerid, COLOR_YELLOW, "You have frozen %s(%d)", GetName(targetid), targetid);
	return 1;
}
CMD:unfreeze(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 3) return SendErrorMessage(playerid, "You are not authorized to use that command.");
    new targetid;
    if(sscanf(params, "u", targetid)) return SendUsageMessage(playerid, "/unfreeze [playername/playerid]");
    if(!IsPlayerConnected(targetid)) return SendErrorMessage(playerid, "That player is not connected.");
    TogglePlayerControllable(targetid, 1);
    SendClientMessageEx(playerid, COLOR_YELLOW, "You have unfrozen %s(%d)", GetName(targetid), targetid);
	return 1;
}
CMD:givegun(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 3) return SendErrorMessage(playerid, "You are not authorized to use that command.");
	new targetid, weaponid, ammo;
	if(sscanf(params, "udd", targetid, weaponid, ammo)) return SendUsageMessage(playerid, "/givegun [playername/playerid] [weaponid] [ammo]");
	if(!IsPlayerConnected(targetid)) return SendErrorMessage(playerid, "That player is not connected.");
	GivePlayerWeapon(targetid, weaponid, ammo);
	SendClientMessageEx(targetid, COLOR_KHAKI, "%s(%d) has given you gun id %d with %d ammo", GetName(playerid), playerid, weaponid, ammo);
	SendClientMessageEx(playerid, COLOR_YELLOW, "AdmCmd: You have given gun id %d (%d ammo) to %s(%d)", weaponid, ammo, GetName(targetid), targetid);
	return 1;
}
CMD:givecash(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 3) return SendErrorMessage(playerid, "You are not authorized to use that command.");
	new targetid, cash;
	if(sscanf(params, "ud", targetid, cash)) return SendUsageMessage(playerid, "/givecash [playername/playerid] [amount]");
	if(!IsPlayerConnected(targetid)) return SendErrorMessage(playerid, "That player is not connected.");
	GivePlayerMoney(targetid, cash);
	SendClientMessageEx(targetid, COLOR_KHAKI, "%s(%d) has given $%d to you.", GetName(playerid), playerid, cash);
	SendClientMessageEx(targetid, COLOR_YELLOW, "AdmCmd: You have given $%d to %s(%d)", cash, GetName(targetid), targetid);
	return 1;
}
CMD:setscore(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 3) return SendErrorMessage(playerid, "You are not authorized to use that command.");
	new targetid, score;
	if(sscanf(params, "ud", targetid, score)) return SendUsageMessage(playerid, "/setscore [playername/playerid] [amount]");
	if(!IsPlayerConnected(targetid)) return SendErrorMessage(playerid, "That player is not connected.");
	SetPlayerScore(targetid, score);
	SendClientMessageEx(targetid, COLOR_KHAKI, "%s(%d) has set your score to %d.", GetName(playerid), playerid, score);
	SendClientMessageEx(targetid, COLOR_YELLOW, "AdmCmd: You have set %s(%d)'s score to %d", GetName(targetid), targetid, score);
	return 1;
}

//Level 4 Admin Commands
CMD:config(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4) return SendErrorMessage(playerid, "You are not authorized to use that command.");
	ShowConfig(playerid);
	return 1;
}
CMD:fakechat(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4) return SendErrorMessage(playerid, "You are not authorized to use that command.");
	new targetid, chat[300], string[300];
	if(sscanf(params, "us[300]", targetid, chat)) return SendUsageMessage(playerid, "/fakechat [playername/playerid] [text]");
	if(!IsPlayerConnected(targetid)) return SendErrorMessage(playerid, "That player is not connected.");
	format(string, sizeof(string), "[%d]%s: %s", targetid, GetName(targetid), chat);
	SendClientMessageToAll(COLOR_WHITE, string);
	return 1;
}
CMD:setadmin(playerid, params[])
{
    if(!IsPlayerAdmin(playerid)) return SendErrorMessage(playerid, "You are not authorized to use that command.");
	new targetid, level, string[300];
	if(sscanf(params, "ud", targetid, level)) return SendUsageMessage(playerid, "/setadmin [playername/playerid] [level]");
	if(!IsPlayerConnected(targetid)) return SendErrorMessage(playerid, "That player is not connected.");
	if(level < 0 || level > 4) return SendErrorMessage(playerid, "Admin Level must be between 0 and 4.");
	PlayerInfo[targetid][pAdmin] = level;
	format(string, sizeof(string), "You have been set as a Level %d Administrator by %s(%d)", level, GetName(playerid), playerid);
	SendClientMessage(targetid, COLOR_KHAKI, string);
	format(string, sizeof(string), "You have set %s(%d) as a Level %d Administrator.", GetName(targetid), targetid, level);
	SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
	return 1;
}
CMD:giveallwep(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 4) return SendErrorMessage(playerid, "You are not authorized to use that command.");
	new weaponid, ammo, string[150];
	if(sscanf(params, "dd", weaponid, ammo)) return SendUsageMessage(playerid, "/giveallwep [weaponid] [ammo]");
	foreach(new i : Player)
	{
		GivePlayerWeapon(i, weaponid, ammo);
		format(string, sizeof(string), "%s(%d) has given all players gun id %d with %d ammo", GetName(playerid), playerid, weaponid, ammo);
		SendClientMessageToAll(COLOR_KHAKI, string);
	}
	return 1;
}
CMD:giveallscore(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 4) return SendErrorMessage(playerid, "You are not authorized to use that command.");
	new score, string[150];
	if(sscanf(params, "d", score)) return SendUsageMessage(playerid, "/giveallscore [score]");
	foreach(new i : Player)
	{
		SetPlayerScore(i, score);
		format(string, sizeof(string), "%s(%d) has given all players %d score", GetName(playerid), playerid, score);
		SendClientMessageToAll(COLOR_KHAKI, string);
	}
	return 1;
}
CMD:settime(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 4) return SendErrorMessage(playerid, "You are not authorized to use that command.");
	new time;
	if (sscanf(params, "d", time)) return SendUsageMessage(playerid, "/settime [time]");
	if (time < 0 || time > 24) return SendErrorMessage(playerid, "Invalid time" );
	SendClientMessageEx(playerid, COLOR_YELLOW, "You have changed the server time to %d", time);
	foreach(new i : Player)
	{
		SetPlayerTime(i, time, 0);
	}
	return 1;
}
CMD:setweather(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 4) return SendErrorMessage(playerid, "You are not authorized to use that command.");
	new weather;
	if(sscanf(params, "d", weather)) return SendUsageMessage(playerid, "/setweather [weather]");
	if(weather < 0 || weather > 24) return SendErrorMessage(playerid, "Invalid weather" );
	SendClientMessageEx(playerid, COLOR_YELLOW, "You have changed the server weather to %d", weather);
	foreach(new i : Player)
	{
		SetPlayerWeather(i, weather);
	}
	return 1;
}
CMD:lockserver(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 4) return SendErrorMessage(playerid, "You are not authorized to use that command.");
    new password[30], string[30];
    if(sscanf(params, "s[30]", password)) return SendUsageMessage(playerid, "/setweather [weather]");
	SendClientMessageEx(playerid, COLOR_YELLOW, "You have set the server password to %s", password);
	format(string, sizeof(string), "password %s", password);
	SendRconCommand(string);
	return 1;
}
CMD:restartserver(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 4) return SendErrorMessage(playerid, "You are not authorized to use that command.");
    if(RestartToggle) return SendErrorMessage(playerid, "That command is currently disabled, contact a level 4 to enable it.");
	SendRconCommand("gmx");
	return 1;
}
#endif
