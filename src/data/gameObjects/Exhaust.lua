local global = ...

ParticleTestContainer = {}
ParticleTestContainer.__index = ParticleTestContainer

function ParticleTestContainer.init(this) --will calles when the gameObject become loaded/reloaded.
	--global.log("ParticleTestContainer: init")
end

function ParticleTestContainer.new(args)
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
	
	this = setmetatable(this, ParticleTestContainer)
	
	--===== init =====--
	local pa = global.ut.parseArgs
	
	this.parent = args.parent
	this.smokeRate = args.smokeRate or 2
	this.particle = args.particle or "Smoke"
	this.width = pa(args.width)
	this.height = pa(args.height)
	
	this.pastTime = 0
	
	--===== global functions =====--
	
	--===== default functions =====--
	this.start = function(this) --will called everytime a new object of the gameObject is created.
		
	end
	
	this.stop = function(this) --will called when gameObject object becomes deloaded (e.g. out of screen)
		
	end
	
	this.update = function(this, dt, ra) --will called on every game tick.
		this.pastTime = this.pastTime + dt
		
		local x, y = this.parent:getPos()
		local toSpawn = math.floor(this.pastTime * this.smokeRate)
		this.pastTime = this.pastTime - toSpawn / this.smokeRate
		
		
		
		for c = 1, toSpawn do
			--global.log(this.particle, x + this.parent.exhaustOffsetX, y + this.parent.exhaustOffsetY)
			local rx, ry = math.random(this.width) -1, math.random(this.height) -1
			
			local particle = this:addParticle(this.particle, x + this.parent.exhaustOffsetX + rx, y + this.parent.exhaustOffsetY + ry)
			
			--particle.gameObject:attach(this.parent.gameObject)
			particle.gameObject:setSpeed(this.parent:getSpeed())
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

return ParticleTestContainer