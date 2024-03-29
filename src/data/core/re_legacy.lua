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

--WorldRenderEngine
local global = ...
local re = {
	rendered = {},
	copyInstructions = {},
}

--===== local vars =====--
local fromX, toX, fromY, toY = 0, 0, 0, 0 --regenerated every update.

--===== local functions =====--
local function print(...)
	if global.conf.debug.reDebug then
		global.debug.log(...)
	end
end

local function isInsideArea(ra, go, cmi)
	local x, y = go:getPos()
	local sx, sy = go.ngeAttributes.sizeX, go.ngeAttributes.sizeY
	local fromX, toX, fromY, toY = ra:getFOV()
	local expansion = {0, 0, 0, 0}
	
	if cmi.raw.x > 0 then
		expansion[1] = expansion[1] + 0
		expansion[2] = expansion[2] + cmi.raw.x
	elseif cmi.raw.x < 0 then
		expansion[1] = expansion[1] + cmi.raw.x
		expansion[2] = expansion[2] + 0
	end
	if cmi.raw.y > 0 then
		expansion[3] = expansion[3] + 0
		expansion[4] = expansion[4] + cmi.raw.y
	elseif cmi.raw.y < 0 then
		expansion[3] = expansion[3] + cmi.raw.y
		expansion[4] = expansion[4] + 0
	end
	
	if x +sx > fromX and x < toX and y +sy > fromY and y < toY then
		go.ngeAttributes.isVisibleIn[ra] = true
		return 1
	elseif x +sx > fromX +expansion[1] and x < toX +expansion[2] and y +sy > fromY +expansion[3] and y < toY +expansion[4] then
		go.ngeAttributes.isVisibleIn[ra] = true
		return 2
	end
	
	go.ngeAttributes.isVisibleIn[ra] = nil
	return 0
end

local function isInQueue(ra, go, l)
	return ra.toRender[l][go] ~= nil
end

local function checkOverlapping(renderArea, gameObject, layer)
	layer = layer or 0
	
	for go in pairs(renderArea.gameObjects) do
		local l = go.ngeAttributes.layer
		
		for i, oca in pairs(gameObject.ngeAttributes.clearAreas) do
			for i, ca in pairs(go.ngeAttributes.clearAreas) do
				local x, y = gameObject:getPos()
				local x2, y2 = go:getPos()
				local sx, sy = oca.sizeX, oca.sizeY
				local sx2, sy2 = ca.sizeX, ca.sizeY
				local lastPosX, lastPosY = gameObject:getLastPos()
				local lastPosX2, lastPosY2 = go:getLastPos()
				
				x, y = x + oca.posX, y + oca.posY
				x2, y2 = x2 + ca.posX, y2 + ca.posY
				lastPosX, lastPosY = lastPosX + oca.posX, lastPosY + oca.posY
				lastPosX2, lastPosY2 = lastPosX2 + ca.posX, lastPosY2 + ca.posY
				
				
				
				if --[[l >= layer and]] not isInQueue(renderArea, go, l) and renderArea.layerBlacklist[l] ~= true and isInsideArea(renderArea, go, renderArea.cameraMoveInstructions) == 1 then
					if gameObject ~= go and 
						x + sx > x2 and
						x < x2 + sx2 and
						y + sy > y2 and
						y < y2 + sy2
					or gameObject ~= go and 
						lastPosX + sx > lastPosX2 and
						lastPosX < lastPosX2 + sx2 and
						lastPosY + sy > lastPosY2 and
						lastPosY < lastPosY2 + sy2 
					then
						if renderArea.gameObjectAttributes[go] ~= nil then
							renderArea.gameObjectAttributes[go].mustBeRendered = true
							renderArea.gameObjectAttributes[go].causedByOverlap = true
							renderArea.toRender[l][go] = renderArea
							checkOverlapping(renderArea, go, l)
							
							print("[RE]: Found overlap with: " .. gameObject.ngeAttributes.name .. ": N:" .. go.ngeAttributes.name .. ", L:" .. tostring(l) .. ", X:" .. tostring(x) .. ", Y:" .. tostring(y) .. ", ID:"..  tostring(go) .. ", F:" .. tostring(global.currentFrame) .. ".")
						end
					end
				end
			end
		end
	end
end

local function calculateFrame(renderArea, area)
	for go in pairs(renderArea.gameObjects) do
		local l = go.ngeAttributes.layer
		
		if not isInQueue(renderArea, go, l) and renderArea.layerBlacklist[l] ~= true and isInsideArea(renderArea, go, renderArea.cameraMoveInstructions) ~= 0 then
			if renderArea.gameObjectAttributes[go].lastCalculatedFrame < global.currentFrame -1 then
				renderArea.gameObjectAttributes[go].mustBeRendered = true
			end
			
			if go.ngeAttributes.hasMoved then
				checkOverlapping(renderArea, go)
				renderArea.toRender[l][go] = renderArea
			elseif renderArea.gameObjectAttributes[go].mustBeRendered then
				renderArea.gameObjectAttributes[go].mustBeRendered = false
				checkOverlapping(renderArea, go, l)
				renderArea.toRender[l][go] = renderArea
			end
		elseif renderArea.gameObjectAttributes[go].wasVisible then
			renderArea.toClear[l][go] = renderArea
			renderArea.gameObjectAttributes[go].wasVisible = nil
		end
		renderArea.gameObjectAttributes[go].lastCalculatedFrame = global.currentFrame
	end
end

local function moveFrame(renderArea)
	if #renderArea.cameraMoveInstructions.copy > 0 then
		local cmi = renderArea.cameraMoveInstructions
		global.gpu.copy(cmi.copy[1], cmi.copy[2], cmi.copy[3], cmi.copy[4], cmi.copy[5], cmi.copy[6])
		if global.conf.useDoubleBuffering then
			table.insert(re.copyInstructions, {cmi.copy[1], cmi.copy[2], cmi.copy[3], cmi.copy[4], cmi.copy[5], cmi.copy[6]})
		end
		
		global.oclrl:draw(0, 0, global.oclrl.generateTexture({
			{"b", global.backgroundColor},
			cmi.clear[1],
			cmi.clear[2],
		}), nil, {renderArea.posX, renderArea.posX + renderArea.sizeX -1, renderArea.posY, renderArea.posY + renderArea.sizeY -1})
		
	end
end

local function moveArea(renderArea)
	--global.log("move")
	for i, ci in pairs(renderArea.copyInstructions) do
		if ci == nil or #ci <= 0 then
			global.warn("[RE]: CopyInstruction is empty: frame: " .. tostring(global.currentFrame) .. ".")
			return false
		end
		
		local fromX, toX, fromY, toY = renderArea:getRealFOV()
		local x1, y1, x2, y2 = ci[1], ci[2], ci[1] + ci[3] -1, ci[2] + ci[4] -1
		local ax, ay, asx, asy, atx, aty
		
		fromX = fromX - math.min(ci[5], 0)
		fromY = fromY - math.min(ci[6], 0)		
		toX = toX - math.max(ci[5] +1, 1)
		toY = toY - math.max(ci[6] +1, 1)
		
		if #renderArea.cameraMoveInstructions.copy > 0 then
			x1, y1, x2, y2 = x1 + renderArea.cameraMoveInstructions.copy[5], y1 + renderArea.cameraMoveInstructions.copy[6], x2 + renderArea.cameraMoveInstructions.copy[5], y2 + renderArea.cameraMoveInstructions.copy[6]
		end
		
		x1 = math.max(x1, fromX)
		y1 = math.max(y1, fromY)
		x2 = math.min(x2, toX)
		y2 = math.min(y2, toY)
		
		ax = x1
		ay = y1
		asx = x2 - x1 +1
		asy = y2 - y1 +1
		
		global.gpu.copy(ax, ay, asx, asy, ci[5], ci[6])
		if global.conf.useDoubleBuffering then
			table.insert(re.copyInstructions, {ax, ay, asx, asy, ci[5], ci[6]})
		end
		
		--global.log("t")
	end
end

local function clearFrame(renderArea, toClear)
	local clearList = global.ut.parseArgs(toClear, renderArea.toRender)
	
	for i, l in pairs(clearList) do
		for go in pairs(l) do
			if go.ngeAttributes.hasMoved and go.ngeAttributes.clearedAlready ~= true then
				print("[RE]: Clear: " .. tostring(go.ngeAttributes.name) .. ": (" .. tostring(go) .. "), RA: " .. renderArea.name .. ", frame: " .. tostring(global.currentFrame) .. ".")
				go:ngeClear(renderArea)
			end
		end
		if toClear ~= nil then
			toClear[i] = {}
		end
	end
end

local function drawFrame(renderArea)
	for i, l in pairs(renderArea.toRender) do
		for go, area in pairs(l) do
			print("[RE]: Draw: " .. tostring(go.ngeAttributes.name) .. ": (" .. tostring(go) .. "), RA: " .. renderArea.name .. ", frame: " .. tostring(global.currentFrame) .. ".")
			go:ngeDraw(area)
			re.rendered[go] = true
			renderArea.gameObjectAttributes[go].causedByOverlap = false
		end
		renderArea.toRender[i] = {}
	end
end

--===== global functions =====--
function re.init()
	
end

function re.draw()
	print("[RE]: New frame: " .. tostring(global.currentFrame))
	for ra in pairs(global.renderAreas) do
		if ra.visible then
			moveFrame(ra)
			moveArea(ra)
			clearFrame(ra, ra.toClear)
			clearFrame(ra)
			drawFrame(ra)
			ra:ngeDraw()
			ra:resetCMI()
		end
	end
	for go in pairs(re.rendered) do
		go:ngeSetLastPos()
	end
end

function re.executeCopyOrders()
	if global.conf.useDoubleBuffering then
		for i, co in pairs(re.copyInstructions) do
			global.realGPU.copy(co[1], co[2], co[3], co[4], co[5], co[6])
		end
		re.copyInstructions = {}
	end
end

function re.newDraw(renderArea)
	for go in pairs(global.gameObjects) do
		renderArea.gameObjectAttributes[go].mustBeRendered = true
	end
end

function re.test()
	for ra in pairs(global.renderAreas) do
		print("TT")
		calculateFrame(ra)
		clearFrame()
		drawFrame()
	end
end

re.calculateRenderArea = function() end
re.checkOverlapping = function() end

re.calculateRenderArea = calculateFrame
re.checkOverlapping = checkOverlapping	

--===== init =====--


return re