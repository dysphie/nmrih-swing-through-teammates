#include <sdktools>
#include <sdkhooks>
#include <dhooks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = {
	name        = "[NMRiH] Swing Through Teammates",
	author      = "Dysphie",
	description = "Allows melee traces to pass through teammates",
	version     = "0.1.0",
	url         = ""
};

enum
{
	Ignore_None,
	Ignore_Healthy,
	Ignore_Infected
}

int offs_RefEHandle;
bool checkingHit;
ConVar cvIgnoreType;
int ignoreType;

public void OnPluginStart()
{
	ParseGamedata();
	cvIgnoreType = CreateConVar("sm_melee_swing_through_players", "1",
		"How melee traces interact with players. " ...
		"0 = Don't pass through (vanilla behaviour), " ...
		"1 = Pass through healthy teammates, " ...
		"2 = Pass through healthy and infected teammates. "
	);

	cvIgnoreType.AddChangeHook(OnIgnoreTypeChanged);
}

public void OnConfigsExecuted()
{
	ignoreType = cvIgnoreType.IntValue;
}

public void OnIgnoreTypeChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	ignoreType = convar.IntValue;
}

void ParseGamedata()
{
	GameData gd = new GameData("swingthrough.games");

	DynamicDetour shouldHitEnt = DynamicDetour.FromConf(gd, "CTraceFilterSkipTwoEntities::ShouldHitEntity");
	if (!shouldHitEnt)
		SetFailState("Failed to detour CTraceFilterSkipTwoEntities::ShouldHitEntity");
	shouldHitEnt.Enable(Hook_Pre, OnMeleeShouldHitEntity);

	DynamicDetour checkMeleeHit = DynamicDetour.FromConf(gd, "CNMRiH_MeleeBase::CheckMeleeHit");
	if (!checkMeleeHit)
		SetFailState("Failed to detour CNMRiH_MeleeBase::CheckMeleeHit");
	checkMeleeHit.Enable(Hook_Pre, OnCheckMeleeHit);
	checkMeleeHit.Enable(Hook_Post, OnCheckMeleeHitPost);

	offs_RefEHandle = gd.GetOffset("CBaseEntity::m_RefEHandle");
	if (offs_RefEHandle == -1)
		SetFailState("Failed to find offset for CBaseEntity::m_RefEHandle");

	delete gd;
}

public MRESReturn OnCheckMeleeHit(DHookReturn hReturn)
{
	checkingHit = true;
	return MRES_Ignored;
}

public MRESReturn OnCheckMeleeHitPost(DHookReturn hReturn)
{
	checkingHit = false;
	return MRES_Ignored;
}

public MRESReturn OnMeleeShouldHitEntity(DHookReturn hReturn, DHookParam hParams)
{
	if (checkingHit && ignoreType != Ignore_None)
	{
		int entity = hParams.GetObjectVar(1, offs_RefEHandle, ObjectValueType_Ehandle); 
		if (0 < entity <= MaxClients)
		{
			hReturn.Value = IsPlayerInfected(entity) && ignoreType != Ignore_Infected;
			return MRES_Supercede;
		}
	}
	return MRES_Ignored;
}

bool IsPlayerInfected(int player)
{
	return GetEntPropFloat(player, Prop_Send, "m_flInfectionTime") != -1.0;
}
