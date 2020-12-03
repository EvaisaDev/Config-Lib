dofile_once("mods/config_lib/files/utilities.lua")
dofile_once("mods/config_lib/files/persistent_store.lua")
--dofile_once("mods/config_lib/files/config_data.lua")
dofile_once("data/scripts/lib/utilities.lua")

button_hidden = false

config_time = 0

config_initialized = false

next_refresh = false

dofile("mods/config_lib/files/translations.lua")
register_localizations("mods/config_lib/files/translations.csv")

config_list_cached = {}

function OnWorldPreUpdate()

    if(GameGetFrameNum() > 30)then
        
        if(config_initialized == false)then
            dofile("mods/config_lib/files/config_list.lua")
            config_list_cached = config_list
        end

        if(next_refresh == true)then
            --print("aaaaa")
            print("Config Lib - Refreshing config")
            dofile("mods/config_lib/files/config_list.lua")
            config_list_cached = config_list
            config_initialized = false
            next_refresh = false
        end


        config_time = config_time + 1

        dofile("mods/config_lib/files/gui.lua")


        if(GameHasFlagRun("config_lib_update_config"))then
            GameRemoveFlagRun("config_lib_update_config")

            next_refresh = true
        end
        
        if(config_initialized == false)then

           -- print("Config lib cleaned")
            
            times_run = 0
            
            gui_options = config_list_cached
            __loaded["mods/config_lib/files/config_special.lua"] = nil
            dofile("mods/config_lib/files/config_special.lua")

            config_initialized = true
        end

        if(HasSettingFlag(get_flag("config_lib", "options", "hide_config_button_after_minutes")))then
        -- GamePrint("button_time = "..config_time)
            if(config_time > 1800 and button_hidden == false)then
                button_hidden = true
                
                if(get_player())then
                    player = get_player()
                    controls = EntityGetFirstComponent(player, "ControlsComponent")
                    if(controls ~= nil and controls ~= 0)then
                        ComponentSetValue2(controls, "enabled",true)
                        -- GamePrint("Enabling controls")
                        --StreamingSetVotingEnabled( true )
                        was_recently_disabled = false
                        was_recently_enabled = true
                    end
                end
            end
        end
    end

end

function OnPlayerSpawned( player_entity )
    GlobalsSetValue( "mod_button_tr_width", "0" );

end

function OnWorldInitialized()
    local mod_button_reservation = tonumber( GlobalsGetValue( "mod_button_tr_width", "0" ) );
    GlobalsSetValue( "config_lib_mod_button_reservation", tostring( mod_button_reservation ) );
    GlobalsSetValue( "mod_button_tr_width", tostring( mod_button_reservation + 15 ) );
end

function OnWorldPostUpdate()

    if GlobalsGetValue( "config_mod_button_tr_max", "0" ) == "0" then
        GlobalsSetValue( "config_mod_button_tr_max", GlobalsGetValue( "mod_button_tr_current", "0" ) );
    end
    GlobalsSetValue( "mod_button_tr_current", "0" );
end
--[[
function OnWorldPreUpdate()

    if(GameGetFrameNum() > 30)then
        
        if(config_initialized == false)then
            dofile("mods/config_lib/files/config_list.lua")
            config_list_cached = config_list
        end

        if(next_refresh ~= 0)then
            --print("aaaaa")
            if(GameGetFrameNum() > next_refresh)then
                print("Config Lib - Refreshing config")
                dofile("mods/config_lib/files/config_list.lua")
                config_list_cached = config_list
                config_initialized = false
                next_refresh = 0
            end
        end


        config_time = config_time + 1
        if(not button_hidden)then
            dofile("mods/config_lib/files/gui.lua")
        end

        if(GameHasFlagRun("config_lib_update_config"))then
            GameRemoveFlagRun("config_lib_update_config")

            next_refresh = GameGetFrameNum() + 20
        end
        
        if(config_initialized == false)then

           -- print("Config lib cleaned")
            
            times_run = 0
            
            gui_options = config_list_cached
            __loaded["mods/config_lib/files/config_special.lua"] = nil
            dofile("mods/config_lib/files/config_special.lua")

            config_initialized = true
        end

        if(HasSettingFlag(get_flag("config_lib", "options", "hide_config_button_after_minutes")))then
        -- GamePrint("button_time = "..config_time)
            if(config_time > 1800)then
                button_hidden = true
            end
        end
    end

end
]]