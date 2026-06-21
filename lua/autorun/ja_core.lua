--- @class JaVoxCore
JaVox = {
	vox = {},
	binds = {},
	modules = {},
} -- pure, nude javox.            lol

--- Registers a module with a given payload into the global JaVox object. Note to future developers, or myself:
--- These **have** to be questionable because lua is unsafe and gmod developers just wanna have fun.
--- @param rawName string?
--- @param payload PlayerVoxModule?
--- @return nil|JaVoxError
function JaVox:registerModule(rawName, payload)
	if ! rawName then
		return JaVox:errorWithMessage(
			"Parameter `rawName` required to register pvox module. If not given, we have no identifier.")
	end;
	if ! payload then
		return JaVox:errorWithMessage(string.format(
			"Parameter `payload` required to register module '%s'.", rawName))
	end;

	-- ight. we assume everything is available.
	-- btw. this shit took way longer to figure out than i wanted.
	return JaVox.Crud:setActionModule(rawName, payload)
end

---Registers a lua module. Just a meta way to know if something is running that modifies/uses JaVox. This is optional.
---@param mod JavoLuaModule
function JaVox:registerLuaModule(mod)
	if ! mod then return JaVox:errorWithMessage("register lua module requires payload.") end
	JaVox.modules[mod.name] = mod
end
