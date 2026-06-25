concommand.Add("javox_print_module", function(ply, cmd, args, argStr)
    if not args[1] then
        print("No module specified.")
        return
    end

    local module = JaVox.Crud:getActionModule(args[1])
    if module then
        PrintTable(module)
    else
        print("No current module.")
    end
end)
