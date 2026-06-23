local ShouldSetModel = CreateClientConVar("javox_should_set_model", "1", { FCVAR_ARCHIVE })
local SendModelNotification = CreateClientConVar("javox_send_model_notification", "1", { FCVAR_ARCHIVE })

local lastSelectedModel = nil
hook.Add("Think", "ClientModelTracker", function()
    if not ShouldSetModel:GetBool() then return end
    local ply = LocalPlayer()
    if (! IsValid(ply)) then return end

    local model = ply:GetModel()
    if not model then return end
    if model == lastSelectedModel then return end

    -- notify player of the change in preset, if it exists
    local preset = JaVox.Crud:getPlayermodelBindFor(model)
    if preset then
        net.Start("JaVox_ChangePlayerPreset")
        net.WriteString(preset)
        net.SendToServer()

        if SendModelNotification:GetBool() then
            notification.AddLegacy(
                "Preset changed to: " .. preset .. ' because of PM binds! (javox_should_set_model 0 to disable)',
                NOTIFY_GENERIC,
                5)
        end

        lastSelectedModel = model
    end
end)
