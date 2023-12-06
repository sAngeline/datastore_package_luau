-- Datastore: global_updates
-- 17/11/2023

-- Package
local global_updates = {
	_list = {}
}

-- Define Functions
function global_updates.run(Data, client: Player, profile)
	-- Find the global update function
	if (global_updates._list[Data.Type]) then
		-- It exist, we can call it
		global_updates._list[Data.Type](client, Data, profile)
	end
	
	-- Warn the player
	return warn("The global update function does not exist.")
end

return global_updates