-- If a colonist is born
-- the player can set the name
function OnMsg.ColonistBorn(colonist)
    
    if not GameState.gameplay then return end

    local initialName = _InternalTranslate(colonist.name)
    local title = ""

    if colonist.traits.Android then
        title = "Name Your Android"
    elseif colonist.traits.Clone then
        title = "Name Your Clone"
    else
        title = "Name Your Newborn Colonist"
    end

    CreateMarsRenameControl(
        terminal.desktop, 
        title,
        initialName, 
        --OK callback
        function(newName)
            colonist.name = newName
        end, 
        --Cancel callback
        function()
            return false
        end,
        {max_len = 250, console_show = true}
    )
end