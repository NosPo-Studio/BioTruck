local global = ...

Smoke = {}
Smoke.__index = Smoke

function Smoke.init(this) --will calles when the gameObject become loaded/reloaded.
	--global.log("Smoke: init")
end

function Smoke.new(args)
	local pa = global.ut.parseArgs
	--===== gameObject definition =====--
	args = args or {}
	args.name = "Blood"
	args.color = 0x8a0303
	args.lifeTime = pa(args.lt, args.lifeTime, args.maxLifeTime, 3)
	
	--===== default stuff =====--
	local this = global.parent.Particle.new(args)
	this = setmetatable(this, Smoke)
	
	--===== init =====--
	local pa = global.ut.parseArgs
	
	this.rng = pa(args.rng, args.wind, 0)
	this.defaultParticleContainer = pa(args.dpc, args.defaultParticleContainer)
	
	this.stillAttached = -1
	this.objectType = "Particle"
	
	this.gameObject:addRigidBody({
		g = pa(g, 70), 
		stiffness = 10,
		stickiness = 1, --.36, --.95,
		speedRetain = .9,
	})
	this.gameObject:addBoxTrigger({x = .25, y = .5, sx = .5, sy = .5, lf = function(collider, otherCollider)
		local this = collider.gameObject.parent
		local obj = otherCollider.gameObject.parent
		
		if obj.objectType ~= "Particle" and obj.particleContainer ~= nil and obj.particleContainer ~= this.container then
			local x, y = this.gameObject:getPos()
			obj.particleContainer:addParticle("Blood", x, y, {dpc = this.defaultParticleContainer, clt = this.lifeTime})
			this:destroy()
		end
		
		cprint(debug.traceback())
		
		if obj.objectType ~= "Particle" then
			collider.gameObject:attach(otherCollider.gameObject)
		end
		this.stillAttached = 1
	end})
	
	--===== global functions =====--
	
	
	--===== default functions =====--
	this.start = function(this) --will called everytime a new object of the gameObject is created.
		
	end
	
	this.stop = function(this) --will called when gameObject object becomes deloaded (e.g. out of screen)
		
	end
	
	this.update = function(this, dt, ra) --will called on every game tick.
		local x = 0
		if math.random() > .5 then
			x = math.random()
		else
			x = -math.random()
		end
		
		this.gameObject:addForce(x *this.rng *dt, 0)
		
		if this.stillAttached == 0 then
			this.gameObject:detach()
			
			--[[
			if this.defaultParticleContainer ~= nil then
				local x, y = this.gameObject:getPos()
				this.defaultParticleContainer:addParticle("Blood", x, y, {dpc = this.defaultParticleContainer, clt = this.lifeTime})
				this:destroy()
			end
			]]
		elseif this.stillAttached == 1 then
			this.stillAttached = 0
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

return Smoke