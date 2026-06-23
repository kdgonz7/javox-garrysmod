if SERVER then
    resource.AddFile("resource/fonts/sharetech.ttf")
    return
end

surface.CreateFont("ShareTech", {
    font = "Share Tech Mono",
    size = 24,
    weight = 400
})
surface.CreateFont("ShareTechSmaller", {
    font = "Share Tech Mono",
    size = 16,
    weight = 400
})
