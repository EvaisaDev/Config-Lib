config_list = {
	{
        mod_id = "config_lib",
        mod_name = "Config Lib",
        categories = {
            {
                category_id = "options",
                category = "$config_lib_options",
                items_per_page = 45,
                items_per_row = 15,
                items = {
                    --[[{
                        name = "Config Lib",
                        required_flag = "",
                        type = "title"
                    },     ]]  
                    {
                        flag = "hide_config_button_after_minutes",
                        required_flag = "",
                        name = "$config_lib_hide_button",
                        description = "$config_lib_hide_button_description",
                        default = false,
                        type = "toggle",
                        requires_restart = false,
                        callback = function(item, enabled)

                        end
                    },  
                    --[[{
                        flag = "input_test",
                        required_flag = "",
                        name = "Some text input",
                        description = "Write something here",
                        default_text = "Input text here",
                        allowed_chars = "",
                        text_max_length = 10,
                        type = "input",
                        requires_restart = true,
                        callback = function(number)

                        end
                    }, ]]
                    --[[
                    {
                        flag = "percentage_test",
                        required_flag = "",
                        name = "Some percentage picker",
                        description = "Pick a probability.",
                        default_number = 100,
                        max_number = 100,
                        min_number = 0,
                        format = "$0%",
                        increments = {
                        1,
                        10
                        },
                        type = "slider",
                        requires_restart = true,
                        callback = function(item, number)
                            GamePrint("Number changed to "..number)
                        end
                    }, 
                    ]]
                    {
                        name = "$config_lib_hide_button_now",
                        required_flag = "",
                        description = "$config_lib_hide_button_now_description",
                        type = "button",
                        callback = function(item)
                            button_hidden = true
                            open = false
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
                    },
                   --[[ {
                        required_flag = "",
                        type = "spacer"
                    },     
                    {
                        name = "Group Title",
                        required_flag = "",
                        type = "title"
                    },       
                    {
                        flag = "hide_config_button_after_minutes",
                        required_flag = "",
                        name = "Auto hide config button",
                        description = "Hides the config button after 30 seconds",
                        default = false,
                        type = "toggle",
                        requires_restart = false,
                        callback = function(enabled)

                        end
                    },  
                    {
                        flag = "percentage_test",
                        required_flag = "",
                        name = "Some percentage picker",
                        description = "Pick a probability.",
                        default_number = 100,
                        max_number = 100,
                        min_number = 0,
                        format = "$0%",
                        increments = {
                        1,
                        10
                        },
                        type = "slider",
                        requires_restart = true,
                        callback = function(number)

                        end
                    }, 
                    {
                        name = "Close menu and hide button",
                        required_flag = "",
                        description = "Closes this config menu and hides the button",
                        type = "button",
                        callback = function()
                            button_hidden = true
                        end
                    },
                    {
                        name = "Text item",
                        required_flag = "",
                        description = "",
                        type = "text"
                    },                   
                    {
                        required_flag = "",
                        type = "spacer"
                    },     
                    ]]                     
                }
            },

        }
    },
--[[	{
        mod_id = "fake_mod1",
        mod_name = "Fake Mod 1",
        categories = {
            {
                category_id = "tab1",
                category = "Cool tab",
                items_per_page = 45,
                items_per_row = 15,
                items = {                
                }
            },
        }
    },
    {
        mod_id = "fake_mod2",
        mod_name = "Fake Mod 2",
        categories = {
            {
                category_id = "tab1",
                category = "Cool tab",
                items_per_page = 45,
                items_per_row = 15,
                items = {                
                }
            },
        }
    },
    {
        mod_id = "fake_mod3",
        mod_name = "Fake Mod 3",
        categories = {
            {
                category_id = "tab1",
                category = "Cool tab",
                items_per_page = 45,
                items_per_row = 15,
                items = {                
                }
            },
        }
    },
    {
        mod_id = "fake_mod4",
        mod_name = "Fake Mod 4",
        categories = {
            {
                category_id = "tab1",
                category = "Cool tab",
                items_per_page = 45,
                items_per_row = 15,
                items = {                
                }
            },
        }
    },
    {
        mod_id = "fake_mod4",
        mod_name = "Fake Mod 4",
        categories = {
            {
                category_id = "tab1",
                category = "Cool tab",
                items_per_page = 45,
                items_per_row = 15,
                items = {                
                }
            },
        }
    },]]
}
