-- Datastore package handler
-- Written by Evangeline (@angewastaken on discord)
-- 17/11/2023

-- Services
local RunService = game:GetService("RunService")

-- Packages
local client = if RunService:IsClient() then require(script.client) else nil
local server = if RunService:IsServer() then require(script.server) else nil
local global_updates = require(script.global_updates)
local data = require(script.data)

-- Types
export type player_data = typeof(data)

-- Package
return {
	client = client,
	server = server,
	
	-- Secondary
	_global_updates = global_updates,
	_data = data
}