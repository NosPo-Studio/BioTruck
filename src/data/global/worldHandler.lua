local global = ...
local wh = {
	game,
	ra,
	biome,
	posY,
	lastStreetPosX = 0,
	lastBarrierPosX = {},
	lastCalculatedX = 0,
}

--===== local functions =====--
local function print(...)
	if global.conf.debug.whDebug then
		global.debug(...)
	end
end

local function initBiomes()
	for i, b in pairs(global.biome) do
		if type(b) == "table" then
			b.maxStreetChance, b.maxBarrierChance, b.maxFuelContainerChance = 0, 0, 0
			for i, o in pairs(b.streets) do
				b.maxStreetChance = b.maxStreetChance + o.chance
			end
			for i, o in pairs(b.barriers) do
				b.maxBarrierChance = b.maxBarrierChance + o.chance
			end
			for i, o in pairs(b.fuelContainers) do
				b.maxFuelContainerChance = b.maxFuelContainerChance + o.chance
			end
		end
	end
end

local function pickObject(maxChance, objects)
	local rng = math.random(wh.biome.maxStreetChance)
	local objectCount = 0
	local go = {}
	
	for i, o in pairs(objects) do
		objectCount = objectCount + o.chance
		if objectCount >= rng then
			return o
		end
	end
end

local function placeStreet(toX)
	while wh.lastStreetPosX < toX do
		go = wh.ra:addGO(pickObject(wh.maxStreetChance, wh.biome.streets).name, {
			posX = wh.lastStreetPosX, 
			posY = wh.posY, 
			layer = 2,
			name = "Street",
		})
		wh.lastStreetPosX = wh.lastStreetPosX + go.ngeAttributes.sizeX
	end
end

local function placeBarrier(fromX, toX)
	local posX = fromX
	
	while posX < toX do
		for i, lbp in pairs(wh.lastBarrierPosX) do
			if lbp < posX and math.random(wh.biome.barrierChance) == wh.biome.barrierChance then
				print("[WH]: Adding barrier: X: " .. tostring(posX) .. " Y: " .. tostring(wh.posY + (i -1) * wh.game.streetWidth))
				local barrier = pickObject(wh.maxBarrierChance, wh.biome.barriers)
				local object = wh.ra:addGO(barrier.name, {
					posX = posX,
					posY = wh.posY + (i -1) * wh.game.streetWidth, 
					layer = 3,
					defaultParticleContainer = wh.game.pcDefaultParticleContainer,
					name = "Barrier",
				})
				
				wh.lastBarrierPosX[i] = posX + object.ngeAttributes.sizeX
				
			end
		end
		posX = posX +1
	end
	
end

local function generateWorld(fromX, toX)	
	toX = toX +3
	placeStreet(toX)
	placeBarrier(fromX, toX)
	
	wh.lastCalculatedX = toX
end

--===== global functions =====--
function wh.start(game, y, biome)
	initBiomes()
	
	wh.game = game
	wh.ra = game.raMain
	wh.posY = y
	wh.lastBarrierPosX = {}
	local fromX, toX = wh.ra:getFOV()
	
	for i = 1, game.lines do
		wh.lastBarrierPosX[i] = 0
	end
	
	wh.biome = global.biome[biome]
	
	generateWorld(fromX +20, toX)
	
end

function wh.update()
	local fromX, toX = wh.ra:getFOV()
	generateWorld(wh.lastCalculatedX, toX)
end

function wh.stop()
	
end

return wh