#include <amxmodx>
#include <customshop>
#include <fakemeta>

additem ITEM_LEAP
new g_iForce, g_iMinSpeed, Float:g_fHeight, Float:g_fCooldown, bool:g_bHasLeap[33], Float:g_fLastLeap[33] 

public plugin_init() 
{
	register_plugin("CSHOP: Leap (Longjump)", "4.x", "OciXCrom & Fry!")
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	
	g_iForce = cshop_get_int(ITEM_LEAP, "Force")
	g_iMinSpeed = cshop_get_int(ITEM_LEAP, "Minimum Speed")
	g_fHeight = cshop_get_float(ITEM_LEAP, "Height")
	g_fCooldown = cshop_get_float(ITEM_LEAP, "Cooldown")
}

public plugin_precache()
{
	ITEM_LEAP = cshop_register_item("leap", "Leap (Longjump)", 2600, 1)
	cshop_set_int(ITEM_LEAP, "Force", 550)
	cshop_set_int(ITEM_LEAP, "Minimum Speed", 80)
	cshop_set_float(ITEM_LEAP, "Height", 255.0)
	cshop_set_float(ITEM_LEAP, "Cooldown", 5.0)
}

public client_putinserver(id)
	g_bHasLeap[id] = false
	
public client_disconnect(id)
	g_bHasLeap[id] = false
	
public cshop_item_selected(id, iItem)
{
	if(iItem == ITEM_LEAP)
		g_bHasLeap[id] = true
}

public cshop_item_removed(id, iItem)
{
	if(iItem == ITEM_LEAP)
		g_bHasLeap[id] = false
}

public fw_PlayerPreThink(id)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED
	
	if(can_do_longjump(id))
	{
		static Float:fVelocity[3]
		velocity_by_aim(id, g_iForce, fVelocity)
		fVelocity[2] = g_fHeight
		set_pev(id, pev_velocity, fVelocity)
		g_fLastLeap[id] = get_gametime()
	}

	return FMRES_IGNORED
}

bool:can_do_longjump(id)
{
	if(!g_bHasLeap[id] || !(pev(id, pev_flags) & FL_ONGROUND) || fm_get_speed(id) < g_iMinSpeed)
		return false
	
	static iButtons
	iButtons = pev(id, pev_button)
	
	if(!is_user_bot(id) && (!(iButtons & IN_JUMP) || !(iButtons & IN_DUCK)))
		return false
	
	if(get_gametime() - g_fLastLeap[id] < g_fCooldown)
		return false
	
	return true
}

stock fm_get_speed(iEnt)
{
	static Float:fVelocity[3]
	pev(iEnt, pev_velocity, fVelocity)
	return floatround(vector_length(fVelocity))
}
