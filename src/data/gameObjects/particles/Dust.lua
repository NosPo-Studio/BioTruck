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
	args.name = "Smoke"
	args.color = 0x1e1e1e
	args.lifeTime = pa(args.lt, args.lifeTime, args.maxLifeTime, 3)
	
	--===== default stuff =====--
	local this = global.parent.Particle.new(args)
	this = setmetatable(this, Smoke)
	
	--===== init =====--
	local pa = global.ut.parseArgs
	
	this.rng = pa(args.rng, args.wind, 20)
	
	this.gameObject:addRigidBody({g = pa(args.weight, 20), speedLoss = 1})
	this.gameObject:addBoxCollider({y = .5, sx = 1, sy = .5})
	
	--this.name = pa(args.name, "Smoke")
	
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
		
		if dt > global.conf.maxTickTime then
			global.log(dt, global.dt)
		end
		
		this.gameObject:addForce(x *this.rng *dt, 0)
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