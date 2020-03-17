--[[
    This file is a GameObject example for the NosGa Engine.
	
	NosGa Engine Copyright (c) 2019-2020 NosPo Studio

    The NosGa Engine is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    The NosGa Engine is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with the NosGa Engine.  If not, see <https://www.gnu.org/licenses/>.
]]

local global = ... 

StreetTest = {}
StreetTest.__index = StreetTest

function StreetTest.new(args) 
	--===== gameObject definition =====--
	args = args or {} 
	
	args.sizeX = 50
	args.sizeY = 27
	args.components = {
		{"Sprite", 
			x = 0, 
			y = 0, 
			texture = "street2",
		},
	}
	args.dots = { --dot = {posX, posY, sizeX, sizeY, normalColor, activeColor}
		--[[{ --Bottom line.
			{1, 24, 5, 1, 0xaa0000, 0x00aa00}, --Dot one.
		},
		{ --Middle line.
			{1, 13, 5, 1, 0xaa0000, 0x00aa00}, --Dot one.
			{3, 12, 1, 3, 0xaa0000, 0x00aa00}, --Dot two.
		},
		{ --Uppder line.
			{1, 4, 5, 1, 0xaa0000, 0x00aa00}, --Dot one.
		},
		]]
	}
	
	--===== default stuff =====--
	local this = global.parent.Street.new(args) 
	this = setmetatable(this, StreetTest) 
	
	return this
end

return StreetTest