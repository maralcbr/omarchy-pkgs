-- Build-time guard for the plugin cache seeded into /etc/skel, run by
-- check_lazy_cache in the PKGBUILD once init.lua has set lazy up.
--   installed: every enabled plugin was cloned.
--   seeded:    lazy can still resolve every plugin's branch and write a
--              lockfile from the slimmed repos, as a fresh user's first
--              :Lazy install or update will.
local Config = require("lazy.core.config")
local Git = require("lazy.manage.git")

local phase = vim.env.OMARCHY_NVIM_CHECK
local plugins = vim.tbl_filter(function(plugin)
  return not plugin._.is_local
end, require("lazy").plugins())
local failures = {}

local function fail(message)
  failures[#failures + 1] = message
end

if phase ~= "installed" and phase ~= "seeded" then
  fail(("unknown check %q"):format(tostring(phase)))
elseif #plugins == 0 then
  fail("lazy has no plugins")
end

for _, plugin in ipairs(plugins) do
  if not plugin._.installed then
    fail(("%s is not installed (%s)"):format(plugin.name, plugin.url))
  elseif phase == "seeded" then
    local ok, branch = pcall(Git.get_branch, plugin)
    if not ok or not branch then
      fail(("lazy cannot resolve the branch of %s"):format(plugin.name))
    end
  end
end

if phase == "seeded" and #failures == 0 then
  -- A scratch lockfile, so the check never rewrites the one that ships.
  local lockfile = vim.fn.tempname()
  Config.options.lockfile = lockfile
  local ok, err = pcall(require("lazy.manage.lock").update)
  if not ok then
    fail("lazy could not write a lockfile: " .. tostring(err))
  else
    local decoded, lock = pcall(vim.json.decode, table.concat(vim.fn.readfile(lockfile), "\n"))
    if not decoded or type(lock) ~= "table" then
      fail("lazy wrote a lockfile that is not valid JSON")
    else
      for _, plugin in ipairs(plugins) do
        local entry = lock[plugin.name]
        if not (entry and entry.branch and entry.commit) then
          fail(("the lockfile has no branch and commit for %s"):format(plugin.name))
        end
      end
    end
  end
end

if #failures > 0 then
  for _, message in ipairs(failures) do
    io.stderr:write("omarchy-nvim: " .. message .. "\n")
  end
  vim.cmd("cquit 1")
end

io.stderr:write(("omarchy-nvim: %d plugins pass the %s check\n"):format(#plugins, phase))
vim.cmd("qall!")
