function turnOn(settings)
 settings.on="1"
 Global.SetTable("PPacks",settings)
 self.script_state=settings.on
 self.setColorTint({r=0,g=255,b=0})
end

function turnOff(settings)
 settings.on="0"
 Global.SetTable("PPacks",settings)
 self.script_state=settings.on
 self.setColorTint({r=255,g=0,b=0})
end

function onLoad(state)
 self.createButton({
 function_owner=self,
 label='Pack Scripts',
 tooltip="If off, Packs won't open.",
 font_size=500,
 width=3000,
 height=550,
 position={0,0,1},
 click_function='offBut'})

 local settings=Global.GetTable("PPacks")

 if not settings or not settings.on then
  if state=="1"then
   turnOn(settings or{})
  else
   turnOff(settings or{})
  end
 else
  if settings.on=="1" then turnOn(settings)else function turnOff(settings)end
  end
 end
end

function onSave()
 return Global.GetVar("PPacks.on")
end

function offBut()
 local settings=Global.GetTable("PPacks")
 if settings.on=="1" then
  turnOff(settings)
 else
  turnOn(settings)
 end
end
