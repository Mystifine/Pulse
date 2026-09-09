local Runtime = require(script.Parent.Runtime)
local Signal = require(script.Parent.Signal);
local FrameLoop = require(script.Parent.FrameLoop);

local Computed = {};
Computed.__index = Computed;

function Computed:Clear()
  local connections = self._Connections;
  if not connections then return end;
  
  self._Connections = {};
  
  for _, connection in pairs(connections) do
    connection:Disconnect();
  end

  self._Seen = {};
end

function Computed:Get()
  if self._Destroyed then return end;

  local activeObserver = Runtime.getCurrentObserver();
  if activeObserver and activeObserver ~= self then
    activeObserver:Add(self);
  end

  if self._Computing then 
    return self.Value;
  end;
  self._Computing = true;

  -- Need to begin tracking
  self:Clear();
  Runtime.pushObserver(self);

  -- Computes value and removes observer
  local sucess, result = xpcall(self.Callback, debug.traceback);
  Runtime.popObserver();

  if not sucess then 
    self._Computing = false;
    error(result) 
  end;

  -- Commit values
  if self.Value ~= result then
    self.Value = result;
    self.Changed:Fire(result);
  end
  self._Computing = false;

  return result;
end

function Computed:Add(value : any)

  if self._Seen[value] then return end;
  self._Seen[value] = true;

  table.insert(self._Connections, value.Changed:Connect(function()
    FrameLoop.queueComputation(self);
  end))
end

function Computed:Destroy()
  if self._Destroyed then return end;
  self._Destroyed = true;

  self:Clear(); -- Clears the connections
  self.Changed:Destroy();
  self.Value = nil;
  self.Callback = nil;
  self._Computing = nil;
  self._Seen = nil;
  self._Connections = nil;
end

function Computed.new(fn : () -> any)
  local computed = setmetatable({}, Computed);
  computed._Destroyed = false;
  computed._Computing = false;
  
  computed.Value = nil;
  computed.Callback = fn;
  computed.Changed = Signal.new();

  computed._Seen = {};
  computed._Connections = {};

  computed:Get();

  return computed;
end

return Computed;
