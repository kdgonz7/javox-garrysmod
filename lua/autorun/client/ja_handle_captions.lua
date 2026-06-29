net.Receive("JaVox_ReceiveCaption", function()
    local strToShow = net.ReadString()
    local duration = net.ReadUInt(16)
    if not strToShow or not duration then return end

    gui.AddCaption(strToShow, duration, true)
end)
