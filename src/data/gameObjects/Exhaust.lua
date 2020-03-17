local global = ...

Exhaust = {}
Exhaust.__index = Exhaust

function Exhaust.init(this) --will calles when the gameObject become loaded/reloaded.
	--global.log("Exhaust: init")
end

function Exhaust.new(args)
	--===== gameObject definition =====--
	args = args or {}
	--args.particle = "TestParticle2"
	args.type = 1
	args.useCollision = false
	args.updateAlways = true
	
	--===== default stuff =====--
	local this = nil
	
	if args.particleContainer ~= nil then
		this = args.particleContainer
	else
		this = global.parent.ParticleContainer.new(args)
	end
	
	this = setmetatable(this, Exhaust)
	
	--===== init =====--
	local pa = global.ut.parseArgs
	
	this.parent = args.parent
	this.smokeRate = global.ut.parseArgs(args.smokeRate, 2) * global.ut.parseArgs(global.conf.particles, 1)
	this.particle = args.particle or "Smoke"
	this.width = pa(args.width)
	this.height = pa(args.height)
	this.offsetX = pa(args.ox, args.offsetX, 0)
	this.offsetY = pa(args.oy, args.offsetY, 0)
	
	this.pastTime = 0
	
	--===== global functions =====--
	this.setSmokeRate = function(this, sr)
		this.smokeRate = sr * global.ut.parseArgs(global.conf.particles, 1)
	end
	this.getSmokeRate = function(this)
		return this.smokeRate
	end
	
	--===== default functions =====--
	this.start = function(this) --will called everytime a new object of the gameObject is created.
		
	end
	
	this.update = function(this, dt, ra) --will called on every game tick.
		this.pastTime = this.pastTime + dt
		
		local x, y = this.parent:getPos()
		local toSpawn = math.floor(this.pastTime * this.smokeRate)
		this.pastTime = this.pastTime - toSpawn / this.smokeRate
		
		if this.pastTime ~= this.pastTime then 
			this.pastTime = 0
		end
		
		for c = 1, toSpawn do
			--global.log(this.particle, x + this.parent.exhaustOffsetX, y + this.parent.exhaustOffsetY)
			local rx, ry = math.random(this.width) -1, math.random(this.height) -1
			
			local particle = this:addParticle(this.particle, x + this.offsetX + rx, y + this.offsetY + ry)
			
			particle.gameObject:setSpeed(this.parent:getSpeed())
		end
	end
	
	this.draw = function(this) --will called every time the gameObject will drawed.
		
	end
	
	this.clear = function(this, acctual) --will called when the sntity graphics are removed.
		
	end
	
	this.stop = function(this) 
		
	end
	
	return this
end

return Exhaust