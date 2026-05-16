local Value = require(script.Value);
local Scope = require(script.Scope);
local Runtime = require(script.Runtime);
local Computed = require(script.Computed);

type Scope = Scope.Scope;

local Pulse = {};

function Pulse._track(obj : any)
  local scope = Runtime.getCurrentScope();
  if scope then
    scope:Add(obj);
  end

  return obj;
end

function Pulse.Computed(callback : () -> any)
  return Pulse._track(Computed.new(callback));
end

function Pulse.Scope(fn : (scope : Scope) -> ())
  
  local scope = Scope.new();

  Runtime.pushScope(scope);

  local results = table.pack(xpcall(fn, debug.traceback, scope));
  
  Runtime.popScope();

  local success = table.remove(results, 1);
  if not success then
    error(results[1]);
  end

  return table.unpack(results), scope;
end

function Pulse.Value(value : any)
  local valueObj = Pulse._track(Value.new(value));

  return valueObj;
end

function Pulse.Create(ui : any, properties : {[string] : any})

  local uiInstance;
  if typeof(ui) == "string" then
    uiInstance = Instance.new(ui);
  else
    uiInstance = ui(properties);
  end

  for property, value in properties do
    if property == "Children" then continue end;

    if property == "Events" then
      for eventName, handler in value do
        local event = uiInstance[eventName];
        if event and event.Connect then
          Pulse._track(event:Connect(function()
            handler(uiInstance);
          end));
        else
          warn(string.format("Event %s does not exist on %s", eventName, uiInstance.ClassName));
        end
      end
    elseif typeof(value) == "table" then
      uiInstance[property] = value:Get();

      Pulse._track(value.Changed:Connect(function(newValue)
        uiInstance[property] = newValue;
      end))
    else
      uiInstance[property] = value;
    end
  end

  local children = properties.Children;
  if children then
    for _, child in children do
      child.Parent = uiInstance;
    end
  end

  return Pulse._track(uiInstance);
end

local text = Pulse.Value("Text");
local label = Pulse.Create("TextLabel", {
  Text = text,
  Size = UDim2.fromOffset(100, 50),
  Children = {
    Pulse.Create("Frame", {
      Size = UDim2.fromScale(1, 1),
      BackgroundColor3 = Color3.fromRGB(255, 0, 0),
    })
  },
})

return Pulse;