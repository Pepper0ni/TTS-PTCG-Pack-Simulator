function turnOn(settings)
 settings.spread="1"
 Global.SetTable("PPacks",settings)
 self.setColorTint({r=0,g=255,b=0})
end

function turnOff(settings)
 settings.spread="0"
 Global.SetTable("PPacks",settings)
 self.setColorTint({r=255,g=0,b=0})
end

function onLoad(state)
 self.createButton({
 function_owner=self,
 label='Auto-Spread cards',
 tooltip='Automatically spread Cards when opening packs.',
 font_size=500,
 width=4000,
 height=550,
 position={0,0,1},
 click_function='spreadBut'})

 local settings=Global.GetTable("PPacks")

 if not settings or not settings.spread then
  if state=="1"then
   turnOn(settings or{})
  else
   turnOff(settings or{})
  end
 else
  if settings.spread=="1" then turnOn(settings)else function turnOff(settings)end
  end
 end
end

function onSave()
 return Global.GetVar("PPacks.spread")
end
 
function spreadBut()
 local settings=Global.GetTable("PPacks")
 if settings.spread=="1" then
  turnOff(settings)
 else
  turnOn(settings)
 end
end
