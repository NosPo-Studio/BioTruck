local global = ...

Player = {}
Player.__index = Player

function Player.init(this) --will calles when the gameObject become loaded/reloaded.
	--global.log("Player: init")
end

function Player.new(args)
	local pa = global.ut.parseArgs
	local texture = {{"b", args.bc}, {"f", args.fc}}
	local resX, resY = args.resX, args.resY
	local line = 1
	
	for i, c in pairs(args.credits) do
		for i2, c2 in pairs(c) do
			if i2 == 1 then
				table.insert(texture, {math.floor(resX / 2 - global.unicode.len(c2) / 2), line, c2})
				line = line +1
			elseif i2 == 2 then
				local t = ""
				for i, c in pairs(c2) do
					if global.unicode.len(t .. c) > resX then
						table.insert(texture, {math.floor(resX / 2 - global.unicode.len(t) / 2), line, t})
						t = ""
						line = line +1
					end
					
					t = t .. c .. ", "
				end
				t = global.unicode.sub(t, 1, global.unicode.len(t) -2)
				
				table.insert(texture, {math.floor(resX / 2 - global.unicode.len(t) / 2), line, t})
				line = line +2
			end
		end
	end
	
	--===== gameObject definition =====--
	args = args or {}
	args.sizeX = resX
	args.sizeY = line
	args.components = {
		{"Sprite", texture = global.oclrl.generateTexture(texture)},
	}
	
	--===== default stuff =====--
	local this = global.core.GameObject.new(args)
	this = setmetatable(this, Player)
	
	this.isMoving = true
	this.lastY = -1
	
	--===== init =====--
	
	--===== global functions =====--
	this.touch = function(sname, s)
		this.lastY = s[4]
		this.isMoving = false
	end
	this.drag = function(sname, s)
		local y = s[4]
		this:move(0, this.lastY - y)
		this.lastY = y
	end
	this.drop = function(sname, s)
		this.isMoving = true
	end
	
	--===== default functions =====--
	this.update = function(this, dt, ra) --will called on every game tick.
		if this.isMoving then
			this:move(0, 3 *dt)
		end
		
		if select(2, this:getPos()) + this.ngeAttributes.sizeY < 0 then
			global.state.credits.done = true
		end
	end
	
	return this
end

return Player