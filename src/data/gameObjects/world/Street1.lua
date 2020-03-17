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
	
	args.sizeX = 20
	args.sizeY = 27
	args.components = {
		{"Sprite", 
			x = 0, 
			y = 0, 
			texture = "street1",
		},
	}
	args.dots = { --dot = {posX, posY, sizeX, sizeY, normalColor, activeColor}
		{ --Bottom line.
			{1, 43, 2, 2, 0x992400, 0xff4900}, --Dot one.
			
			--[[
			{1, 36, 2, 1, 0x992400, 0xff4900}, --Dot one.
			{1, 51, 2, 1, 0x992400, 0xff4900}, --Dot one.
			]]
		},
		{ --Middle line.
			{11, 26, 2, 2, 0x992400, 0xff4900}, --Dot one.
			
			--[[
			{11, 19, 2, 1, 0x992400, 0xff4900}, --Dot one.
			{11, 34, 2, 1, 0x992400, 0xff4900}, --Dot one.
			]]
		},
		{ --Uppder line.
			{1, 15, 2, 1, 0x992400, 0xff4900}, --Dot one.
			{1, 0, 2, 1, 0x992400, 0xff4900}, --Dot one.
		},
		
	}
	
	--===== default stuff =====--
	local this = global.parent.Street.new(args) 
	this = setmetatable(this, StreetTest) 
	
	return this
end

return StreetTest