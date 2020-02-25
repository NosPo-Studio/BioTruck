local global = ...

Player = {}
Player.__index = Player

function Player.init(this) --will calles when the gameObject become loaded/reloaded.
	--global.log("Player: init")
end

function Player.new(args)
	local pa = global.ut.parseArgs
	local texture = {{"b", args.bc}, {"f", args.fc}}
	
	--===== gameObject definition =====--
	args = args or {}
	args.posX = pa(args.x, args.posX)
	args.posY = pa(args.y, args.posY)
	args.sizeX = args.buttonSizeX + 10
	args.sizeY = args.buttonSizeY
	local ui = pa(args.ui, args.ocui, global.ocui)
	
	--===== default stuff =====--
	local this = global.core.GameObject.new(args)
	this = setmetatable(this, Player)
	
	this.stat = args.stat
	this.colors = args.colors
	
	this.button = ui.Button.new(ui, {
		x = args.posX,
		y = args.posY,
		sx = args.buttonSizeX,
		sy = args.buttonSizeY,
		textures = {
			global.getButtonTexture(args.buttonSizeX, args.buttonSizeY, this.colors.button[1], this.colors.button[2], args.statName),
			global.getButtonTexture(args.buttonSizeX, args.buttonSizeY, this.colors.button[3], this.colors.button[4], args.statName),
		},
		lf = function() 
			if global.stats.player.money > 0 then
				global.stats.player[this.stat] = global.stats.player[this.stat] +1
				global.log(global.stats.player[this.stat])
				this.ngeAttributes.hasMoved = true
				global.stats.player.money = global.stats.player.money -1
			end
		end,
	})
	--===== init =====--
	
	--===== global functions =====--
	
	--===== default functions =====--
	this.update = function(this, dt, ra) --will called on every game tick.
		
	end
	
	this.draw = function(this)
		local x, y = this:getPos()
		local sx, sy = this:getSize()
		
		global.gpu.setBackground(this.colors.background[1])
		global.gpu.setForeground(this.colors.background[2])
		
		global.gpu.fill(x, y, sx, sy, " ")
		global.gpu.set(x + args.buttonSizeX +2, y + math.floor(sy /2), tostring(global.stats.player[this.stat]))
	end
	
	this.stop = function(this)
		this.button:stop()
	end
	
	return this
end

return Player