gui = gui or GuiCreate()
--guibackground = guibackground or GuiCreate()
open = open or false
initialized = initialized or false
page = page or 1
current_id = 10000
categories_to_show = 5
page_numbers_to_show = 15
mods_to_show = 5
selected_mod_index = selected_mod_index or 1
selected_category_index = selected_category_index or 1
selected_page_number = selected_page_number or 1
default_items_per_page = 60
default_items_per_row = 15
times_run = times_run or 0
button_position = {x = 70, y = 0}
repeating_timer = repeating_timer or 0
gui_name = GameTextGetTranslatedOrNot("$config_lib_mod_settings")
flag_prefix = "config_lib"
gui_options = gui_options or {}

mod_area = mod_area or 1
category_area = category_area or 1
page_number_area = page_number_area or 1

hover_stats = hover_stats or {}
hover_stats_previous = hover_stats_previous or {}


function do_custom_tooltip( callback, z, x_offset, y_offset )
    if z == nil then z = -12; end
    local left_click,right_click,hover,x,y,width,height,draw_x,draw_y,draw_width,draw_height = GuiGetPreviousWidgetInfo( gui );
    local screen_width,screen_height = GuiGetScreenDimensions( gui );
    if x_offset == nil then x_offset = 0; end
    if y_offset == nil then y_offset = 0; end
    if draw_y > screen_height * 0.5 then
        y_offset = y_offset - height;
    end
    if hover == 1 then
        local screen_width, screen_height = GuiGetScreenDimensions( gui );
        GuiZSet( gui, z );
        GuiLayoutBeginLayer( gui );
            GuiLayoutBeginVertical( gui, ( x + x_offset + width * 2 ) / screen_width * 100, ( y + y_offset ) / screen_height * 100 );
                GuiBeginAutoBox( gui );
                    if callback ~= nil then callback(); end
                    GuiZSetForNextWidget( gui, z + 1 );
                GuiEndAutoBoxNinePiece( gui );
            GuiLayoutEnd( gui );
        GuiLayoutEndLayer( gui );
    end
end

function new_id()
    current_id = current_id + 1
    return current_id
end


function sort_options(a, b)
    a = tostring(a.name)
    b = tostring(b.name)
    local patt = '^(.-)%s*(%d+)$'
    local _,_, col1, num1 = a:find(patt)
    local _,_, col2, num2 = b:find(patt)
    if (col1 and col2) and col1 == col2 then
       return tonumber(num1) < tonumber(num2)
    end
    return a < b
end

function getCategoryIndex(mod_name, category)
    local index = 0
    if(getModIndex(mod_name) ~= 0)then
        for k, v in pairs(gui_options[getModIndex(mod_name)].categories)do 
            --print(dump(v))
            if(v.category_id == category)then
                index = k
            end
        end
    end
    return index
end

function getItemIndex(mod_name, category, item_name)
    local index = 0
    if(getCategoryIndex(mod_name, category) ~= 0)then
        for k, v in pairs(gui_options[getModIndex(mod_name)].categories[getCategoryIndex(mod_name, category)].items)do
            if(v.item_id ~= nil)then
                if(v.item_id == item_name)then
                    index = k
                end
            end
        end
    end
    return index
end


function getModIndex(mod)
    index = 0
    for k, v in pairs(gui_options)do
        if(v.mod_id == mod)then
            index = k
        end
    end
    return index
end
  
function set_options(options)
    gui_options = options
end

function get_flag(mod_id, category, flag)
    local new_flag = ""
    if(getCategoryIndex(mod_id, category) ~= 0)then
        local mod_options = gui_options[getModIndex(mod_id)]
        if(mod_options ~= nil)then
            local category = mod_options.categories[getCategoryIndex(mod_id, category)]
            new_flag = mod_options.mod_id.."_"..category.category_id.."_"..flag
        end
    end
    return new_flag
end

function register_mod(name, mod_id)
    local items_per_page = items_per_page or default_items_per_page
    local items_per_row = items_per_row or default_items_per_row
    if(name ~= nil)then
        if(getModIndex(name) == 0)then
           -- print("Config Lib - Registered mod: "..name)
            --print("Inserted category")
            table.insert(gui_options, {
                mod_id = mod_id,
                mod_name = name,
                categories = {}
            })
        end
    end
end

function register_category(mod_name, category_id, name, items_per_page, items_per_row)
    local items_per_page = items_per_page or default_items_per_page
    local items_per_row = items_per_row or default_items_per_row
    --print("stuff = "..getCategoryIndex(mod_name, category_id))
    if(getCategoryIndex(mod_name, category_id) == 0)then
      --  print(tostring(getModIndex(mod_name)))
        if(getModIndex(mod_name) ~= 0)then
           -- print("Config Lib - Registered category: "..name)
            table.insert(gui_options[getModIndex(mod_name)].categories, {
                category_id = category_id,
                category = name,
                items_per_page = items_per_page,
                items_per_row = items_per_row,
                items = {}
            })
        end
    end
end

function add_option(mod_name, category_id, item)
    if(getCategoryIndex(mod_name, category_id) ~= 0)then
        --print("Added a option.")
        --print(dump(gui_options))
        if(getModIndex(mod_name) ~= 0)then
            table.insert(gui_options[getModIndex(mod_name)].categories[getCategoryIndex(mod_name, category_id)].items, item)
        end
    end
end

function get_player()
    return EntityGetWithTag( "player_unit" )[1]
end

times_run = times_run + 1

if(times_run == 2)then
    for k, v in pairs(gui_options)do
        if(v.init ~= nil)then
            v.init()
        end
        for k2, v2 in pairs(v.categories)do
            for k3, item in pairs(v2.items)do
                if(item.flag ~= nil)then
                    --print("Checking flag: "..get_flag(v.mod_id, v2.category_id, item.flag))
                end
                if(item.type == "toggle")then
                    if(HasSettingFlag(get_flag(v.mod_id, v2.category_id, item.flag) .. "_initialized") == false and item.default)then
                        AddSettingFlag(get_flag(v.mod_id, v2.category_id, item.flag))
                        AddSettingFlag(get_flag(v.mod_id, v2.category_id, item.flag) .. "_initialized")
                    elseif(HasSettingFlag(get_flag(v.mod_id, v2.category_id, item.flag) .. "_initialized") == false)then
                        if(HasSettingFlag(get_flag(v.mod_id, v2.category_id, item.flag)))then
                            RemoveSettingFlag(get_flag(v.mod_id, v2.category_id, item.flag))
                        end
                        AddSettingFlag(get_flag(v.mod_id, v2.category_id, item.flag) .. "_initialized")
                    end
                elseif(item.type == "slider")then
                    --print("Getting flag: "..get_flag(v.mod_id, v2.category_id, item.flag))
                    if(ModSettingGet( get_flag(v.mod_id, v2.category_id, item.flag)) == nil)then
                        item.current_number = item.default_number

                        --store_int(get_flag(v.mod_id, v2.category_id, item.flag), 32, item.current_number)

                        ModSettingSet( get_flag(v.mod_id, v2.category_id, item.flag), item.current_number )
                        --print("Config Lib - Setting data: "..get_flag(v.mod_id, v2.category_id, item.flag))
                    else
                        item.current_number = ModSettingGet( get_flag(v.mod_id, v2.category_id, item.flag))--retrieve_int(get_flag(v.mod_id, v2.category_id, item.flag), 32)
                    end
                elseif(item.type == "input")then
                    --print("Getting flag: "..get_flag(v.mod_id, v2.category_id, item.flag))
                    if(ModSettingGet( get_flag(v.mod_id, v2.category_id, item.flag)) == nil)then
                        item.current_text = item.default_text

                        --store_int(get_flag(v.mod_id, v2.category_id, item.flag), 32, item.current_number)

                        ModSettingSet( get_flag(v.mod_id, v2.category_id, item.flag), item.current_text )
                        --print("Config Lib - Setting data: "..get_flag(v.mod_id, v2.category_id, item.flag))
                    else
                        item.current_text = ModSettingGet( get_flag(v.mod_id, v2.category_id, item.flag))--retrieve_int(get_flag(v.mod_id, v2.category_id, item.flag), 32)
                    end
                elseif(item.type == "enum")then
                    if(ModSettingGet( get_flag(v.mod_id, v2.category_id, item.flag)) == nil)then
                        key = nil
                        for k, v in pairs(item.values)do
                            if(v[1] == item.default)then
                                key = k
                            end
                        end
                        if(key ~= nil)then
                            item.current_key = key

                            ModSettingSet( get_flag(v.mod_id, v2.category_id, item.flag), item.default )
                        end
                    else
                        item_name = ModSettingGet( get_flag(v.mod_id, v2.category_id, item.flag))
                        key = nil
                        for k, v in pairs(item.values)do
                            if(v[1] == item_name)then
                                key = k
                            end
                        end
                        if(key ~= nil)then
                            item.current_key = key
                        end
                    end
                end
            end
        end
    end
end

if(repeating_timer < 20)then
    repeating_timer = repeating_timer + 1
else
    repeating_timer = 0
    for k, mod in pairs(gui_options)do
        for k2, category in pairs(mod.categories)do
            for k3, item in pairs(category.items)do
                if(item.type == "slider")then
                    if(item.previous_number ~= nil)then
                        if(item.previous_number ~= item.current_number and item.old_number == item.current_number)then
                            item.previous_number = item.current_number
                            ModSettingSet(get_flag(mod.mod_id, category.category_id, item.flag), item.current_number)
                        end
                    else
                        ModSettingSet(get_flag(mod.mod_id, category.category_id, item.flag), item.current_number)
                    end
                elseif(item.type == "input")then
                    if(item.previous_text ~= nil)then
                        if(item.previous_text ~= item.current_text and item.old_text == item.current_text)then
                             item.previous_text = item.current_text
                             ModSettingSet(get_flag(mod.mod_id, category.category_id, item.flag), item.current_text)
                         end
                    else
                        ModSettingSet(get_flag(mod.mod_id, category.category_id, item.flag), item.current_text)
                    end
                elseif(item.type == "enum")then
                   -- item.current_key = item.current_key or 1
                    if(item.old_key ~= nil)then
                        if(item.old_key ~= item.current_key)then
                             
                             item.old_key = item.current_key

                             ModSettingSet(get_flag(mod.mod_id, category.category_id, item.flag), item.values[item.current_key][1])
                         end
                    else
                        ModSettingSet(get_flag(mod.mod_id, category.category_id, item.flag), item.values[item.current_key][1])
                    end
                end
            end
        end
    end
end
local sx, sy = GuiGetScreenDimensions( gui )
if(button_hidden == false)then


    

    --[[
    GuiStartFrame(guibackground)
    
    if open then
        GuiImage( guibackground, new_id(), 0, 0, "mods/config_lib/files/gui_background.png", 1, 1000, 0 )
        GamePrint("Width: "..sx.."; Height: "..sy)
        width = sx / 20
        height = sy / 25
        GuiLayoutBeginVertical(guibackground, 5, 22)
            GuiLayoutBeginHorizontal(guibackground, 0, 0)
            GuiImage( guibackground, new_id(), 0, 0, "mods/config_lib/files/gfx/1.png", 1, 1, 0 )
            for i = 1, width do
                
                if(i < width)then

                    GuiImage( guibackground, new_id(), -2, 0, "mods/config_lib/files/gfx/2.png", 1, 1, 0 )
                else
                    GuiImage( guibackground, new_id(), -2, 0, "mods/config_lib/files/gfx/3.png", 1, 1, 0 )
                end
                
            end
            GuiLayoutEnd(guibackground)
            
            for i = 1,  height do
                GuiLayoutBeginHorizontal(guibackground, 0, 0)
                if(i == 1)then
                    GuiImage( guibackground, new_id(), 0, -2, "mods/config_lib/files/gfx/4.png", 1, 1, 0 )
                elseif(i ==  height)then
                    GuiImage( guibackground, new_id(), 0, -2 - (i * 2), "mods/config_lib/files/gfx/7.png", 1, 1, 0 )
                else
                    GuiImage( guibackground, new_id(), 0, -2 - (i * 2), "mods/config_lib/files/gfx/4.png", 1, 1, 0 )
                end
                for i2 = 1, width do
                    if(i ==  height)then
                        if(i2 < width)then
        
                            GuiImage( guibackground, new_id(), -2, -2 - (i * 2), "mods/config_lib/files/gfx/8.png", 1, 1, 0 )
                        else
                            GuiImage( guibackground, new_id(), -2, -2 - (i * 2), "mods/config_lib/files/gfx/9.png", 1, 1, 0 )
                        end
                    else
                        if(i2 < width)then
        
                            GuiImage( guibackground, new_id(), -2, -2 - (i * 2), "mods/config_lib/files/gfx/5.png", 1, 1, 0 )
                        else
                            GuiImage( guibackground, new_id(), -2, -2 - (i * 2), "mods/config_lib/files/gfx/6.png", 1, 1, 0 )
                        end
                    end
                end
                GuiLayoutEnd(guibackground)
            end
            
            
        GuiLayoutEnd(guibackground)
        
    end
]]
    GuiStartFrame(gui)
    GuiIdPushString( gui, "config_lib" )
    GuiZSet( gui, -90 )
    GuiOptionsAdd( gui, GUI_OPTION.NoPositionTween )
    -- Menu toggle button
   -- GuiLayoutBeginVertical(gui, button_position.x, button_position.y)
   if not button_hidden then
        local mod_button_reservation = tonumber( GlobalsGetValue( "config_lib_mod_button_reservation", "0" ) );
        local current_button_reservation = tonumber( GlobalsGetValue( "mod_button_tr_current", "0" ) );
        if current_button_reservation > mod_button_reservation then
            current_button_reservation = mod_button_reservation;
        elseif current_button_reservation < mod_button_reservation then
            current_button_reservation = math.max( 0, mod_button_reservation + (current_button_reservation - mod_button_reservation ) );
        else
            current_button_reservation = mod_button_reservation;
        end
        GlobalsSetValue( "mod_button_tr_current", tostring( current_button_reservation + 15 ) );
        --GuiOptionsAddForNextWidget( gui, GUI_OPTION.NoSound )
        button_id = new_id()
       -- print("button id = "..button_id)

        if(GameHasFlagRun( flag_prefix.."_config_changed" ))then
            if GuiImageButton( gui, button_id, sx - 14 - current_button_reservation, 2, "", "mods/config_lib/files/gfx/icon_changed.png" )then--if GuiButton(gui, 0, 0, "["..gui_name.."*]", new_id()) then
                open = not open
                GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_click", cam_x, cam_y )
            end
        else
            if GuiImageButton( gui, button_id, sx - 14 - current_button_reservation, 2, "", "mods/config_lib/files/gfx/icon.png" )then--if GuiButton(gui, 0, 0, "["..gui_name.."]", new_id()) then
                open = not open
                GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_click", cam_x, cam_y )
            end
        end
        local width = GuiGetTextDimensions( gui, "Settings for mods that utilize Config Lib" );
        --GuiZSetForNextWidget(gui, -200)
        do_custom_tooltip( function()
            GuiText( gui, 0, 0, "Mod Settings" );
            GuiColorSetForNextWidget( gui, 0.5, 0.5, 0.5, 1.0 );
            GuiText( gui, 0, 0, "Settings for mods that utilize Config Lib" );
        end, -100, -width - 24, 10 );

        GlobalsSetValue( "mod_button_tr_current", tostring( current_button_reservation + 15 ) );

    else
        open = false
    end

    GuiZSet( gui, -90 )
   -- GuiLayoutEnd(gui)

    --GuiLayoutBeginVertical(gui, 4, 4)
    
    --GuiLayoutBeginVertical(gui, 8, 23)
    --RemoveSettingFlag("randomized_alchemy_has_run_before")
    
    was_recently_disabled = was_recently_disabled or false
    was_recently_enabled = was_recently_enabled or false

    if open then
        GameAddFlagRun("config_lib_open")
        GlobalsSetValue("config_lib_open", "true")
    else
        GameRemoveFlagRun("config_lib_open")
        GlobalsSetValue("config_lib_open", "false")
    end

    if(get_player())then
        player = get_player()
        controls = EntityGetFirstComponent(player, "ControlsComponent")
        if(controls ~= nil and controls ~= 0)then
            if(open and not was_recently_disabled)then
                player_x, player_y = EntityGetTransform(player)
                ComponentSetValue2(controls, "enabled",false)
                child = EntityLoad("mods/config_lib/files/disable_movement.xml", player_x, player_y)
                EntityAddChild(player, child)
                --GamePrint("Disabling controls")
                --StreamingSetVotingEnabled( false )
                was_recently_disabled = true
                was_recently_enabled = false
            elseif(not open and not was_recently_enabled)then
                ComponentSetValue2(controls, "enabled",true)
                -- GamePrint("Enabling controls")
                --StreamingSetVotingEnabled( true )
                was_recently_disabled = false
                was_recently_enabled = true
            end
        end
    end

    if open and not button_hidden then
        local cx, cy = GameGetCameraPos()

        --local vw = MagicNumbersGetValue("VIRTUAL_RESOLUTION_X") / 2
        --local vh = MagicNumbersGetValue("VIRTUAL_RESOLUTION_Y") / 2

        --print("vw = "..vw.."; vh = "..vh)

        --vw = 213.5; vh = 121

        --GameCreateSpriteForXFrames("mods/config_lib/files/gui_background.png", cx - vw - 1, cy - vh, true, 0, 0, 2)


        
        GuiLayoutBeginVertical(gui, 6, 15)


        
        config_time = 0

        GuiLayoutBeginHorizontal(gui, 0, 0)

        --GuiText(gui, 0, 0, "Mod: ")

        if(#gui_options > mods_to_show)then
            if(mod_area ~= 1)then
                space_count = 3

                text = "<< "
                offset_y = -3
                func = function()
                    count_to_subtract = mods_to_show
                    if(mod_area < count_to_subtract + 1)then
                        count_to_subtract = mod_area - 1
                    end
                    mod_area = mod_area - count_to_subtract

                    GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_click", cam_x, cam_y )
                end
                being_hovered = hover_stats["mods_back_button"] or false
                was_being_hovered = hover_stats_previous["mods_back_button"] or false
                local hovered = false

                
                if(being_hovered and not was_being_hovered)then
                   -- GamePrint("pretty neat")
                    GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_select", cam_x, cam_y )
                end
                
                hover_stats_previous["mods_back_button"] = being_hovered
                
				GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
				--GuiZSetForNextWidget( gui, -50 )
				if GuiImageButton(gui, new_id(), 0, offset_y, "", "mods/config_lib/files/gfx/tab/tab_unselected_left.png") then
                    func()
                end
                local _, _2, is_hover = GuiGetPreviousWidgetInfo( gui )
                if(is_hover == 1)then hovered = true end
                    

                GuiOptionsAddForNextWidget( gui, GUI_OPTION.NoSound )
                GuiZSetForNextWidget( gui, -95 )
                if(being_hovered)then
                    GuiColorSetForNextWidget( gui, 1, 1, 0.6862745098, 1 )
                   -- text = ">" .. text 
                    text = "  " .. text
                else
                    text = "  " .. text
                end
                if GuiButton(gui, 0, 2, text, new_id()) then
                    func()
                end

                local _, _2, is_hover = GuiGetPreviousWidgetInfo( gui )
                if(is_hover == 1)then hovered = true end

                offset = GuiGetTextDimensions( gui, text, 1, 2 ) + 2

                for i2 = 1, space_count do
                    if(i2 > 1)then
                        offset = 0
                    end
					GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
					if GuiImageButton(gui, new_id(), -offset-2-(i2 / (space_count * 32)), offset_y, "", "mods/config_lib/files/gfx/tab/tab_unselected_center.png") then
                        func()
                    end
                    local _, _2, is_hover = GuiGetPreviousWidgetInfo( gui )
                    if(is_hover == 1)then hovered = true end
				end
                
				GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
				if GuiImageButton(gui, new_id(), -2, offset_y, "", "mods/config_lib/files/gfx/tab/tab_unselected_right.png") then
                    func()
                end
                local _, _2, is_hover = GuiGetPreviousWidgetInfo( gui )
                if(is_hover == 1)then hovered = true end

                if(hovered)then
                    hover_stats["mods_back_button"] = true
                else
                    hover_stats["mods_back_button"] = false
                end

                --[[
                text = " << "
                offset_y = -3
                func = function()
                    count_to_subtract = mods_to_show
                    if(mod_area < count_to_subtract + 1)then
                        count_to_subtract = mod_area - 1
                    end
                    mod_area = mod_area - count_to_subtract
                end
		
				GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
				--GuiZSetForNextWidget( gui, -50 )
				if GuiImageButton(gui, new_id(), 0, offset_y, "", "mods/config_lib/files/gfx/tab/tab_"..((selected_mod_index == i) and "selected" or "unselected").."_left"..".png") then
                    func()
				end
                GuiZSetForNextWidget( gui, -50 )
                if GuiButton(gui, 0, 2, text, new_id()) then
                    func()
                end
                
                offset = GuiGetTextDimensions( gui, text, 1, 2 ) + 2

                for i2 = 1, space_count do
                    if(i2 > 1)then
                        offset = 0
                    end
					GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
					if GuiImageButton(gui, new_id(), -offset-2-(i2 / (space_count * 32)), offset_y, "", "mods/config_lib/files/gfx/tab/tab_"..((selected_mod_index == i) and "selected" or "unselected").."_center"..".png") then
                        func()
					end
				end

				GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
				if GuiImageButton(gui, new_id(), -2, offset_y, "", "mods/config_lib/files/gfx/tab/tab_"..((selected_mod_index == i) and "selected" or "unselected").."_right"..".png") then
                    func()
                end
                ]]
                
                --[[
                GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
                GuiZSetForNextWidget( gui, -50 )
                if GuiImageButton(gui, new_id(), 0, -3, " << ", "mods/config_lib/files/gfx/tab/tab_unselected_left"..".png") then
                    count_to_subtract = mods_to_show
                    if(mod_area < count_to_subtract + 1)then
                        count_to_subtract = mod_area - 1
                    end
                    mod_area = mod_area - count_to_subtract
                end
                for i2 = 1, space_count do
                    GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
                    if GuiImageButton(gui, new_id(), -2-(i2 / (space_count * 32)), -3, "", "mods/config_lib/files/gfx/tab/tab_unselected_center"..".png") then
                        count_to_subtract = mods_to_show
                        if(mod_area < count_to_subtract + 1)then
                            count_to_subtract = mod_area - 1
                        end
                        mod_area = mod_area - count_to_subtract
                    end
                end

                GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
                if GuiImageButton(gui, new_id(), -2, -3, "", "mods/config_lib/files/gfx/tab/tab_unselected_right"..".png") then
                    count_to_subtract = mods_to_show
                    if(mod_area < count_to_subtract + 1)then
                        count_to_subtract = mod_area - 1
                    end
                    mod_area = mod_area - count_to_subtract
                end
                ]]
                --[[
                if GuiButton(gui, 0, 0, "[<<]", new_id()) then
            
                    count_to_subtract = mods_to_show
                    if(mod_area < count_to_subtract + 1)then
                        count_to_subtract = mod_area - 1
                    end
                    mod_area = mod_area - count_to_subtract
                    
                end
                ]]
            else
                --[[if GuiButton(gui, 0, 0, "[xx]", new_id()) then

                end]]
            end
            --[[
            if(mod_area ~= 1)then
                if GuiButton(gui, 0, 0, "[<]", new_id()) then
                
                    mod_area = mod_area - 1
                end
            else
                if GuiButton(gui, 0, 0, "[x]", new_id()) then

                end
            end
]]
        end

        for i,category in ipairs(gui_options) do

            if(i < mod_area + mods_to_show and i >= mod_area)then
                local parens = (selected_mod_index == i) and { open="[>", close="<]" } or { open="[ ", close=" ]" }
			   
				
                space_count = math.round(#GameTextGetTranslatedOrNot(category.mod_name) / 1.7) + 1
                
                text =  GameTextGetTranslatedOrNot(category.mod_name)
                offset_y = -3
                func = function()
                    selected_mod_index = i
                    selected_category_index = 1
                    selected_page_number = 1

                    GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_click", cam_x, cam_y )
                end
                being_hovered = hover_stats["mods"..category.mod_name..tostring(i)] or false
                was_being_hovered = hover_stats_previous["mods"..category.mod_name..tostring(i)] or false
                local hovered = false

                
                if(being_hovered and not was_being_hovered)then
                   -- GamePrint("pretty neat")
                    GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_select", cam_x, cam_y )
                end
                
                hover_stats_previous["mods"..category.mod_name..tostring(i)] = being_hovered
                
				GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
				--GuiZSetForNextWidget( gui, -50 )
				if GuiImageButton(gui, new_id(), 0, offset_y, "", "mods/config_lib/files/gfx/tab/tab_"..((selected_mod_index == i) and "selected" or (being_hovered == true and "hover" or "unselected")).."_left"..".png") then
                    func()
                end
                local _, _2, is_hover = GuiGetPreviousWidgetInfo( gui )
                if(is_hover == 1)then hovered = true end
                    

                GuiOptionsAddForNextWidget( gui, GUI_OPTION.NoSound )
                GuiZSetForNextWidget( gui, -95 )
                if(being_hovered)then
                    GuiColorSetForNextWidget( gui, 1, 1, 0.6862745098, 1 )
                    text = ">" .. text 
                else
                    text = "  " .. text
                end
                if GuiButton(gui, 0, 2, text, new_id()) then
                    func()
                end

                local _, _2, is_hover = GuiGetPreviousWidgetInfo( gui )
                if(is_hover == 1)then hovered = true end

                offset = GuiGetTextDimensions( gui, text, 1, 2 ) + 2

                for i2 = 1, space_count do
                    if(i2 > 1)then
                        offset = 0
                    end
					GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
					if GuiImageButton(gui, new_id(), -offset-2-(i2 / (space_count * 32)), offset_y, "", "mods/config_lib/files/gfx/tab/tab_"..((selected_mod_index == i) and "selected" or (being_hovered == true and "hover" or "unselected")).."_center"..".png") then
                        func()
                    end
                    local _, _2, is_hover = GuiGetPreviousWidgetInfo( gui )
                    if(is_hover == 1)then hovered = true end
				end
                
				GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
				if GuiImageButton(gui, new_id(), -2, offset_y, "", "mods/config_lib/files/gfx/tab/tab_"..((selected_mod_index == i) and "selected" or (being_hovered == true and "hover" or "unselected")).."_right"..".png") then
                    func()
                end
                local _, _2, is_hover = GuiGetPreviousWidgetInfo( gui )
                if(is_hover == 1)then hovered = true end

                if(hovered)then
                    hover_stats["mods"..category.mod_name..tostring(i)] = true
                else
                    hover_stats["mods"..category.mod_name..tostring(i)] = false
                end
				
            end

		end

        if(#gui_options > mods_to_show)then
            --[[
            if(#gui_options > mods_to_show and mods_to_show + mod_area <= #gui_options)then
                if GuiButton(gui, 0, 0, "[>]", new_id()) then
                    mod_area = mod_area + 1
                end
            else
                if GuiButton(gui, 0, 0, "[x]", new_id()) then

                end
            end
            ]]

            
            if(#gui_options > mods_to_show and mods_to_show + mod_area <= #gui_options)then
                
                space_count = 3

                text = ">> "
                offset_y = -3
                func = function()
                    count_to_add = mods_to_show

                    if((mod_area + (count_to_add * 2)) > #gui_options)then
                        count_to_add = #gui_options - (mod_area + (count_to_add - 1))
                    end
                    mod_area = mod_area + count_to_add

                    GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_click", cam_x, cam_y )
                end
                being_hovered = hover_stats["mods_back_button"] or false
                was_being_hovered = hover_stats_previous["mods_back_button"] or false
                local hovered = false

                
                if(being_hovered and not was_being_hovered)then
                   -- GamePrint("pretty neat")
                    GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_select", cam_x, cam_y )
                end
                
                hover_stats_previous["mods_back_button"] = being_hovered
                
				GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
				--GuiZSetForNextWidget( gui, -50 )
				if GuiImageButton(gui, new_id(), 0, offset_y, "", "mods/config_lib/files/gfx/tab/tab_"..(being_hovered == true and "hover" or "unselected").."_left.png") then
                    func()
                end
                local _, _2, is_hover = GuiGetPreviousWidgetInfo( gui )
                if(is_hover == 1)then hovered = true end
                    

                GuiOptionsAddForNextWidget( gui, GUI_OPTION.NoSound )
                GuiZSetForNextWidget( gui, -95 )
                if(being_hovered)then
                    GuiColorSetForNextWidget( gui, 1, 1, 0.6862745098, 1 )
                   -- text = ">" .. text 
                    text = "  " .. text
                else
                    text = "  " .. text
                end
                if GuiButton(gui, 0, 2, text, new_id()) then
                    func()
                end

                local _, _2, is_hover = GuiGetPreviousWidgetInfo( gui )
                if(is_hover == 1)then hovered = true end

                offset = GuiGetTextDimensions( gui, text, 1, 2 ) + 2

                for i2 = 1, space_count do
                    if(i2 > 1)then
                        offset = 0
                    end
					GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
					if GuiImageButton(gui, new_id(), -offset-2-(i2 / (space_count * 32)), offset_y, "", "mods/config_lib/files/gfx/tab/tab_"..(being_hovered == true and "hover" or "unselected").."_center.png") then
                        func()
                    end
                    local _, _2, is_hover = GuiGetPreviousWidgetInfo( gui )
                    if(is_hover == 1)then hovered = true end
				end
                
				GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
				if GuiImageButton(gui, new_id(), -2, offset_y, "", "mods/config_lib/files/gfx/tab/tab_"..(being_hovered == true and "hover" or "unselected").."_right.png") then
                    func()
                end
                local _, _2, is_hover = GuiGetPreviousWidgetInfo( gui )
                if(is_hover == 1)then hovered = true end

                if(hovered)then
                    hover_stats["mods_back_button"] = true
                else
                    hover_stats["mods_back_button"] = false
                end

                --[[
                space_count = 2

                text = " >> "
                offset_y = -3
                func = function()
                    count_to_add = mods_to_show

                    if((mod_area + (count_to_add * 2)) > #gui_options)then
                        count_to_add = #gui_options - (mod_area + (count_to_add - 1))
                    end
                    mod_area = mod_area + count_to_add
                end
		
				GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
				--GuiZSetForNextWidget( gui, -50 )
				if GuiImageButton(gui, new_id(), 0, offset_y, "", "mods/config_lib/files/gfx/tab/tab_"..((selected_mod_index == i) and "selected" or "unselected").."_left"..".png") then
                    func()
				end
                GuiZSetForNextWidget( gui, -50 )
                if GuiButton(gui, 0, 2, text, new_id()) then
                    func()
                end
                
                offset = GuiGetTextDimensions( gui, text, 1, 2 ) + 2

                for i2 = 1, space_count do
                    if(i2 > 1)then
                        offset = 0
                    end
					GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
					if GuiImageButton(gui, new_id(), -offset-2-(i2 / (space_count * 32)), offset_y, "", "mods/config_lib/files/gfx/tab/tab_"..((selected_mod_index == i) and "selected" or "unselected").."_center"..".png") then
                        func()
					end
				end

				GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
				if GuiImageButton(gui, new_id(), -2, offset_y, "", "mods/config_lib/files/gfx/tab/tab_"..((selected_mod_index == i) and "selected" or "unselected").."_right"..".png") then
                    func()
                end
                
                ]]
                --[[
                GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
                GuiZSetForNextWidget( gui, -50 )
                if GuiImageButton(gui, new_id(), 0, -3, " >> ", "mods/config_lib/files/gfx/tab/tab_unselected_left"..".png") then
                    count_to_add = mods_to_show

                    if((mod_area + (count_to_add * 2)) > #gui_options)then
                        count_to_add = #gui_options - (mod_area + (count_to_add - 1))
                    end
                    mod_area = mod_area + count_to_add
                end
                for i2 = 1, space_count do
                    GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
                    if GuiImageButton(gui, new_id(), -2-(i2 / (space_count * 32)), -3, "", "mods/config_lib/files/gfx/tab/tab_unselected_center"..".png") then
                        count_to_add = mods_to_show

                        if((mod_area + (count_to_add * 2)) > #gui_options)then
                            count_to_add = #gui_options - (mod_area + (count_to_add - 1))
                        end
                        mod_area = mod_area + count_to_add
                    end
                end

                GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
                if GuiImageButton(gui, new_id(), -2, -3, "", "mods/config_lib/files/gfx/tab/tab_unselected_right"..".png") then
                    count_to_add = mods_to_show

                    if((mod_area + (count_to_add * 2)) > #gui_options)then
                        count_to_add = #gui_options - (mod_area + (count_to_add - 1))
                    end
                    mod_area = mod_area + count_to_add
                end
                ]]

               --[[ if GuiButton(gui, 0, 0, "[>>]", new_id()) then
                

                    count_to_add = mods_to_show

                    if((mod_area + (count_to_add * 2)) > #gui_options)then
                        count_to_add = #gui_options - (mod_area + (count_to_add - 1))
                    end
                    mod_area = mod_area + count_to_add

                end]]
            else
               --[[ if GuiButton(gui, 0, 0, "[xx]", new_id()) then

                end]]
            end

        end
    
        GuiLayoutEnd(gui)       

		GuiBeginAutoBox( gui )
        GuiLayoutBeginHorizontal(gui, 2, 0)

        --print(dump(gui_options[selected_mod_index].categories))
        if(#gui_options[selected_mod_index].categories > 0)then

            --GuiText(gui, 0, 0, GameTextGetTranslatedOrNot("$config_lib_category")..": ")
            if(#gui_options[selected_mod_index].categories > categories_to_show)then
                if(category_area ~= 1)then
                   
                    space_count = 3

                    text = "<< "
                    offset_y = 1
                    func = function()
                        count_to_subtract = categories_to_show
                        if(category_area < count_to_subtract + 1)then
                            count_to_subtract = category_area - 1
                        end
                        category_area = category_area - count_to_subtract
    
                        GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_click", cam_x, cam_y )
                    end
                    being_hovered = hover_stats["categories_back_button"] or false
                    was_being_hovered = hover_stats_previous["categories_back_button"] or false
                    local hovered = false
    
                    
                    if(being_hovered and not was_being_hovered)then
                       -- GamePrint("pretty neat")
                        GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_select", cam_x, cam_y )
                    end
                    
                    hover_stats_previous["categories_back_button"] = being_hovered
                    
                    GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
                    --GuiZSetForNextWidget( gui, -50 )
                    if GuiImageButton(gui, new_id(), 0, offset_y, "", "mods/config_lib/files/gfx/tab/tab_"..(being_hovered == true and "hover" or "unselected").."_left.png") then
                        func()
                    end
                    local _, _2, is_hover = GuiGetPreviousWidgetInfo( gui )
                    if(is_hover == 1)then hovered = true end
                        
    
                    GuiOptionsAddForNextWidget( gui, GUI_OPTION.NoSound )
                    GuiZSetForNextWidget( gui, -95 )
                    if(being_hovered)then
                        GuiColorSetForNextWidget( gui, 1, 1, 0.6862745098, 1 )
                       -- text = ">" .. text 
                        text = "  " .. text
                    else
                        text = "  " .. text
                    end
                    if GuiButton(gui, 0, 6, text, new_id()) then
                        func()
                    end
    
                    local _, _2, is_hover = GuiGetPreviousWidgetInfo( gui )
                    if(is_hover == 1)then hovered = true end
    
                    offset = GuiGetTextDimensions( gui, text, 1, 2 ) + 2
    
                    for i2 = 1, space_count do
                        if(i2 > 1)then
                            offset = 0
                        end
                        GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
                        if GuiImageButton(gui, new_id(), -offset-2-(i2 / (space_count * 32)), offset_y, "", "mods/config_lib/files/gfx/tab/tab_"..(being_hovered == true and "hover" or "unselected").."_center.png") then
                            func()
                        end
                        local _, _2, is_hover = GuiGetPreviousWidgetInfo( gui )
                        if(is_hover == 1)then hovered = true end
                    end
                    
                    GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
                    if GuiImageButton(gui, new_id(), -2, offset_y, "", "mods/config_lib/files/gfx/tab/tab_"..(being_hovered == true and "hover" or "unselected").."_right.png") then
                        func()
                    end
                    local _, _2, is_hover = GuiGetPreviousWidgetInfo( gui )
                    if(is_hover == 1)then hovered = true end
    
                    if(hovered)then
                        hover_stats["categories_back_button"] = true
                    else
                        hover_stats["categories_back_button"] = false
                    end

                   --[[ space_count = 2

					
					GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
					GuiZSetForNextWidget( gui, -50 )
					if GuiImageButton(gui, new_id(), 0, 1, " << ", "mods/config_lib/files/gfx/tab/tab_unselected_left"..".png") then
                        count_to_subtract = categories_to_show
                        if(category_area < count_to_subtract + 1)then
                            count_to_subtract = category_area - 1
                        end
                        category_area = category_area - count_to_subtract
					end
					for i2 = 1, space_count do
						GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
						if GuiImageButton(gui, new_id(), -2-(i2 / (space_count * 32)), 1, "", "mods/config_lib/files/gfx/tab/tab_unselected_center"..".png") then
                            count_to_subtract = categories_to_show
                            if(category_area < count_to_subtract + 1)then
                                count_to_subtract = category_area - 1
                            end
                            category_area = category_area - count_to_subtract
						end
					end

					GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
					if GuiImageButton(gui, new_id(), -2, 1, "", "mods/config_lib/files/gfx/tab/tab_unselected_right"..".png") then
                        count_to_subtract = categories_to_show
                        if(category_area < count_to_subtract + 1)then
                            count_to_subtract = category_area - 1
                        end
                        category_area = category_area - count_to_subtract
                    end
                    ]]
                    
                    --[[if GuiButton(gui, 0, 0, "[<<]", new_id()) then
                
                        count_to_subtract = categories_to_show
                        if(category_area < count_to_subtract + 1)then
                            count_to_subtract = category_area - 1
                        end
                        category_area = category_area - count_to_subtract
                        
                    end]]
                else

                    --[[if GuiButton(gui, 0, 0, "[xx]", new_id()) then

                    end]]
                end
                --[[
                if(category_area ~= 1)then
                    if GuiButton(gui, 0, 0, "[<]", new_id()) then
                    
                        category_area = category_area - 1
                    end
                else
                    if GuiButton(gui, 0, 0, "[x]", new_id()) then

                    end
                end
                ]]

            end

            for i,category in ipairs(gui_options[selected_mod_index].categories) do

                if(i < category_area + categories_to_show and i >= category_area)then
                    local parens = (selected_category_index == i) and { open="[>", close="<]" } or { open="[ ", close=" ]" }
					--GuiLayoutBeginHorizontal(gui, 0, 0)
					--[[
					if GuiImageButton(gui, new_id(), 0, 2, "", "mods/config_lib/files/gfx/tab_".."selected"..".png") then
                        selected_category_index = i
                        selected_page_number = 1
					end
                    ]]
                    
                    space_count = math.round(#GameTextGetTranslatedOrNot(category.category) / 1.7) + 1
                
                    text =  GameTextGetTranslatedOrNot(category.category)
                    offset_y = 1
                    func = function()
                        selected_category_index = i
                        selected_page_number = 1
    
                        GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_click", cam_x, cam_y )
                    end
                    being_hovered = hover_stats["categories"..category.category..tostring(i)] or false
                    was_being_hovered = hover_stats_previous["categories"..category.category..tostring(i)] or false
                    local hovered = false
    
                    
                    if(being_hovered and not was_being_hovered)then
                       -- GamePrint("pretty neat")
                        GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_select", cam_x, cam_y )
                    end
                    
                    hover_stats_previous["categories"..category.category..tostring(i)] = being_hovered
                    
                    GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
                    --GuiZSetForNextWidget( gui, -50 )
                    if GuiImageButton(gui, new_id(), 0, offset_y, "", "mods/config_lib/files/gfx/tab/tab_"..((selected_category_index == i) and "selected" or (being_hovered == true and "hover" or "unselected")).."_left"..".png") then
                        func()
                    end
                    local _, _2, is_hover = GuiGetPreviousWidgetInfo( gui )
                    if(is_hover == 1)then hovered = true end
                        
    
                    GuiOptionsAddForNextWidget( gui, GUI_OPTION.NoSound )
                    GuiZSetForNextWidget( gui, -95 )
                    if(being_hovered)then
                        GuiColorSetForNextWidget( gui, 1, 1, 0.6862745098, 1 )
                        text = ">" .. text 
                    else
                        text = "  " .. text
                    end
                    if GuiButton(gui, 0, 6, text, new_id()) then
                        func()
                    end
    
                    local _, _2, is_hover = GuiGetPreviousWidgetInfo( gui )
                    if(is_hover == 1)then hovered = true end
    
                    offset = GuiGetTextDimensions( gui, text, 1, 2 ) + 2
    
                    for i2 = 1, space_count do
                        if(i2 > 1)then
                            offset = 0
                        end
                        GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
                        if GuiImageButton(gui, new_id(), -offset-2-(i2 / (space_count * 32)), offset_y, "", "mods/config_lib/files/gfx/tab/tab_"..((selected_category_index == i) and "selected" or (being_hovered == true and "hover" or "unselected")).."_center"..".png") then
                            func()
                        end
                        local _, _2, is_hover = GuiGetPreviousWidgetInfo( gui )
                        if(is_hover == 1)then hovered = true end
                    end
                    
                    GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
                    if GuiImageButton(gui, new_id(), -2, offset_y, "", "mods/config_lib/files/gfx/tab/tab_"..((selected_category_index == i) and "selected" or (being_hovered == true and "hover" or "unselected")).."_right"..".png") then
                        func()
                    end
                    local _, _2, is_hover = GuiGetPreviousWidgetInfo( gui )
                    if(is_hover == 1)then hovered = true end
    
                    if(hovered)then
                        hover_stats["categories"..category.category..tostring(i)] = true
                    else
                        hover_stats["categories"..category.category..tostring(i)] = false
                    end

                    --[[
					space_count = math.round(#GameTextGetTranslatedOrNot(category.category) / 2) 

					
					GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
					GuiZSetForNextWidget( gui, -50 )
					if GuiImageButton(gui, new_id(), 0, 1, GameTextGetTranslatedOrNot(category.category), "mods/config_lib/files/gfx/tab/tab_"..((selected_category_index == i) and "selected" or "unselected").."_left"..".png") then
                        selected_category_index = i
                        selected_page_number = 1
					end
					for i2 = 1, space_count do
						GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
						if GuiImageButton(gui, new_id(), -2-(i2 / (space_count * 32)), 1, "", "mods/config_lib/files/gfx/tab/tab_"..((selected_category_index == i) and "selected" or "unselected").."_center"..".png") then
							selected_category_index = i
							selected_page_number = 1
						end
					end

					GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
					if GuiImageButton(gui, new_id(), -2, 1, "", "mods/config_lib/files/gfx/tab/tab_"..((selected_category_index == i) and "selected" or "unselected").."_right"..".png") then
                        selected_category_index = i
                        selected_page_number = 1
                    end
                    ]]

                end

            end

            if(#gui_options[selected_mod_index].categories > categories_to_show)then

                --[[
                if(#gui_options[selected_mod_index].categories > categories_to_show and categories_to_show + category_area <= #gui_options[selected_mod_index].categories)then
                    if GuiButton(gui, 0, 0, "[>]", new_id()) then
                        category_area = category_area + 1
                    end
                else
                    if GuiButton(gui, 0, 0, "[x]", new_id()) then

                    end
                end
                ]]

                
                if(#gui_options[selected_mod_index].categories > categories_to_show and categories_to_show + category_area <= #gui_options[selected_mod_index].categories)then
                    
                    space_count = 3

                    text = ">> "
                    offset_y = 1
                    func = function()
                        count_to_add = categories_to_show

                        if((category_area + (count_to_add * 2)) > #gui_options[selected_mod_index].categories)then
                            count_to_add = #gui_options[selected_mod_index].categories - (category_area + (count_to_add - 1))
                        end
                        category_area = category_area + count_to_add
    
                        GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_click", cam_x, cam_y )
                    end
                    being_hovered = hover_stats["categories_forward_button"] or false
                    was_being_hovered = hover_stats_previous["categories_forward_button"] or false
                    local hovered = false
    
                    
                    if(being_hovered and not was_being_hovered)then
                       -- GamePrint("pretty neat")
                        GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_select", cam_x, cam_y )
                    end
                    
                    hover_stats_previous["categories_forward_button"] = being_hovered
                    
                    GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
                    --GuiZSetForNextWidget( gui, -50 )
                    if GuiImageButton(gui, new_id(), 0, offset_y, "", "mods/config_lib/files/gfx/tab/tab_"..(being_hovered == true and "hover" or "unselected").."_left.png") then
                        func()
                    end
                    local _, _2, is_hover = GuiGetPreviousWidgetInfo( gui )
                    if(is_hover == 1)then hovered = true end
                        
    
                    GuiOptionsAddForNextWidget( gui, GUI_OPTION.NoSound )
                    GuiZSetForNextWidget( gui, -95 )
                    if(being_hovered)then
                        GuiColorSetForNextWidget( gui, 1, 1, 0.6862745098, 1 )
                       -- text = ">" .. text 
                        text = "  " .. text
                    else
                        text = "  " .. text
                    end
                    if GuiButton(gui, 0, 6, text, new_id()) then
                        func()
                    end
    
                    local _, _2, is_hover = GuiGetPreviousWidgetInfo( gui )
                    if(is_hover == 1)then hovered = true end
    
                    offset = GuiGetTextDimensions( gui, text, 1, 2 ) + 2
    
                    for i2 = 1, space_count do
                        if(i2 > 1)then
                            offset = 0
                        end
                        GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
                        if GuiImageButton(gui, new_id(), -offset-2-(i2 / (space_count * 32)), offset_y, "", "mods/config_lib/files/gfx/tab/tab_"..(being_hovered == true and "hover" or "unselected").."_center.png") then
                            func()
                        end
                        local _, _2, is_hover = GuiGetPreviousWidgetInfo( gui )
                        if(is_hover == 1)then hovered = true end
                    end
                    
                    GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
                    if GuiImageButton(gui, new_id(), -2, offset_y, "", "mods/config_lib/files/gfx/tab/tab_"..(being_hovered == true and "hover" or "unselected").."_right.png") then
                        func()
                    end
                    local _, _2, is_hover = GuiGetPreviousWidgetInfo( gui )
                    if(is_hover == 1)then hovered = true end
    
                    if(hovered)then
                        hover_stats["categories_forward_button"] = true
                    else
                        hover_stats["categories_forward_button"] = false
                    end

                    --[[space_count = 2

					
					GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
					GuiZSetForNextWidget( gui, -50 )
					if GuiImageButton(gui, new_id(), 0, 1, " >> ", "mods/config_lib/files/gfx/tab/tab_unselected_left"..".png") then
                        count_to_add = categories_to_show

                        if((category_area + (count_to_add * 2)) > #gui_options[selected_mod_index].categories)then
                            count_to_add = #gui_options[selected_mod_index].categories - (category_area + (count_to_add - 1))
                        end
                        category_area = category_area + count_to_add
					end
					for i2 = 1, space_count do
						GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
						if GuiImageButton(gui, new_id(), -2-(i2 / (space_count * 32)), 1, "", "mods/config_lib/files/gfx/tab/tab_unselected_center"..".png") then
                            count_to_add = categories_to_show

                            if((category_area + (count_to_add * 2)) > #gui_options[selected_mod_index].categories)then
                                count_to_add = #gui_options[selected_mod_index].categories - (category_area + (count_to_add - 1))
                            end
                            category_area = category_area + count_to_add
						end
					end

					GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
					if GuiImageButton(gui, new_id(), -2, 1, "", "mods/config_lib/files/gfx/tab/tab_unselected_right"..".png") then
                        count_to_add = categories_to_show

                        if((category_area + (count_to_add * 2)) > #gui_options[selected_mod_index].categories)then
                            count_to_add = #gui_options[selected_mod_index].categories - (category_area + (count_to_add - 1))
                        end
                        category_area = category_area + count_to_add
                    end
                    ]]
                    
                    --[[if GuiButton(gui, 0, 0, "[>>]", new_id()) then
                    

                        count_to_add = categories_to_show

                        if((category_area + (count_to_add * 2)) > #gui_options[selected_mod_index].categories)then
                            count_to_add = #gui_options[selected_mod_index].categories - (category_area + (count_to_add - 1))
                        end
                        category_area = category_area + count_to_add

                    end]]
                else
                    --[[if GuiButton(gui, 0, 0, "[xx]", new_id()) then

                    end]]
                end

            end

        else    
            GuiText(gui, 0, 0, GameTextGetTranslatedOrNot("$config_lib_no_options"))
        end
        GuiLayoutEnd(gui)

        if(#(gui_options[selected_mod_index].categories) > 0)then

            items_per_page = default_items_per_page
            items_per_row = default_items_per_row

            if(gui_options[selected_mod_index].categories[selected_category_index].items_per_page)then
                items_per_page = gui_options[selected_mod_index].categories[selected_category_index].items_per_page
            end

            if(gui_options[selected_mod_index].categories[selected_category_index].items_per_row)then
                items_per_row = gui_options[selected_mod_index].categories[selected_category_index].items_per_row
            end

            local horizontal_gap = 14

            if(gui_options[selected_mod_index].categories[selected_category_index].horizontal_gap)then
                horizontal_gap = gui_options[selected_mod_index].categories[selected_category_index].horizontal_gap
            end

            local offset = -horizontal_gap



           -- local page_count = math.ceil(#gui_options[selected_mod_index].categories[selected_category_index].items / items_per_page)
			
		   --[[
            GuiLayoutBeginHorizontal(gui, 0, 0)

            if page_count > 1 then

                GuiText(gui, 0, 0, "Page: ")
                if(page_count > page_numbers_to_show)then
                    if(page_number_area ~= 1)then
                        if GuiButton(gui, 0, 0, "[<<]", new_id()) then
                    
                            count_to_subtract = page_numbers_to_show
                            if(page_number_area < count_to_subtract + 1)then
                                count_to_subtract = page_number_area - 1
                            end
                            page_number_area = page_number_area - count_to_subtract
                            
                        end
                    else
                        if GuiButton(gui, 0, 0, "[xx]", new_id()) then

                        end
                    end
                    if(page_number_area ~= 1)then
                        if GuiButton(gui, 0, 0, "[<]", new_id()) then
                        
                            page_number_area = page_number_area - 1
                        end
                    else
                        if GuiButton(gui, 0, 0, "[x]", new_id()) then

                        end
                    end
                end

                for i=1,page_count do

                    if(i < page_number_area + page_numbers_to_show and i >= page_number_area)then
                        local parens = (selected_page_number == i) and { open="[>", close="<]" } or { open="[ ", close=" ]" }
                        if GuiButton(gui, 0, 0, parens.open..i..parens.close, new_id()) then
                            selected_page_number = i
                        end
                    end

                end

                if(page_count > page_numbers_to_show)then

                    if(page_count > page_numbers_to_show and page_numbers_to_show + page_number_area <= page_count)then
                        if GuiButton(gui, 0, 0, "[>]", new_id()) then
                            page_number_area = page_number_area + 1
                        end
                    else
                        if GuiButton(gui, 0, 0, "[x]", new_id()) then

                        end
                    end

                    
                    if(page_count > page_numbers_to_show and page_numbers_to_show + page_number_area <= page_count)then
                        if GuiButton(gui, 0, 0, "[>>]", new_id()) then
                        

                            count_to_add = page_numbers_to_show

                            if((page_number_area + (count_to_add * 2)) > page_count)then
                                count_to_add = page_count - (page_number_area + (count_to_add - 1))
                            end
                            page_number_area = page_number_area + count_to_add

                        end
                    else
                        if GuiButton(gui, 0, 0, "[xx]", new_id()) then

                        end
                    end

                end

            end
            GuiLayoutEnd(gui)       

			]]

			container_w = sx / 100 * 85
			container_h = sy / 100 * 60

            GuiLayoutBeginVertical(gui, 0, 0)
            GuiZSetForNextWidget( gui, -92 )


            local scroll_id = tonumber( tostring( tostring(selected_mod_index) .. tostring(selected_category_index)))
            GuiBeginScrollContainer( gui, scroll_id, 0, 0, container_w, container_h, true, 5, 5 )

            GuiLayoutBeginHorizontal(gui, 2, 2)
		   -- GuiLayoutBeginVertical(gui, 0, 0)
		   
		    offset = offset + horizontal_gap
		    GuiLayoutBeginVertical(gui, offset, 0)

            if(#gui_options[selected_mod_index].categories[selected_category_index].items > 0)then
                for i, item in ipairs(gui_options[selected_mod_index].categories[selected_category_index].items)do
                    local item = gui_options[selected_mod_index].categories[selected_category_index].items[i]

                    local checked = false
                    if(item.type == "toggle")then
                        checked = HasSettingFlag(get_flag(gui_options[selected_mod_index].mod_id, gui_options[selected_mod_index].categories[selected_category_index].category_id, item.flag))
                    end

					--[[
                    if ((i-1) % gui_options[selected_mod_index].categories[selected_category_index].items_per_page) % gui_options[selected_mod_index].categories[selected_category_index].items_per_row == 0 then
                        -- End the current column and start a new one
                        GuiLayoutEnd(gui)
                        offset = offset + horizontal_gap
                        GuiLayoutBeginVertical(gui, offset, 0)
					end
					
					]]

                    local allow_show = false

                    if(item.required_flag ~= nil)then
                        if(item.required_flag ~= "")then
                            if(HasSettingFlag(get_flag(gui_options[selected_mod_index].mod_id, gui_options[selected_mod_index].categories[selected_category_index].category_id, item.required_flag)) or HasSettingFlag(item.required_flag) or HasFlagPersistent(get_flag(gui_options[selected_mod_index].mod_id, gui_options[selected_mod_index].categories[selected_category_index].category_id, item.required_flag)) or HasFlagPersistent(item.required_flag) or GameHasFlagRun(get_flag(gui_options[selected_mod_index].mod_id, gui_options[selected_mod_index].categories[selected_category_index].category_id, item.required_flag)) or GameHasFlagRun(item.required_flag))then
                                allow_show = true
                            end
                        else
                            allow_show = true
                        end
                    else
                        allow_show = true
                    end

                    GuiZSet( gui, -100 )
                    if(allow_show)then
                        if(item.type  == "toggle")then
                            GuiLayoutBeginHorizontal(gui, 0, 0)
                            
                            if (GuiImageButton( gui, new_id(), 0, 1, "", "mods/config_lib/files/gfx/checkbox" .. (checked == true and "_fill" or "") .. ".png" )) then
                               -- print(get_flag(gui_options[selected_mod_index].mod_id, gui_options[selected_mod_index].categories[selected_category_index].category_id, item.flag))
                                if checked then
                                    RemoveSettingFlag(get_flag(gui_options[selected_mod_index].mod_id, gui_options[selected_mod_index].categories[selected_category_index].category_id, item.flag))
                                    if(item.callback ~= nil)then
                                        item.callback(item, false)
                                    end
                                    if(item.requires_restart)then
                                        GameAddFlagRun( flag_prefix.."_config_changed" )
                                    end
                                    checked = false
                                else
                                    AddSettingFlag(get_flag(gui_options[selected_mod_index].mod_id, gui_options[selected_mod_index].categories[selected_category_index].category_id, item.flag))
                                    if(item.callback ~= nil)then
                                        item.callback(item, true)
                                    end
                                    if(item.requires_restart)then
                                        GameAddFlagRun( flag_prefix.."_config_changed" )
                                    end 
                                    checked = true
                                end
                            end
                            if (GuiButton(gui, 0, 0, GameTextGetTranslatedOrNot(item.name), new_id()))then
                             --   print(get_flag(gui_options[selected_mod_index].mod_id, gui_options[selected_mod_index].categories[selected_category_index].category_id, item.flag))
                                if checked then
                                    RemoveSettingFlag(get_flag(gui_options[selected_mod_index].mod_id, gui_options[selected_mod_index].categories[selected_category_index].category_id, item.flag))
                                    if(item.callback ~= nil)then
                                        item.callback(item, false)
                                    end
                                    if(item.requires_restart)then
                                        GameAddFlagRun( flag_prefix.."_config_changed" )
                                    end
                                    checked = false
                                else
                                    AddSettingFlag(get_flag(gui_options[selected_mod_index].mod_id, gui_options[selected_mod_index].categories[selected_category_index].category_id, item.flag))
                                    if(item.callback ~= nil)then
                                        item.callback(item, true)
                                    end
                                    if(item.requires_restart)then
                                        GameAddFlagRun( flag_prefix.."_config_changed" )
                                    end 
                                    checked = true
                                end
                            end
                            GuiLayoutEnd(gui)
                            if(item.description ~= nil)then
                                if(GameTextGetTranslatedOrNot(item.description) ~= "")then
                                    GuiTooltip( gui, "", GameTextGetTranslatedOrNot(item.description) )
                                end
                            end
                        elseif(item.type == "button")then
                            if GuiButton(gui, 0, 0, GameTextGetTranslatedOrNot(item.name), new_id()) then
                                item.callback(item)
                            end
                            if(item.description ~= nil)then
                                if(GameTextGetTranslatedOrNot(item.description) ~= "")then
                                    GuiTooltip( gui, "", GameTextGetTranslatedOrNot(item.description) )
                                end
                            end
                        elseif(item.type == "enum")then
                            local value = item.current_key

                            local text = item.name .. ": " .. item.values[value][2]

                            item.old_key = item.current_key

                            local clicked,right_clicked = GuiButton( gui, new_id(), 0, 0, text )

                            if clicked then
                                value = value + 1
                                if value > #(item.values) then
                                    value = 1
                                end

                                item.current_key = value
                            end

                            --[[
                            if GuiButton(gui, 0, 0, GameTextGetTranslatedOrNot(item.name), new_id()) then
                                item.callback(item)
                            end
                            ]]
                            if(item.description ~= nil)then
                                if(GameTextGetTranslatedOrNot(item.description) ~= "")then
                                    GuiTooltip( gui, "", GameTextGetTranslatedOrNot(item.description) )
                                end
                            end
                        elseif(item.type == "slider")then

                            GuiLayoutBeginHorizontal(gui, 0, 0)

                            longest_name_length = 0

                            for k, checked_item in pairs(gui_options[selected_mod_index].categories[selected_category_index].items)do
                                if(checked_item.type == "slider" or checked_item.type == "input")then
                                    curr_width = GuiGetTextDimensions(gui, GameTextGetTranslatedOrNot(checked_item.name), 1, 2)
                                    if( curr_width > longest_name_length)then
                                        longest_name_length = curr_width
                                    end
                                end
                            end
                            curr_width = GuiGetTextDimensions(gui, GameTextGetTranslatedOrNot(item.name), 1, 2)
                            offset_size = longest_name_length - curr_width + 20

                            GuiText(gui, 0, 0.4, GameTextGetTranslatedOrNot(item.name))
                            if(item.description ~= nil)then
                                if(GameTextGetTranslatedOrNot(item.description) ~= "")then
                                    GuiTooltip( gui, "", GameTextGetTranslatedOrNot(item.description) )
                                end
                            end



                            item.old_number = item.current_number
                            local new_number = math.round(GuiSlider( gui, new_id(), offset_size, 1, "", item.current_number, item.min_number, item.max_number, item.current_number, 1, " ", 160 ))

                            if(item.old_number ~= new_number)then
                                if(item.requires_restart)then
                                    if(not GameHasFlagRun( flag_prefix.."_config_changed" ))then
                                        GameAddFlagRun( flag_prefix.."_config_changed" )
                                    end
                                end 
                                item.previous_number = item.current_number
                                item.current_number = new_number
                            end

                            GuiText(gui, 0, 0, " "..string.gsub( item.format, "$0", tostring(item.current_number)))
                            if(item.description ~= nil)then
                                if(GameTextGetTranslatedOrNot(item.description) ~= "")then
                                    GuiTooltip( gui, "", GameTextGetTranslatedOrNot(item.description) )
                                end
                            end
                            GuiLayoutEnd(gui)

                        elseif(item.type == "input")then

                            longest_name_length = 0

                            for k, checked_item in pairs(gui_options[selected_mod_index].categories[selected_category_index].items)do
                                if(checked_item.type == "slider" or checked_item.type == "input")then
                                    curr_width = GuiGetTextDimensions(gui, GameTextGetTranslatedOrNot(checked_item.name), 1, 2)
                                    if( curr_width > longest_name_length)then
                                        longest_name_length = curr_width
                                    end
                                end
                            end
                            curr_width = GuiGetTextDimensions(gui, GameTextGetTranslatedOrNot(item.name), 1, 2)
                            offset_size = longest_name_length - curr_width + 20

                            GuiLayoutBeginHorizontal(gui, 0, 0)
                            GuiText(gui, 0, 0.4, GameTextGetTranslatedOrNot(item.name))
                            if(item.description ~= nil)then
                                if(GameTextGetTranslatedOrNot(item.description) ~= "")then
                                    GuiTooltip( gui, "", GameTextGetTranslatedOrNot(item.description) )
                                end
                            end

                            item.old_text = item.current_text

                            local text = GuiTextInput( gui, new_id(), offset_size, 0, item.current_text, item.text_max_length * 4, item.text_max_length, item.allowed_chars )
                            if(item.description ~= nil)then
                                if(GameTextGetTranslatedOrNot(item.description) ~= "")then
                                    GuiTooltip( gui, "", GameTextGetTranslatedOrNot(item.description) )
                                end
                            end

                            if(item.old_text ~= text)then
                                if(item.requires_restart)then
                                    if(not GameHasFlagRun( flag_prefix.."_config_changed" ))then
                                        GameAddFlagRun( flag_prefix.."_config_changed" )
                                    end
                                end 
                                item.previous_text = item.current_text
                                item.current_text = text
                            end


                            GuiLayoutEnd(gui)

                        elseif(item.type == "text")then
                            if(item.name ~= nil)then
                                function hex2argb(hex)
                                    local n = tonumber(hex, 16)
                                    return bit.band(bit.rshift(n, 24), 0xFF)/255, bit.band(bit.rshift(n, 16), 0xFF)/255, bit.band(bit.rshift(n, 8), 0xFF)/255, bit.band(n, 0xFF)/255
                                end

                                if item.color ~= nil then
                                    local a, r, g, b = hex2argb(item.color)

                                    if(r ~= nil and g ~= nil and b ~= nil and a ~= nil)then
                                        GuiColorSetForNextWidget(gui, r, g, b, a)
                                    end
                                end

                                GuiText(gui, item.offset_x, item.offset_y, GameTextGetTranslatedOrNot(item.name))
                                if(item.description ~= nil)then
                                    if(GameTextGetTranslatedOrNot(item.description) ~= "")then
                                        GuiTooltip( gui, "", GameTextGetTranslatedOrNot(item.description) )
                                    end
                                end
                            end
                        elseif(item.type == "spacer")then
                            GuiText(gui, 0, 0, "  ")
                        end
                    end
                end
                -- okay
            else
                GuiText(gui, 0, 0, GameTextGetTranslatedOrNot("$config_lib_no_options_category"))
            end
            GuiText(gui, 0, 0, "  ")
            GuiLayoutEnd(gui)

            GuiOptionsAddForNextWidget( gui, GUI_OPTION.NoSound )
            GuiEndScrollContainer( gui )
                
            --GuiLayoutBeginHorizontal(gui, 5, 92)

            if(GameHasFlagRun( flag_prefix.."_config_changed" ))then
            --  GuiBeginAutoBox(gui)
            GuiZSetForNextWidget( gui, -400 )
            GuiText(gui, 0, 5, "New game required!")
            --GuiZSetForNextWidget( gui, -100 )
            --GuiEndAutoBoxNinePiece( gui, 5, 0, 0, false, 0, "mods/config_lib/files/gfx/background.png", "mods/config_lib/files/gfx/background.png" )
            else
            GuiText(gui, 0, 5, " ")
            end

            --GuiLayoutEnd(gui)
            GuiLayoutEnd(gui)
        end

        GuiLayoutEnd(gui)
        
        GuiLayoutBeginHorizontal(gui, 4, 50)
        GuiText( gui, 0, 0, " " )
        GuiLayoutEnd(gui)

        GuiLayoutBeginHorizontal(gui, 95, 90)
        GuiText( gui, 0, 0, " " )
        GuiLayoutEnd(gui)

        GuiZSetForNextWidget( gui, -85 )
        
        GuiEndAutoBoxNinePiece( gui, 5, 0, 0, false, 0, "mods/config_lib/files/gfx/background.png", "mods/config_lib/files/gfx/background.png" )
        --GuiImageNinePiece( gui, new_id(), 25, 60, sx - 50, sy - 85, 1, "data/ui_gfx/decorations/9piece0_gray.png", "data/ui_gfx/decorations/9piece0_gray.png" )

       -- here
    end

    GuiIdPop( gui )
end