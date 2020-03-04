local global = ...

local testBiome = {
	--barrierChance = 99999999999999,
	barrierChance = 100,
	barrierGaps = 20,
	
	--fuelContainerChance = 99999999999,
	fuelContainerChance = 100,
	--fuelContainerChance = 10,

	
	streets = {
		{name = "StreetTest",
			chance = 10,
		},
	},
	
	backgrounds = {
		{name = "Test4",
			chance = 10,
		},
		{name = "Test2",
			chance = 10,
		},
		{name = "Test3",
			chance = 1,
		},
		
	},
	
	barriers = {
		{name = "BarrierTest",
			chance = 10,
		},
	},
	
	fuelContainers = {
		{name = "TestHuman",
			chance = 10,
		},
	},
	
}

return testBiome