--[[
	This libary is third pary content by IgorTimofeev wich is licensed under the MIT License.
	
	There are made some changes to provide the best possible performance in combination with the NosGa Engine (<https://github.com/NosPo-Studio/NosGa-Engine>).
	
	Original source code repo: <https://github.com/IgorTimofeev/DoubleBuffering>
]]

--[[
MIT License

DoubleBuffering Copyright (c) 2018 Igor Timofeev
DoubleBuffering (NosPo version) Copyright (c) 2019-2020 NosPo Studio

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]
local version = "v0.7d" --NosPo version.

local component = require("component")
local unicode = require("unicode")
local color = require("libs/thirdParty/color")
local image = require("libs/thirdParty/image")

--------------------------------------------------------------------------------

local bufferWidth, bufferHeight
local currentFrameBackgrounds, currentFrameForegrounds, currentFrameSymbols, newFrameBackgrounds, newFrameForegrounds, newFrameSymbols
local drawLimitX1, drawLimitX2, drawLimitY1, drawLimitY2
local GPUProxy, GPUProxyGetResolution, GPUProxySetResolution, GPUProxyBind, GPUProxyGetBackground, GPUProxyGetForeground, GPUProxySetBackground, GPUProxySetForeground, GPUProxyGet, GPUProxySet, GPUProxyFill

local mathCeil, mathFloor, mathModf, mathAbs = math.ceil, math.floor, math.modf, math.abs
local tableInsert, tableConcat = table.insert, table.concat
local colorBlend = color.blend
local unicodeLen, unicodeSub = unicode.len, unicode.sub

local drawAreas, nonDrawAreas = {}, {} --drawAreas == pixelWhiteList, nonDrawAreas == pixelBlackList
local drawAreasAreWhitelist = true
local drawAreaOffsetX, drawAreaOffsetY = 0, 0
local bufferOnly = false

--------------------------------------------------------------------------------

local function getIndex(x, y)
	return bufferWidth * (y - 1) + x
end
local function getCoordinates(index)
	return index % bufferWidth, math.floor(index / bufferWidth) +1
end

local function getCurrentFrameTables()
	return currentFrameBackgrounds, currentFrameForegrounds, currentFrameSymbols, bufferWidth, bufferHeight
end
local function getNewFrameTables()
	return newFrameBackgrounds, newFrameForegrounds, newFrameSymbols, bufferWidth, bufferHeight
end
local function setCurrentFrameTables(b, f, s, w, h)
	currentFrameBackgrounds, currentFrameForegrounds, currentFrameSymbols, bufferWidth, bufferHeight = b, f, s, w, h
end
local function setNewFrameTables(b, f, s, w, h)
	newFrameBackgrounds, newFrameForegrounds, newFrameSymbols, bufferWidth, bufferHeight = b, f, s, w, h
end

local function setBufferOnly(b)
	bufferOnly = b
end
local function getBufferOnly()
	return bufferOnly
end

--------------------------------------------------------------------------------

local function setDrawLimit(x1, y1, x2, y2)
	drawLimitX1, drawLimitY1, drawLimitX2, drawLimitY2 = x1, y1, x2, y2
end

local function resetDrawLimit()
	drawLimitX1, drawLimitY1, drawLimitX2, drawLimitY2 = 1, 1, bufferWidth, bufferHeight
end

local function getDrawLimit()
	return drawLimitX1, drawLimitY1, drawLimitX2, drawLimitY2
end

local function setDrawAreas(areas)
	drawAreas = areas
end
local function resetDrawAreas()
	drawAreas = {}
end
local function getDrawAreas()
	return drawAreas
end
local function setNonDrawAreas(areas)
	nonDrawAreas = areas
end
local function resetNonDrawAreas()
	nonDrawAreas = {}
end
local function getNonDrawAreas()
	return nonDrawAreas
end

local function setDrawAreaOffset(x, y)
	drawAreaOffsetX = x or drawAreaOffsetX
	drawAreaOffsetY = y or drawAreaOffsetY
	
end
local function getDrawAreaOffset()
	return drawAreaOffsetX, drawAreaOffsetY
end
local function resetDrawAreaOffset()
	drawAreaOffsetX, drawAreaOffsetY = 0, 0
end

local function isDrawable(x, y)
	local drawable = true
	
	if #drawAreas == 0 and #nonDrawAreas == 0 then
		--return true
	end
	
	for _, a in pairs(drawAreas) do	
		if x >= a[1] + drawAreaOffsetX and x <= a[3] + drawAreaOffsetX and y >= a[2] + drawAreaOffsetY and y <= a[4] + drawAreaOffsetY then
			drawable = true
			break
		end
		drawable = false
	end
	for _, a in pairs(nonDrawAreas) do	
		if x >= a[1] + drawAreaOffsetX and x <= a[3] + drawAreaOffsetX and y >= a[2] + drawAreaOffsetY and y <= a[4] + drawAreaOffsetY then
			drawable = false
			break
		end
	end
	
	return drawable
end

--------------------------------------------------------------------------------

local function flush(width, height)
	if not width or not height then
		width, height = GPUProxyGetResolution()
	end

	currentFrameBackgrounds, currentFrameForegrounds, currentFrameSymbols, newFrameBackgrounds, newFrameForegrounds, newFrameSymbols = {}, {}, {}, {}, {}, {}
	bufferWidth = width
	bufferHeight = height
	resetDrawLimit()

	for y = 1, bufferHeight do
		for x = 1, bufferWidth do
			tableInsert(currentFrameBackgrounds, 0x010101)
			tableInsert(currentFrameForegrounds, 0xFEFEFE)
			tableInsert(currentFrameSymbols, " ")

			tableInsert(newFrameBackgrounds, 0x010101)
			tableInsert(newFrameForegrounds, 0xFEFEFE)
			tableInsert(newFrameSymbols, " ")
		end
	end
end

local function setResolution(width, height)
	GPUProxySetResolution(width, height)
	flush(width, height)
end

local function getResolution()
	return bufferWidth, bufferHeight
end

local function getWidth()
	return bufferWidth
end

local function getHeight()
	return bufferHeight
end

local function bindScreen(...)
	GPUProxyBind(...)
	flush(GPUProxyGetResolution())
end

local function getGPUProxy()
	return GPUProxy
end

local function updateGPUProxyMethods()
	GPUProxyGet = GPUProxy.get
	GPUProxyGetResolution = GPUProxy.getResolution
	GPUProxyGetBackground = GPUProxy.getBackground
	GPUProxyGetForeground = GPUProxy.getForeground

	GPUProxySet = GPUProxy.set
	GPUProxySetResolution = GPUProxy.setResolution
	GPUProxySetBackground = GPUProxy.setBackground
	GPUProxySetForeground = GPUProxy.setForeground

	GPUProxyBind = GPUProxy.bind
	GPUProxyFill = GPUProxy.fill
end

local function bindGPU(address)
	GPUProxy = component.proxy(address)
	updateGPUProxyMethods()
	flush(GPUProxyGetResolution())
end

--------------------------------------------------------------------------------

local function rawSet(index, background, foreground, symbol)
	newFrameBackgrounds[index], newFrameForegrounds[index], newFrameSymbols[index] = background, foreground, symbol
	if bufferOnly then
		currentFrameBackgrounds[index], currentFrameForegrounds[index], currentFrameSymbols[index] = background, foreground, symbol
	end
end

local function rawGet(index)
	return newFrameBackgrounds[index], newFrameForegrounds[index], newFrameSymbols[index]
end

local function get(x, y)
	if x >= 1 and y >= 1 and x <= bufferWidth and y <= bufferHeight then
		local index = bufferWidth * (y - 1) + x
		return newFrameBackgrounds[index], newFrameForegrounds[index], newFrameSymbols[index]
	else
		return 0x000000, 0x000000, " "
	end
end

local function set(x, y, background, foreground, symbol)
	if x >= drawLimitX1 and y >= drawLimitY1 and x <= drawLimitX2 and y <= drawLimitY2 and isDrawable(x, y) then
		local index = bufferWidth * (y - 1) + x
		newFrameBackgrounds[index], newFrameForegrounds[index], newFrameSymbols[index] = background, foreground, symbol
		if bufferOnly then
			currentFrameBackgrounds[index], currentFrameForegrounds[index], currentFrameSymbols[index] = background, foreground, symbol
		end
	end
end

local function drawRectangle(x, y, width, height, background, foreground, symbol, transparency) 
	local index, indexStepOnReachOfSquareWidth = bufferWidth * (y - 1) + x, bufferWidth - width
	for j = y, y + height - 1 do
		if j >= drawLimitY1 and j <= drawLimitY2 then
			for i = x, x + width - 1 do
				if i >= drawLimitX1 and i <= drawLimitX2 and isDrawable(i, j) then
					if transparency then
						newFrameBackgrounds[index], newFrameForegrounds[index] =
							colorBlend(newFrameBackgrounds[index], background, transparency),
							colorBlend(newFrameForegrounds[index], background, transparency)
						if bufferOnly then
							currentFrameBackgrounds[index], currentFrameForegrounds[index] =
								colorBlend(currentFrameBackgrounds[index], background, transparency),
								colorBlend(currentFrameForegrounds[index], background, transparency)
						end
					else
						newFrameBackgrounds[index], newFrameForegrounds[index], newFrameSymbols[index] = background, foreground, symbol
						if bufferOnly then
							currentFrameBackgrounds[index], currentFrameForegrounds[index], currentFrameSymbols[index] = background, foreground, symbol
						end
					end
				end

				index = index + 1
			end

			index = index + indexStepOnReachOfSquareWidth
		else
			index = index + bufferWidth
		end
	end
end

local function clear(color, transparency)
	drawRectangle(1, 1, bufferWidth, bufferHeight, color or 0x0, 0x000000, " ", transparency)
end

local function copy(x, y, width, height, current)
	local copyArray, index = { width, height }
	local rawCopyArray = { width, height }
	
	for j = y, y + height - 1 do
		for i = x, x + width - 1 do
			if i >= 1 and j >= 1 and i <= bufferWidth and j <= bufferHeight then
				index = bufferWidth * (j - 1) + i
				tableInsert(copyArray, newFrameBackgrounds[index])
				tableInsert(copyArray, newFrameForegrounds[index])
				tableInsert(copyArray, newFrameSymbols[index])
				if current or bufferOnly then
					tableInsert(rawCopyArray, currentFrameBackgrounds[index])
					tableInsert(rawCopyArray, currentFrameForegrounds[index])
					tableInsert(rawCopyArray, currentFrameSymbols[index])
				end
			else
				tableInsert(copyArray, 0x0)
				tableInsert(copyArray, 0x0)
				tableInsert(copyArray, " ")
				if current or bufferOnly then
					tableInsert(rawCopyArray, 0x0)
					tableInsert(rawCopyArray, 0x0)
					tableInsert(rawCopyArray, " ")
				end
			end
		end
	end
	
	return copyArray, rawCopyArray
end

local function paste(startX, startY, picture, currentPicture)
	local imageWidth = picture[1]
	local bufferIndex, pictureIndex, bufferIndexStepOnReachOfImageWidth = bufferWidth * (startY - 1) + startX, 3, bufferWidth - imageWidth
	
	for y = startY, startY + picture[2] - 1 do
		if y >= drawLimitY1 and y <= drawLimitY2 then
			for x = startX, startX + imageWidth - 1 do
				if x >= drawLimitX1 and x <= drawLimitX2 and isDrawable(x, y) then
					newFrameBackgrounds[bufferIndex] = picture[pictureIndex]
					newFrameForegrounds[bufferIndex] = picture[pictureIndex + 1]
					newFrameSymbols[bufferIndex] = picture[pictureIndex + 2]
					if currentPicture ~= nil then
						currentFrameBackgrounds[bufferIndex] = currentPicture[pictureIndex]
						currentFrameForegrounds[bufferIndex] = currentPicture[pictureIndex + 1]
						currentFrameSymbols[bufferIndex] = currentPicture[pictureIndex + 2]
					end
				end

				bufferIndex, pictureIndex = bufferIndex + 1, pictureIndex + 3
			end

			bufferIndex = bufferIndex + bufferIndexStepOnReachOfImageWidth
		else
			bufferIndex, pictureIndex = bufferIndex + bufferWidth, pictureIndex + imageWidth * 3
		end
	end
end

local function copyCurrent(x, y, width, height)
	local copyArray, index = { width, height }

	for j = y, y + height - 1 do
		for i = x, x + width - 1 do
			if i >= 1 and j >= 1 and i <= bufferWidth and j <= bufferHeight then
				index = bufferWidth * (j - 1) + i
				tableInsert(copyArray, currentFrameBackgrounds[index])
				tableInsert(copyArray, currentFrameForegrounds[index])
				tableInsert(copyArray, currentFrameSymbols[index])
			else
				tableInsert(copyArray, 0x0)
				tableInsert(copyArray, 0x0)
				tableInsert(copyArray, " ")
			end
		end
	end

	return copyArray
end

local function pasteCurrent(startX, startY, picture)
	local imageWidth = picture[1]
	local bufferIndex, pictureIndex, bufferIndexStepOnReachOfImageWidth = bufferWidth * (startY - 1) + startX, 3, bufferWidth - imageWidth

	for y = startY, startY + picture[2] - 1 do
		if y >= drawLimitY1 and y <= drawLimitY2 then
			for x = startX, startX + imageWidth - 1 do
				if x >= drawLimitX1 and x <= drawLimitX2 and isDrawable(x, y) then
					currentFrameBackgrounds[bufferIndex] = picture[pictureIndex]
					currentFrameForegrounds[bufferIndex] = picture[pictureIndex + 1]
					currentFrameSymbols[bufferIndex] = picture[pictureIndex + 2]
				end

				bufferIndex, pictureIndex = bufferIndex + 1, pictureIndex + 3
			end

			bufferIndex = bufferIndex + bufferIndexStepOnReachOfImageWidth
		else
			bufferIndex, pictureIndex = bufferIndex + bufferWidth, pictureIndex + imageWidth * 3
		end
	end
end

local function directCopy(x, y, width, height, tx, ty, current, actualBuffer)
	local index
	local imageWidth = width
	local bufferIndex, pictureIndex, bufferIndexStepOnReachOfImageWidth = bufferWidth * (ty - 1) + tx, 3, bufferWidth - imageWidth
	
	local newBackgrounds, newForegrounds, newSymbols, currentBackgrounds, currentForegrounds, currentSymbols
	
	if actualBuffer then
		newBackgrounds, newForegrounds, newSymbols, currentBackgrounds, currentForegrounds, currentSymbols = newFrameBackgrounds, newFrameForegrounds, newFrameSymbols, currentFrameBackgrounds, currentFrameForegrounds, currentFrameSymbols
	else
		newBackgrounds, newForegrounds, newSymbols = {table.unpack(newFrameBackgrounds)}, {table.unpack(newFrameForegrounds)}, {table.unpack(newFrameSymbols)}
	
	
		if current or bufferOnly then
			currentBackgrounds, currentForegrounds, currentSymbols = {table.unpack(currentFrameBackgrounds)}, {table.unpack(currentFrameForegrounds)}, {table.unpack(currentFrameSymbols)}
		end
	end
	
	for j = y, y + height - 1 do
		for i = x, x + width - 1 do
			local newX, newY = getCoordinates(bufferIndex)
			if i >= 1 and j >= 1 and i <= bufferWidth and j <= bufferHeight then
				index = bufferWidth * (j - 1) + i
				
				if newY >= drawLimitY1 and newY <= drawLimitY2 and newX >= drawLimitX1 and newX <= drawLimitX2 and isDrawable(ewX, newY) then
					newBackgrounds[bufferIndex] = newFrameBackgrounds[index]
					newForegrounds[bufferIndex] = newFrameForegrounds[index]
					newSymbols[bufferIndex] = newFrameSymbols[index]
					
					if current or bufferOnly then
						currentBackgrounds[bufferIndex] = currentFrameBackgrounds[index]
						currentForegrounds[bufferIndex] = currentFrameForegrounds[index]
						currentSymbols[bufferIndex] = currentFrameSymbols[index]
						--[[
						currentBackgrounds[bufferIndex] = newFrameBackgrounds[index]
						currentForegrounds[bufferIndex] = newFrameForegrounds[index]
						currentSymbols[bufferIndex] = newFrameSymbols[index]
						]]
					end
				end
			else
				if newY >= drawLimitY1 and newY <= drawLimitY2 and newX >= drawLimitX1 and newX <= drawLimitX2 and isDrawable(newX, newY) then
					newBackgrounds[bufferIndex] = 0x0
					newForegrounds[bufferIndex] = 0x0
					newSymbols[bufferIndex] = " "
					--[[
					newBackgrounds[newIndex] = 0x0
					newForegrounds[newIndex] = 0x0
					newSymbols[newIndex] = " "
					]]
					if current or bufferOnly then
						currentBackgrounds[bufferIndex] = 0x0
						currentForegrounds[bufferIndex] = 0x0
						currentSymbols[bufferIndex] = " "
					end
				end
			end
			bufferIndex, pictureIndex = bufferIndex + 1, pictureIndex + 3
		end
		bufferIndex = bufferIndex + bufferIndexStepOnReachOfImageWidth
	end
	newFrameBackgrounds, newFrameForegrounds, newFrameSymbols = newBackgrounds, newForegrounds, newSymbols
	if current or bufferOnly then
		currentFrameBackgrounds, currentFrameForegrounds, currentFrameSymbols = currentBackgrounds, currentForegrounds, currentSymbols
	end
end

local function rasterizeLine(x1, y1, x2, y2, method)
	local inLoopValueFrom, inLoopValueTo, outLoopValueFrom, outLoopValueTo, isReversed, inLoopValueDelta, outLoopValueDelta = x1, x2, y1, y2, false, mathAbs(x2 - x1), mathAbs(y2 - y1)
	if inLoopValueDelta < outLoopValueDelta then
		inLoopValueFrom, inLoopValueTo, outLoopValueFrom, outLoopValueTo, isReversed, inLoopValueDelta, outLoopValueDelta = y1, y2, x1, x2, true, outLoopValueDelta, inLoopValueDelta
	end

	if outLoopValueFrom > outLoopValueTo then
		outLoopValueFrom, outLoopValueTo = outLoopValueTo, outLoopValueFrom
		inLoopValueFrom, inLoopValueTo = inLoopValueTo, inLoopValueFrom
	end

	local outLoopValue, outLoopValueCounter, outLoopValueTriggerIncrement = outLoopValueFrom, 1, inLoopValueDelta / outLoopValueDelta
	local outLoopValueTrigger = outLoopValueTriggerIncrement
	for inLoopValue = inLoopValueFrom, inLoopValueTo, inLoopValueFrom < inLoopValueTo and 1 or -1 do
		if isReversed then
			method(outLoopValue, inLoopValue)
		else
			method(inLoopValue, outLoopValue)
		end

		outLoopValueCounter = outLoopValueCounter + 1
		if outLoopValueCounter > outLoopValueTrigger then
			outLoopValue, outLoopValueTrigger = outLoopValue + 1, outLoopValueTrigger + outLoopValueTriggerIncrement
		end
	end
end

local function rasterizeEllipse(centerX, centerY, radiusX, radiusY, method)
	local function rasterizeEllipsePoints(XP, YP)
		method(centerX + XP, centerY + YP)
		method(centerX - XP, centerY + YP)
		method(centerX - XP, centerY - YP)
		method(centerX + XP, centerY - YP) 
	end

	local x, y, changeX, changeY, ellipseError, twoASquare, twoBSquare = radiusX, 0, radiusY * radiusY * (1 - 2 * radiusX), radiusX * radiusX, 0, 2 * radiusX * radiusX, 2 * radiusY * radiusY
	local stoppingX, stoppingY = twoBSquare * radiusX, 0

	while stoppingX >= stoppingY do
		rasterizeEllipsePoints(x, y)
		
		y, stoppingY, ellipseError = y + 1, stoppingY + twoASquare, ellipseError + changeY
		changeY = changeY + twoASquare

		if (2 * ellipseError + changeX) > 0 then
			x, stoppingX, ellipseError = x - 1, stoppingX - twoBSquare, ellipseError + changeX
			changeX = changeX + twoBSquare
		end
	end

	x, y, changeX, changeY, ellipseError, stoppingX, stoppingY = 0, radiusY, radiusY * radiusY, radiusX * radiusX * (1 - 2 * radiusY), 0, 0, twoASquare * radiusY

	while stoppingX <= stoppingY do 
		rasterizeEllipsePoints(x, y)
		
		x, stoppingX, ellipseError = x + 1, stoppingX + twoBSquare, ellipseError + changeX
		changeX = changeX + twoBSquare
		
		if (2 * ellipseError + changeY) > 0 then
			y, stoppingY, ellipseError = y - 1, stoppingY - twoASquare, ellipseError + changeY
			changeY = changeY + twoASquare
		end
	end
end

local function drawLine(x1, y1, x2, y2, background, foreground, symbol)
	rasterizeLine(x1, y1, x2, y2, function(x, y)
		set(x, y, background, foreground, symbol)
	end)
end

local function drawEllipse(centerX, centerY, radiusX, radiusY, background, foreground, symbol)
	rasterizeEllipse(centerX, centerY, radiusX, radiusY, function(x, y)
		set(x, y, background, foreground, symbol)
	end)
end

local function drawText(x, y, textColor, data, transparency)
	if y >= drawLimitY1 and y <= drawLimitY2 then
		local charIndex, bufferIndex = 1, bufferWidth * (y - 1) + x
		
		for charIndex = 1, unicodeLen(data) do
			if x >= drawLimitX1 and x <= drawLimitX2 and isDrawable(x, y) then
				if transparency then
					newFrameForegrounds[bufferIndex] = colorBlend(newFrameBackgrounds[bufferIndex], textColor, transparency)
					if bufferOnly then
						currentFrameForegrounds[bufferIndex] = colorBlend(currentFrameBackgrounds[bufferIndex], textColor, transparency)
					end
				else
					newFrameForegrounds[bufferIndex] = textColor
					if bufferOnly then
						currentFrameForegrounds[bufferIndex] = textColor
					end
				end

				newFrameSymbols[bufferIndex] = unicodeSub(data, charIndex, charIndex)
				if bufferOnly then
					currentFrameSymbols[bufferIndex] = unicodeSub(data, charIndex, charIndex)
				end
			end

			x, bufferIndex = x + 1, bufferIndex + 1
		end
	end
end

local function drawImage(startX, startY, picture, blendForeground)
	local bufferIndex, pictureIndex, imageWidth, backgrounds, foregrounds, alphas, symbols = bufferWidth * (startY - 1) + startX, 1, picture[1], picture[3], picture[4], picture[5], picture[6]
	local bufferIndexStepOnReachOfImageWidth = bufferWidth - imageWidth

	for y = startY, startY + picture[2] - 1 do
		if y >= drawLimitY1 and y <= drawLimitY2 then
			for x = startX, startX + imageWidth - 1 do
				if x >= drawLimitX1 and x <= drawLimitX2 and isDrawable(x, y) then
					if alphas[pictureIndex] == 0 then
						newFrameBackgrounds[bufferIndex], newFrameForegrounds[bufferIndex] = backgrounds[pictureIndex], foregrounds[pictureIndex]
						if bufferOnly then
							currentFrameBackgrounds[bufferIndex], currentFrameForegrounds[bufferIndex] = backgrounds[pictureIndex], foregrounds[pictureIndex]
						end
					elseif alphas[pictureIndex] > 0 and alphas[pictureIndex] < 1 then
						newFrameBackgrounds[bufferIndex] = colorBlend(newFrameBackgrounds[bufferIndex], backgrounds[pictureIndex], alphas[pictureIndex])
						if bufferOnly then
							currentFrameBackgrounds[bufferIndex] = colorBlend(currentFrameBackgrounds[bufferIndex], backgrounds[pictureIndex], alphas[pictureIndex])
						end
						
						if blendForeground then
							newFrameForegrounds[bufferIndex] = colorBlend(newFrameForegrounds[bufferIndex], foregrounds[pictureIndex], alphas[pictureIndex])
							if bufferOnly then
								currentFrameForegrounds[bufferIndex] = colorBlend(currentFrameForegrounds[bufferIndex], foregrounds[pictureIndex], alphas[pictureIndex])
							end
						else
							newFrameForegrounds[bufferIndex] = foregrounds[pictureIndex]
							if bufferOnly then
								currentFrameForegrounds[bufferIndex] = foregrounds[pictureIndex]
							end
						end
					elseif alphas[pictureIndex] == 1 and symbols[pictureIndex] ~= " " then
						newFrameForegrounds[bufferIndex] = foregrounds[pictureIndex]
						if bufferOnly then
							currentFrameForegrounds[bufferIndex] = foregrounds[pictureIndex]
						end
					end

					newFrameSymbols[bufferIndex] = symbols[pictureIndex]
					if bufferOnly then
						currentFrameSymbols[bufferIndex] = symbols[pictureIndex]
					end
				end

				bufferIndex, pictureIndex = bufferIndex + 1, pictureIndex + 1
			end

			bufferIndex = bufferIndex + bufferIndexStepOnReachOfImageWidth
		else
			bufferIndex, pictureIndex = bufferIndex + bufferWidth, pictureIndex + imageWidth
		end
	end
end

local function drawFrame(x, y, width, height, color)
	local stringUp, stringDown, x2 = "┌" .. string.rep("─", width - 2) .. "┐", "└" .. string.rep("─", width - 2) .. "┘", x + width - 1
	
	drawText(x, y, color, stringUp); y = y + 1
	for i = 1, height - 2 do
		drawText(x, y, color, "│")
		drawText(x2, y, color, "│")
		y = y + 1
	end
	drawText(x, y, color, stringDown)
end

--------------------------------------------------------------------------------

local function semiPixelRawSet(index, color, yPercentTwoEqualsZero, internalRun) --ToDo
	local upperPixel, lowerPixel, bothPixel = "▀", "▄", " "
	local backgroundBuffer, foregroundBuffer, symbolBuffer = newFrameBackgrounds, newFrameForegrounds, newFrameSymbols
	
	if internalRun then
		backgroundBuffer, foregroundBuffer, symbolBuffer = currentFrameBackgrounds, currentFrameForegrounds, currentFrameSymbols
	end
	
	local background, foreground, symbol = backgroundBuffer[index], foregroundBuffer[index], symbolBuffer[index]

	if yPercentTwoEqualsZero then
		if symbol == upperPixel then
			if color == foreground then
				backgroundBuffer[index], foregroundBuffer[index], symbolBuffer[index] = color, foreground, bothPixel
			else
				backgroundBuffer[index], foregroundBuffer[index], symbolBuffer[index] = color, foreground, symbol
			end
		elseif symbol == bothPixel then
			if color ~= background then
				backgroundBuffer[index], foregroundBuffer[index], symbolBuffer[index] = background, color, lowerPixel
			end
		else
			backgroundBuffer[index], foregroundBuffer[index], symbolBuffer[index] = background, color, lowerPixel
		end
	else
		if symbol == lowerPixel then
			if color == foreground then
				backgroundBuffer[index], foregroundBuffer[index], symbolBuffer[index] = color, foreground, bothPixel
			else
				backgroundBuffer[index], foregroundBuffer[index], symbolBuffer[index] = color, foreground, symbol
			end
		elseif symbol == bothPixel then
			if color ~= background then
				backgroundBuffer[index], foregroundBuffer[index], symbolBuffer[index] = background, color, upperPixel
			end
		else
			backgroundBuffer[index], foregroundBuffer[index], symbolBuffer[index] = background, color, upperPixel
		end
	end
	
	if bufferOnly and not internalRun then
		semiPixelRawSet(index, color, yPercentTwoEqualsZero, true)
	end
end

local function semiPixelSet(x, y, color)
	local yFixed = mathCeil(y / 2)
	if x >= drawLimitX1 and yFixed >= drawLimitY1 and x <= drawLimitX2 and yFixed <= drawLimitY2 and isDrawable(x, yFixed) then
		semiPixelRawSet(bufferWidth * (yFixed - 1) + x, color, y % 2 == 0)
	end
end

local function drawSemiPixelRectangle(x, y, width, height, color)
	local index, indexStepForward, indexStepBackward, jPercentTwoEqualsZero, jFixed = bufferWidth * (mathCeil(y / 2) - 1) + x, (bufferWidth - width), width
	for j = y, y + height - 1 do
		jPercentTwoEqualsZero = j % 2 == 0
		
		for i = x, x + width - 1 do
			jFixed = mathCeil(j / 2)
			semiPixelRawSet(index, color, jPercentTwoEqualsZero)
			index = index + 1
		end

		if jPercentTwoEqualsZero then
			index = index + indexStepForward
		else
			index = index - indexStepBackward
		end
	end
end

local function drawSemiPixelLine(x1, y1, x2, y2, color)
	rasterizeLine(x1, y1, x2, y2, function(x, y)
		semiPixelSet(x, y, color)
	end)
end

local function drawSemiPixelEllipse(centerX, centerY, radiusX, radiusY, color)
	rasterizeEllipse(centerX, centerY, radiusX, radiusY, function(x, y)
		semiPixelSet(x, y, color)
	end)
end

--------------------------------------------------------------------------------

local function getPointTimedPosition(firstPoint, secondPoint, time)
	return {
		x = firstPoint.x + (secondPoint.x - firstPoint.x) * time,
		y = firstPoint.y + (secondPoint.y - firstPoint.y) * time
	}
end

local function getConnectionPoints(points, time)
	local connectionPoints = {}
	for point = 1, #points - 1 do
		tableInsert(connectionPoints, getPointTimedPosition(points[point], points[point + 1], time))
	end
	return connectionPoints
end

local function getMainPointPosition(points, time)
	if #points > 1 then
		return getMainPointPosition(getConnectionPoints(points, time), time)
	else
		return points[1]
	end
end

local function drawSemiPixelCurve(points, color, precision)
	local linePoints = {}
	for time = 0, 1, precision or 0.01 do
		tableInsert(linePoints, getMainPointPosition(points, time))
	end
	
	for point = 1, #linePoints - 1 do
		drawSemiPixelLine(mathFloor(linePoints[point].x), mathFloor(linePoints[point].y), mathFloor(linePoints[point + 1].x), mathFloor(linePoints[point + 1].y), color)
	end
end

--------------------------------------------------------------------------------

local function drawChanges(force)
	local index, indexStepOnEveryLine, changes = bufferWidth * (drawLimitY1 - 1) + drawLimitX1, (bufferWidth - drawLimitX2 + drawLimitX1 - 1), {}
	local x, equalChars, equalCharsIndex, charX, charIndex, currentForeground
	local currentFrameBackground, currentFrameForeground, currentFrameSymbol, changesCurrentFrameBackground, changesCurrentFrameBackgroundCurrentFrameForeground

	local changesCurrentFrameBackgroundCurrentFrameForegroundIndex

	for y = drawLimitY1, drawLimitY2 do
		x = drawLimitX1
		while x <= drawLimitX2 do			
			-- Determine if some pixel data was changed (or if <force> argument was passed)
			if
				currentFrameBackgrounds[index] ~= newFrameBackgrounds[index] or
				currentFrameForegrounds[index] ~= newFrameForegrounds[index] or
				currentFrameSymbols[index] ~= newFrameSymbols[index] or
				force
			then
				-- Make pixel at both frames equal
				currentFrameBackground, currentFrameForeground, currentFrameSymbol = newFrameBackgrounds[index], newFrameForegrounds[index], newFrameSymbols[index]
				currentFrameBackgrounds[index] = currentFrameBackground
				currentFrameForegrounds[index] = currentFrameForeground
				currentFrameSymbols[index] = currentFrameSymbol

				-- Look for pixels with equal chars from right of current pixel
				equalChars, equalCharsIndex, charX, charIndex = {currentFrameSymbol}, 2, x + 1, index + 1
				while charX <= drawLimitX2 do
					-- Pixels becomes equal only if they have same background and (whitespace char or same foreground)
					if	
						currentFrameBackground == newFrameBackgrounds[charIndex] and
						(
							newFrameSymbols[charIndex] == " " or
							currentFrameForeground == newFrameForegrounds[charIndex]
						)
					then
						-- Make pixel at both frames equal
					 	currentFrameBackgrounds[charIndex] = newFrameBackgrounds[charIndex]
					 	currentFrameForegrounds[charIndex] = newFrameForegrounds[charIndex]
					 	currentFrameSymbols[charIndex] = newFrameSymbols[charIndex]

					 	equalChars[equalCharsIndex], equalCharsIndex = currentFrameSymbols[charIndex], equalCharsIndex + 1
					else
						break
					end

					charX, charIndex = charX + 1, charIndex + 1
				end

				-- Group pixels that need to be drawn by background and foreground
				changes[currentFrameBackground] = changes[currentFrameBackground] or {}
				changesCurrentFrameBackground = changes[currentFrameBackground]
				changesCurrentFrameBackground[currentFrameForeground] = changesCurrentFrameBackground[currentFrameForeground] or {index = 1}
				changesCurrentFrameBackgroundCurrentFrameForeground = changesCurrentFrameBackground[currentFrameForeground]
				changesCurrentFrameBackgroundCurrentFrameForegroundIndex = changesCurrentFrameBackgroundCurrentFrameForeground.index
				
				changesCurrentFrameBackgroundCurrentFrameForeground[changesCurrentFrameBackgroundCurrentFrameForegroundIndex], changesCurrentFrameBackgroundCurrentFrameForegroundIndex = x, changesCurrentFrameBackgroundCurrentFrameForegroundIndex + 1
				changesCurrentFrameBackgroundCurrentFrameForeground[changesCurrentFrameBackgroundCurrentFrameForegroundIndex], changesCurrentFrameBackgroundCurrentFrameForegroundIndex = y, changesCurrentFrameBackgroundCurrentFrameForegroundIndex + 1
				changesCurrentFrameBackgroundCurrentFrameForeground[changesCurrentFrameBackgroundCurrentFrameForegroundIndex], changesCurrentFrameBackgroundCurrentFrameForegroundIndex = tableConcat(equalChars), changesCurrentFrameBackgroundCurrentFrameForegroundIndex + 1
				
				x, index, changesCurrentFrameBackgroundCurrentFrameForeground.index = x + equalCharsIndex - 2, index + equalCharsIndex - 2, changesCurrentFrameBackgroundCurrentFrameForegroundIndex
			end

			x, index = x + 1, index + 1
		end

		index = index + indexStepOnEveryLine
	end
	
	-- Draw grouped pixels on screen
	for background, foregrounds in pairs(changes) do
		GPUProxySetBackground(background)

		for foreground, pixels in pairs(foregrounds) do
			if currentForeground ~= foreground then
				GPUProxySetForeground(foreground)
				currentForeground = foreground
			end

			for i = 1, #pixels, 3 do
				GPUProxySet(pixels[i], pixels[i + 1], pixels[i + 2])
			end
		end
	end

	changes = nil
end

--------------------------------------------------------------------------------

bindGPU(component.getPrimary("gpu").address)

return {
	getCoordinates = getCoordinates,
	getIndex = getIndex,
	setDrawLimit = setDrawLimit,
	resetDrawLimit = resetDrawLimit,
	getDrawLimit = getDrawLimit,
	flush = flush,
	setResolution = setResolution,
	bindScreen = bindScreen,
	bindGPU = bindGPU,
	getGPUProxy = getGPUProxy,
	getResolution = getResolution,
	getWidth = getWidth,
	getHeight = getHeight,
	getCurrentFrameTables = getCurrentFrameTables,
	getNewFrameTables = getNewFrameTables,
	setCurrentFrameTables = setCurrentFrameTables,
	setNewFrameTables = setNewFrameTables,
	setBufferOnly = setBufferOnly,
	getBufferOnly = getBufferOnly,

	rawSet = rawSet,
	rawGet = rawGet,
	get = get,
	set = set,
	clear = clear,
	copy = copy,
	paste = paste,
	directCopy = directCopy,
	copyCurrent = copyCurrent,
	pasteCurrent = pasteCurrent,
	rasterizeLine = rasterizeLine,
	rasterizeEllipse = rasterizeEllipse,
	semiPixelRawSet = semiPixelRawSet,
	semiPixelSet = semiPixelSet,
	drawChanges = drawChanges,

	drawRectangle = drawRectangle,
	drawLine = drawLine,
	drawEllipse = drawEllipse,
	drawText = drawText,
	drawImage = drawImage,
	drawFrame = drawFrame,

	drawSemiPixelRectangle = drawSemiPixelRectangle,
	drawSemiPixelLine = drawSemiPixelLine,
	drawSemiPixelEllipse = drawSemiPixelEllipse,
	drawSemiPixelCurve = drawSemiPixelCurve,
	
	setDrawAreas = setDrawAreas,
	resetDrawAreas = resetDrawAreas,
	getDrawAreas = getDrawAreas,
	setNonDrawAreas = setNonDrawAreas,
	resetNonDrawAreas = resetNonDrawAreas,
	getNonDrawAreas = getNonDrawAreas,
	
	setDrawAreaOffset = setDrawAreaOffset,
	getDrawAreaOffset = getDrawAreaOffset,
	resetDrawAreaOffset = resetDrawAreaOffset,
}