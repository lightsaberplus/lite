return {//Dont delete this line
/*


██╗     ██╗ ██████╗ ██╗  ██╗████████╗███████╗ █████╗ ██████╗ ███████╗██████╗ ██████╗ ██╗     ██╗   ██╗███████╗
██║     ██║██╔════╝ ██║  ██║╚══██╔══╝██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔══██╗██║     ██║   ██║██╔════╝
██║     ██║██║  ███╗███████║   ██║   ███████╗███████║██████╔╝█████╗  ██████╔╝██████╔╝██║     ██║   ██║███████╗
██║     ██║██║   ██║██╔══██║   ██║   ╚════██║██╔══██║██╔══██╗██╔══╝  ██╔══██╗██╔═══╝ ██║     ██║   ██║╚════██║
███████╗██║╚██████╔╝██║  ██║   ██║   ███████║██║  ██║██████╔╝███████╗██║  ██║██║     ███████╗╚██████╔╝███████║
╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝     ╚══════╝ ╚═════╝ ╚══════╝



 ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗ 
██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝ 
██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗
██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║
╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝
 ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝ 


*/
    OptimizeFeet = true,                    -- disables feet sound, for some reason its causing unneccessary networking.
    NetworkBits = 16,                       -- if sabers are invisible, raise this.

    -- // Movement.
    RunSpeed = 230,
    WalkSpeed = 120,

    -- // Level System Disabler (false = LevelSys Activated)
    LevelSys = false,

    -- // Combat Settings
    DefaultForm = "Shii-Cho",               -- Default Form, make sure this exists or u fuck the system.
    FaceOnBlock = false,                    -- When you block a shot, should we face the target? (the answer is no, its ass, but ur choice.)
    Block360 = true,                        -- Can we block 360 degrees?

    --isnt used?
    DefaultDMG = 100,                       -- Default saber damage.
-- premium prob

    BlockPerc = 0.1,                        -- incomingDamage * LSP.Config.BlockPerc = newDamage
    RegenDelay = 10,                        -- 60s is recommended
    CombatBlock = false,                    -- If both players are attacking, we block (like the movies) makes for a shitty fight.
    MaxReach = 125,                         -- How far away can the client say it is for a hit.
    HitScanSegments = 5,                    -- dont change this

    -- // Combat Rolling
    CombatRoll = true,                      -- Enable Combat rolling.
    RollDelay = 2,                          -- How long between each roll.
    RollSpeed = 200,                        -- How fast the combat roll thrusts you.

    -- VJ NPC Decapitation.
    -- spawns body and a head instead of one ragdoll
    VJDecap = false,                        -- Very Laggy, doubles the ragdolls on death, very bad juju, but it cool doe.
-- premium prob

    -- HUD Elements.
    HUDPerc = 0.85,                         -- 0 to 1, Where the bars should appear, 0 = top 1 = bottom of screen.
    HUDHitNumberSize = 15,                  -- size of the font.
    HUDHitFontName = "Vecna",               -- font of the font.
    HUDHitFontThickNess = 45,               -- thiccness of the font.
-- needs rewrite sth like fontname only

    -- Cosmetics
    SaberTrail = true,

    SaberTrailSpeed = 20,
-- premium or unused

    ForceHudTeam = true,                    -- Team Colors on the outline of the force power hud.
    ForcePointer = true,                    -- should the plumbob exist.

    -- Toggleable Features
    BoneMod = false,                        -- Manipulation of the players bone angles based on their view angles.
-- premium or unused

    DrawBlades = true,                      -- If set to false, no blades will be drawn.
    HitNumbers = true,                      -- Should we draw hit numbers?
    KillHud = false,                        -- Should we stop the HUD?
    SaberTracing = false,                   -- Should we stop all saber tracing?
    KillSounds = false,                     -- Should we kill the sound engine
    KillViewMods = false,                   -- Should we turn off the view mods.
    KillDamageMod = false,                  -- Should we not determine the damage?
    CinematicCam = false,

    -- Item Spawner
    MaxItems = 10,                          -- How many items we spawn at a time.
    ItemRespawnRate = 5,                    -- How long in minutes before we refresh looted items.
    ItemLootTable = {},                     -- Which items we will be releasing to the world.
-- all 3 unused 

    -- Force Powers
    ForceNext = KEY_G,
    ForcePrev = KEY_F,
    ForceCast = KEY_LALT,
    MaxForcePowers = 10,

    -- // Third Person Settings
    FirstPersonRealism = false,             -- Pitch & Yaw are determined by the playermodel.
    FirstPersonRealismLite = false,         -- Only the yaw is determined by the playermodel.
    FirstPersonRealismSmooth = false        -- Adds smoothing to the above to make less jitter.

}//Dont delete this line