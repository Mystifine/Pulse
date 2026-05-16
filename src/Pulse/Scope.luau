export type Scope = {
  Add : (self : Scope, task : any) -> (),
  Destroy : (self : Scope) -> (),
}

local Scope = {};
Scope.__index = Scope;

function Scope:Add(task : any)
  table.insert(self._Items, task);
end

function Scope:Destroy()
  for _, task in self._Items do

    local taskType = typeof(task);

    if taskType == "RBXScriptConnection" then
      task:Disconnect();
    elseif taskType == "Instance" or (type(task) == "table" and task.Destroy) then
      task:Destroy();
    elseif type(task) == "function" then
      task();
    end
  end

  table.clear(self._Items);
end

function Scope.new()
  local self = setmetatable({}, Scope);
  self._Items = {};

  return self;
end

return Scope;