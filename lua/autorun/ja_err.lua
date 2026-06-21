--- Module for JaVOX errors.

if ! JaVox then return end;

--- Print out msg and return the errorPayload.
---@param msg? string
---@param errorPayload? JaVoxError
---@return JaVoxError?
function JaVox:errorWithMessage(msg, errorPayload)
    print(string.format("[JaVox at %s]: Error: %s", tostring(os.time()), msg))

    return errorPayload or {
        ["errorId"] = "JAVOX_ERROR",
        ["errorMessage"] = msg
    }
end

---Returns a boolean if an object is a JaVoxError.
---@param object any
---@return boolean
function JaVox:isError(object)
    return object.errorId and object.errorMessage
end
