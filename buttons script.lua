function onLoad(state)
  local params = {  
  function_owner = self
  label = 'Auto-Spread cards'
  tooltip = 'Auto-Spread cards'
  font_size = 500
  color = {1, 0, 0}
  font_color = {1, 1, 1}
  width = 4000
  height = 550
  position = {0, 0, -1}
  rotation = {0, 180, 0}
  click_function = 'click_spreadswitch'
  }

  self.createButton(params)
  
  if Global.GetVar("pepperPacksAutoSpread") == nil then
    if state == "1" then
      Global.SetVar("pepperPacksAutoSpread", true)
      self.setColorTint({r = 0,g = 255,b = 0})
    else
      Global.SetVar("pepperPacksAutoSpread", false)
      self.setColorTint({r = 255,g = 0,b = 0})
    end
  else
    if Global.GetVar("pepperPacksAutoSpread") then
      self.setColorTint({r = 0,g = 255,b = 0})
    else
      self.setColorTint({r = 255,g = 0,b = 0})
    end
  end
end

function onSave()
  if Global.GetVar("pepperPacksAutoSpread") then
    return("1")
  else
    return("0")
  end
end
  
function click_spreadswitch()
  if Global.GetVar("pepperPacksAutoSpread") then
    Global.SetVar("pepperPacksAutoSpread", false)
    self.setColorTint({r = 255,g = 0,b = 0})
  else
    Global.SetVar("pepperPacksAutoSpread", true)
    self.setColorTint({r = 0,g = 255,b = 0})
  end
end
