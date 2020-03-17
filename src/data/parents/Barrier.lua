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
	args.isParent = true
	
	--===== default stuff =====--
	local this = global.core.GameObject.new(args) 
	this = setmetatable(this, GameObjectsTemplate) 
	
	--===== init =====--
	if global.conf.particles > 0 then
		--this.particleContainer = args.particleContainer or global.getState().raMain:addGO("DefaultParticleContainer", {selfDestroy = true, parent = this})
		this.particleContainer = global.getState().pcDefaultParticleContainer
	end
	
	this.stats = args.stats
	this.life = args.stats.life
	
	this.state = global.getState()
	
	--===== custom functions =====--
	this.collide = function(this, damage, speedX)
		local fuel, money = 0, 0
		local backDamage = damage - math.max(damage - this.life, 0)
		if damage > 0 then
			backDamage = backDamage / damage
		end
		
		this.life = this.life - damage
		
		if this.life <= 0 then
			fuel = this.stats.fuel
			fuel = this.stats.money or 0
			this:explode(speedX)
			this:destroy()
		end
		
		return backDamage * this.stats.hardness, backDamage, fuel, money
	end
	
	--===== default functions =====--
	this.pStart = function(this) 
		global.run(this.start, this)
	end
	
	this.pUpdate = function(this, dt, ra) 
		local posX = this:getPos()
		
		if this.state.raMain:getFOV() > posX + this.ngeAttributes.sizeX then
			this:destroy()
			return
		end
		
		global.run(this.update, this, dt, ra)
	end
	
	this.pDraw = function(this, ra) 
		global.run(this.draw, this, ra)
	end
	
	this.pClear = function(this, acctual) 
		global.run(this.clear, this, acctual)
	end
	
	this.pStop = function(this) 
		global.run(this.stop, this)
	end
	
	return this
end

return GameObjectsTemplate