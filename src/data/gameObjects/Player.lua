local global = ...

Player = {}
Player.__index = Player

function Player.init(this) --will calles when the gameObject become loaded/reloaded.
	--global.log("Player: init")
end

function Player.new(args)
	--===== gameObject definition =====--
	args = args or {}
	args.sizeX = 6
	args.sizeY = 6
	args.components = {
		{"Sprite", texture = global.texture.player.right},
		--{"Sprite", texture = "grass"},
		{"RigidBody", g = 0, stiffness = 3},
		--{"BoxCollider", sx = args.sizeX, sy = args.sizeY},
	}
	
	--===== default stuff =====--
	local this = global.core.GameObject.new(args)
	this = setmetatable(this, Player)
	
	--===== init =====--
	local pa = global.ut.parseArgs
	
	this.stats = args.stats
	
	this.fuel = this.stats.startFuel
	this.life = this.stats.life
	this.armor = this.stats.armor
	
	this.exhaustOffsetX = pa(args.exhaustOffsetX, args.eox, 0)
	this.exhaustOffsetY = pa(args.exhaustOffsetY, args.eoy, 0)
	
	this.startPosY = select(2, this:getPos())
	this.line = args.line or 0
	this.momentum = 0
	
	this.driving = false
	this.maxSmoke = 10
	
	this.gameObject:addBoxCollider({sx = args.sizeX, sy = args.sizeY, lf = function(_, gameObject)
		local barrier = gameObject.gameObject.parent
		local speedX = this:getSpeed()
		local damage = speedX * this.stats.damage
		local backDamage, speedLoss, fuel = barrier:collide(damage, speedX)
		
		this.fuel = math.min(this.fuel + fuel, this.stats.fuelTank)
		
		this.life = this.life - math.max(math.floor(speedX) * backDamage / math.max(this.armor, 1), 0)
		this.armor = this.armor - math.floor(speedX) * backDamage
		
		this.momentum = this.momentum + speedX * (1 - math.min(speedLoss, 1))
	end})
	
	
	--===== global functions =====--
	
	
	this.ctrl_go_key_down = function(this)
		this.driving = true
		global.state.game.pcExhaust.smokeRate = this.maxSmoke * 2 * global.conf.particles
	end
	this.ctrl_up_key_down = function(this)
		local newLine = math.min(this.line +1, global.state.game.lines -1)
		
		if newLine ~= this.line then
			this.line = newLine
		end
	end
	this.ctrl_down_key_down = function(this)
		local newLine = math.max(this.line -1, 0)
		
		if newLine ~= this.line then
			this.line = newLine
		end
	end
	
	--===== default functions =====--
	this.start = function(this) --will called everytime a new object of the gameObject is created.
		
	end
	
	this.stop = function(this) --will called when gameObject object becomes deloaded (e.g. out of screen)
		
	end
	
	this.update = function(this, dt, ra) --will called on every game tick.
		local game = global.state.game
		local streetWidth = game.streetWidth
		local force = this.stats.acceleration
		local posX, posY = this:getPos()
		local speedX, speedY = this:getSpeed()
		local targetY = this.line * streetWidth
		local relativePosY = this.startPosY - posY
		
		this:addSpeed(this.momentum, 0)
		this.momentum = 0
		
		
		if speedY >= -1 and relativePosY < targetY or relativePosY < targetY - streetWidth /2 then
			this:addForce(0, -this.stats.traction *dt, this.stats.traction)
		elseif speedY <= 1 and relativePosY > targetY or relativePosY > targetY + streetWidth /2 then
			this:addForce(0, this.stats.traction *dt, this.stats.traction)
		end
		
		
		if game.pcExhaust.smokeRate > this.maxSmoke then
			game.pcExhaust.smokeRate = math.max(game.pcExhaust.smokeRate - 5 *dt, this.maxSmoke)
		end
		
		if this.driving then
			this.fuel = math.max(this.fuel - this.stats.fuelConsumption * global.dt, 0)
		
			if this.fuel > 0 then
				this:addForce(force *10 * global.dt, 0, this.stats.maxSpeed)
			else
				game.pcExhaust.smokeRate = 0
			end	
		end
		
		this.gameObject:playAnimation(select(1, this:getSpeed() /2))
		
		game.ra1:moveCameraTo(posX + game.cameraOffsetX, game.cameraOffsetY)
	end
	
	this.draw = function(this) --will called every time the gameObject will drawed.
		
	end
	
	this.clear = function(this, acctual) --will called when the sntity graphics are removed.
		
	end
	
	this.activate = function(this) --will called when the gameObject get activated by player or signal (not implemented yet).
		
	end
	
	return this
end

return Player