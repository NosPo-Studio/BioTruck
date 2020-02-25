--[[
    This file is part of the NosGa Engine.
	
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

--===== shared vars =====--
local garage = {
	uiUpgrades = {},
}

--===== local vars =====--

--===== local functions =====--
local function print(...)
	global.log(...)
end

--===== shared functions =====--
function garage.init()
	print("[garage]: Start init.")
	
	--===== debug =====--
	
	--===== debug end =====--
	
	global.load({
		toLoad = {
			textures = true,
			gameObjects = true,
		},
	})
	
	print("[garage]: init done.")
end

function garage.start()
	garage.raMain = global.addRA({
		posX = 1, 
		posY = 1, 
		sizeX = global.resX, 
		sizeY = global.resY - global.conf.consoleSizeY -2, 
		name = "RA1", 
		drawBorders = true,
	})
	local _, resX, _, resY = garage.raMain:getRealFOV()
	resX, resY = resX -1, resY -1
	local ui = nil
	local buttonSizeX, buttonSizeY = 14, 3
	local buttons = 3
	local posY = resY / 2 - buttons * (buttonSizeY + 1)
	
	global.clear()
	
	--[[
		Speed.
		Life.
		Armor.
		Tank.
		Damage.
		Traction.
		FuelConsuption.
	]]
	
	garage.ocui = global.ocui.initiate(global.oclrl)
	ui = garage.ocui
	
	garage.uiUpgrades.uSpeed = garage.raMain:addGO("Upgrade", {
		x = 10,
		y = 10, 
		buttonSizeX = buttonSizeX, 
		buttonSizeY = buttonSizeY,
		stat = "speed",
		statName = "Speed",
		colors = {
			button = {
				0x333333, 0x888888, 0x777777, 0xaaaaaa,
			},
			background = {0x777777, 0xaaaaaa,},
		}
	})
	
	
	garage.uiUpgrades.bBack = ui.Button.new(ui, {
		x = 3,
		y = resY - buttonSizeY,
		sx = buttonSizeX,
		sy = buttonSizeY,
		textures = {
			global.getButtonTexture(buttonSizeX, buttonSizeY, 0x333333, 0x888888, "Back"),
			global.getButtonTexture(buttonSizeX, buttonSizeY, 0x777777, 0xaaaaaa, "Back"),
		},
		lf = function() 
			ui:draw()
			global.db.drawChanges()
			global.changeState("mainMenu") 
		end,
	})
	
	--===== debug =====--
	
	--===== debug end =====--
	
end

function garage.update(dt)	
	
end

function garage.draw()
	
	
	garage.ocui:draw()
	
	global.drawDebug("BiofuleMachine: " .. global.gameVersion)
end

function garage.touch(s)
	local x, y = s[3], s[4]
	
	--garage.ocui:update(x, y)
end

function garage.key_down(s)
	if s[4] == 28 and global.isDev then
		print("--===== EINGABE =====--")
		if true then
			global.realGPU.setBackground(0x000000)
			global.term.clear()
		end
	end 
end

function garage.stop()
	if garage.raMain ~= nil then
		for i, go in pairs(garage.uiUpgrades) do
			garage.raMain:remGO(go)
		end
		global.remRA(garage.raMain)
	end
end

return garage





