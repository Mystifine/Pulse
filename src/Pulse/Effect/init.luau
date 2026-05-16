local Runtime = require(script.Parent.Runtime);
local EffectScheduler = require(script.EffectScheduler);

local Effect = {};

function Effect:Run()
  
  Runtime.pushObserver(self);

  local success, err = xpcall(self.Callback, debug.traceback);
  
  Runtime.popObserver();
  
  if not success then
    error(err);
  end
end

function Effect:Add(value : any)
  table.insert(self._Connections, value.Changed:Connect(function()
    EffectScheduler.schedule(self);
  end))
end

function Effect:Cleanup()
  for _, connection in self._Connections do
    connection:Disconnect();
  end
  table.clear(self._Connections);
end

function Effect:Destroy()
  self:Cleanup();
  self.Callback = nil;
end

function Effect.new(fn : () -> ())
  local self = setmetatable({}, {__index = Effect});
  self._Connections = {};
  self.Callback = fn;

  self:Run();

  return self;
end

return Effect;