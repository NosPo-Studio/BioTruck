local global = ...

TestGO = {}
TestGO.__index = TestGO

function TestGO.init(this) --will calles when the gameObject become loaded/reloaded.
	--global.log("TestGO: init")
end

function TestGO.new(args)
	--===== gameObject definition =====--
	args = args or {}
	args.sizeX = 6
	args.sizeY = 6
	args.components = {
		--{"Sprite", texture = global.texture.player.right},
		--{"Sprite", texture = global.texture.grass},
		--{"CopyArea", x = 0, y = 0, sx = args.sizeX, sy = args.sizeY},
	}
	
	--===== default stuff =====--
	local this = global.parent.Test3.new(this, args)
	this = setmetatable(this, TestGO)
	
	--===== init =====--
	local pa = global.ut.parseArgs
	
	--===== global functions =====--
	
	
	--===== default functions =====--
	this.start = function(this) --will called everytime a new object of the gameObject is created.
		global.log("TestGO: start")
	end
	
	this.update = function(this, dt, ra) --will called on every game tick.
		--global.log("TestGO2: update: ", this:getPos())
	end
	
	this.draw = function(this) --will called every time the gameObject will drawed.
		--global.log("TestGO(" .. tostring(this.ngeAttributes.name) .. "): draw")
	end
	
	this.clear = function(this, acctual) --will called when the sntity graphics are removed.
		
	end
	
	return this
end

return TestGO