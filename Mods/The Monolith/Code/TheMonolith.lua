-- The Monolith building.
-- When the building exists and a new colonist is born on Mars 
-- he or she will receive a Genius trait, low Sanity, both or nothing.
DefineClass.TheMonolith = {
    __parents = { "Building" },
}

GlobalVar("g_HasTheMonolith", false)

function TheMonolith:Init()
    g_HasTheMonolith = true
end

function TheMonolith:OnDemolish()
    g_HasTheMonolith = false
	return Building.OnDemolish(self)
end

-- Show a notification if researched
-- and unlock Monolith building.
function OnMsg.TechResearched(tech_id,city,first_time)

    if tech_id == "TheMonolith" then
        ShowSimpleMessage(
            "An Artefact in the Sand",
            "<color flavor>Just outside our colony we discovered something very strange.\nAn obsidian-like stone barely protruded from the red Martian sand. The deepest black you can imagine and the surface of the stone seems to be cut unnaturally smooth.\nWe do not know how big the object is, but our curiosity is aroused.</color>\n// Joshua Kell, Principal Scientist",
            "We could dig it up and keep it.",
            "Event_TheMonolith.tga"
        )        
        UnlockBuilding("TheMonolith")
    end
end

-- A notification should be shown for the first Genius and the first insanity buff created by The Monolith.
GlobalVar("g_FirstColonistInsaneGeniusByTheMonolith", true)
GlobalVar("g_FirstColonistGeniusByTheMonolith", true)
GlobalVar("g_FirstColonistInsanityByTheMonolith", true)

-- If a new map was loaded,
-- check if the breakthrough for the Monolith is researched,
-- And Lock or Unlock the building.
function OnMsg.NewMapLoaded()

    if IsTechResearched("TheMonolith") then
        UnlockBuilding("TheMonolith")
    else
        LockBuilding("TheMonolith")
    end
end

-- If a game was loaded,
-- check if the breakthrough for the Monolith is researched
-- and Lock or Unlock the building.
function OnMsg.LoadGame()

    if IsTechResearched("TheMonolith") then
        UnlockBuilding("TheMonolith")
    else    
        LockBuilding("TheMonolith")
    end
end

-- React when a colonist is born on Mars.
-- Add Genius trait, insanity, both or nothing on the colonist.
-- Rng distribution: 0-10 | 0 - Genius | 1 - Insane Genius | 2-3 Insane | other normal.
-- Show a notification if it happens for the first time for the different categories.
function OnMsg.ColonistBorn(colonist)

    -- Check if The Monolith is build
    if not g_HasTheMonolith then
        return
    end

    -- Androids are not affected
	if colonist.traits.Android then
		return
    end
    
    local rng = AsyncRand(10)

    if rng < 1 then -- Genius
    
        if not colonist.traits.Genius then
            colonist:AddTrait("Genius") 
        end

        if g_FirstColonistGeniusByTheMonolith then
            -- Show the 'genius by The Monolith' notification
            ShowSimpleMessage(
                "The Monolith",
                "A Genius was born in our colony.\nHas the Monolith anything to do with it?",
                "The blessing of the Monolith!",
                "Event_TheMonolith.tga"
            )
            -- Mark that the notification has already been shown.
            g_FirstColonistGeniusByTheMonolith = false
        end

    elseif rng < 2 then -- Insane Genius
    
        if not colonist.traits.Genius then
            colonist:AddTrait("Genius") 
        end
        
        colonist.stat_sanity = 10000

        if g_FirstColonistInsaneGeniusByTheMonolith then            
            -- Show the 'insane genius by The Monolith' notification            
            ShowSimpleMessage(
                "The Monolith",
                "An insane Genius was born in our colony.\nHas the Monolith anything to do with it?",
                "The Monolith works in mysterious ways!",
                "Event_TheMonolith.tga"
            )
            -- Mark that the notification has already been shown.
            g_FirstColonistInsaneGeniusByTheMonolith = false
        end

    elseif rng < 4 then -- Insane
    
        colonist.stat_sanity = 10000

        if g_FirstColonistInsanityByTheMonolith then
            -- Show the 'insanity by The Monolith' notification
            ShowSimpleMessage(
                "The Monolith",
                "A colonist was born insane.\nHas the Monolith anything to do with it?",
                "The curse of the Monolith!",
                "Event_TheMonolith.tga"
            )
            -- Mark that the notification has already been shown.
            g_FirstColonistInsanityByTheMonolith = false
        end
    end
end

-- Show Fluff Message
function ShowSimpleMessage(title, message, buttonText, image)

    local imagePath = CurrentModPath.."UI/"..image
    
    --function WaitMarsMessage(parent, caption, text, ok_text, image, context, template)
    CreateRealTimeThread(
        WaitMarsMessage,
        terminal.desktop,
        title,
        message,
        buttonText,
        imagePath
    )
end