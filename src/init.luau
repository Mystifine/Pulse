local Value = require(script.Value);
local Scope = require(script.Scope);
local Runtime = require(script.Runtime);
local Computed = require(script.Computed);
local Effect = require(script.Effect);
local Spring = require(script.Spring);
local Tween = require(script.Tween);

type Scope = Scope.Scope;
type SpringConfig = Spring.SpringConfig;

local Pulse = {};

function Pulse._track(obj : any)
  local scope = Runtime.getCurrentScope();
  if scope then
    scope:Add(obj);
  end

  return obj;
end

function Pulse.ColorSpring(source, config : SpringConfig?)
  local initialColor = source:Get();

  local springTarget = Pulse.Value(Vector3.new(initialColor.R, initialColor.G, initialColor.B));
  local internalVectorSpring = Pulse._track(Spring.new(springTarget, config));
  local color3Output = Pulse.Value(initialColor);

  Pulse._track(source.Changed:Connect(function(newColor)
    springTarget:Set(Vector3.new(newColor.R, newColor.G, newColor.B));
  end))

  Pulse._track(internalVectorSpring.Changed:Connect(function(newVector3)
    local r = math.clamp(newVector3.X, 0, 1);
    local g = math.clamp(newVector3.Y, 0, 1);
    local b = math.clamp(newVector3.Z, 0, 1);

    color3Output:Set(Color3.new(r, g, b));
  end))

  return color3Output;
end

function Pulse.Tween(source, tweenInfo)
  return Pulse._track(Tween.new(source, tweenInfo));
end

function Pulse.Spring(source, config : SpringConfig?)
  local sourceValue = source:Get();
  if typeof(sourceValue) == "Color3" then
    return Pulse.ColorSpring(source, config);
  end
  return Pulse._track(Spring.new(source, config));
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

function Pulse.Effect(fn : () -> ())
  return Pulse._track(Effect.new(fn));
end

function Pulse.Value(value : any)
  local valueObj = Pulse._track(Value.new(value));

  return valueObj;
end

function Pulse.ForPairs(sourceValue, buildFn : (key : string, value : any) -> any)
  local entries = {};
  local output = Pulse.Value({});

  Pulse.Effect(function()
    local data = sourceValue:Get();

    for key, entry in entries do
      if data[key] == nil then
        entry.scope:Destroy();
        entries[key] = nil;
      end
    end

    for key, value in data do
      if entries[key] == nil then
        local instance, scope = Pulse.Scope(function()
          return buildFn(key, value);
        end)
        entries[key] = {instance = instance, scope = scope};
      end
    end

    local out = {};
    for key, entry in entries do
      out[key] = entry.instance;
    end
    output:Set(out);
  end)

  return output;
end

function Pulse.Create(ui : string | (props : {}) -> GuiObject, properties : {[string] : any})

  local uiInstance;
  if typeof(ui) == "string" then
    uiInstance = Instance.new(ui :: string);

    for property, value in properties do
      if property == "Children" then continue end;

      if property == "Events" then
        for eventName, handler in value do
          local event = uiInstance[eventName];
          if event and event.Connect then
            Pulse._track(event:Connect(function(...)
              handler(uiInstance, ...);
            end));
          else
            warn(string.format("Event %s does not exist on %s", eventName, uiInstance.ClassName));
          end
        end
      elseif typeof(value) == "table" and (getmetatable(value) == Computed or getmetatable(value) == Value or getmetatable(value) == Spring) then
        uiInstance[property] = value:Get();

        Pulse._track(value.Changed:Connect(function(newValue)
          uiInstance[property] = newValue;
        end))
      else
        uiInstance[property] = value;
      end
    end
  else
    uiInstance = (ui :: (props : {[string] : any}) -> GuiObject)(properties);
  end

  local children = properties.Children;
  if children then

    local function isReactive(v)
      return typeof(v) == "table" and (getmetatable(v) == Computed or getmetatable(v) == Value);
    end

    for _, child in children do
      if isReactive(child) then
        local parented = {};

        local function sync(list)
          for _, inst in list do
            if not parented[inst] then
              inst.Parent = uiInstance;
              parented[inst] = true;
            end
          end
          for inst, _ in parented do
            if inst.Parent == nil then
              parented[inst] = nil;
            end
          end
        end

        sync(child:Get());
        Pulse._track(child.Changed:Connect(sync));
      else
        child.Parent = uiInstance;
      end
    end
  end

  return Pulse._track(uiInstance);
end

return Pulse;