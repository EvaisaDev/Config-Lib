function table.has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function table.indexOf(t, object)
    if type(t) ~= "table" then error("table expected, got " .. type(t), 2) end

    for i, v in pairs(t) do
        if object == v then
            return i
        end
    end
end

function HasSettingFlag(name)
    return ModSettingGet(name) or false
end

function AddSettingFlag(name)
    ModSettingSet(name, true)
  --  ModSettingSetNextValue(name, true)
end

function RemoveSettingFlag(name)
    ModSettingRemove(name)
end

function ModSettingGet2(name)
    return ModSettingGet(name) or nil
end

function ModSettingSet2(name, value)
    ModSettingSet(name, value)
end

function table.clone(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end

function table.removeFirst(tbl, val)
    for i, v in ipairs(tbl) do
      if v == val then
        return table.remove(tbl, i)
      end
    end
end

function math.round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function createSpriteForXFrames(filename, world_x, world_y, offset_x, offset_y, emmisive, frames, scale)
    local point_holder = EntityCreateNew("point_holder")

    EntityAddTag(point_holder, "config_lib_background")

    x, y, r, s1, s2 = EntityGetTransform(point_holder)

    EntitySetTransform(point_holder, world_x, world_y, r, scale, scale)

    EntityAddComponent2(point_holder, "SpriteComponent", {
        alpha=1,
        emissive=emmisive,
        image_file=filename,
        offset_x=offset_x,
        offset_y=offset_y,
    })

    EntityAddComponent2(point_holder, "LuaComponent", {
        execute_on_added = true,
        execute_every_n_frame = 0,
        script_source_file = "mods/config_lib/files/track_camera.lua"
    })

    EntityAddComponent2(point_holder, "LifetimeComponent", {
        lifetime=frames
    })
end