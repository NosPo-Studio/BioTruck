local global = ...

ScoreScreen = {}
ScoreScreen.__index = ScoreScreen

function ScoreScreen.init(this) --will calles when the gameObject become loaded/reloaded.
	this.controls = {reset = "", garage = ""}
	
	local function parseConsols(controls)
		for i, ct in pairs(controls) do
			for _, c in pairs(ct) do
				if c == "reset" then
					this.controls.reset = this.controls.reset .. " or \"" ..  string.char(i) .. "\""
				elseif c == "garage" then
					this.controls.garage = this.controls.garage .. " or \"" ..  string.char(i) .. "\""
				end
			end
		end
	end
	
	parseConsols(global.controls.c)
	parseConsols(global.controls.k)
	parseConsols(global.controls.m)
	
	this.controls.reset = this.controls.reset:sub(5)
	this.controls.garage = this.controls.garage:sub(5)
end

function ScoreScreen.new(args)
	local pa = global.ut.parseArgs
	
	local len = global.unicode.len
	
	--===== gameObject definition =====--
	args = args or {}
	args.sizeX = 40
	args.sizeY = 8
	
	local text = {
		reset = "To reset press: " .. ScoreScreen.controls.reset,
	}
	
	args.components = {
		{"Sprite", x = 0, y = 0, texture = global.oclrl.generateTexture({
			{"b", global.conf.colors.background[1]},
			{"f", global.conf.colors.background[2]},
			
			{0, 0, args.sizeX, args.sizeY, " "},

			{0, 0, args.sizeX, 1, "#"},
			{0, args.sizeY -1, args.sizeX, 1, "#"},
			{0, 0, 1, args.sizeY, "#"},
			{args.sizeX, 0, 1, args.sizeY, "#"},
			
			
			--{args.sizeX / 2 - len(text.reset) / 2, args.sizeY -2, text.reset},
		})},
	}
	args.posX = 0
	args.posY = 0
	
	--===== default stuff =====--
	local this = global.core.GameObject.new(args)
	this = setmetatable(this, ScoreScreen)
	
	--===== init =====--
	this.state = global.getState()
	
	this.maxSpeedY = 15
	this.uiHeight = args.uiHeight
	this.money = args.money
	this.fuel = args.fuel
	this.distance = args.distance
	this.score = args.score
	this.player = args.player
	
	local text = {
		player = "Player: " .. tostring(this.player),
		money = "Money earned: " .. tostring(this.money), -- .. ", total money: " .. tostring(global.stats.player.money),
		fuel = "Fuel earned: " .. tostring(this.fuel),
		distance = "Distance traveled: " .. tostring(this.distance),
		score = "Score: " .. tostring(this.score),
	}
	
	this.gameObject:addSprite({x = 0, y = 0, texture = global.oclrl.generateTexture({
		{"b", global.conf.colors.background[1]},
		{"f", global.conf.colors.background[2]},
		
		{args.sizeX / 2 - len(text.player) / 2, 1, text.player},
		{args.sizeX / 2 - len(text.money) / 2, 2, text.money},
		{args.sizeX / 2 - len(text.fuel) / 2, 3, text.fuel},
		{args.sizeX / 2 - len(text.distance) / 2, 4, text.distance},
		{args.sizeX / 2 - len(text.score) / 2, 5, text.score},
	})})
	
	--this.menu:add({this.bRestart, 3, 3})
	
	--===== global functions =====--
	this.touch = function(sname, s)
		this.lastY = s[4]
		this.isMoving = false
	end
	
	--===== default functions =====--
	this.start = function(this)
		local fx, tx, fy, ty = this.state.raMain:getFOV()
		this:moveTo(0, ty)
	end	
	
	this.update = function(this, dt, ra) --will called on every game tick.
		local fx, tx, fy, ty = this.state.raMain:getFOV()
		local x, y = this:getPos()
		
		this:moveTo(fx + (tx - fx) / 2 - args.sizeX / 2, math.max(y - this.maxSpeedY * dt, ty - args.sizeY))
	end
	
	return this
end

return ScoreScreen