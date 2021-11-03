function setColour(setting)
 self.setColorTint({r=0.1*setting,g=1-0.1*setting,b=0})
end

function onLoad(state)
 local settings=Global.GetTable("PPacks")
 if not settings or not settings.APICalls then
  if state=="" then state="3"end
  if not settings then settings={}end
  settings.APICalls=state
  Global.SetTable("PPacks",settings)
 end
 setColour(tonumber(settings.APICalls))
 applyButtons(settings)
end

function applyButtons(settings)
 params={
 function_owner=self,
 tooltip='Toggle the number of simultainious API calls used when fetching sets. More connections will use up API rate limit (30 per minute) faster but may speed up initial pack/set loading',
 font_size=500,
 width=6500,
 height=550,
 position={0,0,1},
 click_function='dummyFunc',
 label="Num of API calls per fetch: "..settings.APICalls
}

 self.createButton(params)

 params.label="+"
 params.width=550
 params.position[1]=7
 params.click_function='incAPI'
 self.createButton(params)
 
 params.label="-"
 params.position[1]=-7
 params.click_function='decAPI'
 self.createButton(params)
end

function incAPI(obj,color,alt)
 local settings=Global.GetTable("PPacks")
 if settings.APICalls=="10" then
  broadcastToColor("API rate maxed",color,{1,0,0})
  return
 else
  settings.APICalls=tostring(tonumber(settings.APICalls)+1)
 end
 Global.SetTable("PPacks",settings)
 setColour(tonumber(settings.APICalls))
 self.script_state=settings.APICalls
 self.clearButtons()
 applyButtons(settings)
end

function decAPI(obj,color,alt)
 local settings=Global.GetTable("PPacks")
 if settings.APICalls=="2" then
  broadcastToColor("API rate at minimum",color,{1,0,0})
  return
 else
  settings.APICalls=tostring(tonumber(settings.APICalls)-1)
 end
 Global.SetTable("PPacks",settings)
 setColour(tonumber(settings.APICalls))
 self.script_state=settings.APICalls
 self.clearButtons()
 applyButtons(settings)
end

function dummyFunc()
end
