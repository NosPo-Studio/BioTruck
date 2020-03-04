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
	args.updateAlways = true
	
	--===== default stuff =====--
	local this = global.core.GameObject.new(args) 
	this = setmetatable(this, GameObjectsTemplate) 
	
	--===== init =====--
	if global.conf.particles > 0 then
		--this.particleContainer = args.particleContainer or global.getState().raMain:addGO("DefaultParticleContainer", {selfDestroy = true, parent = this})
		this.particleContainer = global.getState().pcDefaultParticleContainer
	end
	
	this.state = global.getState()
	this.player = this.state.goPlayer
	this.lastLine = this.player.line
	
	--===== custom functions =====--
	
	
	--===== default functions =====--
	this.pStart = function(this) 
		global.run(this.start, this)
	end
	
	this.pUpdate = function(this, dt, ra) 
		local posX = this:getPos()
		local sizeX = this:getSize()
		local fromX, toX = this.state.raMain:getFOV()
		
		if fromX > posX + this.ngeAttributes.sizeX then
			this:destroy()
		end
		
		if this.player.line ~= this.lastLine then
			this:rerender()
			this.lastLine = this.player.line
		elseif posX + sizeX > toX then
			this:rerender() --WIP, ToDo: deeper bug!
		end
	end
	
	this.pDraw = function(this, ra, offsetX, offsetY) 
		local x, y = this:getPos()
		local area = {ra:getRealFOV()}
		
		global.db.setDrawLimit(area[1], area[3], area[2], area[4])
		
		this.test = true
		
		for l, ld in pairs(args.dots) do
			for i, d in pairs(ld) do
				if d[1] + x + offsetX > 0 then
					if this.player.line +1 == l then
						global.db.drawSemiPixelRectangle(d[1] + x + offsetX, d[2] + y * 2 + offsetY * 2, d[3], d[4], d[6])
					else
						global.db.drawSemiPixelRectangle(d[1] + x + offsetX, d[2] + y * 2 + offsetY * 2, d[3], d[4], d[5])
					end
				end
			end
		end
		
		global.db.resetDrawLimit()
		
		global.run(this.draw, this, ra)
	end
	
	this.pSUpdate = function(this)
		
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