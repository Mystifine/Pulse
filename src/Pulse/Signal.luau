--[[
  Written by: Mystifine
  Description: A simple implementation of the Signal class, which is used for event handling.
  Last Updated: 2026-05-14
]]

local Signal = {};
Signal.__index = Signal;

local Connection = {};
Connection.__index = Connection;

function Connection:Disconnect()
  local index = table.find(self.signal.connections, self);
  if index then
    local len = #self.signal.connections;
    self.signal.connections[index] = self.signal.connections[len];
    self.signal.connections[len] = nil;
  end
end

function Connection.new(signal, callback : (any) -> ())
  local self = setmetatable({}, Connection);
  self.signal = signal;
  self.callback = callback;

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
  
  table.insert(self.connections, newConnection);

  return newConnection;
end

function Signal:Fire(...)
  for _, connection in self.connections do
    task.spawn(connection.callback, ...);
  end
end

function Signal:Destroy()
  for _, connection in self.connections do
    connection:Disconnect();
  end

  table.clear(self.connections);
  setmetatable(self, nil);
end

function Signal.new()
  local self = setmetatable({}, Signal);

  self.connections = {};

  return self;
end

return Signal;