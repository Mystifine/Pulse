local Value = require(script.Value);

local Pulse = {};

function Pulse.Value(value : any)
  local valueObj = Value.new(value);

  return valueObj;
end

function Pulse.Create(ui : any, properties : {[string] : any})

  local connections = {};

  local uiInstance;
  if typeof(ui) == "string" then
    uiInstance = Instance.new(ui);
  else
    uiInstance = ui(properties);
  end

  local children = properties.Children;
  if children then
    for _, child in children do
      child.Parent = uiInstance;
    end
  end

  for property, value in properties do
    if property == "Children" then continue end;

    if typeof(value) == "table" and value.__type == "PulseValue" then
      local changedConnection = value.Changed:Connect(function(newValue)
        uiInstance[property] = newValue;
      end)
      table.insert(connections, changedConnection);
      uiInstance[property] = value:Get();

      table.insert(connections, uiInstance.Destroying:Connect(function()
        for _, conn in connections do
          conn:Disconnect();
        end
      end));
    else
      uiInstance[property] = value;
    end
  end

  return uiInstance;
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