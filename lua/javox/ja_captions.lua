if CLIENT then return end
util.AddNetworkString("JaVox_ReceiveCaption")

hook.Add("JaVox_PlaySound", "JaVoxCaptions", function(ply, payload, moduleStr)
    if not IsValid(ply) then return end
    if not payload then
        return
    end

    -- payload.targetSound is a sound
    if JaVox.captions and payload.targetSound then
        local caption = JaVox.captions[payload.targetSound]
        if caption and caption.text then
            net.Start("JaVox_ReceiveCaption")
            net.WriteString(caption.text)
            net.WriteUInt(caption.duration or 5, 16)
            net.Send(ply)
        end
    end
end)
