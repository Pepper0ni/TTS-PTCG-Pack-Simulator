function tryObjectEnter(enter_object)
 if Global.GetTable("PPacks").on==false then return true end
 return false
end

function onObjectLeaveContainer(cont,leaving)
 settings=Global.GetTable("PPacks")or{energy=1,on=true,spread=false,APICalls=3,hundred=false,debug=false}
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
 ProcessPack(false,false)
 leaving.destruct()
 self.destruct()
end

function ProcessPack(loop,loading)
 local setCache=Global.getTable("PPacksCache["..setName.."]")
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
  local orderText="&orderBy=number"
  if setUnordered then orderText=''end
  local callPerSet=settings.APICalls
  local loadingNum=callPerSet
  if subSetID then
   callPerSet=math.ceil(settings.APICalls/2)
   loadingNum=callPerSet*2
  end
  if SMEnergy then loadingNum=loadingNum+1 end
  Global.setTable("PPacksCache["..setName.."]",{loading=loadingNum,cache=nil})
  broadcastToAll("Loading Cards...",{0,1,0})
  local count=requestSet(1,callPerSet,setID,setSize,orderText)
  if subSetID then count=requestSet(count,callPerSet,subSetID,subSetSize,orderText) end
  if SMEnergy then requestSMEnergy(count) end
  return
 end
 for a=1,100 do
  local setData=setCache.cache.ContainedObjects
  curCard=1
  packFlag=false
  local slotsAdded={}
  for b=1,#pullRates do
   for c=1,pullRates[b].num do
    slotsAdded=doPullRates(pullRates[b].rates,slotsAdded)
   end
  end
  local packData=getDeckData(packPos,cardRot)
  for b=1,#dropSlots do
   local choices=chooseCards(dropSlots[b],slotsAdded[b]or 0)
   for c=1,#choices do
    local CardID=setData[choices[c]].CardID
    packData.DeckIDs[curCard]=CardID
    packData.CustomDeck[CardID*0.01]=setData[choices[c]].CustomDeck[CardID*0.01]
    packData.ContainedObjects[curCard]=setData[choices[c]]
    curCard=curCard+1
   end
  end
  local deck=spawnObjectData({data=packData})
  if settings.spread then deck.spread(2.25) end
  if not settings.hundred then return end
  packPos[2]=packPos[2]+2
 end
end

function requestSet(count,calls,setIDToLoad,size,orderText)
 for c=1,calls do
  local page=count
  r[count]=WebRequest.get('https://api.pokemontcg.io/v2/cards?q=!set.id:"'..setIDToLoad..'"&page='..tostring(c)..'&pageSize='..tostring(math.ceil(size/calls))..orderText, function() cacheSet(r[page],page)end)
  count=count+1
 end
 return count
end

function requestSMEnergy(count)
 local page=count
 r[count]=WebRequest.get("https://api.pokemontcg.io/v2/cards?q=number:%5B164%20TO%20172%5D%20!set.id:sm1&order_by=number", function() cacheSet(r[page],page)end)
 count=count+1
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
   local spawnPos={packPos[1],packPos[2],packPos[3]+5}
   local curCard=1
   local deckData=getDeckData(spawnPos,cardRot)
   for a=1,#decoded do
    local cardData=decoded[a].data
    for b=1,#cardData do
     local DeckID=999+curCard
     local customData={
       FaceURL=cardData[b].images.large.."?count="..tostring(curCard),
       BackURL="http://cloud-3.steamusercontent.com/ugc/809997459557414686/9ABD9158841F1167D295FD1295D7A597E03A7487/",
       NumWidth=1,
       NumHeight=1,
      }
     deckData.DeckIDs[curCard]=DeckID*100
     deckData.CustomDeck[DeckID]=customData
     deckData.ContainedObjects[curCard]={
      Name="CardCustom",
      Nickname=cardData[b].name,
      Description=cardData[b].set.name.." #"..cardData[b].number,
      GMNotes=enumTypes(cardData[b].supertype,cardData[b].subtypes)..convertNatDex(cardData[b].nationalPokedexNumbers)or"",
      Memo=string.gsub(cardData[b].set.releaseDate,"/","")..string.gsub(cardData[b].number,"[^%d]",""),
      CardID=DeckID*100,
      CustomDeck={[DeckID]=customData}
     }
     curCard=curCard+1
    end
   end
   Global.setTable("PPacksCache["..setName.."]",{loading=nil,cache=deckData})
   ProcessPack(true,false)
  else
  Global.SetTable("PPacksCache["..setName.."]",{loading=cache.loading-1,cache=nil})
  end
 end
end

function getDeckData(spawnPos,cardRot)
 return {Name="Deck",
  Transform={posX=spawnPos[1],posY=spawnPos[2],posZ=spawnPos[3],rotX=cardRot[1],rotY=cardRot[2],rotZ=cardRot[3],scaleX=1,scaleY=1,scaleZ=1},
  DeckIDs={},
  CustomDeck={},
  ContainedObjects={}
 }
end

function convertNatDex(dexNums)
 if dexNums then dexNum=dexNums[1]else return "00000" end
 if natDexReplace[dexNum]then return natDexReplace[dexNum]end
 dexNum = tostring(dexNum*10)
 while #dexNum<5 do dexNum="0"..dexNum end
 return dexNum
end

function enumTypes(Type,subTypes)
 local enum=TypeNums[Type]or 0
 if subTypes then
  for c=1,#subTypes do
   enum=enum+(TypeNums[subTypes[c]]or 0)
  end
 end
 return tostring(enum)
end

function doPullRates(rates,slotsAdded)
 local rand=Global.call("PPacks.rand")
 local initrand=rand
 for c=1,#rates do
  if(not packFlag or not rates[c].flagExclude) then
   if rates[c].remaining then rand=initrand-(rates[c].odds or 1) else rand=rand-(rates[c].odds or 1) end
   if rand<=0 and(settings.energy!=2 or not dropSlots[rates[c].slot].energy)then
    if not slotsAdded[rates[c].slot]then slotsAdded[rates[c].slot]=0 end
    slotsAdded[rates[c].slot]=slotsAdded[rates[c].slot]+1
    if rates[c].flag then packFlag=true end
    return slotsAdded
   end
  end
 end
 return slotsAdded
end

function chooseCards(slot,added)
 local chosen={}
 local choices={}
 if not slot.energy or settings.energy==1 then
  if slot.fixed then
   local deckPos=randomFromRange(1,#slot.cards)
   for c=1,slot.num+added do
    choices[c]=slot.cards[deckPos]
    if deckPos==#slot.cards then deckPos=1 else deckPos=deckPos+1 end
   end
  else
   while #choices<slot.num+added do
    local choice=nil
    if slot.size then
     choice=chooseRandCard(slot.cards,slot.size)
    else
     choice=slot.cards[randomFromRange(1,#slot.cards)]
    end
    if not chosen[choice]then
     chosen[choice]=true
     choices[#choices+1]=choice
    end
   end
  end
 end
 return choices
end

function chooseRandCard(cards,size)
 local rand=randomFromRange(0,size-1)
 for c=1,#cards do
  if type(cards[c])=="table"then
   local size=cards[c][2]-cards[c][1]+1
   if rand>=size then rand=rand-size else return cards[c][1]+rand end
  else
   if rand==0 then return cards[c]else rand=rand-1 end
  end
 end
end

function randomFromRange(low,high)--Credit dzikakulka
 local rand=Global.call("PPacks.rand")
 local scale=high-low+1
 return math.floor(low+rand*scale)
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
