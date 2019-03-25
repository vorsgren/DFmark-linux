DFHack 0.44.12-r2
=================

New Plugins
-----------
- `debug`: manages runtime debug print category filtering
- `nestboxes`: automatically scan for and forbid fertile eggs incubating in a nestbox

New Scripts
-----------
- `devel/query`: searches for field names in DF objects
- `extinguish`: puts out fires
- `tame`: sets tamed/trained status of animals

Fixes
-----
- `building-hacks`: fixed error when dealing with custom animation tables
- `devel/test-perlin`: fixed Lua error (``math.pow()``)
- `embark-assistant`: fixed crash when entering finder with a 16x16 embark selected, and added 16 to dimension choices
- `embark-skills`: fixed missing ``skill_points_remaining`` field
- `full-heal`:

    - stopped wagon resurrection
    - fixed a minor issue with post-resurrection hostility

- `gui/companion-order`:

    - fixed issues with printing coordinates
    - fixed issues with move command
    - fixed cheat commands (and removed "Power up", which was broken)

- `gui/gm-editor`: fixed reinterpret cast (``r``)
- `gui/pathable`: fixed error when sidebar is hidden with ``Tab``
- `labormanager`:

    - stopped assigning labors to ineligible dwarves, pets, etc.
    - stopped assigning invalid labors
    - added support for crafting jobs that use pearl
    - fixed issues causing cleaning jobs to not be assigned
    - added support for disabling management of specific labors

- `prospector`: (also affected `embark-tools`) - fixed a crash when prospecting an unusable site (ocean, mountains, etc.) with a large default embark size in d_init.txt (e.g. 16x16)
- `siege-engine`: fixed a few Lua errors (``math.pow()``, ``unit.relationship_ids``)
- `tweak`: fixed ``hotkey-clear``

Misc Improvements
-----------------
- `armoks-blessing`: improved documentation to list all available arguments
- `devel/export-dt-ini`:

    - added viewscreen offsets for DT 40.1.2
    - added item base flags offset
    - added needs offsets

- `embark-assistant`:

    - added match indicator display on the right ("World") map
    - changed 'c'ancel to abort find if it's under way and clear results if not, allowing use of partial surveys.
    - added Coal as a search criterion, as well as a coal indication as current embark selection info.

- `full-heal`:

    - added ``-all``, ``-all_civ`` and ``-all_citizens`` arguments
    - added module support
    - now removes historical figure death dates and ghost data

- `growcrops`: added ``all`` argument to grow all crops
- `gui/load-screen`: improved documentation
- `labormanager`: now takes nature value into account when assigning jobs
- `open-legends`: added warning about risk of save corruption and improved related documentation
- `points`: added support when in ``viewscreen_setupdwarfgamest`` and improved error messages
- `siren`: removed break handling (relevant ``misc_trait_type`` was no longer used - see "Structures" section)

API
---
- New debug features related to `debug` plugin:

    - Classes (C++ only): ``Signal<Signature, type_tag>``, ``DebugCategory``, ``DebugManager``
    - Macros: ``TRACE``, ``DEBUG``, ``INFO``, ``WARN``, ``ERR``, ``DBG_DECLARE``, ``DBG_EXTERN``


Internals
---------
- Added a usable unit test framework for basic tests, and a few basic tests
- Added ``CMakeSettings.json`` with intellisense support
- Changed ``plugins/CMakeLists.custom.txt`` to be ignored by git and created (if needed) at build time instead
- Core: various thread safety and memory management improvements
- Fixed CMake build dependencies for generated header files
- Fixed custom ``CMAKE_CXX_FLAGS`` not being passed to plugins
- Linux/macOS: changed recommended build backend from Make to Ninja (Make builds will be significantly slower now)

Lua
---
- ``utils``: new ``OrderedTable`` class

Structures
----------
- Win32: added missing vtables for ``viewscreen_storesst`` and ``squad_order_rescue_hfst``
- ``activity_event_performancest``: renamed poem as written_content_id
- ``body_part_status``: identified ``gelded``
- ``dance_form``: named musical_form_id and musical_written_content_id
- ``incident_sub6_performance.participants``: named performance_event and role_index
- ``incident_sub6_performance``:

    - named poetic_form_id, musical_form_id, and dance_form_id
    - made performance_event an enum

- ``misc_trait_type``: removed ``LikesOutdoors``, ``Hardened``, ``TimeSinceBreak``, ``OnBreak`` (all unused by DF)
- ``musical_form_instruments``: named minimum_required and maximum_permitted
- ``musical_form``: named voices field
- ``plant_tree_info``: identified ``extent_east``, etc.
- ``plant_tree_tile``: gave connection bits more meaningful names (e.g. ``connection_east`` instead of ``thick_branches_1``)
- ``poetic_form``: identified many fields and related enum/bitfield types
- ``setup_character_info``: identified ``skill_points_remaining`` (for `embark-skills`)
- ``ui.main``: identified ``fortress_site``
- ``ui.squads``: identified ``kill_rect_targets_scroll``
- ``ui``: fixed alignment of ``main`` and ``squads`` (fixes `tweak` hotkey-clear and DF-AI)
- ``unit_action.attack``:

    - added ``lightly_tap`` and ``spar_report`` flags
    - identified ``attack_skill``

- ``unit_flags3``: identified ``marked_for_gelding``
- ``unit_personality``: identified ``stress_drain``, ``stress_boost``, ``likes_outdoors``, ``combat_hardened``
- ``unit_storage_status``: newly identified type, stores noble holdings information (used in ``viewscreen_layer_noblelistst``)
- ``unit_thought_type``: added new expulsion thoughts from 0.44.12
- ``viewscreen_layer_arena_creaturest``: identified item- and name-related fields
- ``viewscreen_layer_militaryst``: identified ``equip.assigned.assigned_items``
- ``viewscreen_layer_noblelistst``: identified ``storage_status`` (see ``unit_storage_status`` type)
- ``viewscreen_new_regionst``:

    - changed many ``int8_t`` fields to ``bool``
    - identified ``rejection_msg``, ``raw_folder``, ``load_world_params``

- ``viewscreen_setupadventurest``: identified some nemesis and personality fields, and ``page.ChooseHistfig``
- ``world_data``: added ``mountain_peak_flags`` type, including ``is_volcano``
- ``world_history``: identified names and/or types of some fields
- ``world_site``: identified names and/or types of some fields
- ``written_content``: named poetic_form


DFHack 0.44.12-r1
=================

Fixes
-----
- Fixed displayed names (from ``Units::getVisibleName``) for units with identities
- Fixed potential memory leak in ``Screen::show()``
- Fixed special characters in `command-prompt` and other non-console in-game outputs on Linux/macOS (in tools using ``df2console``)
- `command-prompt`: added support for commands that require a specific screen to be visible, e.g. `spotclean`
- `die`: fixed Windows crash in exit handling
- `dwarfmonitor`, `manipulator`: fixed stress cutoffs
- `fix/dead-units`: fixed script trying to use missing isDiplomat function
- `gui/workflow`: fixed advanced constraint menu for crafts
- `modtools/force`: fixed a bug where the help text would always be displayed and nothing useful would happen
- `ruby`: fixed calling conventions for vmethods that return strings (currently ``enabler.GetKeyDisplay()``)
- `startdwarf`: fixed on 64-bit Linux
- `stonesense`: fixed ``PLANT:DESERT_LIME:LEAF`` typo

Misc Improvements
-----------------
- Console:

    - added support for multibyte characters on Linux/macOS
    - made the console exit properly when an interactive command is active (`liquids`, `mode`, `tiletypes`)

- Linux: added automatic support for GCC sanitizers in ``dfhack`` script
- Made the ``DFHACK_PORT`` environment variable take priority over ``remote-server.json``
- Reduced time for designation jobs from tools like `digv` to be assigned workers
- `dfhack-run`: added support for port specified in ``remote-server.json``, to match DFHack's behavior
- `digfort`: added better map bounds checking
- `embark-assistant`:

    - Switched to standard scrolling keys, improved spacing slightly
    - Introduced scrolling of Finder search criteria, removing requirement for 46 lines to work properly (Help/Info still formatted for 46 lines).
    - Added Freezing search criterion, allowing searches for NA/Frozen/At_Least_Partial/Partial/At_Most_Partial/Never Freezing embarks.

- `rejuvenate`:

    - Added ``-all`` argument to apply to all citizens
    - Added ``-force`` to include units under 20 years old
    - Clarified documentation

- `remove-stress`:

    - added support for ``-all`` as an alternative to the existing ``all`` argument for consistency
    - sped up significantly
    - improved output/error messages
    - now removes tantrums, depression, and obliviousness

- `ruby`: sped up handling of onupdate events

API
---
- Added C++-style linked list interface for DF linked lists
- Added to ``Units`` module:

    - ``getStressCategory(unit)``
    - ``getStressCategoryRaw(level)``
    - ``stress_cutoffs`` (Lua: ``getStressCutoffs()``)

- Added ``Screen::Hide`` to temporarily hide screens, like `command-prompt`
- Exposed ``Screen::zoom()`` to C++ (was Lua-only)
- New functions: ``Units::isDiplomat(unit)``

Internals
---------
- Added documentation for all RPC functions and a build-time check
- Added support for build IDs to development builds
- Changed default build architecture to 64-bit
- jsoncpp: updated to version 1.8.4 and switched to using a git submodule
- Use ``dlsym(3)`` to find vtables from libgraphics.so

Lua
---
- Added ``printall_recurse`` to print tables and DF references recursively. It can be also used with ``^`` from the `lua` interpreter.
- ``gui.widgets``: ``List:setChoices`` clones ``choices`` for internal table changes

Structures
----------
- Added support for automatically sizing arrays indexed with an enum
- Added ``start_dwarf_count`` on 64-bit Linux again and fixed scanning script
- Dropped 0.44.10 support
- Dropped 0.44.11 support
- Removed stale generated CSV files and DT layouts from pre-0.43.05
- ``announcement_type``: new in 0.44.11: ``NEW_HOLDING``, ``NEW_MARKET_LINK``
- ``army_controller``: added new vector from 0.44.11
- ``belief_system``: new type, few fields identified
- ``breath_attack_type``: added ``OTHER``
- ``historical_figure_info.relationships.list``: added ``unk_3a``-``unk_3c`` fields at end
- ``history_event_entity_expels_hfst``: added (new in 0.44.11)
- ``history_event_site_surrenderedst``: added (new in 0.44.11)
- ``history_event_type``: added ``SITE_SURRENDERED``, ``ENTITY_EXPELS_HF`` (new in 0.44.11)
- ``interface_key``: added bindings new in 0.44.11
- ``mental_picture``: new type, some fields identified
- ``mission_report``:

    - new type (renamed, was ``mission`` before)
    - identified some fields

- ``mission``: new type (used in ``viewscreen_civlistst``)
- ``occupation_type``: new in 0.44.11: ``MESSENGER``
- ``profession``: new in 0.44.11: ``MESSENGER``
- ``spoils_report``: new type, most fields identified
- ``syndrome``: identified a few fields
- ``ui.squads``: Added fields new in 0.44.12
- ``ui_sidebar_menus``:

    - ``unit.in_squad``: renamed to ``unit.squad_list_opened``, fixed location
    - ``unit``: added ``expel_error`` and other unknown fields new in 0.44.11
    - ``hospital``: added, new in 0.44.11
    - ``num_speech_tokens``, ``unk_17d8``: moved out of ``command_line`` to fix layout on x64

- ``viewscreen_civlistst``:

    - fixed layout and identified many fields
    - identified new pages
    - identified new messenger-related fields

- ``viewscreen_image_creatorst``:

    - fixed layout
    - identified many fields

- ``viewscreen_locationsst``: identified ``edit_input``
- ``viewscreen_reportlistst``: added new mission and spoils report-related fields (fixed layout)
- ``world.languages``: identified (minimal information; whole languages stored elsewhere)
- ``world.status``:

    - ``mission_reports``: renamed, was ``missions``
    - ``spoils_reports``: identified

- ``world.unk_131ec0``, ``world.unk_131ef0``: researched layout
- ``world.worldgen_status``: identified many fields
- ``world``: ``belief_systems``: identified


DFHack 0.44.10-r2
=================

New Plugins
-----------
- `cxxrandom`: exposes some features of the C++11 random number library to Lua

New Scripts
-----------
- `add-recipe`: adds unknown crafting recipes to the player's civ
- `gui/stamper`: allows manipulation of designations by transforms such as translations, reflections, rotations, and inversion

Fixes
-----
- Fixed many tools incorrectly using the ``dead`` unit flag (they should generally check ``flags2.killed`` instead)
- Fixed many tools passing incorrect arguments to printf-style functions, including a few possible crashes (`changelayer`, `follow`, `forceequip`, `generated-creature-renamer`)
- Fixed several bugs in Lua scripts found by static analysis (df-luacheck)
- Fixed ``-g`` flag (GDB) in Linux ``dfhack`` script (particularly on x64)
- `autochop`, `autodump`, `autogems`, `automelt`, `autotrade`, `buildingplan`, `dwarfmonitor`, `fix-unit-occupancy`, `fortplan`, `stockflow`: fix issues with periodic tasks not working for some time after save/load cycles
- `autogems`:

    - stop running repeatedly when paused
    - fixed crash when furnaces are linked to same stockpiles as jeweler's workshops

- `autogems`, `fix-unit-occupancy`: stopped running when a fort isn't loaded (e.g. while embarking)
- `autounsuspend`: now skips planned buildings
- `ban-cooking`: fixed errors introduced by kitchen structure changes in 0.44.10-r1
- `buildingplan`, `fortplan`: stopped running before a world has fully loaded
- `deramp`: fixed deramp to find designations that already have jobs posted
- `dig`: fixed "Inappropriate dig square" announcements if digging job has been posted
- `fixnaked`: fixed errors due to emotion changes in 0.44
- `remove-stress`: fixed an error when running on soul-less units (e.g. with ``-all``)
- `revflood`: stopped revealing tiles adjacent to tiles above open space inappropriately
- `stockpiles`: ``loadstock`` now sets usable and unusable weapon and armor settings
- `stocks`: stopped listing carried items under stockpiles where they were picked up from

Misc Improvements
-----------------
- Added script name to messages produced by ``qerror()`` in Lua scripts
- Fixed an issue in around 30 scripts that could prevent edits to the files (adding valid arguments) from taking effect
- Linux: Added several new options to ``dfhack`` script: ``--remotegdb``, ``--gdbserver``, ``--strace``
- `bodyswap`: improved error handling
- `buildingplan`: added max quality setting
- `caravan`: documented (new in 0.44.10-alpha1)
- `deathcause`: added "slaughtered" to descriptions
- `embark-assistant`:

    - changed region interaction matching to search for evil rain, syndrome rain, and reanimation rather than interaction presence (misleadingly called evil weather), reanimation, and thralling
    - gave syndrome rain and reanimation wider ranges of criterion values

- `fix/dead-units`: added a delay of around 1 month before removing units
- `fix/retrieve-units`: now re-adds units to active list to counteract `fix/dead-units`
- `item-descriptions`: fixed several grammatical errors
- `modtools/create-unit`:

    - added quantity argument
    - now selects a caste at random if none is specified

- `mousequery`:

    - migrated several features from TWBT's fork
    - added ability to drag with left/right buttons
    - added depth display for TWBT (when multilevel is enabled)
    - made shift+click jump to lower levels visible with TWBT

- `title-version`: added version to options screen too

API
---
- New functions (also exposed to Lua):

    - ``Units::isKilled()``
    - ``Units::isActive()``
    - ``Units::isGhost()``

- Removed Vermin module (unused and obsolete)

Internals
---------
- Added build option to generate symbols for large generated files containing df-structures metadata
- Added fallback for YouCompleteMe database lookup failures (e.g. for newly-created files)
- Improved efficiency and error handling in ``stl_vsprintf`` and related functions
- jsoncpp: fixed constructor with ``long`` on Linux

Lua
---
- Added ``profiler`` module to measure lua performance
- Enabled shift+cursor movement in WorkshopOverlay-derived screens

Structures
----------
- ``incident_sub6_performance``: identified some fields
- ``item_body_component``: fixed location of ``corpse_flags``
- ``job_handler``: fixed static array layout
- ``job_type``: added ``is_designation`` attribute
- ``unit_flags1``: renamed ``dead`` to ``inactive`` to better reflect its use
- ``unit_personality``: fixed location of ``current_focus`` and ``undistracted_focus``
- ``unit_thought_type``: added ``SawDeadBody`` (new in 0.44.10)


DFHack 0.44.10-r1
=================

New Scripts
-----------
- `bodyswap`: shifts player control over to another unit in adventure mode
- `caravan`: adjusts properties of caravans
- `devel/find-primitive`: finds a primitive variable in memory
- `gui/autogems`: a configuration UI for the `autogems` plugin

New Tweaks
----------
- `tweak` kitchen-prefs-all: adds an option to toggle cook/brew for all visible items in kitchen preferences
- `tweak` stone-status-all: adds an option to toggle the economic status of all stones

Fixes
-----
- Fixed uninitialized pointer being returned from ``Gui::getAnyUnit()`` in rare cases
- Lua: registered ``dfhack.constructions.designateRemove()`` correctly
- Units::getAnyUnit(): fixed a couple problematic conditions and potential segfaults if global addresses are missing
- `autohauler`, `autolabor`, `labormanager`: fixed fencepost error and potential crash
- `dwarfvet`: fixed infinite loop if an animal is not accepted at a hospital
- `exterminate`: fixed documentation of ``this`` option
- `full-heal`:

    - units no longer have a tendency to melt after being healed
    - healed units are no longer treated as patients by hospital staff
    - healed units no longer attempt to clean themselves unsuccessfully
    - wounded fliers now regain the ability to fly upon being healing
    - now heals suffocation, numbness, infection, spilled guts and gelding

- `liquids`: fixed "range" command to default to 1 for dimensions consistently
- `modtools/create-unit`:

    - creatures of the appropriate age are now spawned as babies or children where applicable
    - fix: civ_id is now properly assigned to historical_figure, resolving several hostility issues (spawned pets are no longer attacked by fortress military!)
    - fix: unnamed creatures are no longer spawned with a string of numbers as a first name

- `prospector`: fixed crash due to invalid vein materials
- `search-plugin`: fixed 4/6 keys in unit screen search
- `stockpiles`: stopped sidebar option from overlapping with `autodump`
- `tweak` block-labors: fixed two causes of crashes related in the v-p-l menu
- `tweak` max-wheelbarrow: fixed conflict with building renaming
- `view-item-info`:

    - fixed an error with some armor
    - stopped appending extra newlines permanently to descriptions


Misc Improvements
-----------------
- Added logo to documentation
- Documented several missing ``dfhack.gui`` Lua functions
- `adv-rumors`: bound to Ctrl-A
- `autogems`: can now blacklist arbitrary gem types (see `gui/autogems`)
- `blueprint`: added a basic Lua API
- `command-prompt`: added support for ``Gui::getSelectedPlant()``
- `devel/export-dt-ini`: added tool offsets for DT 40
- `devel/save-version`: added current DF version to output
- `exterminate`: added more words for current unit, removed warning
- `fpause`: now pauses worldgen as well
- `gui/advfort`: bound to Ctrl-T
- `gui/room-list`: added support for ``Gui::getSelectedBuilding()``
- `gui/unit-info-viewer`: bound to Alt-I
- `install-info`: added information on tweaks
- `modtools/create-unit`: made functions available to other scripts
- `search-plugin`:

    - added support for stone restrictions screen (under ``z``: Status)
    - added support for kitchen preferences (also under ``z``)


API
---
- New functions (all available to Lua as well):

    - ``Buildings::getRoomDescription()``
    - ``Items::checkMandates()``
    - ``Items::canTrade()``
    - ``Items::canTradeWithContents()``
    - ``Items::isRouteVehicle()``
    - ``Items::isSquadEquipment()``
    - ``Kitchen::addExclusion()``
    - ``Kitchen::findExclusion()``
    - ``Kitchen::removeExclusion()``

- syndrome-util: added ``eraseSyndromeData()``

Internals
---------
- Added function names to DFHack's NullPointer and InvalidArgument exceptions
- Added some build scripts for Sublime Text
- Added ``Gui::inRenameBuilding()``
- Changed submodule URLs to relative URLs so that they can be cloned consistently over different protocols (e.g. SSH)
- Fixed compiler warnings on all supported build configurations
- Linux: required plugins to have symbols resolved at link time, for consistency with other platforms
- Windows build scripts now work with non-C system drives

Structures
----------
- ``dfhack_room_quality_level``: new enum
- ``glowing_barrier``: identified ``triggered``, added comments
- ``item_flags2``: renamed ``has_written_content`` to ``unk_book``
- ``kitchen_exc_type``: new enum (for ``ui.kitchen``)
- ``mandate.mode``: now an enum
- ``unit_personality.emotions.flags.memory``: identified
- ``viewscreen_kitchenprefst.forbidden``, ``possible``: now a bitfield, ``kitchen_pref_flag``
- ``world_data.feature_map``: added extensive documentation (in XML)


DFHack 0.44.09-r1
=================

Fixes
-----
- Fixed some CMake warnings (CMP0022)
- Support for building on Ubuntu 18.04
- `digtype`: stopped designating non-vein tiles (open space, trees, etc.)
- `embark-assistant`: fixed detection of reanimating biomes
- `fix/dead-units`: fixed a bug that could remove some arriving (not dead) units
- `labormanager`: fixed crash due to dig jobs targeting some unrevealed map blocks
- `modtools/item-trigger`: fixed token format in help text

Misc Improvements
-----------------
- Reorganized changelogs and improved changelog editing process
- `embark-assistant`:

    - Added search for adamantine
    - Now supports saving/loading profiles

- `fillneeds`: added ``-all`` option to apply to all units
- `modtools/item-trigger`:

    - added the ability to specify inventory mode(s) to trigger on
    - added support for multiple type/material/contaminant conditions

- `remotefortressreader`: added flows, instruments, tool names, campfires, ocean waves, spiderwebs

Internals
---------
- OS X: Can now build with GCC 7 (or older)

Structures
----------
- Several new names in instrument raw structures
- ``army``: added vector new in 0.44.07
- ``building_type``: added human-readable ``name`` attribute
- ``furnace_type``: added human-readable ``name`` attribute
- ``identity``: identified ``profession``, ``civ``
- ``manager_order_template``: fixed last field type
- ``site_reputation_report``: named ``reports`` vector
- ``viewscreen_createquotast``: fixed layout
- ``workshop_type``: added human-readable ``name`` attribute
- ``world.language``: moved ``colors``, ``shapes``, ``patterns`` to ``world.descriptors``
- ``world.reactions``, ``world.reaction_categories``: moved to new compound, ``world.reactions``. Requires renaming:

    - ``world.reactions`` to ``world.reactions.reactions``
    - ``world.reaction_categories`` to ``world.reactions.reaction_categories``



DFHack 0.44.05-r2
=================

New Plugins
-----------
- `embark-assistant`: adds more information and features to embark screen

New Scripts
-----------
- `adv-fix-sleepers`: fixes units in adventure mode who refuse to wake up (:bug:`6798`)
- `hermit`: blocks caravans, migrants, diplomats (for hermit challenge)

New Features
------------
- With ``PRINT_MODE:TEXT``, setting the ``DFHACK_HEADLESS`` environment variable will hide DF's display and allow the console to be used normally. (Note that this is intended for testing and is not very useful for actual gameplay.)

Fixes
-----
- `devel/export-dt-ini`: fix language_name offsets for DT 39.2+
- `devel/inject-raws`: fixed gloves and shoes (old typo causing errors)
- `remotefortressreader`: fixed an issue with not all engravings being included
- `view-item-info`: fixed an error with some shields

Misc Improvements
-----------------
- `adv-rumors`: added more keywords, including names
- `autochop`: can now exclude trees that produce fruit, food, or cookable items
- `remotefortressreader`: added plant type support


DFHack 0.44.05-r1
=================

New Scripts
-----------
- `break-dance`: Breaks up a stuck dance activity
- `devel/check-other-ids`: Checks the validity of "other" vectors in the ``world`` global
- `devel/dump-offsets`: prints an XML version of the global table included in in DF
- `fillneeds`: Use with a unit selected to make them focused and unstressed
- `firestarter`: Lights things on fire: items, locations, entire inventories even!
- `flashstep`: Teleports adventurer to cursor
- `ghostly`: Turns an adventurer into a ghost or back
- `gui/cp437-table`: An in-game CP437 table
- `questport`: Sends your adventurer to the location of your quest log cursor
- `view-unit-reports`: opens the reports screen with combat reports for the selected unit

Fixes
-----
- Fixed a crash that could occur if a symbol table in symbols.xml had no content
- Fixed issues with the console output color affecting the prompt on Windows
- `autolabor`, `autohauler`, `labormanager`: added support for "put item on display" jobs and building/destroying display furniture
- `createitem`: stopped items from teleporting away in some forts
- `devel/inject-raws`:

    - now recognizes spaces in reaction names
    - now recognizes spaces in reaction names

- `dig`: added support for designation priorities - fixes issues with designations from ``digv`` and related commands having extremely high priority
- `dwarfmonitor`:

    - fixed display of creatures and poetic/music/dance forms on ``prefs`` screen
    - added "view unit" option
    - now exposes the selected unit to other tools

- `exportlegends`: fixed an error that could occur when exporting empty lists
- `gui/gm-editor`: fixed an error when editing primitives in Lua tables
- `gui/gm-unit`: can now edit mining skill
- `gui/quickcmd`: stopped error from adding too many commands
- `modtools/create-unit`: fixed error when domesticating units
- `names`: fixed many errors
- `quicksave`: fixed an issue where the "Saving..." indicator often wouldn't appear

Misc Improvements
-----------------
- The console now provides suggestions for built-in commands
- `binpatch`: now reports errors for empty patch files
- `devel/export-dt-ini`: avoid hardcoding flags
- `exportlegends`:

    - reordered some tags to match DF's order
    - added progress indicators for exporting long lists

- `force`: now provides useful help
- `full-heal`:

    - can now select corpses to resurrect
    - now resets body part temperatures upon resurrection to prevent creatures from freezing/melting again
    - now resets units' vanish countdown to reverse effects of `exterminate`

- `gui/gm-editor`: added enum names to enum edit dialogs
- `gui/gm-unit`:

    - made skill search case-insensitive
    - added a profession editor
    - misc. layout improvements

- `gui/liquids`: added more keybindings: 0-7 to change liquid level, P/B to cycle backwards
- `gui/pathable`: added tile types to sidebar
- `gui/rename`: added "clear" and "special characters" options
- `launch`: can now ride creatures
- `modtools/skill-change`:

    - now updates skill levels appropriately
    - only prints output if ``-loud`` is passed

- `names`: can now edit names of units
- `remotefortressreader`:

    - includes item stack sizes
    - some performance improvements
    - support for moving adventurers
    - support for vehicles, gem shapes, item volume, art images, item improvements


Removed
-------
- `tweak`: ``kitchen-keys``: :bug:`614` fixed in DF 0.44.04
- `warn-stuck-trees`: :bug:`9252` fixed in DF 0.44.01

Internals
---------
- ``Gui::getAnyUnit()`` supports many more screens/menus

Lua
---
- Added a new ``dfhack.console`` API
- API can now wrap functions with 12 or 13 parameters
- Exposed ``get_vector()`` (from C++) for all types that support ``find()``, e.g. ``df.unit.get_vector() == df.global.world.units.all``
- Improved ``json`` I/O error messages
- Stopped a crash when trying to create instances of classes whose vtable addresses are not available

Structures
----------
- Added ``buildings_other_id.DISPLAY_CASE``
- Added ``job_type.PutItemOnDisplay``
- Added ``twbt_render_map`` code offset on x64
- Fixed an issue preventing ``enabler`` from being allocated by DFHack
- Fixed ``unit`` alignment
- Fixed ``viewscreen_titlest.start_savegames`` alignment
- Found ``renderer`` vtable on osx64
- Identified ``historical_entity.unknown1b.deities`` (deity IDs)
- Located ``start_dwarf_count`` offset for all builds except 64-bit Linux; `startdwarf` should work now
- New globals:

    - ``version``
    - ``min_load_version``
    - ``movie_version``
    - ``basic_seed``
    - ``title``
    - ``title_spaced``
    - ``ui_building_resize_radius``
    - ``soul_next_id``

- The former ``announcements`` global is now a field in ``d_init``
- The ``ui_menu_width`` global is now a 2-byte array; the second item is the former ``ui_area_map_width`` global, which is now removed
- ``adventure_movement_optionst``, ``adventure_movement_hold_tilest``, ``adventure_movement_climbst``: named coordinate fields
- ``artifact_record``: fixed layout (changed in 0.44.04)
- ``incident``: fixed layout (changed in 0.44.01) - note that many fields have moved
- ``mission``: added type
- ``unit``: added 3 new vmethods: ``getCreatureTile``, ``getCorpseTile``, ``getGlowTile``
- ``viewscreen_assign_display_itemst``: fixed layout on x64 and identified many fields
- ``viewscreen_reportlistst``: fixed layout, added ``mission_id`` vector
- ``world.status``: named ``missions`` vector
- ``world`` fields formerly beginning with ``job_`` are now fields of ``world.jobs``, e.g. ``world.job_list`` is now ``world.jobs.list``


