-- // don't touch these!
LIGHTSABER_PLUS_FORMS = {}
LIGHTSABER_PLUS_MAX_FORCE = {}
LIGHTSABER_PLUS_TEAM_FORCE_POWERS = {}
LIGHTSABER_PLUS_FORM_ORDER = {}
LIGHTSABER_PLUS_RARITIES = {}
LIGHTSABER_PLUS_CONFIG = true -- Leave this alone or it'll break shit.
LIGHTSABER_PLUS_DEBUG_MODE = false -- turn on debugging text.
-- ////////////////////////////////

-- // Optimizations.
LIGHTSABER_PLUS_OPTIMIZE_FEET = true -- disables feet sound, for some reason its causing unneccessary networking.
LIGHTSABER_PLUS_NETWORK_BITS = 16 -- if sabers are invisible, raise this.

-- // Movement.
LIGHTSABER_PLUS_RUNSPEED = 230
LIGHTSABER_PLUS_WALKSPEED = 120

-- // Level System Enabler.
LIGHTSABER_PLUS_NO_LEVEL_REQ = true

-- // Combat Settings
LIGHTSABER_PLUS_DEFAULT_FORM = "Shii-Cho" -- Default Form, make sure this exists or u fuck the system.
LIGHTSABER_PLUS_FACE_ON_BLOCK = false -- When you block a shot, should we face the target? (the answer is no, its ass, but ur choice.)
LIGHTSABER_PLUS_BLOCK_360 = true -- Can we block 360 degrees?
LIGHTSABER_PLUS_DEFAULT_DAMAGE = 100 -- Default saber damage.
LIGHTSABER_PLUS_BLOCK_PERC = 0.1 -- incomingDamage * LIGHTSABER_PLUS_BLOCK_PERC = newDamage
LIGHTSABER_PLUS_REGEN_DELAY = 10 -- 60s is recommended
LIGHTSABER_PLUS_COMBAT_BLOCK_ON_ATTACK = false -- If both players are attacking, we block (like the movies) makes for a shitty fight.
LIGHTSABER_PLUS_MAX_REACH = 125 -- How far away can the client say it is for a hit.
LIGHTSABER_PLUS_HIT_SCAN_SEGMENTS = 5

-- // Combat Rolling
LIGHTSABER_PLUS_ROLL_ENABLED = true -- Enable Combat rolling.
LIGHTSABER_PLUS_ROLL_DELAY = 2 -- How long between each roll.
LIGHTSABER_PLUS_ROLL_SPEED = 200 -- How fast the combat roll thrusts you.

-- VJ NPC Decapitation.
LIGHTSABER_PLUS_VJ_DECAP = false -- Very Laggy, doubles the ragdolls on death, very bad juju, but it cool doe.

-- HUD Elements.
LIGHTSABER_PLUS_HUD_PERC = 0.85 -- 0 to 1, Where the bars should appear, 0 = top 1 = bottom of screen.
LIGHTSABER_PLUS_HUD_HIT_NUMBERS_SIZE = 15 -- size of the font.
LIGHTSABER_PLUS_HUD_HIT_NUMBERS_FONT = "Vecna" -- font of the font.
LIGHTSABER_PLUS_HUD_HIT_NUMBERS_THICC = 45 -- thiccness of the font.

-- Cosmetics
LIGHTSABER_PLUS_SABER_TRAIL = true
LIGHTSABER_PLUS_SABER_TRAIL_SPEED = 20
LIGHTSABER_PLUS_FORCE_HUD_TEAM = true -- Team Colors on the outline of the force power hud.
LIGHTSABER_PLUS_FORCE_POINTER = true -- should the plumbob exist.

-- Toggleable Features
LIGHTSABER_PLUS_BONE_MOD = false -- Manipulation of the players bone angles based on their view angles.
LIGHTSABER_PLUS_DRAW_SABERS = true -- If set to false, no blades will be drawn.
LIGHTSABER_PLUS_ANIME_NUMBERS = true -- Should we draw hit numbers?
LIGHTSABER_PLUS_KILL_HUD = false -- Should we stop the HUD?
LIGHTSABER_PLUS_KILL_SABER_TRACING = false -- Should we stop all saber tracing?
LIGHTSABER_PLUS_KILL_SOUNDS = false -- Should we kill the sound engine
LIGHTSABER_PLUS_KILL_VIEW_MOD = false -- Should we turn off the view mods.
LIGHTSABER_PLUS_KILL_DAMAGE_MOD = false -- Should we not determine the damage?
LIGHTSABER_PLUS_CINEMATIC_CAMERA = false

-- Item Rarities
LIGHTSABER_PLUS_RARITIES["Basic"] = Color(255, 255, 255)
LIGHTSABER_PLUS_RARITIES["Grand"] = Color(59, 156, 48)
LIGHTSABER_PLUS_RARITIES["Rare"] = Color(49, 72, 189)
LIGHTSABER_PLUS_RARITIES["Unique"] = Color(127, 77, 14)
LIGHTSABER_PLUS_RARITIES["Celestial"] = Color(227, 68, 76)
LIGHTSABER_PLUS_RARITIES["Legendary"] = Color(217, 136, 30)
LIGHTSABER_PLUS_RARITIES["Mythic"] = Color(177, 0, 0)


-- Item Spawner
LIGHTSABER_PLUS_MAX_ITEMS = 10 -- How many items we spawn at a time.
LIGHTSABER_PLUS_ITEM_RESPAWN_RATE = 5 -- How long in minutes before we refresh looted items.
LIGHTSABER_PLUS_ITEM_LOOT_TABLE = { -- Which items we will be releasing to the world.
	"",
}


-- Force Powers
LIGHTSABER_PLUS_FORCE_NEXT = KEY_G
LIGHTSABER_PLUS_FORCE_PREV = KEY_F
LIGHTSABER_PLUS_FORCE_CAST = KEY_LALT
LIGHTSABER_PLUS_FORCE_MAX_POWERS = 10

hook.Add("lightsaberPlusJobs", "ls+jobs", function()
	LIGHTSABER_PLUS_MAX_FORCE[1001] = 500
	LIGHTSABER_PLUS_TEAM_FORCE_POWERS[1001] = {
		["Force Leap"] = true,
		["Force Push"] = true,
		["Force Repulse"] = true,
		["Force Pull"] = true, 
		["Force Speed"] = true,
		["Force Slow"] = true,
		["Force Descent"] = true,
		["Force Heal"] = true,
		["Force Meditate"] = true,
		["Force Choke"] = true,
		["Force Heal Other"] = true,
		["Force Cloak"] = true,
		["Force Absorb"] = true,
		["Force Bubble"] = true,
		["Force Block"] = true,
	}

	LIGHTSABER_PLUS_MAX_FORCE[TEAM_CITIZEN] = 5000

	LIGHTSABER_PLUS_TEAM_FORCE_POWERS[TEAM_CITIZEN] = {
		["Force Leap"] = true,
		["Force Push"] = true,
		["Force Repulse"] = true,
		["Force Pull"] = true,
		["Force Speed"] = true,
		["Force Slow"] = true,
		["Force Descent"] = true,
		["Force Heal"] = true,
		["Force Meditate"] = true,
		["Force Choke"] = true,
		["Force Heal Other"] = true,
		["Force Cloak"] = true,
		["Force Absorb"] = true,
		["Force Bubble"] = true,
		["Force Block"] = true,

		["Mass Disarm"] =true,
		["Force Lightning"] =true,
		["Mass Lightning"] =true,
		["Force Dash"] =true,
		["Mass Choke"] =true,
		["Force Storm"] =true,
		["Electric Judgement"] =true,
		["Mass Electric Judgement"] =true,
		["Force Drain"] =true,
		["Force Leech"] =true,
		["Force Crush"] =true,
		["Mass Combust"] =true,
		["Force Extinguish"] =true,
		["Mass Extinguish"] =true,
		["Rock Throw"] =true,
		["Boulder Bash"] =true,
		["Chain Lightning"] =true,
		["Force Shock"] =true,
		["Force Scream"] =true,
		["Lightning Shield"] =true,
		["Force Teleport"] =true,
	}

end)

-- // Third Person Settings
LIGHTSABER_PLUS_FIRSTPERSON_REALISM = false -- Pitch & Yaw are determined by the playermodel.
LIGHTSABER_PLUS_FIRSTPERSON_REALISM_LITE = false -- Only the yaw is determined by the playermodel.
LIGHTSABER_PLUS_FIRSTPERSON_REALISM_SMOOTHED = false -- Adds smoothing to the above to make less jitter.

-- // Form Data
LIGHTSABER_PLUS_FORM_ORDER[1] = "Shii-Cho"
LIGHTSABER_PLUS_FORM_ORDER[2] = "Makashi"

LIGHTSABER_PLUS_FORMS["Shii-Cho"] = {
	desc = "Traditional maneuvers intent on maiming and killing with a focus on disarming an armed foe. Used against superior number of opponenets.",
	icon = "I",
	lvl = 0,
	hold = "melee2",
	walk = "melee2",
	idle = "melee2",
	run = "melee2",
	a = {
		{anim = "ryoku_h_left_t2", rate = 0.75, dmg = 1, shave = 0.1, speed = 100},
		{anim = "ryoku_h_left_t1", rate = 0.75, dmg = 1.1, shave = 0.1, speed = 100, forcedTime = 0.75},
		{anim = "ryoku_r_left_t1", rate = 1, dmg = 1.2, shave = 0.1, speed = 50},
	},
	w = {
		{anim = "ryoku_r_c4_t2", rate = 1, dmg = 1, shave = 0, speed = 100, forcedTime = 0.85},
		{anim = "ryoku_r_c4_t1", rate = 1, dmg = 0.75, shave = 0.1, speed = 0},
		{anim = "ryoku_r_c3_t1", rate = 1, dmg = 1, shave = 0.1, speed = 100},
		{anim = "ryoku_r_c2_t1", rate = 1, dmg = 1.1, shave = 0.1, speed = 75},
		{anim = "ryoku_r_c1_t3", rate = 1, dmg = 1.5, shave = 0.1, speed = 50},
		{anim = "ryoku_r_c5_t1", rate = 1, dmg = 3.5, shave = 0.1, speed = 25},
	},
	d = {
		{anim = "ryoku_h_right_t2", rate = 0.75, dmg = 1, shave = 0.1, speed = 100},
		{anim = "ryoku_h_right_t1", rate = 0.75, dmg = 1.1, shave = 0.1, speed = 100, forcedTime = 0.75},
		{anim = "ryoku_r_right_t1", rate = 1, dmg = 1.2, shave = 0.1, speed = 50},
	},
	wd = {
		{anim = "ryoku_h_right_t1", rate = 1, dmg = 1, shave = 0.25, speed = 100},
		{anim = "ryoku_h_right_t2", rate = 1, dmg = 1.25, shave = 0.25, speed = 75},
		{anim = "ryoku_r_c1_t3", rate = 1, dmg = 1.5, shave = 0, speed = 25},
	},
	wa = {
		{anim = "ryoku_h_left_t1", rate = 1, dmg = 0.5, shave = 0.1, speed = 0},
		{anim = "ryoku_r_left_t1", rate = 1, dmg = 1.25, shave = 0, speed = 75, forcedTime = 0.75},
		{anim = "ryoku_r_c1_t3", rate = 1.25, dmg = 1.5, shave = 0.1, speed = 25},
	}
}

LIGHTSABER_PLUS_FORMS["Makashi"] = {
	desc = "Its primary focus on facing a single opponent and the avoidance of being disarmed by an opponent while simultaneously working to disarming them.",
	icon = "II",
	lvl = 0,
	hold = "melee2",
	walk = "melee2",
	idle = "melee2",
	run = "melee2",
	a = {
		{anim = "vanguard_b_left_t2", rate = 0.75, dmg = 1, shave = 0.1, speed = 100},
		{anim = "vanguard_b_left_t2", rate = 0.75, dmg = 1.1, shave = 0.1, speed = 100, forcedTime = 0.75},
		{anim = "vanguard_b_left_t1", rate = 1, dmg = 1.2, shave = 0.1, speed = 50},
	},
	w = {
		{anim = "pure_h_s1_t1", rate = 1, dmg = 1, shave = 0, speed = 100},
		{anim = "pure_h_s2_t2", rate = 1, dmg = 0.75, shave = 0.5, speed = 0},
		{anim = "pure_r_s1_t1", rate = 1, dmg = 1, shave = 0.1, speed = 100},
		{anim = "pure_h_s2_t1", rate = 1, dmg = 1.1, shave = 0.1, speed = 75},
		{anim = "pure_h_s1_t2", rate = 1, dmg = 1.5, shave = 0.1, speed = 50},
		{anim = "pure_h_s1_t3", rate = 1, dmg = 3.5, shave = 0.1, speed = 25},
	},
	d = {
		{anim = "pure_h_right_t1", rate = 0.75, dmg = 1, shave = 0.1, speed = 100},
		{anim = "pure_r_right_t3", rate = 0.75, dmg = 1.1, shave = 0.1, speed = 100},
		{anim = "pure_h_right_t2", rate = 1, dmg = 1.2, shave = 0.1, speed = 50},
	},
	wd = {
		{anim = "pure_r_s1_t1", rate = 1, dmg = 1, shave = 0.25, speed = 100},
		{anim = "pure_r_right_t3", rate = 1, dmg = 1.25, shave = 0.25, speed = 75},
		{anim = "pure_h_s1_t2", rate = 1, dmg = 1.5, shave = 0, speed = 25},
	},
	wa = {
		{anim = "vanguard_b_left_t2", rate = 1, dmg = 0.5, shave = 0.1, speed = 0},
		{anim = "vanguard_b_left_t1", rate = 1, dmg = 1.25, shave = 0, speed = 75, forcedTime = 0.75},
		{anim = "pure_h_s1_t2", rate = 1.25, dmg = 1.5, shave = 0.1, speed = 25},
	}
}








--// DO NOT TOUCH.
hasGamemodeLoaded = hasGamemodeLoaded or false
local validateJobConfigTime = 0


hook.Add("PostGamemodeLoaded","sdoikmfgsdf", function()
	hasGamemodeLoaded = true
	hook.Run("lightsaberPlusJobs")
	hook.Run("lightsaberPlusForms")
end)

hook.Add("Think", "dpfoigopkdsfg", function()
	if hasGamemodeLoaded then
		if validateJobConfigTime <= CurTime() then
			hook.Run("lightsaberPlusJobs")
			hook.Run("lightsaberPlusForms")
			validateJobConfigTime = CurTime() + 300 -- update every few minutes.
		end
	end
end)

function dbug(m)
	if LIGHTSABER_PLUS_DEBUG_MODE then
		MsgC(Color(255,255,0), "[DEBUG] ", Color(255,255,255), m)
	end
end




