local global = ...

TestHuman = {}
TestHuman.__index = TestHuman

function TestHuman.init(this) --will calles when the gameObject become loaded/reloaded.
	--global.log("TestHuman: init")
end

function TestHuman.new(args)
	
	
	--===== gameObject definition =====--
	args = args or {}
	args.sizeX = 6
	args.sizeY = 6
	args.components = {
		{"Sprite", texture = "human"},
	}
	args.stats = {
		life = .1,
		hardness = 1,
		fuel = 50,
		blood = 10,
		bloodPressure = 20,
		money = 10,
	}
	
	--===== default stuff =====--
	local this = global.parent.Human.new(args)
	this = setmetatable(this, TestHuman)
	
	
	--===== init =====--
	
	--===== global functions =====--
	
	--===== default functions =====--
	this.start = function(this, t)
		
	end	
	
	this.update = function(this, dt, ra) --will called on every game tick.
		
	end
	
	return this
end

return TestHuman