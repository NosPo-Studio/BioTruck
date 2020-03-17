local global = ...

Player = {}
Player.__index = Player

function Player.init(this) --will calles when the gameObject become loaded/reloaded.
	--global.log("Player: init")
end

function Player.new(args)
	--===== gameObject definition =====--
	args = args or {}
	args.sizeX = 35
	args.sizeY = 8
	args.components = {
		{"Sprite", texture = "truck"},
		--{"Sprite", texture = "street1"},
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
	
	this.startPosY = select(2, this:getPos())
	this.line = args.line or 0
	this.lastLine = this.line
	this.momentumX = 0
	this.momentumY = 0
	
	this.driving = false
	this.maxExhaustSmoke = 5
	this.maxDamageSmoke = 8
	this.maxDamageFire = 8
	
	this.state = global.getState()
	
	this.gameObject:addBoxCollider({sx = args.sizeX, sy = args.sizeY, lf = function(_, gameObject)
		local barrier = gameObject.gameObject.parent
		if barrier.collide == nil then return end
		local speedX, speedY = this:getSpeed()
		local damage = speedX * this.stats.damage
		local backDamage, speedLoss, fuel, money = barrier:collide(damage, speedX)
		
		this.fuel = math.min(this.fuel + fuel, this.stats.fuelTank)
		
		this.life = this.life - math.max(math.floor(speedX) * backDamage / math.max(this.armor, 1), 0)
		this.armor = this.armor - math.floor(speedX) * backDamage
		global.stats.player.money = global.stats.player.money + money
		
		this.momentumX = this.momentumX + speedX * (1 - math.min(speedLoss, 1))
		this.momentumY = this.momentumY + speedY * (1 - math.min(speedLoss, 1))
	end})
	
	this.gameObject.test = true
	
	
	--===== global functions =====--
	
	
	this.ctrl_go_key_down = function(this)
		this.driving = true
		this.state.pcExhaust:setSmokeRate(this.maxExhaustSmoke * 2)
	end
	this.ctrl_up_key_down = function(this)
		local newLine = math.min(this.line +1, this.state.lines -1)
		
		if newLine ~= this.line then
			this.lastLine = this.line
			this.line = newLine
		end
	end
	this.ctrl_down_key_down = function(this)
		local newLine = math.max(this.line -1, 0)
		
		if newLine ~= this.line then
			this.lastLine = this.line
			this.line = newLine
		end
	end
	
	--===== default functions =====--
	this.start = function(this) --will called everytime a new object of the gameObject is created.
		
	end
	
	this.stop = function(this) --will called when gameObject object becomes deloaded (e.g. out of screen)
		
	end
	
	this.update = function(this, dt, ra) --will called on every game tick.
		--local game = this.state
		local game = global.getState()
		local streetWidth = game.streetWidth
		local force = this.stats.acceleration
		local posX, posY = this:getPos()
		local speedX, speedY = this:getSpeed()
		local targetY = this.line * streetWidth
		local relativePosY = this.startPosY - posY
		
		this:addForce(this.momentumX, this.momentumY)
		this.momentumX, this.momentumY = 0, 0
		
		
		if speedY >= -1 and relativePosY < targetY or relativePosY < targetY - streetWidth /2 then
			this:addForce(0, -this.stats.traction *dt, this.stats.traction)
		elseif speedY <= 1 and relativePosY > targetY or relativePosY > targetY + streetWidth /2 then
			this:addForce(0, this.stats.traction *dt, this.stats.traction)
		end
		
		
		if game.pcExhaust:getSmokeRate() > this.maxExhaustSmoke then
			game.pcExhaust:setSmokeRate(math.max(game.pcExhaust.smokeRate - 5 *dt, this.maxExhaustSmoke))
		end
		
		game.pcDamageSmoke:setSmokeRate(this.maxDamageSmoke * (1 - this.life / this.stats.life))
		game.pcDamageFire:setSmokeRate(this.maxDamageFire * (1 - this.life / this.stats.life))
		
		if this.driving then
			this.fuel = math.max(this.fuel - this.stats.fuelConsumption * global.dt, 0)
		
			if this.fuel > 0 and this.life > 0 then
				this:addForce(force *10 * global.dt, 0, this.stats.maxSpeed)
				game.pcExhaust:setSmokeRate(this.maxExhaustSmoke)
			else
				game.pcExhaust:setSmokeRate(0)
			end	
		end
		
		this.gameObject:playAnimation(select(1, this:getSpeed() /2))
		
		game.raMain:moveCameraTo(posX + game.cameraOffsetX, game.cameraOffsetY)
		if game.raTest ~= nil then
			game.raTest:moveCameraTo(posX + game.cameraOffsetX -20, game.cameraOffsetY)
		end
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