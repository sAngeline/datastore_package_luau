-- Datastore package: client
-- 17/11/2023

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Libraries
local replica_controller = require(script.Parent.libraries.Replicacontroller.ReplicaController)
local promise = require(script.Parent.libraries.Promise)

-- Package
local client = {
	_stored = nil
}

-- Define Functions
function client.get(): any
	return promise.new(function(resolve, reject)
		-- Check for the replica
		if (client._stored) then
			resolve(client._stored)
		else
			-- Wait for it
			repeat
				-- Prevent memory leak
				if (not Players.LocalPlayer) then
					reject()
				end
				
				-- Yield
				task.wait(1/60)
			until (client._stored)
			
			-- Resolve
			resolve(client._stored)
		end
	end)
end

function client.getAsync(): any
	local success, data_replica = client.get():await()
	
	-- If it didn't work then
	if not success then
		-- We retry until it work è.é
		repeat
			task.wait()
			success, data_replica = client.get():await()
		until success
	end
	
	return data_replica
end

-- Handle replica fetching
replica_controller.ReplicaOfClassCreated("Token-01", function(replica_object)
	client._stored = replica_object
	
	-- Debug
	replica_object:ListenToChange("character", function()
		print("Character changed")
	end)
end)

replica_controller.RequestData()

return client