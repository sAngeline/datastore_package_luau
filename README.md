# Datastore package (LUAU)
Profileservice/Replicaservice modular implementation

# What it has

- Both client & server implementation
- Global updates implementation
- Uses lua-promises
- Type-checked

## API
```
Datastore.client:
- Return the client module, can only be viewed on the client
- client.get() :: Promise<Replica>
- client.getAsync() :: Replica (Yield)

Datastore.server:
- Return the server module, can only be viewed on the server
- server.handle(player) :: Replica | never
- server.remove(player) :: ()
- server.get(player) :: Promise<Replica>

Datastore._data:
- Internal
- Return the data template

Datastore._global_update
- Internal
- Return the global update module
```

## Code Exemple
```Lua
-- Serverscript in ServerScriptService:
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local datastore = require(ReplicatedStorage.datastore)

Players.PlayerAdded:Connect(function(player: Player)
  local Replica = datastore.handle(player)
  local Player_Data: datastore.player_data = Replica.Data
  
  -- Do stuff like a leaderstats or something
end)

Players.PlayerRemoving:Connect(function(player: Player)
  datastore.remove(player)
end)
```

## License

Licensed under GNU General Public License v3.0
