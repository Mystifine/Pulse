local Runtime = require(script.Parent.Runtime);
local FrameLoop = require(script.Parent.FrameLoop);

local Effect = {};
Effect.__index = Effect;

function Effect:Run()
  
  self:Clear();
  Runtime.pushObserver(self);

  local success, err = xpcall(self.Callback, debug.traceback);
  
  Runtime.popObserver();
  
  if not success then
    error(err);
  end
end

function Effect:Add(value : any)
  if self._Seen[value] then return end;
  self._Seen[value] = true;
  table.insert(self._Connections, value.Changed:Connect(function()
    FrameLoop.queueEffect(self);
  end))
end

function Effect:Clear()
  for _, connection in self._Connections do
    connection:Disconnect();
  end
  table.clear(self._Connections);

  self._Seen = {};
end

function Effect:Destroy()
  self:Clear();
  self.Callback = nil;
  self._Seen = nil;
end

function Effect.new(fn : () -> ())
  local self = setmetatable({}, Effect);
  self._Connections = {};
  self._Seen = {};
  self.Callback = fn;

  self:Run();

  return self;
end

return Effect;