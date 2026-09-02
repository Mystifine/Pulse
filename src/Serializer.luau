--!strict

--[[
	Studio-only Roblox UI -> Pulse serializer.

	Usage:

		local Serializer = require(path.to.Serializer)

		local UI = path.to.ui

		print(Serializer.Generate(UI))

		-- or
		Serializer.Print(UI)

	The generated output is pure Roblox/Pulse code.

	It does NOT generate:
		- props.*
		- Computed / Value / Spring
		- Events
		- external asset modules
		- application-specific references
		- reactive properties

	It serializes the actual Roblox hierarchy and current property
	values so you can copy/paste the result and then manually add
	your application-specific logic.

	The serializer is default-aware:
		it creates a temporary Instance of the same class and only
		writes properties that differ from Roblox's defaults.
]]

local RunService = game:GetService("RunService")

if not RunService:IsStudio() then
	error("Pulse UI Serializer can only be used in Roblox Studio.", 2)
end

local Serializer = {}

---------------------------------------------------------------------
-- Configuration
---------------------------------------------------------------------

local INDENT = "    "

---------------------------------------------------------------------
-- Class-specific properties
---------------------------------------------------------------------

local CLASS_PROPERTIES: {[string]: {string}} = {

	-----------------------------------------------------------------
	-- Containers
	-----------------------------------------------------------------

	ScreenGui = {
		"Enabled",
		"DisplayOrder",
		"IgnoreGuiInset",
		"ResetOnSpawn",
		"ZIndexBehavior",
		"ClipToDeviceSafeArea",
		"SafeAreaCompatibility",
		"ScreenInsets",
	},

	BillboardGui = {
		"Active",
		"Adornee",
		"AlwaysOnTop",
		"Brightness",
		"ClipsDescendants",
		"DistanceLowerLimit",
		"DistanceStep",
		"DistanceUpperLimit",
		"ExtentsOffset",
		"ExtentsOffsetWorldSpace",
		"LightInfluence",
		"MaxDistance",
		"PlayerToHideFrom",
		"Size",
		"SizeOffset",
		"StudsOffset",
		"StudsOffsetWorldSpace",
	},

	SurfaceGui = {
		"Active",
		"Adornee",
		"Face",
		"AlwaysOnTop",
		"Brightness",
		"CanvasSize",
		"ClipsDescendants",
		"LightInfluence",
		"MaxDistance",
		"PixelsPerStud",
		"SizingMode",
		"ToolPunchThroughDistance",
		"ZOffset",
	},

	CanvasGroup = {
		"GroupColor3",
		"GroupTransparency",
	},

	-----------------------------------------------------------------
	-- GuiObject subclasses
	-----------------------------------------------------------------

	Frame = {
		"Style",
	},

	ScrollingFrame = {
		"AutomaticCanvasSize",
		"BottomImage",
		"CanvasPosition",
		"CanvasSize",
		"ElasticBehavior",
		"HorizontalScrollBarInset",
		"HorizontalScrollBarPosition",
		"LeftImage",
		"MidImage",
		"RightImage",
		"ScrollBarImageColor3",
		"ScrollBarImageTransparency",
		"ScrollBarThickness",
		"ScrollingDirection",
		"ScrollingEnabled",
		"TopImage",
		"VerticalScrollBarInset",
		"VerticalScrollBarPosition",
	},

	-----------------------------------------------------------------
	-- Images
	-----------------------------------------------------------------

	ImageLabel = {
		"Image",
		"ImageColor3",
		"ImageRectOffset",
		"ImageRectSize",
		"ImageTransparency",
		"ResampleMode",
		"ScaleType",
		"SliceCenter",
		"SliceScale",
		"TileSize",
	},

	ImageButton = {
		"AutoButtonColor",
		"Image",
		"ImageColor3",
		"ImageRectOffset",
		"ImageRectSize",
		"ImageTransparency",
		"Modal",
		"ResampleMode",
		"ScaleType",
		"Selected",
		"SliceCenter",
		"SliceScale",
		"TileSize",
	},

	-----------------------------------------------------------------
	-- Text
	-----------------------------------------------------------------

	TextLabel = {
		"Font",
		"FontFace",
		"LineHeight",
		"MaxVisibleGraphemes",
		"RichText",
		"Text",
		"TextColor3",
		"TextScaled",
		"TextSize",
		"TextStrokeColor3",
		"TextStrokeTransparency",
		"TextTransparency",
		"TextTruncate",
		"TextWrapped",
		"TextXAlignment",
		"TextYAlignment",
	},

	TextButton = {
		"AutoButtonColor",
		"Font",
		"FontFace",
		"LineHeight",
		"MaxVisibleGraphemes",
		"Modal",
		"RichText",
		"Selected",
		"Text",
		"TextColor3",
		"TextScaled",
		"TextSize",
		"TextStrokeColor3",
		"TextStrokeTransparency",
		"TextTransparency",
		"TextTruncate",
		"TextWrapped",
		"TextXAlignment",
		"TextYAlignment",
	},

	TextBox = {
		"ClearTextOnFocus",
		"CursorPosition",
		"Font",
		"FontFace",
		"MultiLine",
		"PlaceholderColor3",
		"PlaceholderText",
		"RichText",
		"SelectionStart",
		"Text",
		"TextColor3",
		"TextEditable",
		"TextScaled",
		"TextSize",
		"TextStrokeColor3",
		"TextStrokeTransparency",
		"TextTransparency",
		"TextTruncate",
		"TextWrapped",
		"TextXAlignment",
		"TextYAlignment",
	},

	-----------------------------------------------------------------
	-- 3D UI
	-----------------------------------------------------------------

	ViewportFrame = {
		"Ambient",
		"CurrentCamera",
		"ImageColor3",
		"ImageTransparency",
		"LightColor",
		"LightDirection",
		"BackgroundTransparency",
	},

	-----------------------------------------------------------------
	-- Video
	-----------------------------------------------------------------

	VideoFrame = {
		"Looped",
		"Playing",
		"TimePosition",
		"Video",
		"Volume",
	},

	-----------------------------------------------------------------
	-- Appearance
	-----------------------------------------------------------------

	UICorner = {
		"CornerRadius",
	},

	UIStroke = {
		"ApplyStrokeMode",
		"BorderOffset",
		"BorderStrokePosition",
		"Color",
		"Enabled",
		"LineJoinMode",
		"StrokeSizingMode",
		"Thickness",
		"Transparency",
		"ZIndex",
	},

	UIGradient = {
		"Color",
		"Enabled",
		"Offset",
		"Rotation",
		"Transparency",
	},

	UITexture = {
		"Color",
		"Enabled",
		"OffsetStuds",
		"StudsPerTile",
		"Transparency",
	},

	UIShadow = {
		"BlurRadius",
		"Color",
		"Enabled",
		"Offset",
		"Spread",
		"Transparency",
		"ZIndex",
	},

	-----------------------------------------------------------------
	-- Padding
	-----------------------------------------------------------------

	UIPadding = {
		"PaddingBottom",
		"PaddingLeft",
		"PaddingRight",
		"PaddingTop",
	},

	-----------------------------------------------------------------
	-- Constraints
	-----------------------------------------------------------------

	UIAspectRatioConstraint = {
		"AspectRatio",
		"AspectType",
		"DominantAxis",
	},

	UISizeConstraint = {
		"MaxSize",
		"MinSize",
	},

	UITextSizeConstraint = {
		"MaxTextSize",
		"MinTextSize",
	},

	-----------------------------------------------------------------
	-- Scaling
	-----------------------------------------------------------------

	UIScale = {
		"Scale",
	},

	-----------------------------------------------------------------
	-- List Layout
	-----------------------------------------------------------------

	UIListLayout = {
		"FillDirection",
		"HorizontalAlignment",
		"HorizontalFlex",
		"ItemLineAlignment",
		"Padding",
		"SortOrder",
		"VerticalAlignment",
		"VerticalFlex",
		"Wraps",
	},

	-----------------------------------------------------------------
	-- Grid Layout
	-----------------------------------------------------------------

	UIGridLayout = {
		"CellPadding",
		"CellSize",
		"FillDirection",
		"FillDirectionMaxCells",
		"HorizontalAlignment",
		"HorizontalFlex",
		"SortOrder",
		"StartCorner",
		"VerticalAlignment",
		"VerticalFlex",
		"Wraps",
	},

	-----------------------------------------------------------------
	-- Table Layout
	-----------------------------------------------------------------

	UITableLayout = {
		"FillEmptySpaceColumns",
		"FillEmptySpaceRows",
		"MajorAxis",
		"Padding",
		"SortOrder",
	},

	-----------------------------------------------------------------
	-- Page Layout
	-----------------------------------------------------------------

	UIPageLayout = {
		"Animated",
		"AnimationDirection",
		"AnimationStyle",
		"Circular",
		"EasingDirection",
		"EasingStyle",
		"GamepadInputEnabled",
		"Padding",
		"ScrollWheelInputEnabled",
		"TouchInputEnabled",
		"TweenTime",
		"HorizontalAlignment",
		"VerticalAlignment",
		"SortOrder",
	},

	-----------------------------------------------------------------
	-- Flex
	-----------------------------------------------------------------

	UIFlexItem = {
		"FlexMode",
		"GrowRatio",
		"ItemLineAlignment",
		"ShrinkRatio",
	},
}

---------------------------------------------------------------------
-- Properties inherited by GuiObject
---------------------------------------------------------------------

local GUI_OBJECT_PROPERTIES = {

	"Active",
	"AnchorPoint",
	"AutomaticSize",
	"BackgroundColor3",
	"BackgroundTransparency",
	"BorderColor3",
	"BorderMode",
	"BorderSizePixel",
	"ClipsDescendants",
	"Interactable",
	"LayoutOrder",
	"Position",
	"Rotation",
	"Selectable",
	"SelectionOrder",
	"Size",
	"SizeConstraint",
	"Visible",
	"ZIndex",

}

---------------------------------------------------------------------
-- Properties inherited by GuiButton
---------------------------------------------------------------------

local GUI_BUTTON_PROPERTIES = {

	"AutoButtonColor",
	"Modal",
	"Selected",

}

---------------------------------------------------------------------
-- Properties that should never be emitted
--
-- These are runtime/read-only/instance-reference properties.
---------------------------------------------------------------------

local EXCLUDED_PROPERTIES: {[string]: boolean} = {

	AbsolutePosition = true,
	AbsoluteRotation = true,
	AbsoluteSize = true,

	GuiState = true,

	SelectionImageObject = true,

	NextSelectionUp = true,
	NextSelectionDown = true,
	NextSelectionLeft = true,
	NextSelectionRight = true,

	-- Instance references aren't serializable into independent Pulse
	-- source. The serializer also skips any Instance-valued property.
	Adornee = true,
	PlayerToHideFrom = true,
	CurrentCamera = true,

}

---------------------------------------------------------------------
-- Formatting
---------------------------------------------------------------------

local function indent(level: number): string
	return string.rep(INDENT, level)
end

local function numberToString(value: number): string

	if value == math.huge then
		return "math.huge"
	end

	if value == -math.huge then
		return "-math.huge"
	end

	if value ~= value then
		return "0/0"
	end

	if math.floor(value) == value then
		return string.format("%.0f", value)
	end

	return string.format("%.15g", value)
end

local function quote(value: string): string
	return string.format("%q", value)
end

---------------------------------------------------------------------
-- Enum serialization
---------------------------------------------------------------------

local function serializeEnumItem(value: any): string?

	-- Roblox's tostring() produces values such as:
	--
	--     Enum.Font.SourceSans
	--     Enum.TextXAlignment.Left
	--     Enum.ScaleType.Tile
	--
	-- This is more robust than accessing .Name because some Roblox
	-- enum representations do not expose Name in the same way.

	local success, result = pcall(function()
		return tostring(value)
	end)

	if not success then
		return nil
	end

	-- Make sure this actually looks like an enum declaration.
	if string.sub(result, 1, 5) == "Enum." then
		return result
	end

	return nil
end

---------------------------------------------------------------------
-- Datatype serialization
---------------------------------------------------------------------

local function serialize(value: any): string?

	local valueType = typeof(value)

	-----------------------------------------------------------------
	-- Primitive
	-----------------------------------------------------------------

	if valueType == "nil" then
		return "nil"
	end

	if valueType == "boolean" then
		return tostring(value)
	end

	if valueType == "number" then
		return numberToString(value)
	end

	if valueType == "string" then
		return quote(value)
	end

  -----------------------------------------------------------------
  -- Enum / EnumItem
  -----------------------------------------------------------------
  
  if valueType == "EnumItem" then
    return serializeEnumItem(value)
  end
  
  if valueType == "Enum" then
    return serializeEnumItem(value)
  end

	-----------------------------------------------------------------
	-- Color3
	-----------------------------------------------------------------

	if valueType == "Color3" then

		return string.format(
			"Color3.fromRGB(%d, %d, %d)",
			math.round(value.R * 255),
			math.round(value.G * 255),
			math.round(value.B * 255)
		)
	end

	-----------------------------------------------------------------
	-- UDim
	-----------------------------------------------------------------

	if valueType == "UDim" then

		return string.format(
			"UDim.new(%s, %s)",
			numberToString(value.Scale),
			numberToString(value.Offset)
		)
	end

	-----------------------------------------------------------------
	-- UDim2
	-----------------------------------------------------------------

	if valueType == "UDim2" then

		return string.format(
			"UDim2.new(%s, %s, %s, %s)",
			numberToString(value.X.Scale),
			numberToString(value.X.Offset),
			numberToString(value.Y.Scale),
			numberToString(value.Y.Offset)
		)
	end

	-----------------------------------------------------------------
	-- Vector2
	-----------------------------------------------------------------

	if valueType == "Vector2" then

		return string.format(
			"Vector2.new(%s, %s)",
			numberToString(value.X),
			numberToString(value.Y)
		)
	end

	-----------------------------------------------------------------
	-- Vector3
	-----------------------------------------------------------------

	if valueType == "Vector3" then

		return string.format(
			"Vector3.new(%s, %s, %s)",
			numberToString(value.X),
			numberToString(value.Y),
			numberToString(value.Z)
		)
	end

	-----------------------------------------------------------------
	-- Rect
	-----------------------------------------------------------------

	if valueType == "Rect" then

		return string.format(
			"Rect.new(%s, %s, %s, %s)",
			numberToString(value.Min.X),
			numberToString(value.Min.Y),
			numberToString(value.Max.X),
			numberToString(value.Max.Y)
		)
	end

	-----------------------------------------------------------------
	-- NumberRange
	-----------------------------------------------------------------

	if valueType == "NumberRange" then

		if value.Min == value.Max then

			return string.format(
				"NumberRange.new(%s)",
				numberToString(value.Min)
			)
		end

		return string.format(
			"NumberRange.new(%s, %s)",
			numberToString(value.Min),
			numberToString(value.Max)
		)
	end

	-----------------------------------------------------------------
  -- Font
  -----------------------------------------------------------------

  if valueType == "Font" then

    local familySuccess, family = pcall(function()
      return value.Family
    end)

    local weightSuccess, weight = pcall(function()
      return value.Weight
    end)

    local styleSuccess, style = pcall(function()
      return value.Style
    end)

    if not familySuccess then
      return nil
    end

    local familyString = tostring(family)

    if weightSuccess and styleSuccess then

      local weightString = serializeEnumItem(weight)
      local styleString = serializeEnumItem(style)

      if weightString and styleString then

        return string.format(
          "Font.new(%q, %s, %s)",
          familyString,
          weightString,
          styleString
        )
      end
    end

    -- Fallback for a Font that cannot expose its weight/style.
    return string.format(
      "Font.fromName(%q)",
      familyString
    )
  end

	-----------------------------------------------------------------
	-- ColorSequence
	-----------------------------------------------------------------

	if valueType == "ColorSequence" then

		local keypoints = {}

		for _, keypoint in value.Keypoints do

			local color = serialize(keypoint.Value)

			if not color then
				return nil
			end

			table.insert(
				keypoints,

				string.format(
					"ColorSequenceKeypoint.new(%s, %s)",
					numberToString(keypoint.Time),
					color
				)
			)
		end

		-- Cleaner output for the common two-point case.
		if #value.Keypoints == 2 then

			local first = value.Keypoints[1]
			local second = value.Keypoints[2]

			if first.Time == 0
				and second.Time == 1
			then

				local firstColor = serialize(first.Value)
				local secondColor = serialize(second.Value)

				if firstColor and secondColor then

					return string.format(
						"ColorSequence.new(%s, %s)",
						firstColor,
						secondColor
					)
				end
			end
		end

		return string.format(
			"ColorSequence.new({%s})",
			table.concat(keypoints, ", ")
		)
	end

	-----------------------------------------------------------------
	-- NumberSequence
	-----------------------------------------------------------------

	if valueType == "NumberSequence" then

		local keypoints = {}

		for _, keypoint in value.Keypoints do

			table.insert(
				keypoints,

				string.format(
					"NumberSequenceKeypoint.new(%s, %s, %s)",
					numberToString(keypoint.Time),
					numberToString(keypoint.Value),
					numberToString(keypoint.Envelope)
				)
			)
		end

		return string.format(
			"NumberSequence.new({%s})",
			table.concat(keypoints, ", ")
		)
	end

	-----------------------------------------------------------------
	-- CFrame
	-----------------------------------------------------------------

	if valueType == "CFrame" then

		local components = {value:GetComponents()}
		local output = {}

		for _, component in components do
			table.insert(
				output,
				numberToString(component)
			)
		end

		return string.format(
			"CFrame.new(%s)",
			table.concat(output, ", ")
		)
	end

	-----------------------------------------------------------------
	-- Unsupported datatype
	-----------------------------------------------------------------

	return nil
end

---------------------------------------------------------------------
-- Property access
---------------------------------------------------------------------

local function tryGetProperty(
	instance: Instance,
	propertyName: string
): (boolean, any)

	return pcall(function()
		return instance[propertyName]
	end)
end

---------------------------------------------------------------------
-- Compare values
---------------------------------------------------------------------

local function valuesEqual(a: any, b: any): boolean

	if typeof(a) ~= typeof(b) then
		return false
	end

	-- Instance references are deliberately not compared.
	if typeof(a) == "Instance" then
		return false
	end

	local success, result = pcall(function()
		return a == b
	end)

	if not success then
		return false
	end

	return result == true
end

---------------------------------------------------------------------
-- Is supported UI?
---------------------------------------------------------------------

local function isSupportedUI(instance: Instance): boolean

	if instance:IsA("GuiObject") then
		return true
	end

	if CLASS_PROPERTIES[instance.ClassName] then
		return true
	end

	-- UIBase catches UI classes that may not yet have explicit
	-- serializer property definitions.
	local success, isUIBase = pcall(function()
		return instance:IsA("UIBase")
	end)

	if success and isUIBase then
		return true
	end

	return false
end

---------------------------------------------------------------------
-- Get relevant properties
---------------------------------------------------------------------

local function getPropertyList(instance: Instance): {string}

	local properties = {}
	local seen: {[string]: boolean} = {}

	local function add(propertyName: string)

		if seen[propertyName] then
			return
		end

		seen[propertyName] = true

		if EXCLUDED_PROPERTIES[propertyName] then
			return
		end

		table.insert(properties, propertyName)
	end

	-----------------------------------------------------------------
	-- GuiObject
	-----------------------------------------------------------------

	if instance:IsA("GuiObject") then

		for _, propertyName in GUI_OBJECT_PROPERTIES do
			add(propertyName)
		end
	end

	-----------------------------------------------------------------
	-- GuiButton
	-----------------------------------------------------------------

	if instance:IsA("GuiButton") then

		for _, propertyName in GUI_BUTTON_PROPERTIES do
			add(propertyName)
		end
	end

	-----------------------------------------------------------------
	-- Specific class
	-----------------------------------------------------------------

	local classProperties = CLASS_PROPERTIES[instance.ClassName]

	if classProperties then

		for _, propertyName in classProperties do
			add(propertyName)
		end
	end

	return properties
end

---------------------------------------------------------------------
-- Serialize properties
---------------------------------------------------------------------

local function serializeProperties(
	instance: Instance
): {{Name: string, Value: string}}

	local output = {}

	-----------------------------------------------------------------
	-- Create default instance.
	-----------------------------------------------------------------

	local defaultInstance: Instance? = nil

	local success, result = pcall(function()
		return Instance.new(instance.ClassName)
	end)

	if success then
		defaultInstance = result
	end

	-----------------------------------------------------------------
	-- Process each relevant property.
	-----------------------------------------------------------------

	for _, propertyName in getPropertyList(instance) do

		local propertySuccess, value =
			tryGetProperty(instance, propertyName)

		if not propertySuccess then
			continue
		end

		-------------------------------------------------------------
		-- Instance references cannot be recreated by pure generated
		-- code, so skip them.
		-------------------------------------------------------------

		if typeof(value) == "Instance" then
			continue
		end

		-------------------------------------------------------------
		-- Compare against Roblox default.
		-------------------------------------------------------------

		local isDefault = false

		if defaultInstance then

			local defaultSuccess, defaultValue =
				tryGetProperty(
					defaultInstance,
					propertyName
				)

			if defaultSuccess then

				isDefault = valuesEqual(
					value,
					defaultValue
				)
			end
		end

		if isDefault then
			continue
		end

		-------------------------------------------------------------
		-- Serialize.
		-------------------------------------------------------------

		local serialized = serialize(value)

		if not serialized then
			continue
		end

		table.insert(
			output,
			{
				Name = propertyName,
				Value = serialized,
			}
		)
	end

	-----------------------------------------------------------------
	-- Cleanup.
	-----------------------------------------------------------------

	if defaultInstance then
		defaultInstance:Destroy()
	end

	return output
end

---------------------------------------------------------------------
-- Children
---------------------------------------------------------------------

local function getSupportedChildren(
	instance: Instance
): {Instance}

	local children = {}

	for _, child in instance:GetChildren() do

		if isSupportedUI(child) then
			table.insert(children, child)
		end
	end

	return children
end

---------------------------------------------------------------------
-- Generate Pulse.Create
---------------------------------------------------------------------

local function generate(
	instance: Instance,
	level: number
): string

	local lines = {}

	local currentIndent = indent(level)
	local propertyIndent = indent(level + 1)

	-----------------------------------------------------------------
	-- Opening
	-----------------------------------------------------------------

	table.insert(
		lines,

		currentIndent
			.. "Pulse.Create("
			.. string.format("%q", instance.ClassName)
			.. ", {"
	)

	-----------------------------------------------------------------
	-- Properties
	-----------------------------------------------------------------

	local properties = serializeProperties(instance)

	for _, property in properties do

		table.insert(
			lines,

			propertyIndent
				.. property.Name
				.. " = "
				.. property.Value
				.. ","
		)
	end

	-----------------------------------------------------------------
	-- Children
	-----------------------------------------------------------------

	local children = getSupportedChildren(instance)

	if #children > 0 then

		table.insert(lines, "")

		table.insert(
			lines,
			propertyIndent .. "Children = {"
		)

		for _, child in children do

			table.insert(
				lines,

				generate(
					child,
					level + 2
				)
				.. ","
			)
		end

		table.insert(
			lines,
			propertyIndent .. "},"
		)
	end

	-----------------------------------------------------------------
	-- Closing
	-----------------------------------------------------------------

	table.insert(
		lines,
		currentIndent .. "})"
	)

	return table.concat(lines, "\n")
end

---------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------

function Serializer.Generate(UI: Instance): string

	assert(
		RunService:IsStudio(),
		"Serializer.Generate can only be called in Studio."
	)

	assert(
		typeof(UI) == "Instance",
		"Serializer.Generate expected an Instance."
	)

	assert(
		isSupportedUI(UI),
		string.format(
			"Unsupported UI class: %s",
			UI.ClassName
		)
	)

	return generate(UI, 0)
end

function Serializer.Print(UI: Instance): string

	local output = Serializer.Generate(UI)

	print(output)

	return output
end

return Serializer