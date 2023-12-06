-- Datastore package: server
-- 17/11/2023

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Libraries
local profile_service = require(script.Parent.libraries.Profileservice)
local replica_service = require(script.Parent.libraries.Replicaservice)
local promise = require(script.Parent.libraries.Promise)

-- Dependencies
local data_template = require(script.Parent.data)
local global_updates = require(script.Parent.global_updates)

-- Datastore Variables
local replica_token = replica_service.NewClassToken("Token-01")
local profile_store = profile_service.GetProfileStore("Store-01", data_template) do
	-- Use a mock if the game is running in the studio runtime
	if (RunService:IsStudio()) then
		profile_store = profile_store.Mock
	end
end

-- Package
local server = {
	_replica = {},
	_profile = {}
}

-- Define Functions
function server.handle(client: Player): any | never
	local user_id: number = client.UserId
	local profile_object = profile_store:LoadProfileAsync("playerdata_".. user_id)
	
	-- Check for a profile
	if (profile_object) then
		-- Reconcile the profile
		profile_object:AddUserId(user_id)
		profile_object:Reconcile()
		
		-- Listen to the profile release and cleanup to prevent memory leaks
		profile_object:ListenToRelease(function()
			server._profile[user_id] = nil
			
			-- Get rid of the replica
			server._replica[user_id]:Destroy()
			server._replica[user_id] = nil
			
			-- Kick the player to avoid errors
			client:Kick("Your data was released. (Potential error: 01)")
		end)
		
		-- Check if the client is still ingame
		if (client:IsDescendantOf(Players)) then
			-- Profile was fully initialized! ^-^
			-- Create the replica_object
			local replica_object = replica_service.NewReplica({
				ClassToken = replica_token,
				Data = profile_object.Data,
				Replication = client
			})
			
			-- Store the profile_object and the replica_object
			server._profile[user_id] = profile_object
			server._replica[user_id] = replica_object
			
			-- Global Updates!
			-- Iterate through all actives global_updates and lock them
			for i: number, update in profile_object.GlobalUpdates:GetActiveUpdates() do
				profile_object.GlobalUpdates:LockActiveUpdate(update[1])
			end
			
			-- Iterate through all locked global_updates and clear them
			for i: number, update in profile_object.GlobalUpdates:GetLockedUpdates() do
				-- Run the update logic and then clear it
				global_updates.run(update[2], client, profile_object)
				profile_object.GlobalUpdates:ClearLockedUpdate(update[1])
			end
			
			-- Return the client profile
			return replica_object
		else
			-- Release the profile
			profile_object:Release()
		end
	end
	
	-- Throw a critical error, kick the player out
	client:Kick("Critical error: 01")
	return error(`{client.Name} ({user_id}) did not have a data_profile.`)
end

function server.remove(client: Player): ()
	-- Release any existing profile
	if (server._profile[client.UserId]) then
		server._profile[client.UserId]:Release()
	end
end

function server.get(client: Player): ()
	return promise.new(function(resolve, reject)
		-- Check for the profile_object
		if (not server._replica[client.UserId]) then
			repeat
				-- Reject the promise if the player leave the game
				if (not client:IsDescendantOf(Players)) then
					reject("The player has left the game")
				end
				
				-- Yield
				task.wait(1/60)
			until (server._replica[client.UserId])
		end
		
		-- Resolve
		resolve(server._replica[client.UserId])
	end)
end

return server