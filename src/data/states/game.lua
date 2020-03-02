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
global.gameVersion = "v0.0.6"

--===== shared vars =====--
local game = {
	stats = global.stats,
	cameraOffsetX = 0,
	cameraOffsetY = 0,
	ui = {},
	ocui = {},
	maxDistance = 0,
	lines = 3,
	streetWidth = 5,
}

--===== local vars =====--
local t = false
local c = 0

--===== local functions =====--
local function print(...)
	global.log(...)
end

--===== shared functions =====--
function game.init()
	print("[game]: Start init.")
	
	--===== debug =====--
	--[[
	package.loaded["libs/thirdParty/DoubleBuffering"] = nil
	global.db = require("libs/thirdParty/DoubleBuffering")
	
	package.loaded["libs/dbgpu_api"] = nil
	global.gpu = loadfile("libs/dbgpu_api.lua")({path = "libs/thirdParty", directDraw = false, forceDraw = false, rawCopy = true})
	
	package.loaded["libs/ocal"] = nil
	global.ocal = require("libs/ocal").initiate({oclrl = global.oclrl, db = global.db, libs = "libs/thirdParty"})
	
	package.loaded["libs/ocgf"] = nil
	global.ocgf = dofile("libs/ocgf.lua").initiate({gpu = global.gpu, db = global.db, oclrl = global.oclrl, ocal = global.ocal})
	]]
	--===== debug end =====--
	
	print("[game]: init done.")
end

function game.start()
	local resX, resY = global.resX, global.resY
	
	global.load({
		toLoad = {
			parents = true,
			gameObjects = true,
			structuredGameObjects = true,
			textures = true,
			animations = true,
		},
	})
	global.clear()
	
	game.ocui = global.ocui.initiate(global.oclrl)
	game.ui.speed = game.ocui.Bar.new(game.ocui, {posX = 10, posY = resY -5, sizeX = global.resX / 2 - 10, sizeY = 1, clickable = false})
	game.ui.armor = game.ocui.Bar.new(game.ocui, {posX = 10, posY = resY -3, sizeX = global.resX / 2 - 10, sizeY = 1, clickable = false})
	
	game.ui.fuel = game.ocui.Bar.new(game.ocui, {posX = global.resX / 2 + 9, posY = resY -5, sizeX = global.resX / 2 - 10, sizeY = 1, clickable = false})
	game.ui.life = game.ocui.Bar.new(game.ocui, {posX = global.resX / 2 + 9, posY = resY -3, sizeX = global.resX / 2 - 10, sizeY = 1, clickable = false})
	--[[
	game.raMain = global.addRA({
		posX = 1, 
		posY = 8, 
		sizeX = global.resX, 
		sizeY = global.resY - global.conf.consoleSizeY -4, 
		name = "RA1", 
		drawBorders = true,
	})
	]]
	game.raMain = global.addRA({
		posX = 15, 
		posY = 1, 
		sizeX = global.resX -30, 
		sizeY = 20, 
		name = "RA1", 
		drawBorders = true,
	})
	
	game.raTest = global.addRA({
		posX = 2, 
		posY = 22, 
		sizeX = global.resX -2, 
		sizeY = 20, 
		name = "RA2", 
		drawBorders = true,
		silent = true,
		parent = game.raMain,
	})
	
	game.goPlayer = game.raMain:addGO("Player", {
		posX = 10, 
		posY = 13, 
		layer = 4, 
		name = "player", 
		particleContainer = game.raMain:addGO("DefaultParticleContainer", {}),
		stats = game.stats,
		eoy = -1,
		eox = 2,
	})
	
	game.pcExhaust = game.raMain:addGO("Exhaust", {
		width = 2, 
		height = 1, 
		particle = "Smoke", 
		parent = game.goPlayer,
		smokeRate = 2 * global.conf.particles,
	})
	
	game.pcDefaultParticleContainer = game.raMain:addGO("DefaultParticleContainer", {})
	
	global.worldHandler.start(game, 5, "test")
	
	--===== debug =====--
	--[[
	game.goBarrierTest = game.raMain:addGO("world/BarrierTest", {posX = 24, posY = 12, layer = 3, name = "goBarrierTest",
		particleContainer = game.raMain:addGO("DefaultParticleContainer", {}),
		defaultParticleContainer = game.pcDefaultParticleContainer,
	})
	]]
	--[[
	game.goTest = game.raMain:addGO("world/Test2", {posX = 24, posY = 6, layer = 3, maxSpeed = 20, name = "goTest",
		particleContainer = game.raMain:addGO("DefaultParticleContainer", {}),
	})
	
	game.goTest = game.raMain:addGO("world/Test2", {posX = 24, posY = 6, layer = 3, maxSpeed = 20, name = "goTest",
		particleContainer = game.raMain:addGO("DefaultParticleContainer", {}),
	})
	game.goTest2 = game.raMain:addGO("world/Test3", {posX = 55, posY = 8, layer = 2, name = "goTest2"})
	game.goTest3 = game.raMain:addGO("world/Test4", {posX = 6, posY = -3, layer = 2, name = "goTest3",
		particleContainer = game.raMain:addGO("DefaultParticleContainer", {}),
	})
	]]
	--[[
	game.testGOs = {}
	local amount = 10
	local dis = 20
	for c = 1, amount * dis, dis do
		table.insert(game.testGOs, game.raMain:addGO("world/BarrierTest", {posX = 34 +c, posY = 12, layer = 3, name = "goBarrierTest",
			defaultParticleContainer = game.pcDefaultParticleContainer,
		}))
		
	end
	]]
	
	--===== debug end =====--
	
end

function game.update(dt)	
	local x, y = game.goPlayer:getPos()
	local speed = select(1, game.goPlayer:getSpeed())
	
	game.ui.speed:setStatus(math.abs(speed) / game.stats.maxSpeed / 1.5)
	game.ui.fuel:setStatus(game.goPlayer.fuel / game.stats.fuelTank)
	game.ui.life:setStatus(game.goPlayer.life / game.stats.life)
	game.ui.armor:setStatus(game.goPlayer.armor / game.stats.armor)
	
	global.worldHandler.update()
	
	
	if false then 
		if c == 0 then
			game.raMain:moveCameraTo(12, 0)
			c = 1
		elseif c == 1 then
			--os.sleep(.5)
			game.raMain:moveCameraTo(9, 0)
			c = 2
		end
	end
	
	
	if false then
		if t then
			game.raMain:moveCamera(1, 0)
			c = c +1
			if c > 10 then
				t = false
			end
		else
			game.raMain:moveCamera(-1, 0)
			c = c -1
			if c < 0 then
				t = true
			end
		end
	end
	
	--game.raMain:moveCamera(1, 0)
	
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
	local resX, resY = global.resX, global.resY
	game.maxDistance = math.max(game.goPlayer:getPos(), game.maxDistance)
	
	global.gpu.setBackground(global.conf.uiBackgroundColor)
	global.gpu.setForeground(global.conf.uiForegroundColor)
	global.gpu.fill(1, resY - 6, global.resX, 7, " ")
	global.gpu.set(3, resY - 5, "Speed:")
	global.gpu.set(global.resX / 2 + 3, resY -5, "Fuel:")
	global.gpu.set(3, resY - 3, "Armor:")
	global.gpu.set(global.resX / 2 + 3, resY - 3, "Life:")
	
	global.gpu.set(global.resX / 2 - 10, resY - 1, "Max distance: " .. tostring(game.maxDistance))
	
	game.ocui:draw()
	
	global.drawDebug("BiofuleMachine: " .. global.gameVersion)
end

function game.key_down(s)
	if s[4] == 28 and global.isDev then
		print("--===== EINGABE =====--")
		
		c = 0
		
		if true then
			global.realGPU.setBackground(0x000000)
			global.term.clear()
		end
		
	end 
	
	
end

function game.ctrl_camLeft_key_pressed()
	game.raTest:moveCamera(- 10 * global.dt, 0)
end
function game.ctrl_camRight_key_pressed()
	game.raTest:moveCamera(10 * global.dt, 0)
end

function game.stop()
	
end

return game





