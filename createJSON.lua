local box=require "APIBox"
local json=require 'JSON'

local jsonTable={}
local count=1

function getCardNumbers(cardsStruct)
 local cardTable={}
 for c=1,#cardsStruct do
  if type(cardsStruct[c])=="table"then
   for d=cardsStruct[c][1],cardsStruct[c][2]do cardTable[#cardTable+1]=d-1 end
  else
   cardTable[#cardTable+1]=cardsStruct[c]-1
  end
 end
 return cardTable
end

for c=1,#setData do
 local packData=setData[c].packData
 if packData then
  jsonTable[count]={
   name=setData[c].setName,
   id=setData[c].setID,
   size=setData[c].size,
   dropSlots={},
   pullRates={},
   sets={
    {
     setName=setData[c].setName,
     setId=setData[c].setID,
     setSize=setData[c].size
    }
   }
  }
  if setData[c].SMEnergy then jsonTable[count].energy="SM1"end
  if setData[c].BSEnergy then jsonTable[count].energy="SWSH2"end
  if setData[c].SVEnergy then jsonTable[count].energy="SVE"end
  if setData[c].VStar then jsonTable[count].VStar=true end
  if setData[c].subSet then
   jsonTable[count].sets[2]={
    setId=setData[c]["subSet"].setID,
    setSize=setData[c]["subSet"].size
   }
  end
  local dropSlots=load("return "..packData.dropSlots)()
  for d=1,#dropSlots do
   jsonTable[count]["dropSlots"][d]={
    cards=getCardNumbers(dropSlots[d].cards),
    number=dropSlots[d].num
   }
   if dropSlots[d].fixed then jsonTable[count]["dropSlots"][d].fixed=true end
  end
  local pullRates=load("return "..packData.pullRates)()
  for d=1,#pullRates do
   jsonTable[count]["pullRates"][d]={rates={},num=pullRates[d].num}
   if pullRates[d].noGod then jsonTable[count]["pullRates"][d].noGod=pullRates[d].noGod end
   for e=1,#pullRates[d].rates do
    local rates=pullRates[d]["rates"][e]
    jsonTable[count]["pullRates"][d]["rates"][e]={
     slot=rates.slot-1,
     remaining=rates.remaining,
     flag=rates.flag,
     flagExclude=rates.flagExclude
    }
    if rates.odds then jsonTable[count]["pullRates"][d]["rates"][e].odds=rates.odds end
   end
  end
  if packData.boxPulls then
   jsonTable[count]["boxPulls"]={}
   local boxPulls=load("return "..packData.boxPulls)()
   for d=1,#boxPulls do
    local rOther=boxPulls[d].other
    if type(boxPulls[d].other)=="table" then
     for f=1,#rOther do
      rOther[f]=rOther[f]-1
     end
    else
     rOther=boxPulls[d].other-1
    end
    jsonTable[count]["boxPulls"][d]={
     other=rOther,
     otherRat=boxPulls[d].otherRat
    }
    if boxPulls[d].rates then
    jsonTable[count]["boxPulls"][d].rates={}
     for e=1,#boxPulls[d].rates do
      local rates=boxPulls[d]["rates"][e]
      local rSlot=rates.slot
      if type(rates.slot)=="table" then
       for f=1,#rSlot do
        rSlot[f]=rSlot[f]-1
       end
      else
       rSlot=rates.slot-1
      end
      entry={
       slot=rSlot,
       chances={}
      }
      for f=1,#rates.chances do
       entry["chances"][f]=rates.chances[f]
      end
      jsonTable[count]["boxPulls"][d]["rates"][e]=entry
     end
    end
   end
  end
  if setData[c].godChance then jsonTable[count].godChance=setData[c].godChance end
  if setData[c].godSlot then jsonTable[count].godSlot=setData[c].godSlot end
  if setData[c].godPacks then jsonTable[count].godPacks=setData[c].godPacks end
  end
  count=count+1
 end
end

local file=io.open("packs.json","w")

if file then
 local outputJson=json:encode_pretty(jsonTable,nil,{pretty=true,array_newline=true,indent="  "})
 file:write(outputJson)
 io.close(file)
end
