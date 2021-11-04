# TTS-PTCG-Pack-Simulator
A collection of scripts that allow for easy simulation of Pokemon TCG booster packs on Tabletop Simulator, producing cards that can instantly be used with games.

How to add to your game:

To create the box, which is the hub for the pack simulator, create a custom model that is an infinite bag (the model's appearance is unimportant, the script will overwrite it anyway), copy APIbox.lua into the scripting window, and refreash the object by either using "Save and play" or cuting and pasting the object to load the scripts. Press next set and the box will transfigure into the correct shape, however to work properly you need to add the base pack.

To create the base pack, make a custom model with "http://pastebin.com/raw/PqfGKtKR" as the mesh and ""http://cloud-3.steamusercontent.com/ugc/861734852198391028/D75480247FA058266F0D423501D867407458666D/" as the normal, and make it a bag. Place a random default TTS object in the pack (NOT A CARD FROM THE MOD), then copy APIpack.lua into the scripting window. Place the base pack into the box. Now when you pull packs from the box the script should transform them into packs of the displayed box.
