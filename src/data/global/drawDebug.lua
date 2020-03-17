local global = ...

local fillString = global.ut.fillString("", global.resX, " ")

return function(...)
	if global.conf.showDebug then
		local debugString = ""
		global.gpu.setForeground(0xaaaaaa)
		global.gpu.setBackground(0x333333)
		
		debugString = debugString .. 
			"NosGa Engine: " .. global.version .. 
			" | MemoryUsage: " .. tostring(math.floor(100 - (global.computer.freeMemory() / global.computer.totalMemory() * 100) +.5)) .. "%" ..
			" | FPS: " .. tostring(math.floor((global.fps) +.5) .. 
			" | Frame: " .. tostring(global.currentFrame)
		)
			
		for _, s in pairs({...}) do
			debugString = debugString .. " | " .. s
		end
		
		global.gpu.set(1, global.debugDisplayPosY, debugString .. fillString)
	end
end