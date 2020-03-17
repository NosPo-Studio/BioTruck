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

Human = {}
Human.__index = Human

--Called once when the class is loaded by the engine.
function Human.init(this) 
	
end

--Calles on the bject creation of the class. Here you define/initiate the class.
function Human.new(args) 
	--===== gameObject definition =====--
	--Take given GameObject args if present and prevents it from being nil if not.
	args = args or {} 
	args.sizeX = 6
	args.sizeY = 6
	
	table.insert(args.components, {
		"BoxCollider",
		sx = args.sizeX,
		sy = args.sizeY,
	})
	
	--===== default stuff =====--
	local this = global.parent.Barrier.new(args) 
	this = setmetatable(this, Human) 
	
	--===== init =====--
	--this.args = args
	
	this.ngeAttributes.usesAnimation = false
	
	--===== custom functions =====--
	this.explode = global.expandFunction(function(this, speed)
		local x, y = this:getPos()
		local sx, sy = this:getSize()
		x, y = x + sx / 2, y --+ sy / 2
		
		if this.particleContainer == nil then return end
		
		global.sfx.explosion(this.particleContainer, x, y, "Blood", args.stats.blood, args.stats.bloodPressure)
		
	end, this.explode or function() end)
	
	--===== default functions =====--
	this.pStart = global.expandFunction(this.pStart, function(this)
		
	end)
	
	this.pUpdate = global.expandFunction(this.pUpdate, function(this, dt, ra) 
		
	end)
	
	this.pDraw = global.expandFunction(this.pDraw, function(this, ra) 
		
	end)
	
	this.pClear = global.expandFunction(this.pClear, function(this, acctual) 
		
	end)
	
	this.pStop = global.expandFunction(this.pStop, function(this) 
		--this.particleContainer:destroy()
	end)
	
	return this
end

return Human