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
	args.sizeY = 6
	args.components = { --Define the GameObjects components.
		
		{"Sprite", 
			x = 0, 
			y = 0, 
			--texture = global.texture.player.right,
			texture = "test",
			--texture = "exampleTexture",
		},
		
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
		life = 5,
		hardness = 1,
		fuel = 50,
	}
	
	args.useAnimation = true
	
	--===== default stuff =====--
	local this = global.parent.Barrier.new(args) 
	this = setmetatable(this, GameObjectsTemplate) 
	
	--===== init =====--
	
	--===== custom functions =====--
	this.explode = function(this, speed)
		local posX, posY = this:getPos()
		this.defaultParticleContainer:addParticle("Blood", posX, posY)
		this.defaultParticleContainer:addParticle("Blood", posX +1, posY)
		this.defaultParticleContainer:addParticle("Blood", posX +2, posY)
		this.defaultParticleContainer:addParticle("Blood", posX +3, posY)
		this.defaultParticleContainer:addParticle("Blood", posX +4, posY)
		this.defaultParticleContainer:addParticle("Blood", posX +5, posY)
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