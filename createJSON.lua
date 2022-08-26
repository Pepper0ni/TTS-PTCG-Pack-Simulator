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
  count=count+1
 end
end

local file=io.open("packs.json","w")

if file then
 local outputJson=json:encode_pretty(jsonTable,nil,{pretty=true,array_newline=true,indent="  "})
 file:write(outputJson)
 io.close(file)
end
