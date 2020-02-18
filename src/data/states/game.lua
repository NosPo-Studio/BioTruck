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
global.gameVersion = "v0.0.1"

--===== shared vars =====--
local game = {
	stats = {
		maxSpeed = 10,
		acceleration = 1,
		brake = 1,
		traction = 1,
		fuelTank = 30,
		startFuel = 10,
		fuelConsumption = 1,
		armor = 10,
		life = 10,
	},
	cameraOffsetX = -3,
	cameraOffsetY = 0,
	ui = {},
	ocui = {},
	maxDistance = 0,
	lines = 3,
	streetWidth = 5,
}

--===== local vars =====--

--===== local functions =====--
local function print(...)
	global.log(...)
end

--===== shared functions =====--
function game.init()
	print("[game]: Start init.")
	
	--===== debug =====--
	
	--===== debug end =====--
	
	global.load({
		toLoad = {
			parents = true,
			gameObjects = true,
			textures = true,
			animations = true,
		},
	})
	
	game.ocui = global.ocui.initiate(global.oclrl)
	game.ui.speed = game.ocui.Bar.new(game.ocui, {posX = 10, posY = 2, sizeX = global.resX / 2 - 10, sizeY = 1, clickable = false})
	game.ui.life = game.ocui.Bar.new(game.ocui, {posX = 10, posY = 4, sizeX = global.resX / 2 - 10, sizeY = 1, clickable = false})
	
	game.ui.fuel = game.ocui.Bar.new(game.ocui, {posX = global.resX / 2 + 9, posY = 2, sizeX = global.resX / 2 - 10, sizeY = 1, clickable = false})
	game.ui.armor = game.ocui.Bar.new(game.ocui, {posX = global.resX / 2 + 9, posY = 4, sizeX = global.resX / 2 - 10, sizeY = 1, clickable = false})
	
	game.ra1 = global.addRA({
		posX = 1, 
		posY = 8, 
		sizeX = global.resX, 
		sizeY = global.resY - global.conf.consoleSizeY -4, 
		name = "RA1", 
		drawBorders = true,
	})
	
	game.goPlayer = game.ra1:addGO("Player", {
		posX = 10, 
		posY = 10, 
		layer = 4, 
		name = "player", 
		particleContainer = game.ra1:addGO("DefaultParticleContainer", {}),
		stats = game.stats,
		eoy = -1,
		eox = 2,
	})
	
	game.pcExhaust = game.ra1:addGO("Exhaust", {
		width = 2, 
		height = 1, 
		particle = "Smoke", 
		parent = game.goPlayer,
		smokeRate = 2 * global.conf.particles,
	})
	
	print("[game]: init done.")
end

function game.start()
	global.clear()
	
	
	--===== debug =====--
	
	game.goTest = game.ra1:addGO("Test2", {posX = 24, posY = 6, layer = 3, maxSpeed = 20, name = "goTest",
		particleContainer = game.ra1:addGO("DefaultParticleContainer", {}),
	})
	game.goTest2 = game.ra1:addGO("Test3", {posX = 55, posY = 8, layer = 2, name = "goTest2"})
	game.goTest3 = game.ra1:addGO("Test4", {posX = 35, posY = 12, layer = 2, name = "goTest3",
		particleContainer = game.ra1:addGO("DefaultParticleContainer", {}),
	})
	
	game.testGOs = {}
	local amount = 10
	local dis = 20
	for c = 0, amount * dis, dis do
		table.insert(game.testGOs, game.ra1:addGO("Test4", 
			{posX = 45 +c, posY = 12, layer = 2, name = "goTest3",
			--particleContainer = game.ra1:addGO("DefaultParticleContainer", {}),
		}))
		
		table.insert(game.testGOs, game.ra1:addGO("Test4", 
			{posX = 40 +c, posY = 3, layer = 2, name = "goTest3",
			--particleContainer = game.ra1:addGO("DefaultParticleContainer", {}),
		}))
	end
	
	--===== debug end =====--
	
end

function game.update()	
	local x, y = game.goPlayer:getPos()
	local speed = select(1, game.goPlayer:getSpeed())
	
	x = x + game.cameraOffsetX
	y = game.cameraOffsetY
	game.ra1:moveCameraTo(x, y)
	
	game.ui.speed:setStatus(math.abs(speed) / game.stats.maxSpeed / 1.5)
	game.ui.fuel:setStatus(game.goPlayer.fuel / game.stats.fuelTank)
	game.ui.life:setStatus(game.goPlayer.life / game.stats.life)
	game.ui.armor:setStatus(game.goPlayer.armor / game.stats.armor)
	
	--game.ra1:moveCamera(1, 0)
	
	--print("=====New frame=====")
	while game.pause do
		os.sleep(.1)
		if global.keyboard.isKeyDown("z") or global.keyboard.isKeyDown(60) or global.keyboard.isKeyDown(63) or global.keyboard.isControlDown() then
			game.pause = not game.pause
		end
	end
end

function game.ctrl_pause_key_down(s, sname)
	game.pause = true
end

function game.draw()
	game.maxDistance = math.max(game.goPlayer:getPos(), game.maxDistance)
	
	
	global.gpu.setBackground(global.conf.uiBackgroundColor)
	global.gpu.setForeground(global.conf.uiForegroundColor)
	global.gpu.fill(1, 1, global.resX, 7, " ")
	global.gpu.set(3, 2, "Speed:")
	global.gpu.set(global.resX / 2 + 3, 2, "Fuel:")
	global.gpu.set(3, 4, "Armor:")
	global.gpu.set(global.resX / 2 + 3, 4, "Life:")
	
	global.gpu.set(global.resX / 2 - 10, 6, "Max distance: " .. tostring(game.maxDistance))
	
	game.ocui:draw()
end

function game.key_down(s)
	if s[4] == 28 and global.isDev then
		print("--===== EINGABE =====--")
		
		if true then
			global.realGPU.setBackground(0x000000)
			global.term.clear()
		end
		
	end 
	
	
end

function game.ctrl_camLeft_key_pressed()
	game.ra1:moveCamera(- 10 * global.dt, 0)
end
function game.ctrl_camRight_key_pressed()
	game.ra1:moveCamera(10 * global.dt, 0)
end

function game.stop()
	
end

return game





