--[[
  Written by: Mystifine
  Description: A simple implementation of the Signal class, which is used for event handling.
  Last Updated: 2026-05-15
]]

export type Connection = {
  Disconnect : (self : Connection) -> (),
}

export type Signal = {
  Connect : (self : Signal, callback : (any) -> ()) -> Connection,
  Once : (self : Signal, callback : (any) -> ()) -> Connection,
  Fire : (self : Signal, ...any) -> nil,
  Destroy : (self : Signal) -> nil,
}

local Signal = {};
Signal.__index = Signal;

local Connection = {};
Connection.__index = Connection;

function Connection:Disconnect()
  if not self.Signal then return end;

  local index = table.find(self.Signal.Connections, self);
  if index then
    local len = #self.Signal.Connections;
    self.Signal.Connections[index] = self.Signal.Connections[len];
    self.Signal.Connections[len] = nil;
  end

  self.Signal = nil;
  self.Callback = nil;
end

function Connection.new(signal : Signal, callback : (any) -> ())
  local self = setmetatable({}, Connection);
  self.Signal = signal;
  self.Callback = callback;

  return self;
end

function Signal:Once(callback : (any) -> ())
  local connection;
  connection = self:Connect(function(...)
    connection:Disconnect();
    callback(...);
  end)
  return connection;
end

function Signal:Connect(callback : (any) -> ())
  
  local newConnection = Connection.new(self, callback);
  
  table.insert(self.Connections, newConnection);

  return newConnection;
end

function Signal:Fire(...)
  local snapShot = table.clone(self.Connections);
  for _, connection in snapShot do
    task.spawn(connection.Callback, ...);
  end
end

function Signal:Destroy()
  while #self.Connections > 0 do
    self.Connections[#self.Connections]:Disconnect()
  end

  table.clear(self.Connections);
  setmetatable(self, nil);
end

function Signal.new()
  local self = setmetatable({}, Signal);

  self.Connections = {};

  return self;
end

return Signal;