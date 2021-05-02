# QuickSilver
QuickSilver - Automated cfg generateration for Textures Unlimited (KSP)

Prerequisites:
--------------
This mod enables the shine, but for it to work you will need to have Textures Unlimited installed.

ModuleManager ties the two together and is also needed.

Installation:
-------------
Make sure the QuickSilver folder goes inside ..\GameData\ just like any mod.

NOTE: The QuickSilver exe will only launch from within the ..\GameData\QuickSilver\ folder. 
      Please manually make a shortcut to the exe as needed.

Useage:
-------
Launch, click scan, wait a moment for the list to populate, deselect any mods you don't want included, hit generate, and you're done.

A cfg will be created in the same folder, which ModuleManager will pick up, so all you need to do is launch the game. Assuming Textures Unlimited is installed correctly, and no other cfg for that is interfering, your parts should be nice and shiny.

Description:
-----------

QuickSilver v1.1 - A .cfg builder for Textures Unlimited.

QuickSilver will search your GameData, look for mods with parts, filter them against a list of blacklisted parts (e.g. wheels, windows), then present you with a list of potentially compatible mods, and allow you to select which mods to allow the 'shine' for.

Any mods deselected from the list will be blacklisted, and ignored in the cfg building process, further, these selections will be written into the companion 'Setting.ini' file so they will be recalled upon next launch.

While quicksilver allows you disable all parts for a mod at once from the checklist, it also allows for custom blacklisting of individual parts by (manually) adding them to the relevant section of the settings file. This way you can ignore a troublesome part while keeping the rest of that mods parts shiny. *

Quicksilver also draws its header and footer strings for the final cfg from the settings.ini, so, those with custom configs should be able to edit those sections and have them be included in the final cfg. *

While still far from a perfect solution, QuickSilver should make it easy to toggle the beautiful metal shader for your mods as needed, and tries to mitigate its catch-all nature via the editable settings file.

QuickSilver is free and open source, it was written with AutoIT, source is included, please note I literally had to learn the language to make this, it was an exercise in mental gymnastics for me, a 3D artist with 22 years in that field, who has never written an app before, please be gentle!

    See inside Settings.ini for more information.

u\0-0-1
