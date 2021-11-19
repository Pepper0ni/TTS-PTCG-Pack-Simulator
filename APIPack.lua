curCard=0

function tryObjectEnter(enter_object)
 if Global.GetTable("PPacks").on==false then return true end
 return false
end

function onObjectLeaveContainer(cont,leaving)
 settings=Global.GetTable("PPacks")or{energy=1,on=true,spread=false,APICalls=3}
 if cont~=self or settings.on==false then return end

 if not settings then
  Global.SetTable("PPacks",settings)
 end

 if not settings.rand then
  local globalMath=Global.getVar("math")
  Global.setVar("PPacks.rand",globalMath.random)
 end

 packPos=self.getPosition()
 cardRot=self.getRotation()
 local secondCard=self.positionToWorld({x=2.25,y=0,z=0})
 cardMov={x=packPos.x-secondCard.x,y=packPos.y-secondCard.y,z=packPos.z-secondCard.z}
 secondCard=self.positionToWorld({x=0,y=0.1,z=0})
 cardSpawn={x=packPos.x-secondCard.x,y=packPos.y-secondCard.y,z=packPos.z-secondCard.z}
 if settings.spread then cardRot.z=0 else cardRot.z=cardRot.z+180 end

 ProcessPack(false,false)

 leaving.destruct()
 self.destruct()
end

function ProcessPack(loop,loading)
 setCache=Global.getTable("PPacksCache["..setName.."]")
 if not setCache or not setCache.cache then
  if setCache and setCache.loading and setCache.loading!=0 then
   if not loading then broadcastToAll("Loading Cards...",{0,1,0})end
   Wait.frames(ProcessPack(loop,true),10)
   return
  end
  if loop then
   broadcastToAll("Pack loop detected",{1,0,0})
   return
  end
  r={}
  decoded={}
  local orderText=""
  if setUnordered then orderText='&orderBy=number'end
  local callPerSet=settings.APICalls
  if subSetName then
   callPerSet=math.ceil(settings.APICalls/2)
   Global.setTable("PPacksCache["..setName.."]",{loading=callPerSet*2,cache=nil})
  else
   Global.setTable("PPacksCache["..setName.."]",{loading=callPerSet,cache=nil})
  end
  broadcastToAll("Loading Cards...",{0,1,0})
  local count=requestSet(1,callPerSet,setName,setSize,orderText)
  if subSetName then count=requestSet(count,callPerSet,subSetName,subSetSize,orderText) end
  return
 end

 for _,rate in pairs(pullRate)do
  for c=1,rate.num do
   doPullRates(rate)
  end
 end

 for _,slot in pairs(dropSlots)do
  if slot.fixed then doFixed(slot)
  elseif not slot.energy or settings.energy==1 then chooseCard(slot)end
 end
 if pulls then pulls.use_hands=true end
end

function requestSet(count,calls,setToLoad,size,orderText)
 for c=1,calls do
  local page=count
  r[count]=WebRequest.get('https://api.pokemontcg.io/v2/cards?q=!set.name:"'..string.gsub(setToLoad,"&","%%26")..'"&page='..tostring(c)..'&pageSize='..tostring(math.ceil(size/calls))..orderText, function() cacheSet(r[page],page)end)
  count=count+1
 end
 return count
end

function cacheSet(request,page)
 local cache=Global.GetTable("PPacksCache["..setName.."]")
 if request.is_error or request.response_code>=400 then
  log(request.error)
  log(request.text)
  broadcastToAll("Error: "..tostring(request.response_code),{1,0,0})
  Global.setTable("PPacksCache["..setName.."]",{loading=0,cache=nil})
 else
  decoded[page]=json.parse(string.gsub(request.text,"\\u0026","&"))
--credit to dzikakulka and Larikk
--use the below line in the parse if this line of code ever breaks
--string.gsub(request.text,[[\u([0-9a-fA-F]+)]],function(s)return([[\u{%s}]]):format(s)end)
  if cache.loading==1 then
   local count=1
   for _,jsons in ipairs(decoded)do
    for _,cardData in ipairs(jsons.data)do
     local card=spawnObject({type="CardCustom",position={x=packPos.x,y=packPos.y+(0.01*count),z=packPos.z}})
     card.setCustomObject({face=cardData.images.large.."?count="..tostring(count),back="http://cloud-3.steamusercontent.com/ugc/809997459557414686/9ABD9158841F1167D295FD1295D7A597E03A7487/"})
     card.setName(cardData.name)
     card.setDescription(setName.." #"..cardData.number)
     card.setGMNotes(enumTypes(cardData.supertype,cardData.subtypes)..convertNatDex(cardData.nationalPokedexNumbers)or"")
     card.memo=string.gsub(cardData.set.releaseDate,"/","")..string.gsub(cardData.number,"[^%d]","")
     setDeck=addToDeck(card,setDeck)
     count=count+1
    end
   end
  Global.setTable("PPacksCache["..setName.."]",{loading=0,cache=setDeck.getData()})
  setDeck.destruct()
  ProcessPack(true,false)
  else
  Global.SetTable("PPacksCache["..setName.."]",{loading=cache.loading-1,cache=nil})
  end
 end
end

function convertNatDex(dexNums)
 if dexNums then dexNum=dexNums[1]else return "00000" end
 if natDexReplace[dexNum] then return natDexReplace[dexNum] end
 dexNum = tostring(dexNum*10)
 while #dexNum<5 do dexNum="0"..dexNum end
 return dexNum
end

function enumTypes(Type,subTypes)
 local enum=TypeNums[Type] or 0
 if subTypes then
  for _,subType in pairs(subTypes)do
   enum=enum+(TypeNums[subType] or 0)
  end
 end
 return tostring(enum)
end

function doPullRates(rate)
 local rand=Global.call("PPacks.rand")
 for _,slot in pairs(rate.rates)do
  rand=rand-(slot.odds or 1)
  if rand<=0 and (settings.energy!=2 or not dropSlots[slot.slot].energy) then
   dropSlots[slot.slot].num=dropSlots[slot.slot].num+1
   return
  end
 end
end

function chooseCard(slot)
 local chosen={}
 local c=1
 while c<=slot.num do
  local choice=nil
  if slot.size then
   choice=chooseRandCard(slot)
  else
   choice=slot.cards[randomFromRange(1,#slot.cards)]
  end
  if not chosen[choice] then
   chosen[choice]=true
   c=c+1
   spawnCard(choice)
  end
 end
end

function chooseRandCard(slot)
 local rand=randomFromRange(0,slot.size-1)
 for _,cards in pairs(slot.cards) do
  if type(cards)=="table"then
   local size=cards[2]-cards[1]+1
   if rand>=size then rand=rand-size else return cards[1]+rand end
  else
   if rand==0 then return cards else rand=rand-1 end
  end
 end
end

function doFixed(slot)
 local deckPos=randomFromRange(1,#slot.cards)
 for c=1,slot.num do
  spawnCard(slot.cards[deckPos])
  if deckPos==#slot.cards then deckPos=1 else deckPos=deckPos+1 end
 end
end

function randomFromRange(low,high)--Credit dzikakulka
 local rand=Global.call("PPacks.rand")
 local scale=high-low+1
 return math.floor(low+rand*scale)
end

function spawnCard(index)
 local card=spawnObjectData({data=setCache.cache.ContainedObjects[index],position={x=packPos.x+(cardSpawn.x*curCard),y=packPos.y+(cardSpawn.y*curCard),z=packPos.z+(cardSpawn.z*curCard)},rotation=cardRot})

 if settings.spread then
  card.setPositionSmooth({x=packPos.x+(cardMov.x*curCard),y=packPos.y+(cardMov.y*curCard),z=packPos.z+(cardMov.z*curCard)},false,false)
 else
  pulls=addToDeck(card,pulls)
 end
 curCard=curCard+1
end

function addToDeck(card,deck)
 if deck==nil then
  deck=card
 elseif deck.type=="Card"then
  deck=deck.putObject(card)
 else
  deck=deck.putObject(card)
  card.destruct()
 end
 return deck
end

TypeNums={
 ["Trainer"]=3,
 ["Energy"]=7,
 ["Supporter"]=1,
 ["Stadium"]=2,
 ["Pokémon Tool"]=3,
 ["Special"]=1,
 ["Level-Up"]=1,
}
natDexReplace={
 [172]="00245",
 [173]="00345",
 [174]="00385",
 [169]="00425",
 [182]="00455",
 [863]="00535",
 [186]="00625",
 [199]="00805",
 [462]="00823",
 [865]="00827",
 [208]="00955",
 [236]="01055",
 [237]="01075",
 [463]="01085",
 [464]="01123",
 [440]="01127",
 [242]="01135",
 [465]="01145",
 [230]="01175",
 [439]="01215",
 [866]="01225",
 [212]="01233",
 [238]="01237",
 [239]="01245",
 [466]="01253",
 [240]="01257",
 [467]="01265",
 [196]="01361",
 [197]="01362",
 [470]="01363",
 [471]="01364",
 [700]="01365",
 [233]="01373",
 [474]="01377",
 [446]="01425",
 [468]="01765",
 [298]="01825",
 [438]="01845",
 [424]="01905",
 [469]="01935",
 [430]="01985",
 [429]="02005",
 [360]="02015",
 [472]="02075",
 [461]="02155",
 [473]="02215",
 [864]="02225",
 [458]="02255",
 [862]="02645",
 [475]="02825",
 [476]="02995",
 [406]="03145",
 [407]="03155",
 [477]="03565",
 [433]="03575",
 [478]="03625",
 [867]="05635",
}
