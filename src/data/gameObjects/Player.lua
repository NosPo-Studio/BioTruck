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
	
	this.fuelEarned = 0
	this.moneyEarned = 0
	
	this.startPosY = select(2, this:getPos())
	this.line = args.line or 0
	this.lastLine = this.line
	this.momentumX = 0
	this.momentumY = 0
	
	this.driving = false
	this.maxExhaustSmoke = 5
	this.maxDamageSmoke = 6
	this.maxDamageFire = 1
	this.explosionSmoke = 30
	this.explosionFire = 30
	this.explosionForce = 10
	this.fullDamageSmoke = 14
	this.fullDamageFire = 14
	this.isExploded = false
	
	this.fullDamageSlowDown = 5
	
	this.state = global.getState()
	
	this.gameObject:addBoxCollider({sx = args.sizeX, sy = args.sizeY, lf = function(_, gameObject)
		local barrier = gameObject.gameObject.parent
		if barrier.collide == nil then return end
		local speedX, speedY = this:getSpeed()
		local damage = speedX * this.stats.damage
		local backDamage, speedLoss, fuel, money = barrier:collide(damage, speedX)
		
		this.fuel = math.min(this.fuel + fuel, this.stats.fuelTank)
		this.fuelEarned = this.fuelEarned + fuel
		this.moneyEarned = this.moneyEarned + money
		global.stats.player.money = global.stats.player.money + money
		
		this.life = this.life - math.max(math.floor(speedX) * backDamage / math.max(this.armor, 1), 0)
		this.armor = this.armor - math.floor(speedX) * backDamage
		
		this.momentumX = this.momentumX + speedX * (1 - math.min(speedLoss, 1))
		this.momentumY = this.momentumY + speedY * (1 - math.min(speedLoss, 1))
	end})
	
	if global.conf.particles > 0 then
		this.pcExhaust = this.state.raMain:addGO("Exhaust", {
			width = 1, 
			height = 1, 
			particle = "Smoke", 
			parent = this,
			smokeRate = 2,
			--particleContainer = this.pcDefaultParticleContainer,
			oy = -1,
			ox = 26,
		})
		this.pcDamageSmoke = this.state.raMain:addGO("Exhaust", {
			width = 6, 
			height = 1, 
			particle = "Smoke", 
			parent = this,
			smokeRate = 0,
			particleContainer = this.pcExhaust.particleContainer,
			oy = 3,
			ox = 28,
		})
		this.pcDamageFire = this.state.raMain:addGO("Exhaust", {
			width = 6, 
			height = 1, 
			particle = "Fire", 
			parent = this,
			smokeRate = 0,
			--particleContainer = this.pcDefaultParticleContainer,
			oy = 3,
			ox = 28,
		})	
	else
		local exhaustPlaceHolder = {setSmokeRate = function() end, getSmokeRate = function() return 0 end, offsetX = 0, offsetY = 0, width = 0, height = 0}
		this.pcExhaust = exhaustPlaceHolder --prevents crash caused by Player.lua if no pcExhaust is existing.
		this.pcDamageSmoke = exhaustPlaceHolder --prevents crash caused by Player.lua if no pcExhaust is existing.
		this.pcDamageFire = exhaustPlaceHolder --prevents crash caused by Player.lua if no pcExhaust is existing.
	end
	
	--===== global functions =====--
	
	
	this.ctrl_go_key_down = function(this)
		this.driving = true
		this.pcExhaust:setSmokeRate(this.maxExhaustSmoke * 2)
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
	this.ctrl_selfDestroy_key_down = function(this)
		this.life = 0
	end
	
	--===== default functions =====--
	this.start = function(this) --will called everytime a new object of the gameObject is created.
		--this.life = 0 --debug
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
		
		--this:addForce(this.momentumX, this.momentumY)
		this:addForce(this.momentumX, 0)
		this.momentumX, this.momentumY = 0, 0
		speedX, speedY = this:getSpeed()
		
		
		if relativePosY < targetY then --tmp
			this:setSpeed(speedX, 8)
		elseif relativePosY > targetY then
			this:setSpeed(speedX, -8)
		else
			this:setSpeed(speedX, 0)
		end
		--[[
		global.log(this.stats.traction,
			--math.max(math.min((targetY - relativePosY) / streetWidth, 1), -1),
			(targetY - relativePosY) / streetWidth
		)
		]]
		if relativePosY < targetY - streetWidth / 2 then
			--global.log("T1")
		elseif relativePosY > targetY + streetWidth / 2 then
			--global.log("T2")
		else
			--global.log("T3")
		end
		
		if this.pcExhaust:getSmokeRate() > this.maxExhaustSmoke then
			this.pcExhaust:setSmokeRate(math.max(this.pcExhaust.smokeRate - 5 *dt, this.maxExhaustSmoke))
		end	
		
		--this.life = math.max(this.life - 5 * dt, 0)
		
		if this.life <= 0 and not this.isExploded then
			local x, y = this:getPos()
			local pc = this.pcDamageFire
			x, y = x + pc.offsetX + pc.width / 2, y + pc.offsetY + pc.height / 2
			
			
			global.sfx.explosion(pc, x, y, "Smoke", this.explosionSmoke, this.explosionForce, {lt = 5, ltrng = 3, fx = speedX / 2})
			global.sfx.explosion(pc, x, y, "Fire", this.explosionFire, this.explosionForce, {lt = 3, ltrng = 1.5, fx = speedX / 2})
			
			this.pcDamageSmoke:setSmokeRate(this.fullDamageSmoke)
			this.pcDamageFire:setSmokeRate(this.fullDamageFire)
			
			this.isExploded = true
		elseif not this.isExploded then
			this.pcDamageSmoke:setSmokeRate(this.maxDamageSmoke * (1 - this.life / this.stats.life))
			this.pcDamageFire:setSmokeRate(this.maxDamageFire * (1 - this.life / this.stats.life))
		end
		
		if this.driving then
			this.fuel = math.max(this.fuel - this.stats.fuelConsumption * global.dt, 0)
		
			if this.fuel > 0 and this.life > 0 then
				this:addForce(force *10 * global.dt, 0, this.stats.maxSpeed)
				this.pcExhaust:setSmokeRate(this.maxExhaustSmoke)
			else
				this.pcExhaust:setSmokeRate(0)
			end	
		end
		
		if this.life <= 0 and speedX > 0 then
			this:addForce(-this.fullDamageSlowDown * dt, 0)
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
	
	this.stop = function(this) --will called when gameObject object becomes deloaded (e.g. out of screen)
		if global.conf.particles > 0 then
			this.state.raMain:remGO(this.pcExhaust)
			this.state.raMain:remGO(this.pcDamageSmoke)
			this.state.raMain:remGO(this.pcDamageFire)
		end
	end
	
	return this
end

return Player