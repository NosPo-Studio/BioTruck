local global = ...

PlayerDummy = {}
PlayerDummy.__index = PlayerDummy

function PlayerDummy.new(args)
	--===== gameObject definition =====--
	args = args or {}
	args.sizeX = 35
	args.sizeY = 8
	args.components = {
		{"Sprite", texture = "truck"},
	}
	
	--===== default stuff =====--
	local this = global.core.GameObject.new(args)
	this = setmetatable(this, PlayerDummy)
	
	--===== init =====--
	
	--===== global functions =====--
	
	--===== default functions =====--
	
	return this
end

return PlayerDummy