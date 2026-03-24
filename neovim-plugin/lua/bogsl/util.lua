local M = {}

---Escape a string as a Rascal `jar+file` location
---@param str string
function M.to_rascal_jar_loc(str)
  local escaped = str
    :gsub(" ", "%%20")
    :gsub("|", "%%7C")
    :gsub([[\]], "%%5C")
  return "|jar+file://" .. escaped .. "!|"
end

return M
