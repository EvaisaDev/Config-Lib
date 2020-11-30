entity = GetUpdatedEntityID()

cam_x, cam_y = GameGetCameraPos()

local vw = MagicNumbersGetValue("VIRTUAL_RESOLUTION_X") / 2
local vh = MagicNumbersGetValue("VIRTUAL_RESOLUTION_Y") / 2

EntitySetTransform(entity, cam_x - vw - 1, cam_y- vh)