local hex_digits = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F" }

function hex_string_to_number(hex_string)
  if type(hex_string) ~= "string" then
    error("String expected")
  end
  local output = 0
  for char_pos=#hex_string, 1, -1 do
    local value
    for hex_value, digit in ipairs(hex_digits) do
      if hex_string:sub(char_pos,char_pos) == digit then
        value = (hex_value - 1) * 16 ^ (#hex_string - char_pos)

        output = output + value
      end
    end
    if value == nil then
      error("Not a valid hex string")
    end
  end
  return output
end

function store_int(name, num_bits, val)
  if type(val) ~= "number" then
    error("value must be a number")
  end

  for i=1, num_bits do
    if bit.band(val, 1) == 1 then
      AddFlagPersistent(name .. "_" .. i)
    else
      RemoveFlagPersistent(name .. "_" .. i)
    end
    val = bit.rshift(val, 1)
  end
end

function retrieve_int(name, num_bits)
  local value = 0
  for i=1, num_bits do
    local bit = HasFlagPersistent(name .. "_" .. i) and 1 or 0
    if bit > 0 then
      value = value + 2 ^ (i - 1)
    end
  end
  return value
end

