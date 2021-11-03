function turnBlue(settings)
 settings.energy="2"
 Global.SetTable("PPacks",settings)
 self.script_state=settings.energy
 self.setColorTint({r=0,g=0,b=255})
end

function turnOn(settings)
 settings.energy="1"
 Global.SetTable("PPacks",settings)
 self.script_state=settings.energy
 self.setColorTint({r=0,g=255,b=0})
end

function turnOff(settings)
 settings.energy="0"
 Global.SetTable("PPacks",settings)
 self.script_state=settings.energy
 self.setColorTint({r=255,g=0,b=0})
end

function onLoad(state)
 self.createButton({
 function_owner=self,
 label='Energy in packs',
 tooltip='Toggle basic Energy in packs. Blue causes the energy to be replaced with a normal card.',
 font_size=500,
 width=4000,
 height=550,
 position={0,0,1},
 click_function='energyBut'})

 local settings=Global.GetTable("PPacks")

 if not settings or not settings.energy then
  if state=="1"then
   turnOn(settings or{})
  elseif state=="2"then
   turnBlue(settings or{})
  else
   turnOff(settings or{})
  end
 else
  if settings.energy=="0"then
   turnOn(settings)
  elseif settings.energy=="1"then
   turnBlue(settings)
  else
   turnOff(settings)
  end
 end
end
 
function energyBut()
 local settings=Global.GetTable("PPacks")
 if settings.energy=="0"then
  turnOn(settings)
 elseif settings.energy=="1"then
  turnBlue(settings)
 else
  turnOff(settings)
 end
end
