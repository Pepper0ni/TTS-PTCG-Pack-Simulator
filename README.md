# TTS-PTCG-Pack-Simulator
A collection of scripts that allow for easy simulation of Pokemon TCG booster packs on Tabletop Simulator, producing cards that can instantly be used with games with the help of the [Pokemon TCG API](https://pokemontcg.io/).

## How to add to your game:

To create the box, which is the hub for the pack simulator, create a custom model that is an infinite bag with the cardboard's material(the model's appearance is unimportant, the script will overwrite it anyway, but one must be provided for it to be able to exist), copy APIbox.lua into the scripting window, and refreash the object by either using "Save and play" or cuting and pasting the object. Press next set and the box will transfigure into the correct shape, however to work properly you need to add the base pack.

To create the base pack, make a custom model with "http://pastebin.com/raw/PqfGKtKR" as the mesh and ""http://cloud-3.steamusercontent.com/ugc/861734852198391028/D75480247FA058266F0D423501D867407458666D/" as the normal, and make it a bag. Place a random default TTS object in the pack (*not another card from the mod*, this causes loading issues with the card back), then copy APIpack.lua into the scripting window. Place the base pack into the box. Now when you pull packs from the box the script should transform them into packs of the displayed box.

## How to use:

Once you have your box, you can use it by navigating to the pack you wish using the "<" and ">" buttons, left click moving 1 pack and right click jumping to the next gen, and then pull out packs by simply removing them from the box. you can draw packs en masse by using the number keys on the box (like multi-drawing from a deck). Alternativly you can get the entire set by clicking the "Get Whole Set" button. 

Once you have your packs you can open them by simply click-dragging on top of them, as you would remove an object from a bag. In order to move packs without opening them you must hold before dragging, just like with a bag. 

By default the packs will not spread, and will contain energy as normal. If you want to configure these otherwise you can do so in the right-click menu of the main box. These settings will be saved between games or if you carry the box around. Note that it is not reccomended to have multiple boxes in the game room, as they may get confused about the current settings. The only option not in the right click menu is the "API calls per pack" option. As these packs need to fetch data from an API to function, the first use of them in a set has a loading time while the mod fetches and caches the data. Increasing the number of parallel API calls speeds up this loading, especially for larger sets, but runs the risk of getting ratelimited if you load a number of new sets in quick succession.

### Credits:
- dzikakulka and Larikk for helping with the code to decode the json properly.
- dzikakulka again for helping me solve RNG seeding issues.
- The rest of the TTS discord #scripting room for random answers and help.
