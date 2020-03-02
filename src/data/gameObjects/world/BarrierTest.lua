--[[
    This file is a GameObject example for the NosGa Engine.
	
	NosGa Engine Copyright (c) 2019-2020 NosPo Studio

    The NosGa Engine is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    The NosGa Engine is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with the NosGa Engine.  If not, see <https://www.gnu.org/licenses/>.
]]

local global = ... --Here we get global.

GameObjectsTemplate = {}
GameObjectsTemplate.__index = GameObjectsTemplate

--Called once when the class is loaded by the engine.
function GameObjectsTemplate.init(this) 
	
end


--Calles on the bject creation of the class. Here you define/initiate the class.
function GameObjectsTemplate.new(args) 
	--===== gameObject definition =====--
	--Take given GameObject args if present and prevents it from being nil if not.
	args = args or {} 
	
	args.sizeX = 6
	args.sizeY = 3
	args.components = { --Define the GameObjects components.
		{"Sprite", 
			x = 0, 
			y = 0, 
			texture = "grass",
			--texture = "pipipu",
		},
		{"BoxCollider",
			sx = args.sizeX,
			sy = args.sizeY,
		},
	}
	args.stats = {
		life = .1,
		hardness = 1,
		fuel = 50,
		dust = 6,
		dustPressure = 10,
	}
	
	
	--===== default stuff =====--
	local this = global.parent.Barrier.new(args) 
	this = setmetatable(this, GameObjectsTemplate) 
	
	--===== init =====--
	
	--===== custom functions =====--
	this.explode = function(this, speed)
		local x, y = this:getPos()
		local sx, sy = this:getSize()
		x, y = x + sx / 2, y + sy / 2
		
		if this.particleContainer == nil then return end
		
		global.sfx.explosion(this.particleContainer, x, y, "Smoke", args.stats.dust * global.conf.particles, args.stats.dustPressure)
	end
	
	--===== default functions =====--
	this.start = function(this) 
		
	end
	
	this.update = function(this, dt, ra) 
		
	end
	
	this.draw = function(this) 
	
	end
	
	this.clear = function(this, acctual) 
		
	end
	
	this.stop = function(this) 
		
	end
	
	return this
end

return GameObjectsTemplate