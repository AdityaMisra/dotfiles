-- Hyper key binding helper.
-- Pair this with Karabiner-Elements remapping caps_lock -> F18 (or to all
-- four modifiers). When Karabiner emits ctrl+option+cmd+shift, we treat it
-- as a single "hyper" modifier here.

local M = {}

M.mods = {"ctrl", "alt", "cmd", "shift"}

function M.bind(key, fn)
  hs.hotkey.bind(M.mods, key, fn)
end

_G.hyper = M
return M
