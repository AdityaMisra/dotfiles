-- Window tiling: halves, quarters, full, center.
local hyper = require("modules.hyper")

local function move(x, y, w, h)
  return function()
    local win = hs.window.focusedWindow()
    if not win then return end
    local f = win:screen():frame()
    win:setFrame({
      x = f.x + f.w * x,
      y = f.y + f.h * y,
      w = f.w * w,
      h = f.h * h,
    })
  end
end

-- Halves
hyper.bind("h", move(0,    0,    0.5,  1))    -- left half
hyper.bind("l", move(0.5,  0,    0.5,  1))    -- right half
hyper.bind("k", move(0,    0,    1,    0.5))  -- top half
hyper.bind("j", move(0,    0.5,  1,    0.5))  -- bottom half

-- Quarters
hyper.bind("u", move(0,    0,    0.5,  0.5))  -- top-left
hyper.bind("i", move(0.5,  0,    0.5,  0.5))  -- top-right
hyper.bind("n", move(0,    0.5,  0.5,  0.5))  -- bottom-left
hyper.bind("m", move(0.5,  0.5,  0.5,  0.5))  -- bottom-right

-- Full + center
hyper.bind("f", move(0,    0,    1,    1))             -- maximize
hyper.bind("c", move(0.10, 0.10, 0.80, 0.80))          -- centered 80%

-- Move focus to next/previous screen
hyper.bind("right", function()
  local win = hs.window.focusedWindow()
  if win then win:moveToScreen(win:screen():next()) end
end)
hyper.bind("left", function()
  local win = hs.window.focusedWindow()
  if win then win:moveToScreen(win:screen():previous()) end
end)
