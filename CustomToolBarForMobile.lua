-- Credit: Satchel v1.4.1 by @WinnersTakesAll (https://devforum.roblox.com/t/2451549) - includes topbarplus/GoodSignal/Janitor
-- Converted By @C00lCh4os, Forced touch patch by @Jskfhggjxu(Tory)

local UserInputService = game:GetService("UserInputService")
local targetMetatable = getrawmetatable(game)
local originalIndex = targetMetatable.__index
local originalNamecall = targetMetatable.__namecall

if setreadonly then setreadonly(targetMetatable, false) end

targetMetatable.__index = newcclosure(function(self, key)
    if self == UserInputService then
        if key == "GetLastInputType" then
            return function() return Enum.UserInputType.Touch end
        elseif key == "KeyboardEnabled" then
            return false
        elseif key == "TouchEnabled" then
            return true
        end
    end
    return originalIndex(self, key)
end)

targetMetatable.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if self == UserInputService and method == "GetLastInputType" then
        return Enum.UserInputType.Touch
    end
    return originalNamecall(self, ...)
end)

if setreadonly then targetMetatable.setreadonly(true) end






local loadedCache = {}
local function requireNode(node)
	if typeof(node) == "Instance" then
		return require(node)
	end
	if loadedCache[node] ~= nil then
		return loadedCache[node]
	end
	local result = node.__loader(node, requireNode)
	if result == nil then result = true end
	loadedCache[node] = result
	return result
end

local FakeSignal = {}
FakeSignal.__index = FakeSignal
local function newFakeSignal()
	return setmetatable({ __conns = {} }, FakeSignal)
end
function FakeSignal:Connect(fn)
	local conn = { __fn = fn, Connected = true }
	table.insert(self.__conns, conn)
	local disconnect = function()
		conn.Connected = false
	end
	return { Disconnect = disconnect, Destroy = disconnect }
end
function FakeSignal:Fire(...)
	for _, conn in ipairs(self.__conns) do
		if conn.Connected then
			conn.__fn(...)
		end
	end
end

local NodeMethods = {}
function NodeMethods:GetAttribute(name)
	return self.__attributes and self.__attributes[name]
end
function NodeMethods:SetAttribute(name, value)
	self.__attributes = self.__attributes or {}
	self.__attributes[name] = value
	if self.__attrSignals and self.__attrSignals[name] then
		self.__attrSignals[name]:Fire()
	end
end
function NodeMethods:GetAttributeChangedSignal(name)
	self.__attrSignals = self.__attrSignals or {}
	if not self.__attrSignals[name] then
		self.__attrSignals[name] = newFakeSignal()
	end
	return self.__attrSignals[name]
end
function NodeMethods:FindFirstChild(name, recursive)
	local direct = rawget(self, "__children")[name]
	if direct then return direct end
	if recursive then
		for _, child in pairs(rawget(self, "__children")) do
			local found = child:FindFirstChild(name, true)
			if found then return found end
		end
	end
	return nil
end
NodeMethods.WaitForChild = NodeMethods.FindFirstChild
function NodeMethods:GetChildren()
	local list = {}
	for _, child in pairs(rawget(self, "__children")) do
		table.insert(list, child)
	end
	return list
end
function NodeMethods:IsA(className)
	return className == "Instance" or className == self.ClassName
end
function NodeMethods:GetFullName()
	local parts = { self.Name }
	local p = self.Parent
	while p do
		table.insert(parts, 1, p.Name)
		p = p.Parent
	end
	return table.concat(parts, ".")
end

local function Node(name, className, loader)
	local node = { Name = name, ClassName = className, __loader = loader, __children = {} }
	setmetatable(node, { __index = function(t, key)
		local m = NodeMethods[key]
		if m then return m end
		return rawget(t, "__children")[key]
	end })
	return node
end

local function AddChild(parent, child)
	parent.__children[child.Name] = child
	child.Parent = parent
end

local node_0 = Node('Satchel', 'Folder', nil)
local node_1 = Node('SatchelLoader', 'Script', function(script, require)
require(script.Satchel)
end)
local node_2 = Node('Satchel', 'ModuleScript', function(script, require)
return require(script.Packages["satchel"])
end)
local node_3 = Node('Packages', 'Folder', nil)
local node_4 = Node('_Index', 'Folder', nil)
local node_5 = Node('1foreverhd_topbarplus@3.4.0', 'Folder', nil)
local node_6 = Node('topbarplus', 'ModuleScript', function(script, require)
local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local Types = require(script.Types)

export type Icon = Types.Icon

local iconModule = script
local Reference = require(iconModule.Reference)
local referenceObject = Reference.getObject()
local leadPackage = referenceObject and referenceObject.Value
if leadPackage and leadPackage ~= iconModule then
	return require(leadPackage) :: Types.StaticIcon
end
if not referenceObject then
	Reference.addToReplicatedStorage()
end

local Signal = require(iconModule.Packages.GoodSignal)
local Janitor = require(iconModule.Packages.Janitor)
local Utility = require(iconModule.Utility)
local Themes = require(iconModule.Features.Themes)
local Gamepad = require(iconModule.Features.Gamepad)
local Overflow = require(iconModule.Features.Overflow)
local Icon = {}
Icon.__index = Icon

local localPlayer = Players.LocalPlayer
local themes = iconModule.Features.Themes
local iconsDict = {}
local anyIconSelected = Signal.new()
local elements = iconModule.Elements
local totalCreatedIcons = 0
local preferredInput = {
	mobile = Enum.PreferredInput.Touch,
	desktop = Enum.PreferredInput.KeyboardAndMouse,
	console = Enum.PreferredInput.Gamepad
}

Icon.baseDisplayOrderChanged = Signal.new()
Icon.baseDisplayOrder = 10
Icon.baseTheme = require(themes.Default)
Icon.isOldTopbar = false 
Icon.iconsDictionary = iconsDict
Icon.insetHeightChanged = Signal.new()
Icon.container = require(elements.Container)(Icon)
Icon.topbarEnabled = true
Icon.iconAdded = Signal.new()
Icon.iconRemoved = Signal.new()
Icon.iconChanged = Signal.new()

function Icon.getIcons()
	return Icon.iconsDictionary
end

function Icon.getIconByUID(UID)
	local match = Icon.iconsDictionary[UID]
	if match then
		return match
	end
	return nil
end

function Icon.getIcon(nameOrUID)
	local match = Icon.getIconByUID(nameOrUID)
	if match then
		return match
	end
	for _, icon in pairs(iconsDict) do
		if icon.name == nameOrUID then
			return icon
		end
	end
	return nil
end

function Icon.setTopbarEnabled(bool, isInternal)
	if typeof(bool) ~= "boolean" then
		bool = Icon.topbarEnabled
	end
	if not isInternal then
		Icon.topbarEnabled = bool
	end
	for _, screenGui in pairs(Icon.container) do
		screenGui.Enabled = bool
	end
end

function Icon.modifyBaseTheme(modifications)
	modifications = Themes.getModifications(modifications)
	for _, modification in pairs(modifications) do
		for _, detail in pairs(Icon.baseTheme) do
			Themes.merge(detail, modification)
		end
	end
	for _, icon in pairs(iconsDict) do
		icon:setTheme(Icon.baseTheme)
	end
end

function Icon.setDisplayOrder(int)
	Icon.baseDisplayOrder = int
	Icon.baseDisplayOrderChanged:Fire(int)
end

task.defer(Gamepad.start, Icon)
task.defer(Overflow.start, Icon)
task.defer(function()
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	for _, screenGui in pairs(Icon.container) do
		screenGui.Parent = playerGui
	end
	require(iconModule.Attribute)
end)

function Icon.new()
	local self = {}
	setmetatable(self, Icon)

	
	local janitor = Janitor.new()
	self.janitor = janitor
	self.themesJanitor = janitor:add(Janitor.new())
	self.singleClickJanitor = janitor:add(Janitor.new())
	self.captionJanitor = janitor:add(Janitor.new())
	self.joinJanitor = janitor:add(Janitor.new())
	self.menuJanitor = janitor:add(Janitor.new())
	self.dropdownJanitor = janitor:add(Janitor.new())

	
	local iconUID = Utility.generateUID()
	iconsDict[iconUID] = self
	janitor:add(function()
		iconsDict[iconUID] = nil
	end)

	
	self.selected = janitor:add(Signal.new())
	self.deselected = janitor:add(Signal.new())
	self.toggled = janitor:add(Signal.new())
	self.viewingStarted = janitor:add(Signal.new())
	self.viewingEnded = janitor:add(Signal.new())
	self.stateChanged = janitor:add(Signal.new())
	self.notified = janitor:add(Signal.new())
	self.noticeStarted = janitor:add(Signal.new())
	self.noticeChanged = janitor:add(Signal.new())
	self.endNotices = janitor:add(Signal.new())
	self.toggleKeyAdded = janitor:add(Signal.new())
	self.fakeToggleKeyChanged = janitor:add(Signal.new())
	self.alignmentChanged = janitor:add(Signal.new())
	self.updateSize = janitor:add(Signal.new())
	self.resizingComplete = janitor:add(Signal.new())
	self.joinedParent = janitor:add(Signal.new())
	self.menuSet = janitor:add(Signal.new())
	self.dropdownSet = janitor:add(Signal.new())
	self.updateMenu = janitor:add(Signal.new())
	self.startMenuUpdate = janitor:add(Signal.new())
	self.childThemeModified = janitor:add(Signal.new())
	self.indicatorSet = janitor:add(Signal.new())
	self.dropdownChildAdded = janitor:add(Signal.new())
	self.menuChildAdded = janitor:add(Signal.new())

	
	self.iconModule = iconModule
	self.UID = iconUID
	self.isEnabled = true
	self.enabled = self.isEnabled 
	self.isSelected = false
	self.isViewing = false
	self.joinedFrame = false
	self.parentIconUID = false
	self.deselectWhenOtherIconSelected = true
	self.totalNotices = 0
	self.activeState = "Deselected"
	self.alignment = ""
	self.originalAlignment = ""
	self.appliedTheme = {}
	self.appearance = {}
	self.cachedInstances = {}
	self.cachedNamesToInstances = {}
	self.cachedCollectives = {}
	self.bindedToggleKeys = {}
	self.customBehaviours = {}
	self.toggleItems = {}
	self.bindedEvents = {}
	self.notices = {}
	self.menuIcons = {}
	self.dropdownIcons = {}
	self.childIconsDict = {}
	self.creationTime = os.clock()

	
	local widget = janitor:add(require(elements.Widget)(self, Icon))
	self.widget = widget
	self:setAlignment()
	
	
	
	totalCreatedIcons += 1
	local ourOrder = 1+(totalCreatedIcons*0.01)
	self:setOrder(ourOrder, "deselected")
	self:setOrder(ourOrder, "selected")

	
	self:setTheme(Icon.baseTheme)

	
	local clickRegion = self:getInstance("ClickRegion")
	local hasUsedMouseButton1Click = false
	local lastToggleTime = 0
	local DEBOUNCE_TIME = 0.1 

	local function handleToggle()
		if self.locked then
			return
		end

		
		local currentTime = tick()
		if currentTime - lastToggleTime < DEBOUNCE_TIME then
			return
		end
		lastToggleTime = currentTime

		if self.isSelected then
			self:deselect("User", self)
		else
			self:select("User", self)
		end
	end

	clickRegion.MouseButton1Click:Connect(function()
		hasUsedMouseButton1Click = true
		handleToggle()
	end)

	clickRegion.TouchTap:Connect(function()
		
		
		
		
		
		
		if not hasUsedMouseButton1Click then
			handleToggle()
		end
	end)

	
	janitor:add(UserInputService.InputBegan:Connect(function(input, touchingAnObject)
		if self.locked then
			return
		end
		if self.bindedToggleKeys[input.KeyCode] and not touchingAnObject then
			handleToggle()
		end
	end))

	
	
	
	local function viewingStarted(dontSetState)
		if self.locked then
			return
		end
		self.isViewing = true
		self.viewingStarted:Fire(true)
		if not dontSetState then
			self:setState("Viewing", "User", self)
		end
	end
	local function viewingEnded()
		if self.locked then
			return
		end
		self.isViewing = false
		self.viewingEnded:Fire(true)
		self:setState(nil, "User", self)
	end
	self.joinedParent:Connect(function()
		if self.isViewing then
			viewingEnded()
		end
	end)
	clickRegion.MouseEnter:Connect(function()
		local dontSetState = UserInputService.PreferredInput ~= preferredInput.desktop
		viewingStarted(dontSetState)
	end)
	local touchCount = 0
	janitor:add(UserInputService.TouchEnded:Connect(viewingEnded))
	clickRegion.MouseLeave:Connect(viewingEnded)
	clickRegion.SelectionGained:Connect(viewingStarted)
	clickRegion.SelectionLost:Connect(viewingEnded)
	clickRegion.MouseButton1Down:Connect(function()
		if not self.locked and UserInputService.PreferredInput == preferredInput.mobile then
			touchCount += 1
			local myTouchCount = touchCount
			task.delay(0.2, function()
				if myTouchCount == touchCount then
					viewingStarted()
				end
			end)
		end
	end)
	clickRegion.MouseButton1Up:Connect(function()
		touchCount += 1
	end)

	
	local iconOverlay = self:getInstance("IconOverlay")
	self.viewingStarted:Connect(function()
		iconOverlay.Visible = not self.overlayDisabled
	end)
	self.viewingEnded:Connect(function()
		iconOverlay.Visible = false
	end)

	
	janitor:add(anyIconSelected:Connect(function(incomingIcon)
		if incomingIcon ~= self and self.deselectWhenOtherIconSelected and incomingIcon.deselectWhenOtherIconSelected then
			self:deselect("AutoDeselect", incomingIcon)
		end
	end))

	
	
	
	
	
	local source =  debug.info(2, "s")
	local sourcePath = string.split(source, ".")
	local origin = game
	local originsScreenGui
	for i, sourceName in pairs(sourcePath) do
		origin = origin:FindFirstChild(sourceName)
		if not origin then
			break
		end
		if origin:IsA("ScreenGui") then
			originsScreenGui = origin
		end
	end
	if origin and originsScreenGui and originsScreenGui.ResetOnSpawn == true then
		self.originsScreenGui = originsScreenGui
		Utility.localPlayerRespawned(function()
			self:destroy()
		end)
	end

	
	self.toggled:Connect(function(isSelected)
		self.noticeChanged:Fire(self.totalNotices)
		for childIconUID, _ in pairs(self.childIconsDict) do
			local childIcon = Icon.getIconByUID(childIconUID)
			childIcon.noticeChanged:Fire(childIcon.totalNotices)
			if not isSelected and childIcon.isSelected then
				
				
				for _, _ in pairs(childIcon.childIconsDict) do
					childIcon:deselect("HideParentFeature", self)
				end
			end
		end
	end)
	
	
	
	
	
	
	
	
	
	self.selected:Connect(function()
		local isDropdown = #self.dropdownIcons > 0
		if isDropdown then
			if StarterGui:GetCore("ChatActive") and self.alignment ~= "Right" then
				self.chatWasPreviouslyActive = true
				StarterGui:SetCore("ChatActive", false)
			end
			if StarterGui:GetCoreGuiEnabled("PlayerList") and self.alignment ~= "Left" then
				self.playerlistWasPreviouslyActive = true
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
			end
		end
	end)
	self.deselected:Connect(function()
		if self.chatWasPreviouslyActive then
			self.chatWasPreviouslyActive = nil
			StarterGui:SetCore("ChatActive", true)
		end
		if self.playerlistWasPreviouslyActive then
			self.playerlistWasPreviouslyActive = nil
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
		end
	end)
	
	
	
	
	task.delay(0.1, function()
		if self.activeState == "Deselected" then
			self.stateChanged:Fire("Deselected")
			self:refresh()
		end
	end)
	
	
	Icon.iconAdded:Fire(self)

	return self
end

function Icon:setName(name)
	self.widget.Name = name
	self.name = name
	return self
end

function Icon:setState(incomingStateName, fromSource, sourceIcon)
	
	
	
	if not incomingStateName then
		incomingStateName = (self.isSelected and "Selected") or "Deselected"
	end
	local stateName = Utility.formatStateName(incomingStateName)
	local previousStateName = self.activeState
	if previousStateName == stateName then
		return
	end
	local currentIsSelected = self.isSelected
	self.activeState = stateName
	if stateName == "Deselected" then
		self.isSelected = false
		if currentIsSelected then
			self.toggled:Fire(false, fromSource, sourceIcon)
			self.deselected:Fire(fromSource, sourceIcon)
		end
		self:_setToggleItemsVisible(false, fromSource, sourceIcon)
	elseif stateName == "Selected" then
		self.isSelected = true
		if not currentIsSelected then
			self.toggled:Fire(true, fromSource, sourceIcon)
			self.selected:Fire(fromSource, sourceIcon)
			anyIconSelected:Fire(self, fromSource, sourceIcon)
		end
		self:_setToggleItemsVisible(true, fromSource, sourceIcon)
	end
	self.stateChanged:Fire(stateName, fromSource, sourceIcon)
end

function Icon:getInstance(name)
	
	
	
	local instance = self.cachedNamesToInstances[name]
	if instance then
		return instance
	end
	local function cacheInstance(childName, child)
		local currentCache = self.cachedInstances[child]
		if not currentCache then
			local collectiveName = child:GetAttribute("Collective")
			local cachedCollective = collectiveName and self.cachedCollectives[collectiveName]
			if cachedCollective then
				table.insert(cachedCollective, child)
			end
			self.cachedNamesToInstances[childName] = child
			self.cachedInstances[child] = true
			child.Destroying:Once(function()
				self.cachedNamesToInstances[childName] = nil
				self.cachedInstances[child] = nil
			end)
		end
	end
	local widget = self.widget
	cacheInstance("Widget", widget)
	if name == "Widget" then
		return widget
	end

	local returnChild
	local function scanChildren(parentInstance)
		for _, child in pairs(parentInstance:GetChildren()) do
			local widgetUID = child:GetAttribute("WidgetUID")
			if widgetUID and widgetUID ~= self.UID then
				
				
				continue
			end
			
			
			local realChild = Themes.getRealInstance(child)
			if realChild then
				child = realChild
			end
			
			scanChildren(child)
			if child:IsA("GuiBase") or child:IsA("UIBase") or child:IsA("ValueBase") then
				local childName = child.Name
				cacheInstance(childName, child)
				if childName == name then
					returnChild = child
				end
			end
		end
	end
	scanChildren(widget)
	return returnChild
end

function Icon:getCollective(name)
	
	
	
	
	
	
	local collective = self.cachedCollectives[name]
	if collective then
		return collective
	end
	collective = {}
	for instance, _ in pairs(self.cachedInstances) do
		if instance:GetAttribute("Collective") == name then
			table.insert(collective, instance)
		end
	end
	self.cachedCollectives[name] = collective
	return collective
end

function Icon:getInstanceOrCollective(collectiveOrInstanceName)
	
	
	local instances = {}
	local instance = self:getInstance(collectiveOrInstanceName)
	if instance then
		table.insert(instances, instance)
	end
	if #instances == 0 then
		instances = self:getCollective(collectiveOrInstanceName)
	end
	return instances
end

function Icon:getStateGroup(iconState)
	local chosenState = iconState or self.activeState
	local stateGroup = self.appearance[chosenState]
	if not stateGroup then
		stateGroup = {}
		self.appearance[chosenState] = stateGroup
	end
	return stateGroup
end

function Icon:refreshAppearance(instance, specificProperty)
	Themes.refresh(self, instance, specificProperty)
	return self
end

function Icon:refresh()
	self:refreshAppearance(self.widget)
	self.updateSize:Fire()
	return self
end

function Icon:updateParent()
	local parentIcon = Icon.getIconByUID(self.parentIconUID)
	if parentIcon then
		parentIcon.updateSize:Fire()
	end
end

function Icon:setBehaviour(collectiveOrInstanceName, property, callback, refreshAppearance)
	
	
	local key = collectiveOrInstanceName.."-"..property
	self.customBehaviours[key] = callback
	if refreshAppearance then
		local instances = self:getInstanceOrCollective(collectiveOrInstanceName)
		for _, instance in pairs(instances) do
			self:refreshAppearance(instance, property)
		end
	end
end

function Icon:modifyTheme(modifications, customModificationUID)
	local modificationUID = Themes.modify(self, modifications, customModificationUID)
	return self, modificationUID
end

function Icon:modifyChildTheme(modifications, modificationUID)
	
	
	self.childModifications = modifications
	self.childModificationsUID = modificationUID
	for childIconUID, _ in pairs(self.childIconsDict) do
		local childIcon = Icon.getIconByUID(childIconUID)
		childIcon:modifyTheme(modifications, modificationUID)
	end
	self.childThemeModified:Fire()
	return self
end

function Icon:removeModification(modificationUID)
	Themes.remove(self, modificationUID)
	return self
end

function Icon:removeModificationWith(instanceName, property, state)
	Themes.removeWith(self, instanceName, property, state)
	return self
end

function Icon:setTheme(theme)
	Themes.set(self, theme)
	return self
end

function Icon:setEnabled(bool)
	self.isEnabled = bool
	self.enabled = self.isEnabled
	self.widget.Visible = bool
	self:updateParent()
	return self
end

function Icon:select(fromSource, sourceIcon)
	self:setState("Selected", fromSource, sourceIcon)
	return self
end

function Icon:deselect(fromSource, sourceIcon)
	self:setState("Deselected", fromSource, sourceIcon)
	return self
end

function Icon:notify(customClearSignal, noticeId)
	
	
	
	
	local notice = self.notice
	if not notice then
		notice = require(elements.Notice)(self, Icon)
		self.notice = notice
	end
	self.noticeStarted:Fire(customClearSignal, noticeId)
	return self
end

function Icon:clearNotices()
	self.endNotices:Fire()
	return self
end

function Icon:disableOverlay(bool)
	self.overlayDisabled = bool
	return self
end
Icon.disableStateOverlay = Icon.disableOverlay

function Icon:setImage(imageId, iconState)
	self:modifyTheme({"IconImage", "Image", imageId, iconState})
	
	
	task.spawn(function()
		local newIdContent = if tonumber(imageId) then `rbxassetid://{imageId}` else imageId
		local initialAssetFetchStatus = ContentProvider:GetAssetFetchStatus(newIdContent)
	
		if initialAssetFetchStatus ~= Enum.AssetFetchStatus.Success then
			pcall(ContentProvider.PreloadAsync, ContentProvider, { newIdContent })
		end
	end)
		
	return self
end

function Icon:setLabel(text, iconState)
	self:modifyTheme({"IconLabel", "Text", text, iconState})
	return self
end

function Icon:setOrder(int, iconState)
	
	
	local newInt = int*100
	self:modifyTheme({"IconSpot", "LayoutOrder", newInt, iconState})
	self:modifyTheme({"Widget", "LayoutOrder", newInt, iconState})
	return self
end

function Icon:setCornerRadius(udim, iconState)
	self:modifyTheme({"IconCorners", "CornerRadius", udim, iconState})
	return self
end

function Icon:align(leftCenterOrRight, isFromParentIcon)
	
	local direction = tostring(leftCenterOrRight):lower()
	if direction == "mid" or direction == "centre" then
		direction = "center"
	end
	if direction ~= "left" and direction ~= "center" and direction ~= "right" then
		direction = "left"
	end
	local screenGui = (direction == "center" and Icon.container.TopbarCentered) or Icon.container.TopbarStandard
	local holders = screenGui.Holders
	local finalDirection = string.upper(string.sub(direction, 1, 1))..string.sub(direction, 2)
	if not isFromParentIcon then
		self.originalAlignment = finalDirection
	end
	local joinedFrame = self.joinedFrame
	local alignmentHolder = holders[finalDirection]
	self.screenGui = screenGui
	self.alignmentHolder = alignmentHolder
	if not self.isDestroyed then
		self.widget.Parent = joinedFrame or alignmentHolder
	end
	self.alignment = finalDirection
	self.alignmentChanged:Fire(finalDirection)
	Icon.iconChanged:Fire(self)
	return self
end
Icon.setAlignment = Icon.align

function Icon:setLeft()
	self:setAlignment("Left")
	return self
end

function Icon:setMid()
	self:setAlignment("Center")
	return self
end

function Icon:setRight()
	self:setAlignment("Right")
	return self
end

function Icon:setWidth(offsetMinimum, iconState)
	
	
	
	self:modifyTheme({"Widget", "DesiredWidth", offsetMinimum, iconState})
	return self
end

function Icon:setImageScale(number, iconState)
	self:modifyTheme({"IconImageScale", "Value", number, iconState})
	return self
end

function Icon:setImageRatio(number, iconState)
	self:modifyTheme({"IconImageRatio", "AspectRatio", number, iconState})
	return self
end

function Icon:setTextSize(number, iconState)
	self:modifyTheme({"IconLabel", "TextSize", number, iconState})
	return self
end

function Icon:setTextFont(font, fontWeight, fontStyle, iconState)
	fontWeight = fontWeight or Enum.FontWeight.Regular
	fontStyle = fontStyle or Enum.FontStyle.Normal
	local fontFace
	local fontType = typeof(font)
	if fontType == "number" then
		fontFace = Font.fromId(font, fontWeight, fontStyle)
	elseif fontType == "EnumItem" then
		fontFace = Font.fromEnum(font)
	elseif fontType == "string" then
		if not font:match("rbxasset") then
			fontFace = Font.fromName(font, fontWeight, fontStyle)
		end
	end
	if not fontFace then
		fontFace = Font.new(font, fontWeight, fontStyle)
	end
	self:modifyTheme({"IconLabel", "FontFace", fontFace, iconState})
	return self
end

function Icon:setTextColor(Color, iconState)
	if Color == nil or Color == "" or (type(Color) ~= "userdata" or typeof(Color) ~= "Color3") then
		if Color ~= nil and Color ~= "" then
			warn("setTextColor item must be a Color3 value! Changed the color to white.")
		end
		Color = Color3.fromRGB(255, 255, 255)
	end

	self:modifyTheme({"IconLabel", "TextColor3", Color, iconState})
	return self
end

function Icon:bindToggleItem(guiObjectOrLayerCollector)
	if not guiObjectOrLayerCollector:IsA("GuiObject") and not guiObjectOrLayerCollector:IsA("LayerCollector") then
		error("Toggle item must be a GuiObject or LayerCollector!")
	end
	self.toggleItems[guiObjectOrLayerCollector] = true
	self:_updateSelectionInstances()
	return self
end

function Icon:unbindToggleItem(guiObjectOrLayerCollector)
	self.toggleItems[guiObjectOrLayerCollector] = nil
	self:_updateSelectionInstances()
	return self
end

function Icon:_updateSelectionInstances()
	
	
	for guiObjectOrLayerCollector, _ in pairs(self.toggleItems) do
		local buttonInstancesArray = {}
		for _, instance in pairs(guiObjectOrLayerCollector:GetDescendants()) do
			if (instance:IsA("TextButton") or instance:IsA("ImageButton")) and instance.Active then
				table.insert(buttonInstancesArray, instance)
			end
		end
		self.toggleItems[guiObjectOrLayerCollector] = buttonInstancesArray
	end
end

function Icon:_setToggleItemsVisible(bool, fromSource, sourceIcon)
	for toggleItem, _ in pairs(self.toggleItems) do
		if not sourceIcon or sourceIcon == self or sourceIcon.toggleItems[toggleItem] == nil then
			local property = "Visible"
			if toggleItem:IsA("LayerCollector") then
				property = "Enabled"
			end
			toggleItem[property] = bool
		end
	end
end

function Icon:bindEvent(iconEventName, eventFunction)
	local event = self[iconEventName]
	assert(event and typeof(event) == "table" and event.Connect, "argument[1] must be a valid topbarplus icon event name!")
	assert(typeof(eventFunction) == "function", "argument[2] must be a function!")
	self.bindedEvents[iconEventName] = event:Connect(function(...)
		eventFunction(self, ...)
	end)
	return self
end

function Icon:unbindEvent(iconEventName)
	local eventConnection = self.bindedEvents[iconEventName]
	if eventConnection then
		eventConnection:Disconnect()
		self.bindedEvents[iconEventName] = nil
	end
	return self
end

function Icon:bindToggleKey(keyCodeEnum)
	assert(typeof(keyCodeEnum) == "EnumItem", "argument[1] must be a KeyCode EnumItem!")
	self.bindedToggleKeys[keyCodeEnum] = true
	self.toggleKeyAdded:Fire(keyCodeEnum)
	self:setCaption("_hotkey_")
	return self
end

function Icon:unbindToggleKey(keyCodeEnum)
	assert(typeof(keyCodeEnum) == "EnumItem", "argument[1] must be a KeyCode EnumItem!")
	self.bindedToggleKeys[keyCodeEnum] = nil
	return self
end

function Icon:call(callback, ...)
	local packedArgs = table.pack(...)
	task.spawn(function()
		callback(self, table.unpack(packedArgs))
	end)
	return self
end

function Icon:addToJanitor(callback, methodName, index)
	self.janitor:add(callback, methodName, index)
	return self
end

function Icon:lock()
	
	local clickRegion = self:getInstance("ClickRegion")
	clickRegion.Visible = false
	self.locked = true
	return self
end

function Icon:unlock()
	local clickRegion = self:getInstance("ClickRegion")
	clickRegion.Visible = true
	self.locked = false
	return self
end

function Icon:debounce(seconds)
	self:lock()
	task.wait(seconds)
	self:unlock()
	return self
end

function Icon:autoDeselect(bool)
	
	
	if bool == nil then
		bool = true
	end
	self.deselectWhenOtherIconSelected = bool
	return self
end

function Icon:oneClick(bool)
	
	
	local singleClickJanitor = self.singleClickJanitor
	singleClickJanitor:clean()
	if bool or bool == nil then
		singleClickJanitor:add(self.selected:Connect(function()
			self:deselect("OneClick", self)
		end))
	end
	self.oneClickEnabled = true
	return self
end

function Icon:setCaption(text)
	if text == "_hotkey_" and (self.captionText) then
		return self
	end
	local captionJanitor = self.captionJanitor
	self.captionJanitor:clean()
	if not text or text == "" then
		self.caption = nil
		self.captionText = nil
		return self
	end
	local caption = captionJanitor:add(require(elements.Caption)(self))
	caption:SetAttribute("CaptionText", text)
	self.caption = caption
	self.captionText = text
	return self
end

function Icon:setCaptionHint(keyCodeEnum)
	assert(typeof(keyCodeEnum) == "EnumItem", "argument[1] must be a KeyCode EnumItem!")
	self.fakeToggleKey = keyCodeEnum
	self.fakeToggleKeyChanged:Fire(keyCodeEnum)
	self:setCaption("_hotkey_")
	return self
end

function Icon:leave()
	local joinJanitor = self.joinJanitor
	joinJanitor:clean()
	return self
end

function Icon:joinMenu(parentIcon)
	Utility.joinFeature(self, parentIcon, parentIcon.menuIcons, parentIcon:getInstance("Menu"))
	parentIcon.menuChildAdded:Fire(self)
	return self
end

function Icon:setMenu(arrayOfIcons)
	self.menuSet:Fire(arrayOfIcons)
	return self
end

function Icon:setFixedMenu(arrayOfIcons)
	self:freezeMenu(arrayOfIcons)
	self:setMenu(arrayOfIcons)
end
Icon.setFrozenMenu = Icon.setFixedMenu

function Icon:freezeMenu()
	
	
	self:select("FrozenMenu", self)
	self:bindEvent("deselected", function(icon)
		icon:select("FrozenMenu", self)
	end)
	self:modifyTheme({"IconSpot", "Visible", false})
end

function Icon:joinDropdown(parentIcon)
	parentIcon:getDropdown()
	Utility.joinFeature(self, parentIcon, parentIcon.dropdownIcons, parentIcon:getInstance("DropdownScroller"))
	parentIcon.dropdownChildAdded:Fire(self)
	return self
end

function Icon:getDropdown()
	local dropdown = self.dropdown
	if not dropdown then
		dropdown = require(elements.Dropdown)(self)
		self.dropdown = dropdown
		self:clipOutside(dropdown)
	end
	return dropdown
end

function Icon:setDropdown(arrayOfIcons)
	self:getDropdown()
	self.dropdownSet:Fire(arrayOfIcons)
	return self
end

function Icon:clipOutside(instance)
	
	
	
	
	
	local instanceClone = Utility.clipOutside(self, instance)
	self:refreshAppearance(instance)
	return self, instanceClone
end

function Icon:setIndicator(keyCode)
	
	
	
	local indicator = self.indicator
	if not indicator then
		indicator = self.janitor:add(require(elements.Indicator)(self, Icon))
		self.indicator = indicator
	end
	self.indicatorSet:Fire(keyCode)
end

function Icon:convertLabelToNumberSpinner(numberSpinner, callback)
	task.defer(function()
		
		local label = self:getInstance("IconLabel")
		label.Transparency = 1
		numberSpinner.Parent = label.Parent
		numberSpinner.Size = UDim2.fromScale(1, 1)
		numberSpinner.AnchorPoint = Vector2.new(0.5, 0.5)
		numberSpinner.Position = UDim2.new(0.5, 0, 0.5, 0)
		numberSpinner.TextXAlignment = Enum.TextXAlignment.Center
		numberSpinner.ClipsDescendants = false

		local propertiesToChangeLabel = {
			"FontFace",
			"BorderSizePixel",
			"BorderColor3",
			"Rotation",
			"TextStrokeTransparency",
			"TextStrokeColor3",
			"TextStrokeTransparency",
			"TextColor3",
		}
		for _, property in ipairs(propertiesToChangeLabel) do
			numberSpinner[property] = label[property]
			self:addToJanitor(label:GetPropertyChangedSignal(property):Connect(function()
				numberSpinner[property] = label[property]
			end))
		end

		local minDigits = 0
		local maxDigits = 8
		local function getSpinnerSizeAndDigitCount()
			local TotalSize = 0
			local numOfDigits = 0
			for i, child in numberSpinner.Frame:GetChildren() do
				local name = string.lower(child.Name)
				if name == "digit" then
					TotalSize += child.AbsoluteSize.X
					numOfDigits += 1
				elseif name == "prefix" or name == "suffix" or name == "comma" then
					if child.Text ~= "" then
						TotalSize += child.AbsoluteSize.X
						numOfDigits += 1
					end
				end
			end
			return TotalSize, numOfDigits
		end
		
		local function getLabelParentContainerXSize()
			local firstParent = label.Parent
			local nextParent = firstParent and firstParent.Parent
			if nextParent == nil then
				return 0
			end
			if nextParent.IconImage.Visible == true then
				return numberSpinner.Frame.AbsoluteSize.X + label.Parent.Parent.IconImage.AbsoluteSize.X
			else
				return nextParent.AbsoluteSize.X
			end
		end
		local function getNumberSpinnerXSize()
			return numberSpinner.Frame.AbsoluteSize.X
		end

		local function adjustSize()
			local totalDigitXSize, numOfDigits = getSpinnerSizeAndDigitCount()
			if numOfDigits < 18 then
				self:setLabel(numberSpinner.Value)
			end

			local NumberSpinnerXSize = getNumberSpinnerXSize()

			while totalDigitXSize < NumberSpinnerXSize and self.isDestroyed ~= true do
				task.wait(0.05)
				if numOfDigits > minDigits and numOfDigits < maxDigits then
					numberSpinner.TextSize = label.TextSize
					break
				else
					numberSpinner.TextSize += 1
				end

				NumberSpinnerXSize = getNumberSpinnerXSize()
				totalDigitXSize, numOfDigits = getSpinnerSizeAndDigitCount()
			end

			local labelParentContainerXSize = getLabelParentContainerXSize()
			while totalDigitXSize > labelParentContainerXSize and self.isDestroyed ~= true do
				task.wait(0.05)
				if numOfDigits < maxDigits and numOfDigits > minDigits then
					numberSpinner.TextSize = label.TextSize
					break
				else
					numberSpinner.TextSize -= 1
				end

				labelParentContainerXSize = getLabelParentContainerXSize()
				totalDigitXSize, numOfDigits = getSpinnerSizeAndDigitCount()
			end
		end

		self:addToJanitor(numberSpinner.Frame.ChildAdded:Connect(adjustSize))
		self:addToJanitor(numberSpinner.Frame.ChildRemoved:Connect(adjustSize))
		self:addToJanitor(self.iconAdded:Connect(function()
			task.wait(1)
			adjustSize()
		end))

		self:updateParent()

		
		numberSpinner.Name = "LabelSpinner"
		numberSpinner.Prefix = "$"
		numberSpinner.Commas = true
		numberSpinner.Decimals = 0
		numberSpinner.Duration = 0.25
		numberSpinner.Value = 10
		task.wait(0.2)
		
		if typeof(callback) == "function" then
			callback()
		end
		
	end)
	return self
end

function Icon:destroy()
	if self.isDestroyed then
		return
	end
	self:clearNotices()
	if self.parentIconUID then
		self:leave()
	end
	self.isDestroyed = true
	self.janitor:clean()
	Icon.iconRemoved:Fire(self)
end
Icon.Destroy = Icon.destroy

return Icon :: Types.StaticIcon
end)
local node_7 = Node('Attribute', 'ModuleScript', function(script, require)
task.defer(function()
	local RunService = game:GetService("RunService")
	local VERSION = require(script.Parent.VERSION)
	local appVersion = VERSION.getAppVersion()
	local latestVersion = VERSION.getLatestVersion()
	local isOutdated = not VERSION.isUpToDate()
	if not RunService:IsStudio() then
		print(`Mambo - Converted By C00l_Ch4os`)
	end
	if isOutdated then
		warn(`Mambo - Converted By C00l_Ch4os`)
	end
end)

return {}
end)
local node_8 = Node('Elements', 'Folder', nil)
local node_9 = Node('Caption', 'ModuleScript', function(script, require)
local CAPTION_COLOR = Color3.fromRGB(39, 41, 48)
local TEXT_SIZE = 15
return function(icon)

	
	
	local clickRegion = icon:getInstance("ClickRegion")
	local caption = Instance.new("CanvasGroup")
	caption.Name = "Caption"
	caption.AnchorPoint = Vector2.new(0.5, 0)
	caption.BackgroundTransparency = 1
	caption.BorderSizePixel = 0
	caption.GroupTransparency = 1
	caption.Position = UDim2.fromOffset(0, 0)
	caption.Visible = true
	caption.ZIndex = 30
	caption.Parent = clickRegion

	local box = Instance.new("Frame")
	box.Name = "Box"
	box.AutomaticSize = Enum.AutomaticSize.XY
	box.BackgroundColor3 = CAPTION_COLOR
	box.Position = UDim2.fromOffset(4, 7)
	box.ZIndex = 12
	box.Parent = caption

	local header = Instance.new("TextLabel")
	header.Name = "Header"
	header.FontFace = Font.new(
		"rbxasset://fonts/families/BuilderSans.json",
		Enum.FontWeight.Medium,
		Enum.FontStyle.Normal
	)
	header.Text = "Caption"
	header.TextColor3 = Color3.fromRGB(255, 255, 255)
	header.TextSize = TEXT_SIZE
	header.TextTruncate = Enum.TextTruncate.None
	header.TextWrapped = false
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.AutomaticSize = Enum.AutomaticSize.X
	header.BackgroundTransparency = 1
	header.LayoutOrder = 1
	header.Size = UDim2.fromOffset(0, 16)
	header.ZIndex = 18
	header.Parent = box

	local layout = Instance.new("UIListLayout")
	layout.Name = "Layout"
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = box

	local UICorner = Instance.new("UICorner")
	UICorner.Name = "CaptionCorner"
	UICorner.Parent = box

	local padding = Instance.new("UIPadding")
	padding.Name = "Padding"
	padding.PaddingBottom = UDim.new(0, 12)
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.PaddingTop = UDim.new(0, 12)
	padding.Parent = box

	local hotkeys = Instance.new("Frame")
	hotkeys.Name = "Hotkeys"
	hotkeys.AutomaticSize = Enum.AutomaticSize.Y
	hotkeys.BackgroundTransparency = 1
	hotkeys.LayoutOrder = 3
	hotkeys.Size = UDim2.fromScale(1, 0)
	hotkeys.Visible = false
	hotkeys.Parent = box

	local layout1 = Instance.new("UIListLayout")
	layout1.Name = "Layout1"
	layout1.Padding = UDim.new(0, 6)
	layout1.FillDirection = Enum.FillDirection.Vertical
	layout1.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout1.HorizontalFlex = Enum.UIFlexAlignment.None
	layout1.ItemLineAlignment = Enum.ItemLineAlignment.Automatic
	layout1.VerticalFlex = Enum.UIFlexAlignment.None
	layout1.SortOrder = Enum.SortOrder.LayoutOrder
	layout1.Parent = hotkeys

	local keyTag1 = Instance.new("ImageLabel")
	keyTag1.Name = "Key1"
	keyTag1.Image = "rbxasset://textures/ui/Controls/key_single.png"
	keyTag1.ImageTransparency = 0.7
	keyTag1.ScaleType = Enum.ScaleType.Slice
	keyTag1.SliceCenter = Rect.new(5, 5, 23, 24)
	keyTag1.AutomaticSize = Enum.AutomaticSize.X
	keyTag1.BackgroundTransparency = 1
	keyTag1.LayoutOrder = 1
	keyTag1.Size = UDim2.fromOffset(0, 30)
	keyTag1.ZIndex = 15
	keyTag1.Parent = hotkeys

	local inset = Instance.new("UIPadding")
	inset.Name = "Inset"
	inset.PaddingLeft = UDim.new(0, 8)
	inset.PaddingRight = UDim.new(0, 8)
	inset.Parent = keyTag1

	local labelContent = Instance.new("TextLabel")
	labelContent.AutoLocalize = false
	labelContent.Name = "LabelContent"
	labelContent.FontFace = Font.new(
		"rbxasset://fonts/families/GothamSSm.json",
		Enum.FontWeight.Medium,
		Enum.FontStyle.Normal
	)
	labelContent.Text = ""
	labelContent.TextColor3 = Color3.fromRGB(189, 190, 190)
	labelContent.TextSize = TEXT_SIZE
	labelContent.AutomaticSize = Enum.AutomaticSize.X
	labelContent.BackgroundTransparency = 1
	labelContent.Position = UDim2.fromOffset(0, -1)
	labelContent.Size = UDim2.fromScale(1, 1)
	labelContent.ZIndex = 16
	labelContent.Parent = keyTag1
	
	local caret = Instance.new("ImageLabel")
	caret.Name = "Caret"
	caret.Image = "rbxassetid://101906294438076"
	caret.ImageColor3 = CAPTION_COLOR
	caret.AnchorPoint = Vector2.new(0, 0.5)
	caret.BackgroundTransparency = 1
	caret.Position = UDim2.new(0, 0, 0, 4)
	caret.Size = UDim2.fromOffset(16, 8)
	caret.ZIndex = 12
	caret.Parent = caption

	local dropShadow = Instance.new("ImageLabel")
	dropShadow.Visible = true
	dropShadow.Name = "DropShadow"
	dropShadow.Image = "rbxassetid://124920646932671"
	dropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	dropShadow.ImageTransparency = 0.45
	dropShadow.ScaleType = Enum.ScaleType.Slice
	dropShadow.SliceCenter = Rect.new(12, 12, 13, 13)
	dropShadow.BackgroundTransparency = 1
	dropShadow.Position = UDim2.fromOffset(0, 5)
	dropShadow.Size = UDim2.new(1, 0, 0, 48)
	dropShadow.Parent = caption
	box:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		dropShadow.Size = UDim2.new(1, 0, 0, box.AbsoluteSize.Y + 8)
	end)
	
	
	
	
	local captionJanitor = icon.captionJanitor
	local _, captionClone = icon:clipOutside(caption)
	captionClone.AutomaticSize = Enum.AutomaticSize.None
	local function matchSize()
		local absolute = caption.AbsoluteSize
		captionClone.Size = UDim2.fromOffset(absolute.X, absolute.Y)
	end
	captionJanitor:add(caption:GetPropertyChangedSignal("AbsoluteSize"):Connect(matchSize))
	matchSize()
	
	
	
	
	local isCompletelyEnabled = false
	local captionHeader = caption.Box.Header
	local UserInputService = game:GetService("UserInputService")
	local function updateHotkey(keyCodeEnum)
		local hasKeyboard = UserInputService.KeyboardEnabled
		local text = caption:GetAttribute("CaptionText") or ""
		local hideHeader = text == "_hotkey_"
		if not hasKeyboard and hideHeader then
			icon:setCaption()
			return
		end
		captionHeader.Text = text
		captionHeader.Visible = not hideHeader
		if keyCodeEnum then
			labelContent.Text = keyCodeEnum.Name
			hotkeys.Visible = true
		end
		if not hasKeyboard then
			hotkeys.Visible = false
		end
	end
	caption:GetAttributeChangedSignal("CaptionText"):Connect(updateHotkey)

	local EASING_STYLE = Enum.EasingStyle.Quad
	local TWEEN_SPEED = 0.2
	local TWEEN_INFO_IN = TweenInfo.new(TWEEN_SPEED, EASING_STYLE, Enum.EasingDirection.In)
	local TWEEN_INFO_OUT = TweenInfo.new(TWEEN_SPEED, EASING_STYLE, Enum.EasingDirection.Out)
	local TweenService = game:GetService("TweenService")
	local RunService = game:GetService("RunService")
	local function getCaptionPosition(customEnabled)
		local enabled = if customEnabled ~= nil then customEnabled else isCompletelyEnabled
		local yOut = 2
		local yIn = yOut + 8
		local yOffset = if enabled then yIn else yOut
		return UDim2.new(0.5, 0, 1, yOffset)
	end
	local function updatePosition(forcedEnabled)
		
		
		if not isCompletelyEnabled then
			return
		end
		
		
		
		
		local enabled = if forcedEnabled ~= nil then forcedEnabled else isCompletelyEnabled
		local startPosition = getCaptionPosition(not enabled)
		local endPosition = getCaptionPosition(enabled)
		
		
		
		if enabled then
			local caretY = caret.Position.Y.Offset
			caret.Position = UDim2.fromOffset(0, caretY)
			caption.AutomaticSize = Enum.AutomaticSize.XY
			caption.Size = UDim2.fromOffset(32, 53)
		else
			local absolute = caption.AbsoluteSize
			caption.AutomaticSize = Enum.AutomaticSize.Y
			caption.Size = UDim2.fromOffset(absolute.X, absolute.Y)
		end
		
		
		local previousCaretX
		local function updateCaret()
			local caretX = clickRegion.AbsolutePosition.X - caption.AbsolutePosition.X + clickRegion.AbsoluteSize.X/2 - caret.AbsoluteSize.X/2
			local caretY = caret.Position.Y.Offset
			local newCaretPosition = UDim2.fromOffset(caretX, caretY)
			if previousCaretX ~= caretX then
				
				
				
				
				previousCaretX = caretX
				caret.Position = UDim2.fromOffset(0, caretY)
				task.wait()
			end
			caret.Position = newCaretPosition
		end
		captionClone.Position = startPosition
		updateCaret()
		
		
		local tweenInfo = (enabled and TWEEN_INFO_IN) or TWEEN_INFO_OUT
		local tween = TweenService:Create(captionClone, tweenInfo, {Position = endPosition})
		local updateCaretConnection = RunService.Heartbeat:Connect(updateCaret)
		tween:Play()
		tween.Completed:Once(function()
			updateCaretConnection:Disconnect()
		end)
		
	end
	captionJanitor:add(clickRegion:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		updatePosition()
	end))
	updatePosition(false)
	
	captionJanitor:add(icon.toggleKeyAdded:Connect(updateHotkey))
	for keyCodeEnum, _ in pairs(icon.bindedToggleKeys) do
		updateHotkey(keyCodeEnum)
		break
	end
	captionJanitor:add(icon.fakeToggleKeyChanged:Connect(updateHotkey))
	local fakeToggleKey = icon.fakeToggleKey
	if fakeToggleKey then
		updateHotkey(fakeToggleKey)
	end

	local function setCaptionEnabled(enabled)
		if isCompletelyEnabled == enabled then
			return
		end
		local joinedFrame = icon.joinedFrame
		if joinedFrame and string.match(joinedFrame.Name, "Dropdown") then
			enabled = false
		end
		isCompletelyEnabled = enabled
		local newTransparency = (enabled and 0) or 1
		local tweenInfo = (enabled and TWEEN_INFO_IN) or TWEEN_INFO_OUT
		local tweenTransparency = TweenService:Create(caption, tweenInfo, {
			GroupTransparency = newTransparency
		})
		tweenTransparency:Play()
		if enabled then
			captionClone:SetAttribute("ForceUpdate", true)
		end
		updatePosition()
		updateHotkey()
	end
	
	local WAIT_DURATION = 0.5
	local RECOVER_PERIOD = 0.3
	local Icon = require(icon.iconModule)
	captionJanitor:add(icon.stateChanged:Connect(function(stateName)
		if stateName == "Viewing" then
			local lastClock = Icon.captionLastClosedClock
			local clockDifference = (lastClock and os.clock() - lastClock) or 999
			local waitDuration = (clockDifference < RECOVER_PERIOD and 0) or WAIT_DURATION
			task.delay(waitDuration, function()
				if icon.activeState == "Viewing" then
					setCaptionEnabled(true)
				end
			end)
		else
			Icon.captionLastClosedClock = os.clock()
			setCaptionEnabled(false)
		end
	end))
	
	return caption
end
end)
local node_10 = Node('Container', 'ModuleScript', function(script, require)
local hasBecomeOldTheme = false
local previousInsetHeight = 0
return function(Icon)
	
	
	
	local GuiService = game:GetService("GuiService")
	local Players =  game:GetService("Players")
	local UserInputService = game:GetService("UserInputService")
	local container = {}
	local Signal = require(script.Parent.Parent.Packages.GoodSignal)
	local insetChanged = Signal.new()
	local guiInset = GuiService:GetGuiInset()
	local startInset = 0
	local yDownOffset = 0
	local ySizeOffset = 0
	local checkCount = 0
	local isConsoleScreen = false
	local isUsingVR = false
	local function checkInset(status)
		local currentHeight = GuiService.TopbarInset.Height
		local isOldTopbar = currentHeight <= 36
		

		
		
		
		isConsoleScreen = GuiService:IsTenFootInterface()
		isUsingVR = UserInputService.VREnabled
		Icon.isOldTopbar = isOldTopbar
		checkCount += 1
		if currentHeight == 0 and status == nil then
			task.defer(function()
				task.wait(8)
				checkInset("ForceConvertToOld")
			end)
		elseif checkCount == 1 then
			task.delay(5, function()
				local localPlayer = Players.LocalPlayer
				localPlayer:WaitForChild("PlayerGui")
				if checkCount == 1 then
					checkInset()
				end
			end)
		end

		
		if Icon.isOldTopbar and not isConsoleScreen and not isUsingVR and hasBecomeOldTheme == false and (currentHeight ~= 0 or status == "ForceConvertToOld") then
			hasBecomeOldTheme = true
			task.defer(function()
				
				local themes = script.Parent.Parent.Features.Themes
				local Classic = require(themes.Classic)
				Icon.modifyBaseTheme(Classic)

				
				local function decideToHideTopbar()
					if GuiService.MenuIsOpen then
						Icon.setTopbarEnabled(false, true)
					else
						Icon.setTopbarEnabled()
					end
				end
				GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(decideToHideTopbar)
				decideToHideTopbar()
			end)
		end

		
		guiInset = GuiService:GetGuiInset()
		startInset = if isOldTopbar then 12 else guiInset.Y - 50
		yDownOffset = if isOldTopbar then 2 else 0 
		ySizeOffset = -2
		if isConsoleScreen then
			startInset = 10
			yDownOffset = 0 
		end
		if GuiService.TopbarInset.Height == 0 and not hasBecomeOldTheme then
			yDownOffset += 13
			ySizeOffset = 50
		end

		
		insetChanged:Fire(guiInset)
		local insetHeight = guiInset.Y
		if insetHeight ~= previousInsetHeight then
			previousInsetHeight = insetHeight
			task.defer(function()
				Icon.insetHeightChanged:Fire(insetHeight)
			end)
		end
		
	end
	GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(checkInset)
	checkInset("FirstTime")

	local screenGui = Instance.new("ScreenGui")
	insetChanged:Connect(function()
		screenGui:SetAttribute("StartInset", startInset)
	end)
	screenGui.Name = "TopbarStandard"
	screenGui.Enabled = true
	screenGui.DisplayOrder = Icon.baseDisplayOrder
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.ScreenInsets = Enum.ScreenInsets.TopbarSafeInsets
	container[screenGui.Name] = screenGui
	Icon.baseDisplayOrderChanged:Connect(function()
		screenGui.DisplayOrder = Icon.baseDisplayOrder
	end)

	local holders = Instance.new("Frame")
	holders.Name = "Holders"
	holders.BackgroundTransparency = 1
	insetChanged:Connect(function()
		local holderY = if isUsingVR then 36 else 56
		local holderSize = if isConsoleScreen then UDim2.new(1, 0, 0, holderY) else UDim2.new(1, 0, 1, ySizeOffset)
		holders.Position = UDim2.new(0, 0, 0, yDownOffset)
		holders.Size = holderSize
	end)
	holders.Visible = true
	holders.ZIndex = 1
	holders.Parent = screenGui
	
	local screenGuiCenter = screenGui:Clone()
	local holdersCenter = screenGuiCenter.Holders
	local function updateCenteredHoldersHeight()
		holdersCenter.Size = UDim2.new(1, 0, 0, GuiService.TopbarInset.Height+ySizeOffset)
	end
	screenGuiCenter.Name = "TopbarCentered"
	screenGuiCenter.DisplayOrder = Icon.baseDisplayOrder
	screenGuiCenter.ScreenInsets = Enum.ScreenInsets.None
	Icon.baseDisplayOrderChanged:Connect(function()
		screenGuiCenter.DisplayOrder = Icon.baseDisplayOrder
	end)
	container[screenGuiCenter.Name] = screenGuiCenter
	
	insetChanged:Connect(updateCenteredHoldersHeight)
	updateCenteredHoldersHeight()
	
	local screenGuiClipped = screenGui:Clone()
	screenGuiClipped.Name = screenGuiClipped.Name.."Clipped"
	screenGuiClipped.DisplayOrder = (Icon.baseDisplayOrder + 1)
	Icon.baseDisplayOrderChanged:Connect(function()
		screenGuiClipped.DisplayOrder = (Icon.baseDisplayOrder + 1)
	end)
	container[screenGuiClipped.Name] = screenGuiClipped
	
	local screenGuiCenterClipped = screenGuiCenter:Clone()
	screenGuiCenterClipped.Name = screenGuiCenterClipped.Name.."Clipped"
	screenGuiCenterClipped.DisplayOrder = (Icon.baseDisplayOrder + 1)
	Icon.baseDisplayOrderChanged:Connect(function()
		screenGuiCenterClipped.DisplayOrder = (Icon.baseDisplayOrder + 1)
	end)
	container[screenGuiCenterClipped.Name] = screenGuiCenterClipped
	
	local holderReduction = -24
	local left = Instance.new("ScrollingFrame")
	left:SetAttribute("IsAHolder", true)
	left.Name = "Left"
	insetChanged:Connect(function()
		left.Position = UDim2.fromOffset(startInset, 0)
	end)
	left.Size = UDim2.new(1, holderReduction, 1, 0)
	left.BackgroundTransparency = 1
	left.Visible = true
	left.ZIndex = 1
	left.Active = false
	left.ClipsDescendants = true
	left.HorizontalScrollBarInset = Enum.ScrollBarInset.None
	left.CanvasSize = UDim2.new(0, 0, 1, -1) 
	left.AutomaticCanvasSize = Enum.AutomaticSize.X
	left.ScrollingDirection = Enum.ScrollingDirection.X
	left.ScrollBarThickness = 0
	left.BorderSizePixel = 0
	left.Selectable = false
	left.ScrollingEnabled = false
	left.ElasticBehavior = Enum.ElasticBehavior.Never
	left.Parent = holders
	
	local UIListLayout = Instance.new("UIListLayout")
	insetChanged:Connect(function()
		UIListLayout.Padding = UDim.new(0, startInset)
	end)
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	UIListLayout.Parent = left
	
	local center = left:Clone()
	insetChanged:Connect(function()
		center.UIListLayout.Padding = UDim.new(0, startInset)
	end)
	center.ScrollingEnabled = false
	center.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	center.Name = "Center"
	center.Parent = holdersCenter
	
	local right = left:Clone()
	insetChanged:Connect(function()
		right.UIListLayout.Padding = UDim.new(0, startInset)
	end)
	right.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	right.Name = "Right"
	right.AnchorPoint = Vector2.new(1, 0)
	right.Position = UDim2.new(1, -12, 0, 0)
	right.Parent = holders

	
	insetChanged:Fire(guiInset)

	return container
end
end)
local node_11 = Node('Dropdown', 'ModuleScript', function(script, require)
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Themes = require(script.Parent.Parent.Features.Themes)
local PADDING = 0 
return function(icon)
	
	local dropdown = Instance.new("Frame") 
	dropdown.Name = "Dropdown"
	dropdown.AutomaticSize = Enum.AutomaticSize.X
	dropdown.BackgroundTransparency = 1
	dropdown.BorderSizePixel = 0
	dropdown.AnchorPoint = Vector2.new(0.5, 0)
	dropdown.Position = UDim2.new(0.5, 0, 1, 10)
	dropdown.ZIndex = -2
	dropdown.ClipsDescendants = true
	dropdown.Parent = icon.widget

	
	local GuiService = game:GetService("GuiService")
	icon:setBehaviour("Dropdown", "BackgroundTransparency", function(value)
		local preference = GuiService.PreferredTransparency
		local newValue = value * preference
		if value == 1 then
			return value
		end
		return newValue
	end)
	icon.janitor:add(GuiService:GetPropertyChangedSignal("PreferredTransparency"):Connect(function()
		icon:refreshAppearance(dropdown, "BackgroundTransparency")
	end))

	local UICorner = Instance.new("UICorner")
	UICorner.Name = "DropdownCorner"
	UICorner.CornerRadius = UDim.new(0, 10)
	UICorner.Parent = dropdown

	local dropdownScroller = Instance.new("ScrollingFrame")
	dropdownScroller.Name = "DropdownScroller"
	dropdownScroller.AutomaticSize = Enum.AutomaticSize.X
	dropdownScroller.BackgroundTransparency = 1
	dropdownScroller.BorderSizePixel = 0
	dropdownScroller.AnchorPoint = Vector2.new(0, 0)
	dropdownScroller.Position = UDim2.new(0, 0, 0, 0)
	dropdownScroller.ZIndex = -1
	dropdownScroller.ClipsDescendants = true
	dropdownScroller.Visible = true
	dropdownScroller.VerticalScrollBarInset = Enum.ScrollBarInset.None 
	dropdownScroller.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
	dropdownScroller.Active = false
	dropdownScroller.ScrollingEnabled = true
	dropdownScroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
	dropdownScroller.ScrollBarThickness = 5
	dropdownScroller.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
	dropdownScroller.ScrollBarImageTransparency = 0.8
	dropdownScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
	dropdownScroller.Selectable = false
	dropdownScroller.Active = true
	dropdownScroller.Parent = dropdown

	local TweenDuration = Instance.new("NumberValue") 
	TweenDuration.Name = "DropdownSpeed"
	TweenDuration.Value = 0.07
	TweenDuration.Parent = dropdown

	local dropdownPadding = Instance.new("UIPadding")
	dropdownPadding.Name = "DropdownPadding"
	dropdownPadding.PaddingTop = UDim.new(0, PADDING)
	dropdownPadding.PaddingBottom = UDim.new(0, PADDING)
	dropdownPadding.Parent = dropdownScroller

	local dropdownList = Instance.new("UIListLayout")
	dropdownList.Name = "DropdownList"
	dropdownList.FillDirection = Enum.FillDirection.Vertical
	dropdownList.SortOrder = Enum.SortOrder.LayoutOrder
	dropdownList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	dropdownList.HorizontalFlex = Enum.UIFlexAlignment.SpaceEvenly
	dropdownList.Parent = dropdownScroller

	local dropdownJanitor = icon.dropdownJanitor
	local Icon = require(icon.iconModule)
	icon.dropdownChildAdded:Connect(function(childIcon)
		local _, modificationUID = childIcon:modifyTheme({
			{"Widget", "BorderSize", 0},
			{"IconCorners", "CornerRadius", UDim.new(0, 10)},
			{"Widget", "MinimumWidth", 190},
			{"Widget", "MinimumHeight", 58},
			{"IconLabel", "TextSize", 20},
			{"IconOverlay", "Size", UDim2.new(1, 0, 1, 0)},
			{"PaddingLeft", "Size", UDim2.fromOffset(25, 0)},
			{"Notice", "Position", UDim2.new(1, -24, 0, 5)},
			{"ContentsList", "HorizontalAlignment", Enum.HorizontalAlignment.Left},
			{"Selection", "Size", UDim2.new(1, -PADDING, 1, -PADDING)},
			{"Selection", "Position", UDim2.new(0, PADDING/2, 0, PADDING/2)},
		})
		task.defer(function()
			childIcon.joinJanitor:add(function()
				childIcon:removeModification(modificationUID)
			end)
		end)
	end)
	icon.dropdownSet:Connect(function(arrayOfIcons)
		for i, otherIconUID in pairs(icon.dropdownIcons) do
			local otherIcon = Icon.getIconByUID(otherIconUID)
			otherIcon:destroy()
		end
		if type(arrayOfIcons) == "table" then
			for i, otherIcon in pairs(arrayOfIcons) do
				otherIcon:joinDropdown(icon)
			end
		end
	end)

	local function updateMaxIcons()
		
		local maxIcons = dropdown:GetAttribute("MaxIcons")
		if not maxIcons then return 0 end
		local children = {}
		for _, child in pairs(dropdownScroller:GetChildren()) do
			if child:IsA("GuiObject") and child.Visible then
				table.insert(children, child)
			end
		end

		table.sort(children, function(a, b) return a.AbsolutePosition.Y < b.AbsolutePosition.Y end)
		local totalHeight = 0
		local maxIconsRoundedUp = math.ceil(maxIcons)
		for i = 1, maxIconsRoundedUp do
			local child = children[i]
			if not child then break end
			local height = child.AbsoluteSize.Y
			local isReduced = i == maxIconsRoundedUp and maxIconsRoundedUp ~= maxIcons
			if isReduced then
				height *= (maxIcons - maxIconsRoundedUp + 1)
			end
			totalHeight += height
		end
		totalHeight += dropdownPadding.PaddingTop.Offset + dropdownPadding.PaddingBottom.Offset
		return totalHeight
	end
	
	local openTween = nil
	local closeTween = nil
	local currentSpeedMultiplier = nil
	local currentTweenInfo = nil
	local function getTweenInfo()
		local speedMultiplier = Themes.getInstanceValue(dropdown, "MaxIcons") or 1
		if currentSpeedMultiplier and currentSpeedMultiplier == speedMultiplier and currentTweenInfo then
			return currentTweenInfo
		end
		local newTweenInfo = TweenInfo.new(
			TweenDuration.Value * speedMultiplier,
			Enum.EasingStyle.Exponential,
			Enum.EasingDirection.Out
		)
		currentTweenInfo = newTweenInfo
		currentSpeedMultiplier = speedMultiplier
		return newTweenInfo
	end
	local function updateVisibility()
		
		local tweenInfo = getTweenInfo()
		
		if openTween then
			openTween:Cancel()
			openTween = nil
		end
		if closeTween then
			closeTween:Cancel()
			closeTween = nil
		end

		if icon.isSelected then
			local height = updateMaxIcons()
			dropdown.Visible = true
			dropdown.BackgroundTransparency = 0 
			dropdown.Size = UDim2.new(0, dropdown.Size.X.Offset, 0, 0) 

			openTween = TweenService:Create(dropdown, tweenInfo, {Size = UDim2.new(0, dropdown.Size.X.Offset, 0, height)})
			openTween:Play()
			openTween.Completed:Connect(function()
				openTween = nil
			end)
		else
			local closeTweenInfo = TweenInfo.new(0)
			closeTween = TweenService:Create(dropdown, closeTweenInfo, {Size = UDim2.new(0, dropdown.Size.X.Offset, 0, 0)})
			closeTween:Play()
			closeTween.Completed:Connect(function()
				closeTween = nil
			end)
		end
	end

	dropdownJanitor:add(icon.toggled:Connect(updateVisibility))
	updateVisibility()
	

	local function updateChildSize()
		local tweenInfo = getTweenInfo()
		if not icon.isSelected then return end
		if openTween then
			openTween:Cancel()
			openTween = nil
		end
		if closeTween then
			closeTween:Cancel()
			closeTween = nil
		end
		
		RunService.Heartbeat:Wait()
		
		local height = updateMaxIcons()

		openTween = TweenService:Create(dropdown, tweenInfo, {Size = UDim2.new(0, dropdown.Size.X.Offset, 0, height)})
		openTween:Play()
		openTween.Completed:Connect(function()	
			openTween = nil
		end)
	end

	dropdownJanitor:add(icon.toggled:Connect(updateVisibility))

	
	local updateCount = 0
	local isUpdating = false

	
	
	local function updateMaxIconsListener()
		updateCount += 1
		if isUpdating then return end
		local myUpdateCount = updateCount
		isUpdating = true
		task.defer(function()
			isUpdating = false
			if updateCount ~= myUpdateCount then
				updateMaxIconsListener()
			end
		end)
		local maxIcons = dropdown:GetAttribute("MaxIcons")
		if not maxIcons then return end

		local orderedInstances = {}
		for _, child in pairs(dropdownScroller:GetChildren()) do
			if child:IsA("GuiObject") and child.Visible then
				table.insert(orderedInstances, {child, child.AbsolutePosition.Y})
			end
		end
		table.sort(orderedInstances, function(a, b) return a[2] < b[2] end)

		local totalHeight = 0
		local hasSetNextSelection = false
		local maxIconsRoundedUp = math.ceil(maxIcons)
		for i = 1, maxIconsRoundedUp do
			local group = orderedInstances[i]
			if not group then break end
			local child = group[1]
			local height = child.AbsoluteSize.Y
			local isReduced = i == maxIconsRoundedUp and maxIconsRoundedUp ~= maxIcons
			if isReduced then
				height = height * (maxIcons - maxIconsRoundedUp + 1)
			end
			totalHeight += height
			if isReduced then
				continue
			end
			local iconUID = child:GetAttribute("WidgetUID")
			local childIcon = iconUID and Icon.getIconByUID(iconUID)
			if childIcon then
				local nextSelection = nil
				if not hasSetNextSelection then
					hasSetNextSelection = true
					nextSelection = icon:getInstance("ClickRegion")
				end
				childIcon:getInstance("ClickRegion").NextSelectionUp = nextSelection
			end
		end
		totalHeight += dropdownPadding.PaddingTop.Offset + dropdownPadding.PaddingBottom.Offset

		dropdownScroller.Size = UDim2.fromOffset(0, totalHeight)

	end

	dropdownJanitor:add(dropdownScroller:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(updateMaxIconsListener))
	dropdownJanitor:add(dropdownScroller.ChildAdded:Connect(updateMaxIconsListener))
	dropdownJanitor:add(dropdownScroller.ChildRemoved:Connect(updateChildSize)) 
	dropdownJanitor:add(dropdownScroller.ChildRemoved:Connect(updateMaxIconsListener))
	dropdownJanitor:add(dropdown:GetAttributeChangedSignal("MaxIcons"):Connect(updateMaxIconsListener))
	dropdownJanitor:add(dropdown:GetAttributeChangedSignal("MaxIcons"):Connect(updateChildSize))
	dropdownJanitor:add(icon.childThemeModified:Connect(updateMaxIconsListener))
	updateMaxIconsListener()

	
	local function connectVisibilityListeners(child)
		if child:IsA("GuiObject") then
			child:GetPropertyChangedSignal("Visible"):Connect(updateChildSize)
			child:GetPropertyChangedSignal("Size"):Connect(updateChildSize) 
		end
	end
	
	
	for _, child in pairs(dropdownScroller:GetChildren()) do
		connectVisibilityListeners(child)
	end
	
	dropdownScroller.ChildAdded:Connect(function(child)
		RunService.Heartbeat:Wait()
		connectVisibilityListeners(child)
		updateChildSize()
	end)

	
	dropdown.Visible = false

	return dropdown
end
end)
local node_12 = Node('Indicator', 'ModuleScript', function(script, require)
return function(icon, Icon)

	local widget = icon.widget
	local contents = icon:getInstance("Contents")
	local indicator = Instance.new("Frame")
	indicator.Name = "Indicator"
	indicator.LayoutOrder = 9999999
	indicator.ZIndex = 6
	indicator.Size = UDim2.new(0, 42, 0, 42)
	indicator.BorderColor3 = Color3.fromRGB(0, 0, 0)
	indicator.BackgroundTransparency = 1
	indicator.Position = UDim2.new(1, 0, 0.5, 0)
	indicator.BorderSizePixel = 0
	indicator.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	indicator.Parent = contents

	local indicatorButton = Instance.new("Frame")
	indicatorButton.Name = "IndicatorButton"
	indicatorButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	indicatorButton.AnchorPoint = Vector2.new(0.5, 0.5)
	indicatorButton.BorderSizePixel = 0
	indicatorButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	indicatorButton.Parent = indicator
	
	local GuiService = game:GetService("GuiService")
	local GamepadService = game:GetService("GamepadService")
	local ourClickRegion = icon:getInstance("ClickRegion")
	local function selectionChanged()
		local selectedClickRegion = GuiService.SelectedObject
		if selectedClickRegion == ourClickRegion then
			indicatorButton.BackgroundTransparency = 1
			indicatorButton.Position = UDim2.new(0.5, -2, 0.5, 0)
			indicatorButton.Size = UDim2.fromScale(1.2, 1.2)
		else
			indicatorButton.BackgroundTransparency = 0.75
			indicatorButton.Position = UDim2.new(0.5, 2, 0.5, 0)
			indicatorButton.Size = UDim2.fromScale(1, 1)
		end
	end
	icon.janitor:add(GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(selectionChanged))
	selectionChanged()

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.LayoutOrder = 2
	imageLabel.ZIndex = 15
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	imageLabel.Image = "rbxasset://textures/ui/Controls/XboxController/DPadUp@2x.png"
	imageLabel.Parent = indicatorButton

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(1, 0)
	UICorner.Parent = indicatorButton

	local UserInputService = game:GetService("UserInputService")
	local function setIndicatorVisible(visibility)
		if visibility == nil then
			visibility = indicator.Visible
		end
		if GamepadService.GamepadCursorEnabled then
			visibility = false
		end
		if visibility then
			icon:modifyTheme({"PaddingRight", "Size", UDim2.new(0, 0, 1, 0)}, "IndicatorPadding")
		elseif indicator.Visible then
			icon:removeModification("IndicatorPadding")
		end
		icon:modifyTheme({"Indicator", "Visible", visibility})
		icon.updateSize:Fire()
	end
	icon.janitor:add(GamepadService:GetPropertyChangedSignal("GamepadCursorEnabled"):Connect(setIndicatorVisible))
	icon.indicatorSet:Connect(function(keyCode)
		local visibility = false
		if keyCode then
			imageLabel.Image = UserInputService:GetImageForKeyCode(keyCode)
			visibility = true
		end
		setIndicatorVisible(visibility)
	end)

	local function updateSize()
		local ySize = widget.AbsoluteSize.Y*0.96
		indicator.Size = UDim2.new(0, ySize, 0, ySize)
	end
	widget:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSize)
	updateSize()

	return indicator
end
end)
local node_13 = Node('Menu', 'ModuleScript', function(script, require)
return function(icon)

	local menu = Instance.new("ScrollingFrame")
	menu.Name = "Menu"
	menu.BackgroundTransparency = 1
	menu.Visible = true
	menu.ZIndex = 1
	menu.Size = UDim2.fromScale(1, 1)
	menu.ClipsDescendants = true
	menu.TopImage = ""
	menu.BottomImage = ""
	menu.HorizontalScrollBarInset = Enum.ScrollBarInset.Always
	menu.CanvasSize = UDim2.new(0, 0, 1, -1) 
	menu.ScrollingEnabled = true
	menu.ScrollingDirection = Enum.ScrollingDirection.X
	menu.ZIndex = 20
	menu.ScrollBarThickness = 3
	menu.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
	menu.ScrollBarImageTransparency = 0.8
	menu.BorderSizePixel = 0
	menu.Selectable = false
	
	local Icon = require(icon.iconModule)
	local menuUIListLayout = Icon.container.TopbarStandard:FindFirstChild("UIListLayout", true):Clone()
	menuUIListLayout.Name = "MenuUIListLayout"
	menuUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	menuUIListLayout.Parent = menu

	local menuGap = Instance.new("Frame")
	menuGap.Name = "MenuGap"
	menuGap.BackgroundTransparency = 1
	menuGap.Visible = false
	menuGap.AnchorPoint = Vector2.new(0, 0.5)
	menuGap.ZIndex = 5
	menuGap.Parent = menu
	
	local hasStartedMenu = false
	local Themes = require(script.Parent.Parent.Features.Themes)
	local function totalChildrenChanged()
		
		local menuJanitor = icon.menuJanitor
		local totalIcons = #icon.menuIcons
		if hasStartedMenu then
			if totalIcons <= 0 then
				menuJanitor:clean()
				hasStartedMenu = false
			end
			return
		end
		hasStartedMenu = true
		
		
		menuJanitor:add(icon.toggled:Connect(function()
			if #icon.menuIcons > 0 then
				icon.updateSize:Fire()
			end
		end))
		
		
		local _, modificationUID = icon:modifyTheme({
			{"Menu", "Active", true},
		})
		task.defer(function()
			menuJanitor:add(function()
				icon:removeModification(modificationUID)
			end)
		end)
		
		
		
		
		local previousCanvasX = menu.AbsoluteCanvasSize.X
		local function rightAlignCanvas()
			if icon.alignment == "Right" then
				local newCanvasX = menu.AbsoluteCanvasSize.X
				local difference = previousCanvasX - newCanvasX
				previousCanvasX = newCanvasX
				menu.CanvasPosition = Vector2.new(menu.CanvasPosition.X - difference, 0)
			end
		end
		menuJanitor:add(icon.selected:Connect(rightAlignCanvas))
		menuJanitor:add(menu:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(rightAlignCanvas))
		
		
		local stateGroup = icon:getStateGroup()
		local imageDeselected = Themes.getThemeValue(stateGroup, "IconImage", "Image", "Deselected")
		local imageSelected = Themes.getThemeValue(stateGroup, "IconImage", "Image", "Selected")
		if imageDeselected == imageSelected then
			local fontLink = "rbxasset://fonts/families/FredokaOne.json"
			local fontFace = Font.new(fontLink, Enum.FontWeight.Light, Enum.FontStyle.Normal)
			icon:removeModificationWith("IconLabel", "Text", "Viewing")
			icon:removeModificationWith("IconLabel", "Image", "Viewing")
			icon:modifyTheme({
				{"IconLabel", "FontFace", fontFace, "Selected"},
				{"IconLabel", "Text", "X", "Selected"},
				{"IconLabel", "TextSize", 20, "Selected"},
				{"IconLabel", "TextStrokeTransparency", 0.8, "Selected"},
				{"IconImage", "Image", "", "Selected"},
			})
		end

		
		local menuGap = icon:getInstance("MenuGap")
		local function updateAlignent()
			local alignment = icon.alignment
			local spotIndex = -99999
			local gapIndex = -99998
			if alignment == "Right" then
				spotIndex = 99999
				gapIndex = 99998
			end
			icon:modifyTheme({"IconSpot", "LayoutOrder", spotIndex})
			menuGap.LayoutOrder = gapIndex
		end
		menuJanitor:add(icon.alignmentChanged:Connect(updateAlignent))
		updateAlignent()
		
		
		
		menu:GetAttributeChangedSignal("MenuCanvasWidth"):Connect(function()
			local canvasWidth = menu:GetAttribute("MenuCanvasWidth")
			local canvasY = menu.CanvasSize.Y
			menu.CanvasSize = UDim2.new(0, canvasWidth, canvasY.Scale, canvasY.Offset)
		end)
		menuJanitor:add(icon.updateMenu:Connect(function()
			local maxIcons = menu:GetAttribute("MaxIcons")
			if not maxIcons then
				return
			end
			local orderedInstances = {}
			for _, child in pairs(menu:GetChildren()) do
				local widgetUID = child:GetAttribute("WidgetUID")
				if widgetUID and child.Visible then
					table.insert(orderedInstances, {child, child.AbsolutePosition.X})
				end
			end
			table.sort(orderedInstances, function(groupA, groupB)
				return groupA[2] < groupB[2]
			end)
			local totalWidth = 0
			for i = 1, maxIcons do
				local group = orderedInstances[i]
				if not group then
					break
				end
				local child = group[1]
				local width = child.AbsoluteSize.X + menuUIListLayout.Padding.Offset
				totalWidth += width
			end
			menu:SetAttribute("MenuWidth", totalWidth)
		end))
		local function startMenuUpdate()
			task.delay(0.1, function()
				icon.startMenuUpdate:Fire()
			end)
		end
		menuJanitor:add(menu.ChildAdded:Connect(startMenuUpdate))
		menuJanitor:add(menu.ChildRemoved:Connect(startMenuUpdate))
		menuJanitor:add(menu:GetAttributeChangedSignal("MaxIcons"):Connect(startMenuUpdate))
		menuJanitor:add(menu:GetAttributeChangedSignal("MaxWidth"):Connect(startMenuUpdate))
		startMenuUpdate()
	end
	
	icon.menuChildAdded:Connect(totalChildrenChanged)
	icon.menuSet:Connect(function(arrayOfIcons)
		
		for i, otherIconUID in pairs(icon.menuIcons) do
			local otherIcon = Icon.getIconByUID(otherIconUID)
			otherIcon:destroy()
		end
		
		if type(arrayOfIcons) == "table" then
			for i, otherIcon in pairs(arrayOfIcons) do
				otherIcon:joinMenu(icon)
			end
		end
	end)
	
	return menu
end
end)
local node_14 = Node('Notice', 'ModuleScript', function(script, require)
return function(icon, Icon)

	local notice = Instance.new("Frame")
	notice.Name = "Notice"
	notice.ZIndex = 25
	notice.AutomaticSize = Enum.AutomaticSize.X
	notice.BorderColor3 = Color3.fromRGB(0, 0, 0)
	notice.BorderSizePixel = 0
	notice.BackgroundTransparency = 0.1
	notice.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	notice.Visible = false
	notice.Parent = icon.widget

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(1, 0)
	UICorner.Parent = notice

	local UIStroke = Instance.new("UIStroke")
	UIStroke.Parent = notice

	local noticeLabel = Instance.new("TextLabel")
	noticeLabel.Name = "NoticeLabel"
	noticeLabel.ZIndex = 26
	noticeLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	noticeLabel.AutomaticSize = Enum.AutomaticSize.X
	noticeLabel.Size = UDim2.new(1, 0, 1, 0)
	noticeLabel.BackgroundTransparency = 1
	noticeLabel.Position = UDim2.new(0.5, 0, 0.515, 0)
	noticeLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	noticeLabel.FontSize = Enum.FontSize.Size14
	noticeLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
	noticeLabel.Text = "1"
	noticeLabel.TextWrapped = true
	noticeLabel.TextWrap = true
	noticeLabel.Font = Enum.Font.Arial
	noticeLabel.Parent = notice
	
	local iconModule = script.Parent.Parent
	local packages = iconModule.Packages
	local Janitor = require(packages.Janitor)
	local Signal = require(packages.GoodSignal)
	local Utility = require(iconModule.Utility)
	icon.noticeChanged:Connect(function(totalNotices)

		
		if not totalNotices then
			return
		end
		local exceeded99 = totalNotices > 99
		local noticeDisplay = (exceeded99 and "99+") or totalNotices
		noticeLabel.Text = noticeDisplay
		if exceeded99 then
			noticeLabel.TextSize = 11
		end

		
		local enabled = true
		if totalNotices < 1 then
			enabled = false
		end
		local parentIcon = Icon.getIconByUID(icon.parentIconUID)
		local dropdownOrMenuActive = #icon.dropdownIcons > 0 or #icon.menuIcons > 0
		if icon.isSelected and dropdownOrMenuActive then
			enabled = false
		elseif parentIcon and not parentIcon.isSelected then
			enabled = false
		end
		Utility.setVisible(notice, enabled, "NoticeHandler")

	end)
	icon.noticeStarted:Connect(function(customClearSignal, noticeId)
	
		if not customClearSignal then
			customClearSignal = icon.deselected
		end
		local parentIcon = Icon.getIconByUID(icon.parentIconUID)
		if parentIcon then
			parentIcon:notify(customClearSignal)
		end
		
		local noticeJanitor = icon.janitor:add(Janitor.new())
		local noticeComplete = noticeJanitor:add(Signal.new())
		noticeJanitor:add(icon.endNotices:Connect(function()
			noticeComplete:Fire()
		end))
		noticeJanitor:add(customClearSignal:Connect(function()
			noticeComplete:Fire()
		end))
		noticeId = noticeId or Utility.generateUID()
		icon.notices[noticeId] = {
			completeSignal = noticeComplete,
			clearNoticeEvent = customClearSignal,
		}
		local function updateNotice()
			icon.noticeChanged:Fire(icon.totalNotices)
		end
		icon.notified:Fire(noticeId)
		icon.totalNotices += 1
		updateNotice()
		noticeComplete:Once(function()
			noticeJanitor:destroy()
			icon.totalNotices -= 1
			icon.notices[noticeId] = nil
			updateNotice()
		end)
	end)
	
	
	notice:SetAttribute("ClipToJoinedParent", true)
	icon:clipOutside(notice)
	
	return notice
end
end)
local node_15 = Node('Selection', 'ModuleScript', function(script, require)
return function(Icon)

	
	
	local selectionContainer = Instance.new("Frame")
	selectionContainer.Name = "SelectionContainer"
	selectionContainer.Visible = false
	
	local selection = Instance.new("Frame")
	selection.Name = "Selection"
	selection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	selection.BackgroundTransparency = 1
	selection.BorderColor3 = Color3.fromRGB(0, 0, 0)
	selection.BorderSizePixel = 0
	selection.Parent = selectionContainer

	local UIStroke = Instance.new("UIStroke")
	UIStroke.Name = "UIStroke"
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Color = Color3.fromRGB(255, 255, 255)
	UIStroke.Thickness = 3
	UIStroke.Parent = selection

	local selectionGradient = Instance.new("UIGradient")
	selectionGradient.Name = "SelectionGradient"
	selectionGradient.Parent = UIStroke

	local UICorner = Instance.new("UICorner")
	UICorner:SetAttribute("Collective", "IconCorners")
	UICorner.Name = "UICorner"
	UICorner.CornerRadius = UDim.new(1, 0)
	UICorner.Parent = selection
	
	local RunService = game:GetService("RunService")
	local GuiService = game:GetService("GuiService")
	local rotationSpeed = 1
	selection:GetAttributeChangedSignal("RotationSpeed"):Connect(function()
		rotationSpeed = selection:GetAttribute("RotationSpeed")
	end)
	RunService.Heartbeat:Connect(function()
		if not GuiService.SelectedObject then
			return
		end
		selectionGradient.Rotation = (os.clock() * rotationSpeed * 100) % 360
	end)

	return selectionContainer
	
end
end)
local node_16 = Node('Widget', 'ModuleScript', function(script, require)
return function(icon, Icon)

	local widget = Instance.new("Frame")
	widget:SetAttribute("WidgetUID", icon.UID)
	widget.Name = "Widget"
	widget.BackgroundTransparency = 1
	widget.Visible = true
	widget.ZIndex = 20
	widget.Active = false
	widget.ClipsDescendants = true

	local button = Instance.new("Frame")
	button.Name = "IconButton"
	button.Visible = true
	button.ZIndex = 2
	button.BorderSizePixel = 0
	button.Parent = widget
	button.ClipsDescendants = true
	button.Active = false 
	icon.deselected:Connect(function()
		button.ClipsDescendants = true
		task.delay(0.2, function()
			if icon.isSelected then
				button.ClipsDescendants = false
			end
		end)
	end)

	
	local GuiService = game:GetService("GuiService")
	icon:setBehaviour("IconButton", "BackgroundTransparency", function(value)
		local preference = GuiService.PreferredTransparency
		local newValue = value * preference
		if value == 1 then
			return value
		end
		return newValue
	end)
	icon.janitor:add(GuiService:GetPropertyChangedSignal("PreferredTransparency"):Connect(function()
		icon:refreshAppearance(button, "BackgroundTransparency")
	end))

	local iconCorner = Instance.new("UICorner")
	iconCorner:SetAttribute("Collective", "IconCorners")
	iconCorner.Name = "UICorner"
	iconCorner.Parent = button

	local menu = require(script.Parent.Menu)(icon)
	local menuUIListLayout = menu.MenuUIListLayout
	local menuGap = menu.MenuGap
	menu.Parent = button

	local iconSpot = Instance.new("Frame")
	iconSpot.Name = "IconSpot"
	iconSpot.BackgroundColor3 = Color3.fromRGB(225, 225, 225)
	iconSpot.BackgroundTransparency = 0.9
	iconSpot.Visible = true
	iconSpot.AnchorPoint = Vector2.new(0, 0.5)
	iconSpot.ZIndex = 5
	iconSpot.Parent = menu

	local iconSpotCorner = iconCorner:Clone()
	iconSpotCorner.Parent = iconSpot

	local overlay = iconSpot:Clone()
	overlay.UICorner.Name = "OverlayUICorner"
	overlay.Name = "IconOverlay"
	overlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	overlay.ZIndex = iconSpot.ZIndex + 1
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.Position = UDim2.new(0, 0, 0, 0)
	overlay.AnchorPoint = Vector2.new(0, 0)
	overlay.Visible = false
	overlay.Parent = iconSpot

	local clickRegion = Instance.new("TextButton")
	clickRegion:SetAttribute("CorrespondingIconUID", icon.UID)
	clickRegion.Name = "ClickRegion"
	clickRegion.BackgroundTransparency = 1
	clickRegion.Visible = true
	clickRegion.Text = ""
	clickRegion.ZIndex = 20
	clickRegion.Selectable = true
	clickRegion.SelectionGroup = true
	clickRegion.Parent = iconSpot
	
	local Gamepad = require(script.Parent.Parent.Features.Gamepad)
	Gamepad.registerButton(clickRegion)

	local clickRegionCorner = iconCorner:Clone()
	clickRegionCorner.Parent = clickRegion

	local contents = Instance.new("Frame")
	contents.Name = "Contents"
	contents.BackgroundTransparency = 1
	contents.Size = UDim2.fromScale(1, 1)
	contents.Parent = iconSpot

	local contentsList = Instance.new("UIListLayout")
	contentsList.Name = "ContentsList"
	contentsList.FillDirection = Enum.FillDirection.Horizontal
	contentsList.VerticalAlignment = Enum.VerticalAlignment.Center
	contentsList.SortOrder = Enum.SortOrder.LayoutOrder
	contentsList.VerticalFlex = Enum.UIFlexAlignment.SpaceEvenly
	contentsList.Padding = UDim.new(0, 3)
	contentsList.Parent = contents

	local paddingLeft = Instance.new("Frame")
	paddingLeft.Name = "PaddingLeft"
	paddingLeft.LayoutOrder = 1
	paddingLeft.ZIndex = 5
	paddingLeft.BorderColor3 = Color3.fromRGB(0, 0, 0)
	paddingLeft.BackgroundTransparency = 1
	paddingLeft.BorderSizePixel = 0
	paddingLeft.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	paddingLeft.Parent = contents

	local paddingCenter = Instance.new("Frame")
	paddingCenter.Name = "PaddingCenter"
	paddingCenter.LayoutOrder = 3
	paddingCenter.ZIndex = 5
	paddingCenter.Size = UDim2.new(0, 0, 1, 0)
	paddingCenter.BorderColor3 = Color3.fromRGB(0, 0, 0)
	paddingCenter.BackgroundTransparency = 1
	paddingCenter.BorderSizePixel = 0
	paddingCenter.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	paddingCenter.Parent = contents

	local paddingRight = Instance.new("Frame")
	paddingRight.Name = "PaddingRight"
	paddingRight.LayoutOrder = 5
	paddingRight.ZIndex = 5
	paddingRight.BorderColor3 = Color3.fromRGB(0, 0, 0)
	paddingRight.BackgroundTransparency = 1
	paddingRight.BorderSizePixel = 0
	paddingRight.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	paddingRight.Parent = contents

	local iconLabelContainer = Instance.new("Frame")
	iconLabelContainer.Name = "IconLabelContainer"
	iconLabelContainer.LayoutOrder = 4
	iconLabelContainer.ZIndex = 3
	iconLabelContainer.AnchorPoint = Vector2.new(0, 0.5)
	iconLabelContainer.Size = UDim2.new(0, 0, 0.5, 0)
	iconLabelContainer.BackgroundTransparency = 1
	iconLabelContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
	iconLabelContainer.Parent = contents

	local iconLabel = Instance.new("TextLabel")
	local viewportX = workspace.CurrentCamera.ViewportSize.X+200
	iconLabel.Name = "IconLabel"
	iconLabel.LayoutOrder = 4
	iconLabel.ZIndex = 15
	iconLabel.AnchorPoint = Vector2.new(0, 0)
	iconLabel.Size = UDim2.new(0, viewportX, 1, 0)
	iconLabel.ClipsDescendants = false
	iconLabel.BackgroundTransparency = 1
	iconLabel.Position = UDim2.fromScale(0, 0)
	iconLabel.RichText = true
	iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	iconLabel.TextXAlignment = Enum.TextXAlignment.Left
	iconLabel.Text = ""
	iconLabel.TextWrapped = true
	iconLabel.TextWrap = true
	iconLabel.TextScaled = false
	iconLabel.Active = false
	iconLabel.AutoLocalize = true
	iconLabel.Parent = iconLabelContainer

	local iconImage = Instance.new("ImageLabel")
	iconImage.Name = "IconImage"
	iconImage.LayoutOrder = 2
	iconImage.ZIndex = 15
	iconImage.AnchorPoint = Vector2.new(0, 0.5)
	iconImage.Size = UDim2.new(0, 0, 0.5, 0)
	iconImage.BackgroundTransparency = 1
	iconImage.Position = UDim2.new(0, 11, 0.5, 0)
	iconImage.ScaleType = Enum.ScaleType.Stretch
	iconImage.Active = false
	iconImage.Parent = contents

	local iconImageCorner = iconCorner:Clone()
	iconImageCorner:SetAttribute("Collective", nil)
	iconImageCorner.CornerRadius = UDim.new(0, 0)
	iconImageCorner.Name = "IconImageCorner"
	iconImageCorner.Parent = iconImage

	local TweenService = game:GetService("TweenService")
	local resizingCount = 0
	local function handleLabelAndImageChangesUnstaggered(forceUpdateString)

		
		
		
		
		
		task.defer(function()
			local indicator = icon.indicator
			local usingIndicator = indicator and indicator.Visible
			local usingText = usingIndicator or iconLabel.Text ~= ""
			local usingImage = iconImage.Image ~= "" and iconImage.Image ~= nil
			local _alignment = Enum.HorizontalAlignment.Center
			local NORMAL_BUTTON_SIZE = UDim2.fromScale(1, 1)
			local buttonSize = NORMAL_BUTTON_SIZE
			if usingImage and not usingText then
				iconLabelContainer.Visible = false
				iconImage.Visible = true
				paddingLeft.Visible = false
				paddingCenter.Visible = false
				paddingRight.Visible = false
			elseif not usingImage and usingText then
				iconLabelContainer.Visible = true
				iconImage.Visible = false
				paddingLeft.Visible = true
				paddingCenter.Visible = false
				paddingRight.Visible = true
			elseif usingImage and usingText then
				iconLabelContainer.Visible = true
				iconImage.Visible = true
				paddingLeft.Visible = true
				paddingCenter.Visible = not usingIndicator
				paddingRight.Visible = not usingIndicator
				_alignment = Enum.HorizontalAlignment.Left
			end
			button.Size = buttonSize

			local function getItemWidth(item)
				local targetWidth = item:GetAttribute("TargetWidth") or item.AbsoluteSize.X
				return targetWidth
			end
			local contentsPadding = contentsList.Padding.Offset
			local initialWidgetWidth = contentsPadding 
			local textWidth = iconLabel.TextBounds.X
			iconLabelContainer.Size = UDim2.new(0, textWidth, iconLabel.Size.Y.Scale, 0)
			for _, child in pairs(contents:GetChildren()) do
				if child:IsA("GuiObject") and child.Visible == true then
					local itemWidth = getItemWidth(child)
					initialWidgetWidth += itemWidth + contentsPadding
				end
			end
			local widgetMinimumWidth = widget:GetAttribute("MinimumWidth")
			local widgetMinimumHeight = widget:GetAttribute("MinimumHeight")
			local widgetBorderSize = widget:GetAttribute("BorderSize")
			local widgetWidth = math.clamp(initialWidgetWidth, widgetMinimumWidth, viewportX)
			local menuIcons = icon.menuIcons
			local additionalWidth = 0
			local hasMenu = #menuIcons > 0
			local showMenu = hasMenu and icon.isSelected
			if showMenu then
				for _, frame in pairs(menu:GetChildren()) do
					if frame ~= iconSpot and frame:IsA("GuiObject") and frame.Visible then
						additionalWidth += getItemWidth(frame) + menuUIListLayout.Padding.Offset
					end
				end
				if not iconSpot.Visible then
					widgetWidth -= (getItemWidth(iconSpot) + menuUIListLayout.Padding.Offset*2 + widgetBorderSize)
				end
				additionalWidth -= (widgetBorderSize*0.5)
				widgetWidth += additionalWidth - (widgetBorderSize*0.75)
			end
			menuGap.Visible = showMenu and iconSpot.Visible
			local desiredWidth = widget:GetAttribute("DesiredWidth")
			if desiredWidth and widgetWidth < desiredWidth then
				widgetWidth = desiredWidth
			end

			icon.updateMenu:Fire()
			local preWidth = math.max(widgetWidth-additionalWidth, widgetMinimumWidth)
			local spotWidth = preWidth-(widgetBorderSize*2)
			local menuWidth = menu:GetAttribute("MenuWidth")
			local totalMenuWidth = menuWidth and menuWidth + spotWidth + menuUIListLayout.Padding.Offset + 10
			if totalMenuWidth then
				local maxWidth = menu:GetAttribute("MaxWidth")
				if maxWidth then
					totalMenuWidth = math.max(maxWidth, widgetMinimumWidth)
				end
				menu:SetAttribute("MenuCanvasWidth", widgetWidth)
				if totalMenuWidth < widgetWidth then
					widgetWidth = totalMenuWidth
				end
			end

			local style = Enum.EasingStyle.Quint
			local direction = Enum.EasingDirection.Out
			local spotWidthMax = math.max(spotWidth, getItemWidth(iconSpot), iconSpot.AbsoluteSize.X)
			local widgetWidthMax = math.max(widgetWidth, getItemWidth(widget), widget.AbsoluteSize.X)
			local SPEED = 750
			local spotTweenInfo = TweenInfo.new(spotWidthMax/SPEED, style, direction)
			local widgetTweenInfo = TweenInfo.new(widgetWidthMax/SPEED, style, direction)
			TweenService:Create(iconSpot, spotTweenInfo, {
				Position = UDim2.new(0, widgetBorderSize, 0.5, 0),
				Size = UDim2.new(0, spotWidth, 1, -widgetBorderSize*2),
			}):Play()
			TweenService:Create(clickRegion, spotTweenInfo, {
				Size = UDim2.new(0, spotWidth, 1, 0),
			}):Play()
			local newWidgetSize = UDim2.fromOffset(widgetWidth, widgetMinimumHeight)
			local updateInstantly = widget.Size.Y.Offset ~= widgetMinimumHeight
			if updateInstantly then
				widget.Size = newWidgetSize
			end
			widget:SetAttribute("TargetWidth", newWidgetSize.X.Offset)
			local movingTween = TweenService:Create(widget, widgetTweenInfo, {
				Size = newWidgetSize,
			})
			movingTween:Play()
			resizingCount += 1
			for i = 1, widgetTweenInfo.Time * 100 do
				task.delay(i/100, function()
					Icon.iconChanged:Fire(icon)
				end)
			end
			task.delay(widgetTweenInfo.Time-0.2, function()
				resizingCount -= 1
				task.defer(function()
					if resizingCount == 0 then
						icon.resizingComplete:Fire()
					end
				end)
			end)
			icon:updateParent()
		end)
	end
	local Utility = require(script.Parent.Parent.Utility)
	local handleLabelAndImageChanges = Utility.createStagger(0.01, handleLabelAndImageChangesUnstaggered)
	local firstTimeSettingFontFace = true
	icon:setBehaviour("IconLabel", "Text", handleLabelAndImageChanges)
	icon:setBehaviour("IconLabel", "FontFace", function(value)
		local previousFontFace = iconLabel.FontFace
		if previousFontFace == value then
			return
		end
		task.spawn(function()
			

			
			
			
			handleLabelAndImageChanges()
			if firstTimeSettingFontFace then
				firstTimeSettingFontFace = false
				for i = 1, 10 do
					task.wait(1)
					handleLabelAndImageChanges()
				end
			end
		end)
	end)
	local function updateBorderSize()
		task.defer(function()
			local borderOffset = widget:GetAttribute("BorderSize")
			local alignment = icon.alignment
			local alignmentOffset = (iconSpot.Visible == false and 0) or (alignment == "Right" and -borderOffset) or borderOffset
			menu.Position = UDim2.new(0, alignmentOffset, 0, 0)
			menuGap.Size = UDim2.fromOffset(borderOffset, 0)
			menuUIListLayout.Padding = UDim.new(0, 0)
			handleLabelAndImageChanges()
		end)
	end
	icon:setBehaviour("Widget", "BorderSize", updateBorderSize)
	icon:setBehaviour("IconSpot", "Visible", updateBorderSize)
	icon.startMenuUpdate:Connect(handleLabelAndImageChanges)
	icon.updateSize:Connect(handleLabelAndImageChanges)
	icon:setBehaviour("ContentsList", "HorizontalAlignment", handleLabelAndImageChanges)
	icon:setBehaviour("Widget", "Visible", handleLabelAndImageChanges)
	icon:setBehaviour("Widget", "DesiredWidth", handleLabelAndImageChanges)
	icon:setBehaviour("Widget", "MinimumWidth", handleLabelAndImageChanges)
	icon:setBehaviour("Widget", "MinimumHeight", handleLabelAndImageChanges)
	icon:setBehaviour("Indicator", "Visible", handleLabelAndImageChanges)
	icon:setBehaviour("IconImageRatio", "AspectRatio", handleLabelAndImageChanges)
	icon:setBehaviour("IconImage", "Image", function(value)
		local textureId = (tonumber(value) and "http://www.roblox.com/asset/?id="..value) or value or ""
		if iconImage.Image ~= textureId then
			handleLabelAndImageChanges()
		end
		return textureId
	end)
	icon.alignmentChanged:Connect(function(newAlignment)
		if newAlignment == "Center" then
			newAlignment = "Left"
		end
		menuUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment[newAlignment]
		updateBorderSize()
	end)

	
	local Players = game:GetService("Players")
	local localPlayer = Players.LocalPlayer
	local lastLocaleId = localPlayer.LocaleId
	icon.janitor:add(localPlayer:GetPropertyChangedSignal("LocaleId"):Connect(function()
		task.delay(0.2, function()
			local newLocaleId = localPlayer.LocaleId
			if newLocaleId ~= lastLocaleId then
				lastLocaleId = newLocaleId
				icon:refresh()
				task.wait(0.5)
				icon:refresh()
			end
		end)
	end))
	
	local iconImageScale = Instance.new("NumberValue")
	iconImageScale.Name = "IconImageScale"
	iconImageScale.Parent = iconImage
	iconImageScale:GetPropertyChangedSignal("Value"):Connect(function()
		iconImage.Size = UDim2.new(iconImageScale.Value, 0, iconImageScale.Value, 0)
	end)

	local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint.Name = "IconImageRatio"
	UIAspectRatioConstraint.AspectType = Enum.AspectType.FitWithinMaxSize
	UIAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
	UIAspectRatioConstraint.Parent = iconImage

	local iconGradient = Instance.new("UIGradient")
	iconGradient.Name = "IconGradient"
	iconGradient.Enabled = true
	iconGradient.Parent = button

	local iconSpotGradient = Instance.new("UIGradient")
	iconSpotGradient.Name = "IconSpotGradient"
	iconSpotGradient.Enabled = true
	iconSpotGradient.Parent = iconSpot

	return widget
end
end)
local node_17 = Node('Features', 'Folder', nil)
local node_18 = Node('Gamepad', 'ModuleScript', function(script, require)
local GamepadService = game:GetService("GamepadService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local DEFAULT_HIGHLIGHT_KEY = Enum.KeyCode.DPadUp 
local GAMEPAD_INPUT = Enum.PreferredInput.Gamepad
local Gamepad = {}
local Icon

function Gamepad.start(incomingIcon)
	
	
	Icon = incomingIcon
	Icon.highlightKey = if Icon.highlightKey ~= nil then Icon.highlightKey else DEFAULT_HIGHLIGHT_KEY 
	Icon.highlightIcon = false 
	
	
	
	task.delay(1, function()
		
		local iconsDict = Icon.iconsDictionary
		local function getIconFromSelectedObject()
			local clickRegion = GuiService.SelectedObject
			local iconUID = clickRegion and clickRegion:GetAttribute("CorrespondingIconUID")
			local icon = iconUID and iconsDict[iconUID]
			return icon
		end
		
		
		local previousHighlightedIcon
		local usedIndicatorOnce = DEFAULT_HIGHLIGHT_KEY ~= Icon.highlightKey
		local usedBOnce = DEFAULT_HIGHLIGHT_KEY ~= Icon.highlightKey
		local Selection = require(script.Parent.Parent.Elements.Selection)
		local function updateSelectedObject()
			local icon = getIconFromSelectedObject()
			local isUsingGamepad = UserInputService.PreferredInput == GAMEPAD_INPUT
			if icon then
				if isUsingGamepad then
					local clickRegion = icon:getInstance("ClickRegion")
					local selection = icon.selection
					if not selection then
						selection = icon.janitor:add(Selection(Icon))
						selection:SetAttribute("IgnoreVisibilityUpdater", true)
						selection.Parent = icon.widget
						icon.selection = selection
						icon:refreshAppearance(selection) 
					end
					clickRegion.SelectionImageObject = selection.Selection
				end
				if previousHighlightedIcon and previousHighlightedIcon ~= icon then
					previousHighlightedIcon:setIndicator()
				end
				local newIndicator = if isUsingGamepad and not usedBOnce and not icon.parentIconUID then Enum.KeyCode.ButtonB else nil
				previousHighlightedIcon = icon
				Icon.lastHighlightedIcon = icon
				icon:setIndicator(newIndicator)
			else
				local newIndicator = if isUsingGamepad and not usedIndicatorOnce then Icon.highlightKey else nil
				if not previousHighlightedIcon then
					previousHighlightedIcon = Gamepad.getIconToHighlight()
				end
				if newIndicator == Icon.highlightKey then
					
					
					usedIndicatorOnce = true
				else
					
				end
				if previousHighlightedIcon then
					previousHighlightedIcon:setIndicator(newIndicator)
				end
			end
		end
		GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(updateSelectedObject)

		
		local function preferredInputChanged()
			local preferredInput = UserInputService.PreferredInput
			local isUsingGamepad = preferredInput == GAMEPAD_INPUT

			if not isUsingGamepad then
				usedIndicatorOnce = false
				usedBOnce = false
			end
			updateSelectedObject()
		end
		UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(preferredInputChanged)
		preferredInputChanged()

		
		
		
		UserInputService.InputBegan:Connect(function(input, touchingAnObject)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				
				
				
				local icon = getIconFromSelectedObject()
				if icon then
					GuiService.SelectedObject = nil
				end
				return
			end
			if input.KeyCode ~= Icon.highlightKey then
				return
			end
			local iconToHighlight = Gamepad.getIconToHighlight()
			if iconToHighlight then
				if GamepadService.GamepadCursorEnabled then
					task.wait(0.2)
					GamepadService:DisableGamepadCursor()
				end
				local clickRegion = iconToHighlight:getInstance("ClickRegion")
				GuiService.SelectedObject = clickRegion
			end
		end)
	end)
end

function Gamepad.getIconToHighlight()
	
	
	local iconsDict = Icon.iconsDictionary
	local iconToHighlight = Icon.highlightIcon or Icon.lastHighlightedIcon
	if not iconToHighlight then
		local currentX
		for _, icon in pairs(iconsDict) do
			if icon.parentIconUID then
				continue
			end
			local thisX = icon.widget.AbsolutePosition.X
			if not currentX or thisX < currentX then
				iconToHighlight = icon
				currentX = iconToHighlight.widget.AbsolutePosition.X
			end
		end
	end
	return iconToHighlight
end

function Gamepad.registerButton(buttonInstance)
	
	
	
	
	local inputBegan = false
	buttonInstance.InputBegan:Connect(function(input)
		
		
		
		inputBegan = true
		task.wait()
		task.wait()
		inputBegan = false
	end)
	local connection = UserInputService.InputBegan:Connect(function(input)
		task.wait()
		if input.KeyCode == Enum.KeyCode.ButtonA and inputBegan then
			
			task.wait(0.2)
			GamepadService:DisableGamepadCursor()
			GuiService.SelectedObject = buttonInstance
			return
		end
		local isSelected = GuiService.SelectedObject == buttonInstance
		local unselectKeyCodes = {"ButtonB", "ButtonSelect"}
		local keyName = input.KeyCode.Name
		if table.find(unselectKeyCodes, keyName) and isSelected then
			
			
			
			if not(keyName == "ButtonSelect" and not GamepadService.GamepadCursorEnabled) then
				GuiService.SelectedObject = nil
			end
		end
	end)
	buttonInstance.Destroying:Once(function()
		connection:Disconnect()
	end)
end

return Gamepad
end)
local node_19 = Node('Overflow', 'ModuleScript', function(script, require)
local Overflow = {}
local holders = {}
local orderedAvailableIcons = {}
local iconsDict
local currentCamera = workspace.CurrentCamera
local overflowIcons = {}
local overflowIconUIDs = {}
local Utility = require(script.Parent.Parent.Utility)
local beginCheckingCenterIcons = false
local beganSecondaryCenterCheck = false
local Icon

function Overflow.start(incomingIcon)
	Icon = incomingIcon
	iconsDict = Icon.iconsDictionary
	local primaryScreenGui
	for _, screenGui in pairs(Icon.container) do
		if primaryScreenGui == nil and screenGui.ScreenInsets == Enum.ScreenInsets.TopbarSafeInsets then
			primaryScreenGui = screenGui
		end
		for _, holder in pairs(screenGui.Holders:GetChildren()) do
			if holder:GetAttribute("IsAHolder") then
				holders[holder.Name] = holder
			end
		end
	end

	
	
	local beginOverflow = false
	local updateBoundaries = Utility.createStagger(0.1, function(ignoreAvailable)
		if not beginOverflow then
			return
		end
		if not ignoreAvailable then
			Overflow.updateAvailableIcons("Center")
		end
		Overflow.updateBoundary("Left")
		Overflow.updateBoundary("Right")
	end)
	task.delay(0.5, function()
		beginOverflow = true
		updateBoundaries()
	end)
	task.delay(2, function()
		
		
		
		beginCheckingCenterIcons = true
		updateBoundaries()
	end)
	Icon.iconAdded:Connect(updateBoundaries)
	Icon.iconRemoved:Connect(updateBoundaries)
	Icon.iconChanged:Connect(updateBoundaries)
	currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		updateBoundaries(true)
	end)
	primaryScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		updateBoundaries(true)
	end)
end

function Overflow.getWidth(icon, getMaxWidth)
	local widget = icon.widget
	return widget:GetAttribute("TargetWidth") or widget.AbsoluteSize.X
end

function Overflow.getAvailableIcons(alignment)
	local ourOrderedIcons = orderedAvailableIcons[alignment]
	if not ourOrderedIcons then
		ourOrderedIcons = Overflow.updateAvailableIcons(alignment)
	end
	return ourOrderedIcons
end

function Overflow.updateAvailableIcons(alignment)

	
	local ourTotal = 0
	local ourOrderedIcons = {}
	for _, icon in pairs(iconsDict) do
		local parentUID = icon.parentIconUID
		local isDirectlyOnTopbar = not parentUID or overflowIconUIDs[parentUID]
		local isOverflow = overflowIconUIDs[icon.UID]
		if isDirectlyOnTopbar and icon.alignment == alignment and not isOverflow and icon.isEnabled then
			table.insert(ourOrderedIcons, icon)
			ourTotal += 1
		end
	end

	
	if ourTotal <= 0 then
		return {}
	end

	
	
	table.sort(ourOrderedIcons, function(iconA, iconB)
		local orderA = iconA.widget.LayoutOrder
		local orderB = iconB.widget.LayoutOrder
		local hasParentA = iconA.parentIconUID
		local hasParentB = iconB.parentIconUID
		if hasParentA == hasParentB then
			if orderA < orderB then
				return true
			end
			if orderA > orderB then
				return false
			end
			return iconA.widget.AbsolutePosition.X < iconB.widget.AbsolutePosition.X
		elseif hasParentB then
			return false
		elseif hasParentA then
			return true
		end
		return nil
	end)

	
	orderedAvailableIcons[alignment] = ourOrderedIcons
	return ourOrderedIcons

end

function Overflow.getRealXPositions(alignment, orderedIcons)
	
	
	local isLeft = alignment == "Left"
	local holder = holders[alignment]
	local holderXPos = holder.AbsolutePosition.X
	local holderXSize = holder.AbsoluteSize.X
	local holderUIList = holder.UIListLayout
	local topbarInset = holderUIList.Padding.Offset
	local absoluteX = (isLeft and holderXPos) or holderXPos + holderXSize
	local realXPositions = {}
	if isLeft then
		Utility.reverseTable(orderedIcons)
	end
	for i = #orderedIcons, 1, -1 do
		local icon = orderedIcons[i]
		local sizeX = Overflow.getWidth(icon)
		if not isLeft then
			absoluteX -= sizeX
		end
		realXPositions[icon.UID] = absoluteX
		if isLeft then
			absoluteX += sizeX
		end
		absoluteX += (isLeft and topbarInset) or -topbarInset
	end
	return realXPositions
end

function Overflow.updateBoundary(alignment)

	
	local holder = holders[alignment]
	local holderUIList = holder.UIListLayout
	local holderXPos = holder.AbsolutePosition.X
	local holderXSize = holder.AbsoluteSize.X
	local topbarInset = holderUIList.Padding.Offset
	local topbarPadding = holderUIList.Padding.Offset
	local BOUNDARY_GAP = topbarInset
	local ourOrderedIcons = Overflow.updateAvailableIcons(alignment)
	local boundWidth = 0
	local ourTotal = 0
	for _, icon in pairs(ourOrderedIcons) do
		boundWidth += Overflow.getWidth(icon) + topbarPadding
		ourTotal += 1
	end
	if ourTotal <= 0 then
		return
	end
	
	
	
	local isCentral = alignment == "Center"
	local isLeft = alignment == "Left"
	local isRight = not isLeft
	local overflowIcon = overflowIcons[alignment]
	if not overflowIcon and not isCentral and #ourOrderedIcons > 0 then
		local order = (isLeft and -9999999) or 9999999
		overflowIcon = Icon.new()
		overflowIcon:setImage(6069276526, "Deselected")
		overflowIcon:setName("Overflow"..alignment)
		overflowIcon:setOrder(order)
		overflowIcon:setAlignment(alignment)
		overflowIcon:autoDeselect(false)
		overflowIcon.isAnOverflow = true
		
		overflowIcon:select("OverflowStart", overflowIcon)
		overflowIcon:setEnabled(false)
		overflowIcons[alignment] = overflowIcon
		overflowIconUIDs[overflowIcon.UID] = true
		if not Icon.closeableOverflowMenus then
			local iconSpot = overflowIcon:getInstance("IconSpot")
			iconSpot.Visible = false
		end
	end

	
	
	local oppositeAlignment = (alignment == "Left" and "Right") or "Left"
	local oppositeOrderedIcons = Overflow.updateAvailableIcons(oppositeAlignment)
	local nearestOppositeIcon = (isLeft and oppositeOrderedIcons[1]) or (isRight and oppositeOrderedIcons[#oppositeOrderedIcons])
	local oppositeOverflowIcon = overflowIcons[oppositeAlignment]
	local boundary = (isLeft and holderXPos + holderXSize) or holderXPos
	if nearestOppositeIcon then
		local oppositeRealXPositions = Overflow.getRealXPositions(oppositeAlignment, oppositeOrderedIcons)
		local oppositeX = oppositeRealXPositions[nearestOppositeIcon.UID]
		local oppositeXSize = Overflow.getWidth(nearestOppositeIcon)
		boundary = (isLeft and oppositeX - BOUNDARY_GAP) or oppositeX + oppositeXSize + BOUNDARY_GAP
	end
	
	
	
	
	
	local totalChecks = 0
	local usingNearestCenter = false
	local function checkToShiftCentralIcon()
		local centerOrderedIcons = Overflow.getAvailableIcons("Center")
		local centerPos = (isLeft and 1) or #centerOrderedIcons
		local nearestCenterIcon = centerOrderedIcons[centerPos]
		local function secondaryCheck()
			if not beganSecondaryCenterCheck then
				beganSecondaryCenterCheck = true
				task.delay(3, Overflow.updateBoundary, alignment)
			end
		end
		if nearestCenterIcon and not nearestCenterIcon.hasRelocatedInOverflow then
			local ourNearestIcon = (isLeft and ourOrderedIcons[#ourOrderedIcons]) or (isRight and ourOrderedIcons[1])
			local centralNearestXPos = nearestCenterIcon.widget.AbsolutePosition.X
			local ourNearestXPos = ourNearestIcon.widget.AbsolutePosition.X
			local ourNearestXSize = Overflow.getWidth(ourNearestIcon)
			local centerBoundary = (isLeft and centralNearestXPos-BOUNDARY_GAP) or centralNearestXPos + Overflow.getWidth(nearestCenterIcon) + BOUNDARY_GAP
			local removeBoundary = (isLeft and ourNearestXPos + ourNearestXSize) or ourNearestXPos
			local hasShifted = false
			if isLeft then
				if centerBoundary < removeBoundary then
					if not beginCheckingCenterIcons then
						secondaryCheck()
						return
					end
					nearestCenterIcon:align("Left")
					nearestCenterIcon.hasRelocatedInOverflow = true
					hasShifted = true
				end
			elseif isRight then
				if centerBoundary > removeBoundary then
					if not beginCheckingCenterIcons or removeBoundary < 0 then
						secondaryCheck()
						return
					end
					nearestCenterIcon:align("Right")
					nearestCenterIcon.hasRelocatedInOverflow = true
					hasShifted = true
				end
			end
			if hasShifted then
				totalChecks += 1
				if totalChecks <= 4 then
					Overflow.updateAvailableIcons("Center")
					checkToShiftCentralIcon()
				end
			end
		end
	end
	checkToShiftCentralIcon()
	
	
	if overflowIcon then
		local menuBoundary = boundary
		local menu = overflowIcon:getInstance("Menu")
		local holderXEndPos = holderXPos + holderXSize
		local menuWidth = holderXSize
		if menu and oppositeOverflowIcon then
			local oppositeWidget = oppositeOverflowIcon.widget
			local oppositeXPos = oppositeWidget.AbsolutePosition.X
			local oppositeXSize = Overflow.getWidth(oppositeOverflowIcon)
			local oppositeBoundary = (isLeft and oppositeXPos - BOUNDARY_GAP) or oppositeXPos + oppositeXSize + BOUNDARY_GAP
			local oppositeMenu = oppositeOverflowIcon:getInstance("Menu")
			local isDominant = menu.AbsoluteCanvasSize.X >= oppositeMenu.AbsoluteCanvasSize.X
			if not usingNearestCenter then
				local halfwayXPos = holderXPos + holderXSize/2
				local halfwayBoundary = (isLeft and halfwayXPos - BOUNDARY_GAP/2) or halfwayXPos + BOUNDARY_GAP/2
				menuBoundary = halfwayBoundary
				if isDominant then
					menuBoundary = oppositeBoundary
				end
			end
			menuWidth = (isLeft and menuBoundary - holderXPos) or (holderXEndPos - menuBoundary)
		end
		local currentMaxWidth = menu and menu:GetAttribute("MaxWidth")
		menuWidth = Utility.round(menuWidth)
		if menu and currentMaxWidth ~= menuWidth then
			menu:SetAttribute("MaxWidth", menuWidth)
		end
	end

	
	
	
	
	local joinOverflow = false
	local realXPositions = Overflow.getRealXPositions(alignment, ourOrderedIcons)
	for i = #ourOrderedIcons, 1, -1 do
		local icon = ourOrderedIcons[i]
		local widgetX = Overflow.getWidth(icon)
		local xPos = realXPositions[icon.UID]
		if (isLeft and xPos + widgetX >= boundary) or (isRight and xPos <= boundary) then
			joinOverflow = true
		end
	end
	for i = #ourOrderedIcons, 1, -1 do
		local icon = ourOrderedIcons[i]
		local isOverflow = overflowIconUIDs[icon.UID]
		if not isOverflow then
			if joinOverflow and not icon.parentIconUID then
				icon:joinMenu(overflowIcon)
			elseif not joinOverflow and icon.parentIconUID then
				icon:leave()
			end
		end
	end
	
	
	if overflowIcon.isEnabled ~= joinOverflow then
		overflowIcon:setEnabled(joinOverflow)
	end
	
	
	if overflowIcon.isEnabled and not overflowIcon.overflowAlreadyOpened then
		overflowIcon.overflowAlreadyOpened = true
		overflowIcon:select()
	end

end

return Overflow
end)
local node_20 = Node('Themes', 'ModuleScript', function(script, require)
local Themes = {}
local Utility = require(script.Parent.Parent.Utility)
local baseTheme = require(script.Default)

function Themes.getThemeValue(stateGroup, instanceName, property, iconState)
	if stateGroup then
		for _, detail in pairs(stateGroup) do
			local checkingInstanceName, checkingPropertyName, checkingValue = unpack(detail)
			if instanceName == checkingInstanceName and property == checkingPropertyName then
				return checkingValue
			end
		end
	end
	return nil
end

function Themes.getInstanceValue(instance, property)
	local success, value = pcall(function()
		return instance[property]
	end)
	if not success then
		value = instance:GetAttribute(property)
	end
	return value
end

function Themes.getRealInstance(instance)
	if not instance:GetAttribute("IsAClippedClone") then
		return
	end
	local originalInstance = instance:FindFirstChild("OriginalInstance")
	if not originalInstance then
		return
	end
	return originalInstance.Value
end

function Themes.getClippedClone(instance)
	if not instance:GetAttribute("HasAClippedClone") then
		return
	end
	local clippedClone = instance:FindFirstChild("ClippedClone")
	if not clippedClone then
		return
	end
	return clippedClone.Value
end

function Themes.refresh(icon, instance, specificProperty)
	
	
	if specificProperty then
		local stateGroup = icon:getStateGroup()
		local value = Themes.getThemeValue(stateGroup, instance.Name, specificProperty) or Themes.getInstanceValue(instance, specificProperty)
		Themes.apply(icon, instance, specificProperty, value, true)
		return
	end
	
	
	local stateGroup = icon:getStateGroup()
	if not stateGroup then
		return
	end
	local validInstances = {[instance.Name] = instance}
	for _, child in pairs(instance:GetDescendants()) do
		local collective = child:GetAttribute("Collective")
		if collective then
			validInstances[collective] = child
		end
		validInstances[child.Name] = child
	end
	for _, detail in pairs(stateGroup) do
		local checkingInstanceName, checkingPropertyName, checkingValue = unpack(detail)
		local instanceToUpdate = validInstances[checkingInstanceName]
		if instanceToUpdate then
			Themes.apply(icon, instanceToUpdate.Name, checkingPropertyName, checkingValue, true)
		end
	end
	return
end

function Themes.apply(icon, collectiveOrInstanceNameOrInstance, property, value, forceApply)
	
	
	
	
	if icon.isDestroyed then
		return
	end
	local instances
	local collectiveOrInstanceName = collectiveOrInstanceNameOrInstance
	if typeof(collectiveOrInstanceNameOrInstance) == "Instance" then
		instances = {collectiveOrInstanceNameOrInstance}
		collectiveOrInstanceName = collectiveOrInstanceNameOrInstance.Name
	else
		instances = icon:getInstanceOrCollective(collectiveOrInstanceNameOrInstance)
	end
	local key = collectiveOrInstanceName.."-"..property
	local customBehaviour = icon.customBehaviours[key]
	for _, instance in pairs(instances) do
		local clippedClone = Themes.getClippedClone(instance)
		if clippedClone then
			
			
			
			
			table.insert(instances, clippedClone)
		end
	end
	for _, instance in pairs(instances) do
		if property == "Position" and Themes.getClippedClone(instance) then
			
			continue
		elseif property == "Size" and Themes.getRealInstance(instance) then
			
			continue
		end
		local currentValue = Themes.getInstanceValue(instance, property)
		if not forceApply and value == currentValue then
			continue
		end
		if customBehaviour then
			local newValue = customBehaviour(value, instance, property)
			if newValue ~= nil then
				value = newValue
			end
		end
		local success = pcall(function()
			instance[property] = value
		end)
		if not success then
			
			
			
			
			
			instance:SetAttribute(property, value)
		end
	end
end

function Themes.getModifications(modifications)
	if typeof(modifications[1]) ~= "table" then
		
		
		modifications = {modifications}
	end
	return modifications
end

function Themes.merge(detail, modification, callback)
	local instanceName, property, value, stateName = table.unpack(modification)
	local checkingInstanceName, checkingPropertyName, _, checkingStateName = table.unpack(detail)
	if instanceName == checkingInstanceName and property == checkingPropertyName and Themes.statesMatch(stateName, checkingStateName) then
		detail[3] = value
		if callback then
			callback(detail)
		end
		return true
	end
	return false
end

function Themes.modify(icon, modifications, modificationsUID)
	
	
	
	
	
	
	
	task.spawn(function()
		modificationsUID = modificationsUID or Utility.generateUID()
		modifications = Themes.getModifications(modifications)
		for _, modification in pairs(modifications) do
			local instanceName, property, value, iconState = table.unpack(modification)
			if iconState == nil then
				
				Themes.modify(icon, {instanceName, property, value, "Selected"}, modificationsUID)
				Themes.modify(icon, {instanceName, property, value, "Viewing"}, modificationsUID)
			end
			local chosenState = Utility.formatStateName(iconState or "Deselected")
			local stateGroup = icon:getStateGroup(chosenState)
			local function nowSetIt()
				if chosenState == icon.activeState then
					Themes.apply(icon, instanceName, property, value)
				end
			end
			local function updateRecord()
				for stateName, detail in pairs(stateGroup) do
					local didMerge = Themes.merge(detail, modification, function(detail)
						detail[5] = modificationsUID
						nowSetIt()
					end)
					if didMerge then
						return
					end
				end
				local detail = {instanceName, property, value, chosenState, modificationsUID}
				table.insert(stateGroup, detail)
				nowSetIt()
			end
			updateRecord()
		end
	end)
	return modificationsUID
end

function Themes.remove(icon, modificationsUID)
	for iconState, stateGroup in pairs(icon.appearance) do
		for i = #stateGroup, 1, -1 do
			local detail = stateGroup[i]
			local checkingUID = detail[5]
			if checkingUID == modificationsUID then
				table.remove(stateGroup, i)
			end
		end
	end
	Themes.rebuild(icon)
end

function Themes.removeWith(icon, instanceName, property, state)
	for iconState, stateGroup in pairs(icon.appearance) do
		if state == iconState or not state then
			for i = #stateGroup, 1, -1 do
				local detail = stateGroup[i]
				local detailName = detail[1]
				local detailProperty = detail[2]
				if detailName == instanceName and detailProperty == property then
					table.remove(stateGroup, i)
				end
			end
		end
	end
	Themes.rebuild(icon)
end

function Themes.change(icon)
	
	
	local stateGroup = icon:getStateGroup()
	for _, detail in pairs(stateGroup) do
		local instanceName, property, value = unpack(detail)
		Themes.apply(icon, instanceName, property, value)
	end
end

function Themes.set(icon, theme)
	
	
	
	local themesJanitor = icon.themesJanitor
	themesJanitor:clean()
	themesJanitor:add(icon.stateChanged:Connect(function()
		Themes.change(icon)
	end))
	if typeof(theme) == "Instance" and theme:IsA("ModuleScript") then
		theme = require(theme)
	end
	icon.appliedTheme = theme
	Themes.rebuild(icon)
end

function Themes.statesMatch(state1, state2)
	
	local state1lower = (state1 and string.lower(state1))
	local state2lower = (state2 and string.lower(state2))
	return state1lower == state2lower or not state1 or not state2
end

function Themes.rebuild(icon)
	
	
	
	
	local appliedTheme = icon.appliedTheme
	local statesArray = {"Deselected", "Selected", "Viewing"}
	local function generateTheme()
		for _, stateName in pairs(statesArray) do
			
			
			
			local stateAppearance = {}
			local function updateDetails(theme, incomingStateName)
				
				if not theme then
					return
				end
				for _, detail in pairs(theme) do
					local modificationsUID = detail[5]
					local detailStateName = detail[4]
					if Themes.statesMatch(incomingStateName, detailStateName) then
						local key = detail[1].."-"..detail[2]
						local newDetail = Utility.copyTable(detail)
						newDetail[5] = modificationsUID
						stateAppearance[key] = newDetail
					end
				end
			end
			
			if stateName == "Selected" then
				updateDetails(baseTheme, "Deselected")
			end
			updateDetails(baseTheme, "Empty")
			updateDetails(baseTheme, stateName)
			
			if appliedTheme ~= baseTheme then
				if stateName == "Selected" then
					updateDetails(appliedTheme, "Deselected")
				end
				updateDetails(baseTheme, "Empty")
				updateDetails(appliedTheme, stateName)
			end
			
			
			local alreadyAppliedTheme = {}
			local alreadyAppliedGroup = icon.appearance[stateName]
			if alreadyAppliedGroup then
				for _, modifier in pairs(alreadyAppliedGroup) do
					local modificationsUID = modifier[5]
					if modificationsUID ~= nil then
						local modification = {modifier[1], modifier[2], modifier[3], stateName, modificationsUID}
						table.insert(alreadyAppliedTheme, modification)
					end
				end
			end
			updateDetails(alreadyAppliedTheme, stateName)
			
			local finalStateAppearance = {}
			for _, detail in pairs(stateAppearance) do
				table.insert(finalStateAppearance, detail)
			end
			icon.appearance[stateName] = finalStateAppearance
		end
		Themes.change(icon)
	end
	generateTheme()
end

return Themes
end)
local node_21 = Node('Classic', 'ModuleScript', function(script, require)
return {
	{"Selection", "Size", UDim2.new(1, -6, 1, -5)},
	{"Selection", "Position", UDim2.new(0, 3, 0, 3)},
	
	{"Widget", "MinimumWidth", 32, "Deselected"},
	{"Widget", "MinimumHeight", 32, "Deselected"},
	{"Widget", "BorderSize", 0, "Deselected"},
	{"IconCorners", "CornerRadius", UDim.new(0, 9), "Deselected"},
	{"IconButton", "BackgroundTransparency", 0.5, "Deselected"},
	{"IconLabel", "TextSize", 14, "Deselected"},
	{"Dropdown", "BackgroundTransparency", 0.5, "Deselected"},
	{"Notice", "Position", UDim2.new(1, -12, 0, -3), "Deselected"},
	{"Notice", "Size", UDim2.new(0, 15, 0, 15), "Deselected"},
	{"NoticeLabel", "TextSize", 11, "Deselected"},
	
	{"IconSpot", "BackgroundColor3", Color3.fromRGB(0, 0, 0), "Selected"},
	{"IconSpot", "BackgroundTransparency", 0.702, "Selected"},
	{"IconSpotGradient", "Enabled", false, "Selected"},
	{"IconOverlay", "BackgroundTransparency", 0.97, "Selected"},
	
}
end)
local node_22 = Node('Default', 'ModuleScript', function(script, require)
return {
	
	
	{"IconCorners", "CornerRadius", UDim.new(1, 0)},
	{"Selection", "RotationSpeed", 1},
	{"Selection", "Size", UDim2.new(1, 0, 1, 1)},
	{"Selection", "Position", UDim2.new(0, 0, 0, 0)},
	{"SelectionGradient", "Color", ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(86, 86, 86)),
	})},
	
	
	{"IconImage", "Image", "", "Deselected"},
	{"IconLabel", "Text", "", "Deselected"},
	{"IconLabel", "Position", UDim2.fromOffset(0, 0), "Deselected"}, 
	{"Widget", "DesiredWidth", 44, "Deselected"},
	{"Widget", "MinimumWidth", 44, "Deselected"},
	{"Widget", "MinimumHeight", 44, "Deselected"},
	{"Widget", "BorderSize", 4, "Deselected"},
  	{"IconButton", "BackgroundColor3", Color3.fromRGB(18, 18, 21), "Deselected"},
	{"IconButton", "BackgroundTransparency", 0.08, "Deselected"},
	{"IconImageScale", "Value", 0.5, "Deselected"},
	{"IconImageCorner", "CornerRadius", UDim.new(0, 0), "Deselected"},
	{"IconImage", "ImageColor3", Color3.fromRGB(255, 255, 255), "Deselected"},
	{"IconImage", "ImageTransparency", 0, "Deselected"},
	{"IconImageRatio", "AspectRatio", 1, "Deselected"},
	{"IconLabel", "FontFace", Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), "Deselected"},
	{"IconLabel", "TextSize", 16, "Deselected"},
	{"IconSpot", "BackgroundTransparency", 1, "Deselected"},
	{"IconOverlay", "BackgroundTransparency", 0.85, "Deselected"},
	{"IconSpotGradient", "Enabled", false, "Deselected"},
	{"IconGradient", "Enabled", false, "Deselected"},
	{"ClickRegion", "Active", true, "Deselected"},  
	{"Menu", "Active", false, "Deselected"},
	{"ContentsList", "HorizontalAlignment", Enum.HorizontalAlignment.Center, "Deselected"},
  	{"Dropdown", "BackgroundColor3", Color3.fromRGB(18, 18, 21), "Deselected"},
	{"Dropdown", "BackgroundTransparency", 0.08, "Deselected"},
	{"Dropdown", "MaxIcons", 4.5, "Deselected"},
	{"Menu", "MaxIcons", 4, "Deselected"},
	{"Notice", "Position", UDim2.new(1, -12, 0, -1), "Deselected"},
	{"Notice", "Size", UDim2.new(0, 20, 0, 20), "Deselected"},
	{"NoticeLabel", "TextSize", 13, "Deselected"},
	{"PaddingLeft", "Size", UDim2.new(0, 9, 1, 0), "Deselected"},
	{"PaddingRight", "Size", UDim2.new(0, 11, 1, 0), "Deselected"},
	
	
	
	{"IconSpot", "BackgroundTransparency", 0.7, "Selected"},
	{"IconSpot", "BackgroundColor3", Color3.fromRGB(255, 255, 255), "Selected"},
	{"IconSpotGradient", "Enabled", true, "Selected"},
	{"IconSpotGradient", "Rotation", 45, "Selected"},
	{"IconSpotGradient", "Color", ColorSequence.new(Color3.fromRGB(96, 98, 100), Color3.fromRGB(77, 78, 80)), "Selected"},
	
	
	
	
	
}
end)
local node_23 = Node('Packages', 'Folder', nil)
local node_24 = Node('GoodSignal', 'ModuleScript', function(script, require)
local freeRunnerThread = nil

local function acquireRunnerThreadAndCallEventHandler(fn, ...)
	local acquiredRunnerThread = freeRunnerThread
	freeRunnerThread = nil
	fn(...)
	
	freeRunnerThread = acquiredRunnerThread
end

local function runEventHandlerInFreeThread()
	
	
	
	
	
	while true do
		acquireRunnerThreadAndCallEventHandler(coroutine.yield())
	end
end

local Connection = {}
Connection.__index = Connection

function Connection.new(signal, fn)
	return setmetatable({
		_connected = true,
		_signal = signal,
		_fn = fn,
		_next = false,
	}, Connection)
end

function Connection:Disconnect()
	self._connected = false

	
	
	
	
	if self._signal._handlerListHead == self then
		self._signal._handlerListHead = self._next
	else
		local prev = self._signal._handlerListHead
		while prev and prev._next ~= self do
			prev = prev._next
		end
		if prev then
			prev._next = self._next
		end
	end
end
Connection.Destroy = Connection.Disconnect

setmetatable(Connection, {
	__index = function(tb, key)
		error(("Attempt to get Connection::%s (not a valid member)"):format(tostring(key)), 2)
	end,
	__newindex = function(tb, key, value)
		error(("Attempt to set Connection::%s (not a valid member)"):format(tostring(key)), 2)
	end
})

local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({
		_handlerListHead = false,
	}, Signal)
end

function Signal:Connect(fn)
	local connection = Connection.new(self, fn)
	if self._handlerListHead then
		connection._next = self._handlerListHead
		self._handlerListHead = connection
	else
		self._handlerListHead = connection
	end
	return connection
end

function Signal:DisconnectAll()
	self._handlerListHead = false
end
Signal.Destroy = Signal.DisconnectAll

function Signal:Fire(...)
	local item = self._handlerListHead
	while item do
		if item._connected then
			if not freeRunnerThread then
				freeRunnerThread = coroutine.create(runEventHandlerInFreeThread)
				
				coroutine.resume(freeRunnerThread)
			end
			task.spawn(freeRunnerThread, item._fn, ...)
		end
		item = item._next
	end
end

function Signal:Wait()
	local waitingCoroutine = coroutine.running()
	local cn;
	cn = self:Connect(function(...)
		cn:Disconnect()
		task.spawn(waitingCoroutine, ...)
	end)
	return coroutine.yield()
end

function Signal:Once(fn)
	local cn;
	cn = self:Connect(function(...)
		if cn._connected then
			cn:Disconnect()
		end
		fn(...)
	end)
	return cn
end

setmetatable(Signal, {
	__index = function(tb, key)
		error(("Attempt to get Signal::%s (not a valid member)"):format(tostring(key)), 2)
	end,
	__newindex = function(tb, key, value)
		error(("Attempt to set Signal::%s (not a valid member)"):format(tostring(key)), 2)
	end
})

return Signal
end)
local node_25 = Node('Janitor', 'ModuleScript', function(script, require)
local RunService = game:GetService("RunService")
local Heartbeat = RunService.Heartbeat
local function getPromiseReference()
	return false
end

local IndicesReference = newproxy(true)
getmetatable(IndicesReference).__tostring = function()
	return "IndicesReference"
end

local LinkToInstanceIndex = newproxy(true)
getmetatable(LinkToInstanceIndex).__tostring = function()
	return "LinkToInstanceIndex"
end

local METHOD_NOT_FOUND_ERROR = "Object %s doesn't have method %s, are you sure you want to add it? Traceback: %s"
local NOT_A_PROMISE = "Invalid argument #1 to 'Janitor:AddPromise' (Promise expected, got %s (%s))"

local Janitor = {
	IGNORE_MEMORY_DEBUG = true,
	ClassName = "Janitor";
	__index = {
		CurrentlyCleaning = true;
		[IndicesReference] = nil;
	};
}

local TypeDefaults = {
	["function"] = true;
	["Promise"] = "cancel";
	RBXScriptConnection = "Disconnect";
}

function Janitor.new()
	return setmetatable({
		CurrentlyCleaning = false;
		[IndicesReference] = nil;
	}, Janitor)
end

function Janitor.Is(Object)
	return type(Object) == "table" and getmetatable(Object) == Janitor
end

Janitor.is = Janitor.Is

function Janitor.__index:Add(Object, MethodName, Index)
	if Index then
		self:Remove(Index)

		local This = self[IndicesReference]
		if not This then
			This = {}
			self[IndicesReference] = This
		end

		This[Index] = Object
	end

	local objectType = typeof(Object)
	if objectType == "table" and string.match(tostring(Object), "Promise") then
		objectType = "Promise"
		
		
	end
	MethodName = MethodName or TypeDefaults[objectType] or "Destroy"
	if type(Object) ~= "function" and not Object[MethodName] then
		warn(string.format(METHOD_NOT_FOUND_ERROR, tostring(Object), tostring(MethodName), debug.traceback(nil :: any, 2)))
	end

	local OriginalTraceback = debug.traceback("")
	self[Object] = {MethodName, OriginalTraceback}
	return Object
end
Janitor.__index.Give = Janitor.__index.Add

function Janitor.__index:AddPromise(PromiseObject)
	local Promise = getPromiseReference()
	if Promise then
		if not Promise.is(PromiseObject) then
			error(string.format(NOT_A_PROMISE, typeof(PromiseObject), tostring(PromiseObject)))
		end
		if PromiseObject:getStatus() == Promise.Status.Started then
			local Id = newproxy(false)
			local NewPromise = self:Add(Promise.new(function(Resolve, _, OnCancel)
				if OnCancel(function()
						PromiseObject:cancel()
					end) then
					return
				end

				Resolve(PromiseObject)
			end), "cancel", Id)

			NewPromise:finallyCall(self.Remove, self, Id)
			return NewPromise
		else
			return PromiseObject
		end
	else
		return PromiseObject
	end
end
Janitor.__index.GivePromise = Janitor.__index.AddPromise

function Janitor.__index:AddObject(Object)
	local Id = newproxy(false)
	local Promise = getPromiseReference()
	if Promise and Promise.is(Object) then
		if Object:getStatus() == Promise.Status.Started then
			local NewPromise = self:Add(Promise.resolve(Object), "cancel", Id)
			NewPromise:finallyCall(self.Remove, self, Id)
			return NewPromise, Id
		else
			return Object
		end
	else
		return self:Add(Object, false, Id), Id
	end
end

Janitor.__index.GiveObject = Janitor.__index.AddObject

function Janitor.__index:Remove(Index)
	local This = self[IndicesReference]
	if This then
		local Object = This[Index]

		if Object then
			local ObjectDetail = self[Object]
			local MethodName = ObjectDetail and ObjectDetail[1]

			if MethodName then
				if MethodName == true then
					Object()
				else
					local ObjectMethod = Object[MethodName]
					if ObjectMethod then
						ObjectMethod(Object)
					end
				end

				self[Object] = nil
			end

			This[Index] = nil
		end
	end

	return self
end

function Janitor.__index:Get(Index)
	local This = self[IndicesReference]
	if This then
		return This[Index]
	end
	return nil
end

function Janitor.__index:Cleanup()
	if not self.CurrentlyCleaning then
		self.CurrentlyCleaning = nil
		for Object, ObjectDetail in next, self do
			if Object == IndicesReference then
				continue
			end

			
			local TypeOf = type(Object)
			if TypeOf == "string" or TypeOf == "number" then
				self[Object] = nil
				continue
			end

			local MethodName = ObjectDetail[1]
			local OriginalTraceback = ObjectDetail[2]
			local function warnUser(warning)
				local cleanupLine = debug.traceback("", 3)
				local addedLine = OriginalTraceback
				warn("-------- Janitor Error --------".."\n"..tostring(warning).."\n"..cleanupLine..""..addedLine)
			end
			if MethodName == true then
				local success, warning = pcall(Object)
				if not success then
					warnUser(warning)
				end
			else
				local ObjectMethod = Object[MethodName]
				if ObjectMethod then
					local success, warning = pcall(ObjectMethod, Object)
					local isAnInstanceBeingDestroyed = typeof(Object) == "Instance" and ObjectMethod == "Destroy"
					if not success and not isAnInstanceBeingDestroyed then
						warnUser(warning)
					end
				end
			end

			self[Object] = nil
		end

		local This = self[IndicesReference]
		if This then
			for Index in next, This do
				This[Index] = nil
			end

			self[IndicesReference] = {}
		end

		self.CurrentlyCleaning = false
	end
end

Janitor.__index.Clean = Janitor.__index.Cleanup

function Janitor.__index:Destroy()
	self:Cleanup()
	
	
end

Janitor.__call = Janitor.__index.Cleanup

local Disconnect = {Connected = true}
Disconnect.__index = Disconnect
function Disconnect:Disconnect()
	if self.Connected then
		self.Connected = false
		self.Connection:Disconnect()
	end
end

function Disconnect:__tostring()
	return "Disconnect<" .. tostring(self.Connected) .. ">"
end

function Janitor.__index:LinkToInstance(Object, AllowMultiple)
	local Connection
	local IndexToUse = AllowMultiple and newproxy(false) or LinkToInstanceIndex
	local IsNilParented = Object.Parent == nil
	local ManualDisconnect = setmetatable({}, Disconnect)

	local function ChangedFunction(_DoNotUse, NewParent)
		if ManualDisconnect.Connected then
			_DoNotUse = nil
			IsNilParented = NewParent == nil

			if IsNilParented then
				coroutine.wrap(function()
					Heartbeat:Wait()
					if not ManualDisconnect.Connected then
						return
					elseif not Connection.Connected then
						self:Cleanup()
					else
						while IsNilParented and Connection.Connected and ManualDisconnect.Connected do
							Heartbeat:Wait()
						end

						if ManualDisconnect.Connected and IsNilParented then
							self:Cleanup()
						end
					end
				end)()
			end
		end
	end

	Connection = Object.AncestryChanged:Connect(ChangedFunction)
	ManualDisconnect.Connection = Connection

	if IsNilParented then
		ChangedFunction(nil, Object.Parent)
	end

	Object = nil
	return self:Add(ManualDisconnect, "Disconnect", IndexToUse)
end

function Janitor.__index:LinkToInstances(...)
	local ManualCleanup = Janitor.new()
	for _, Object in ipairs({...}) do
		ManualCleanup:Add(self:LinkToInstance(Object, true), "Disconnect")
	end

	return ManualCleanup
end

for FunctionName, Function in next, Janitor.__index do
	local NewFunctionName = string.sub(string.lower(FunctionName), 1, 1) .. string.sub(FunctionName, 2)
	Janitor.__index[NewFunctionName] = Function
end

return Janitor
end)
local node_26 = Node('Reference', 'ModuleScript', function(script, require)
local replicatedStorage = game:GetService("ReplicatedStorage")
local Reference = {}
Reference.objectName = "TopbarPlusReference"

function Reference.addToReplicatedStorage()
	local existingItem = replicatedStorage:FindFirstChild(Reference.objectName)
    if existingItem then
        return false
    end
    local objectValue = Instance.new("ObjectValue")
	objectValue.Name = Reference.objectName
    objectValue.Value = script.Parent
    objectValue.Parent = replicatedStorage
    return objectValue
end

function Reference.getObject()
	local objectValue = replicatedStorage:FindFirstChild(Reference.objectName)
    if objectValue then
        return objectValue
    end
    return false
end

return Reference
end)
local node_27 = Node('Types', 'ModuleScript', function(script, require)
type Connection<Variant... = ...any> = {
	Disconnect: (self: Connection<Variant...>) -> (),
}

type Signal<Variant... = ...any> = {
	Connect: (self: Signal<Variant...>, func: (Variant...) -> ()) -> Connection<Variant...>,
    Once: (self: Signal<Variant...>, func: (Variant...) -> ()) -> Connection<Variant...>,
	Wait: (self: Signal<Variant...>) -> Variant...,
}

export type IconState = "Deselected" | "Selected" | "Viewing"
export type Events = "selected" | "deselected" | "toggled" | "viewingStarted" | "viewingEnded" | "notified"
export type Alignment = "Left" | "Center" | "Right"
export type EventSource = "User" | "OneClick" | "AutoDeselect" | "HideParentFeature" | "Overflow"
export type Modification = { any }

type StaticFunctions = {
	getIcons: typeof(
		
		function(): { Icon }
			return (nil :: any) :: { Icon }
		end
	),
	getIcon: typeof(
		
		function(nameOrUID: string): Icon?
			return nil :: any
		end
	),
	setTopbarEnabled: typeof(
		
		function(enabled: boolean)

		end
	),
	modifyBaseTheme: typeof(
		
		function(modifications: { Modification })

		end
	),
	setDisplayOrder: typeof(
		
		function(order: number)

		end
	),
}

type Methods = {
	
	
	setName: typeof(
		
		function(self: Icon, name: string): Icon
			return nil :: any
		end
	),
	getInstance: typeof(
		
		function(self: Icon, instanceName: string): Instance?
			return (nil :: any) :: Instance?
		end
	),
	modifyTheme: typeof(
		
		function(self: Icon, modifications: {Modification} | Modification): Icon
			return nil :: any
		end
	),
	modifyChildTheme: typeof(
		
		function(self: Icon, modifications: { Modification }): Icon
			return nil :: any
		end
	),
	setEnabled: typeof(
		
		function(self: Icon, enabled: boolean): Icon
			return nil :: any
		end
	),
	select: typeof(
		
		function(self: Icon): Icon
			return nil :: any
		end
	),
	deselect: typeof(
		
		function(self: Icon): Icon
			return nil :: any
		end
	),
	notify: typeof(
		
		function(self: Icon, clearNoticeEvent: Signal?): Icon
			return nil :: any
		end
	),
	clearNotices: typeof(
		
		function(self: Icon): Icon
			return nil :: any
		end
	),
	disableOverlay: typeof(
		
		function(self: Icon, disabled: boolean): Icon
			return nil :: any
		end
	),
	setImage: typeof(
		
		function(self: Icon, imageId: string | number, iconState: IconState?): Icon
			return nil :: any
		end
	),
	setLabel: typeof(
		
		function(self: Icon, text: string, iconState: IconState?): Icon
			return nil :: any
		end
	),
	setOrder: typeof(
		
		function(self: Icon, order: number, iconState: IconState?): Icon
			return nil :: any
		end
	),
	setCornerRadius: typeof(
		
		function(self: Icon, udim: UDim2, iconState: IconState?): Icon
			return nil :: any
		end
	),
	align: typeof(
		
		function(self: Icon, alignment: Alignment?): Icon
			return nil :: any
		end
	),
	setWidth: typeof(
		
		function(self: Icon, minimumSize: number, iconState: IconState?): Icon
			return nil :: any
		end
	),
	setImageScale: typeof(
		
		function(self: Icon, scale: number, iconState: IconState?): Icon
			return nil :: any
		end
	),
	setImageRatio: typeof(
		
		function(self: Icon, ratio: number, iconState: IconState?): Icon
			return nil :: any
		end
	),
	setTextSize: typeof(
		
		function(self: Icon, textSize: number, iconState: IconState?): Icon
			return nil :: any
		end
	),
	setTextColor: typeof(
		
		function(self: Icon, color: Color3, iconState: IconState?): Icon
			return nil :: any
		end
	),
	setTextFont: typeof(
		
		function(self: Icon, font: string | Enum.Font, fontWeight: Enum.FontWeight?, fontStyle: Enum.FontSize?, iconState: IconState?): Icon
			return nil :: any
		end
	),
	bindToggleItem: typeof(
		
		function(self: Icon, guiObjectOrLayerCollector: GuiObject | LayerCollector): Icon
			return nil :: any
		end
	),
	unbindToggleItem: typeof(
		
		function(self: Icon, guiObjectOrLayerCollector: GuiObject | LayerCollector): Icon
			return nil :: any
		end
	),
	bindEvent: typeof(
		
		function(self: Icon, event: Events, callback: (...any) -> ()): Icon
			return nil :: any
		end
	),
	unbindEvent: typeof(
		
		function(self: Icon, event: Events): Icon
			return nil :: any
		end
	),
	bindToggleKey: typeof(
		
		function(self: Icon, keycode: Enum.KeyCode): Icon
			return nil :: any
		end
	),
	unbindToggleKey: typeof(
		
		function(self: Icon, keycode: Enum.KeyCode): Icon
			return nil :: any
		end
	),
	call: typeof(
		
		function(self: Icon, func: (self: Icon) -> (...any), ...: any): Icon
			return nil :: any
		end
	),
	addToJanitor: typeof(
		
		function(self: Icon, userdata: unknown): Icon
			return nil :: any
		end
	),
	lock: typeof(
		
		function(self: Icon): Icon
			return nil :: any
		end
	),
	unlock: typeof(
		
		function(self: Icon): Icon
			return nil :: any
		end
	),
	debounce: typeof(
		
		function(self: Icon, seconds: number): Icon
			return nil :: any
		end
	),
	autoDeselect: typeof(
		
		function(self: Icon, enabled: boolean?): Icon
			return nil :: any
		end
	),
	oneClick: typeof(
		
		function(self: Icon, enabled: boolean?): Icon
			return nil :: any
		end
	),
	setCaption: typeof(
		
		function(self: Icon, text: string?): Icon
			return nil :: any
		end
	),
	setCaptionHint: typeof(
		
		function(self: Icon, keyCode: Enum.KeyCode): Icon
			return nil :: any
		end
	),
	setDropdown: typeof(
		
		function(self: Icon, icons: { Icon }): Icon
			return nil :: any
		end
	),
	joinDropdown: typeof(
		
		function(self: Icon, parent: Icon): Icon
			return nil :: any
		end
	),
	setMenu: typeof(
		
		function(self: Icon, icons: { Icon }): Icon
			return nil :: any
		end
	),
	setFixedMenu: typeof(
		
		function(self: Icon, icons: { Icon }): Icon
			return nil :: any
		end
	),
	joinMenu: typeof(
		
		function(self: Icon, parentIcon: Icon): Icon
			return nil :: any
		end
	),
	leave: typeof(
		
		function(self: Icon): Icon
			return nil :: any
		end
	),
	convertLabelToNumberSpinner: typeof(
		
		function(self: Icon, numberSpinner: any, func: (...any) -> (...any), ...: any): Icon
			return nil :: any
		end
	),
	destroy: typeof(
		
		function(self: Icon): Icon
			return nil :: any
		end
	),
} & StaticFunctions

type Fields = {
	
	name: string,
	isSelected: boolean,
	isEnabled: boolean,
	totalNotices: number,
	locked: boolean,

	
	selected: Signal<EventSource>,
	deselected: Signal<EventSource>,
	toggled: Signal<boolean, EventSource>,
	viewingStarted: Signal,
	viewingEnded: Signal,
	notified: Signal,
}

export type Icon = Methods & StaticFunctions 

export type StaticIcon = {
	new: typeof(
		
		function(): Icon
			return (nil :: any) :: Icon
		end
	),
} & StaticFunctions

return {}
end)
local node_28 = Node('Utility', 'ModuleScript', function(script, require)
local Utility = {}
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

function Utility.createStagger(delayTime, callback, delayInitially)
	
	
	
	
	
	
	
	
	local staggerActive = false
	local multipleCalls = false
	if not delayTime or delayTime == 0 then
		
		
		delayTime = 0.01
	end
	local function staggeredCallback(...)
		if staggerActive then
			multipleCalls = true
			return
		end
		local packedArgs = table.pack(...)
		staggerActive = true
		multipleCalls = false
		task.spawn(function()
			if delayInitially then
				task.wait(delayTime)
			end
			callback(table.unpack(packedArgs))
		end)
		task.delay(delayTime, function()
			staggerActive = false
			if multipleCalls then
				
				
				staggeredCallback(table.unpack(packedArgs))
			end
		end)
	end
	return staggeredCallback
end

function Utility.round(n)
	
	return math.floor(n + 0.5)
end

function Utility.reverseTable(t)
	for i = 1, math.floor(#t/2) do
		local j = #t - i + 1
		t[i], t[j] = t[j], t[i]
	end
end

function Utility.copyTable(t)
	
	assert(type(t) == "table", "First argument must be a table")
	local tCopy = table.create(#t)
	for k,v in pairs(t) do
		if (type(v) == "table") then
			tCopy[k] = Utility.copyTable(v)
		else
			tCopy[k] = v
		end
	end
	return tCopy
end

local validCharacters = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","1","2","3","4","5","6","7","8","9","0","<",">","?","@","{","}","[","]","!","(",")","=","+","~","#"}
function Utility.generateUID(length)
	length = length or 8
	local UID = ""
	local list = validCharacters
	local total = #list
	for i = 1, length do
		local randomCharacter = list[math.random(1, total)]
		UID = UID..randomCharacter
	end
	return UID
end

local instanceTrackers = {}
function Utility.setVisible(instance, bool, sourceUID)
	
	
	
	
	local tracker = instanceTrackers[instance]
	if not tracker then
		tracker = {}
		instanceTrackers[instance] = tracker
		instance.Destroying:Once(function()
			instanceTrackers[instance] = nil
		end)
	end
	if not bool then
		tracker[sourceUID] = true
	else
		tracker[sourceUID] = nil
	end
	local isVisible = bool
	if bool then
		for sourceUID, _ in pairs(tracker) do
			isVisible = false
			break
		end
	end
	instance.Visible = isVisible
end

function Utility.formatStateName(incomingStateName)
	return string.upper(string.sub(incomingStateName, 1, 1))..string.lower(string.sub(incomingStateName, 2))
end

function Utility.localPlayerRespawned(callback)
	
	
	
	
	
	
	localPlayer.CharacterRemoving:Connect(callback)
end

function Utility.getClippedContainer(screenGui)
	
	
	local clippedContainer = screenGui:FindFirstChild("ClippedContainer")
	if not clippedContainer then
		clippedContainer = Instance.new("Folder")
		clippedContainer.Name = "ClippedContainer"
		clippedContainer.Parent = screenGui
	end
	return clippedContainer
end

local Janitor = require(script.Parent.Packages.Janitor)
local GuiService = game:GetService("GuiService")
function Utility.clipOutside(icon, instance)
	local cloneJanitor = icon.janitor:add(Janitor.new())
	instance.Destroying:Once(function()
		cloneJanitor:Destroy()
	end)
	icon.janitor:add(instance)

	local originalParent = instance.Parent
	local clone = cloneJanitor:add(Instance.new("Frame"))
	clone:SetAttribute("IsAClippedClone", true)
	clone.Name = instance.Name
	clone.AnchorPoint = instance.AnchorPoint
	clone.Size = instance.Size
	clone.Position = instance.Position
	clone.BackgroundTransparency = 1
	clone.LayoutOrder = instance.LayoutOrder
	clone.Parent = originalParent

	local valueInstance = Instance.new("ObjectValue")
	valueInstance.Name = "OriginalInstance"
	valueInstance.Value = instance
	valueInstance.Parent = clone

	local valueInstanceCopy = valueInstance:Clone()
	instance:SetAttribute("HasAClippedClone", true)
	valueInstanceCopy.Name = "ClippedClone"
	valueInstanceCopy.Value = clone
	valueInstanceCopy.Parent = instance

	local screenGui
	local Icon = require(icon.iconModule)
	local container = Icon.container
	local function updateScreenGui()
		local originalScreenGui = originalParent:FindFirstAncestorWhichIsA("ScreenGui")
		screenGui = if string.match(originalScreenGui.Name, "Clipped") then originalScreenGui else container[originalScreenGui.Name.."Clipped"]
		instance.AnchorPoint = Vector2.new(0, 0)
		instance.Parent = Utility.getClippedContainer(screenGui)
	end
	cloneJanitor:add(icon.alignmentChanged:Connect(updateScreenGui))
	updateScreenGui()

	
	for _, child in pairs(instance:GetChildren()) do
		if child:IsA("UIAspectRatioConstraint") then
			child:Clone().Parent = clone
		end
	end

	
	
	
	local widget = icon.widget
	local isOutsideParent = false
	local ignoreVisibilityUpdater = instance:GetAttribute("IgnoreVisibilityUpdater")
	local function updateVisibility()
		if ignoreVisibilityUpdater then
			return
		end
		local isVisible = widget.Visible
		if isOutsideParent then
			isVisible = false
		end
		Utility.setVisible(instance, isVisible, "ClipHandler")
	end
	cloneJanitor:add(widget:GetPropertyChangedSignal("Visible"):Connect(updateVisibility))

	local previousScroller
	local function checkIfOutsideParentXBounds()
		
		task.defer(function()
			
			
			local parentInstance
			local ourUID = icon.UID
			local nextIconUID = ourUID
			local shouldClipToParent = instance:GetAttribute("ClipToJoinedParent")
			if shouldClipToParent then
				for i = 1, 10 do 
					local nextIcon = Icon.getIconByUID(nextIconUID)
					if not nextIcon then
						break
					end
					local nextParentInstance = nextIcon.joinedFrame
					nextIconUID = nextIcon.parentIconUID
					if not nextParentInstance then
						break
					end
					parentInstance = nextParentInstance
					if parentInstance and parentInstance.Name == "DropdownScroller" then
						break
					end
				end
			end
			if not parentInstance then
				isOutsideParent = false
				updateVisibility()
				return
			end
			local pos = instance.AbsolutePosition
			local halfSize = instance.AbsoluteSize/2
			local parentPos = parentInstance.AbsolutePosition
			local parentSize = parentInstance.AbsoluteSize
			local posHalf = (pos + halfSize)
			local exceededLeft = posHalf.X < parentPos.X
			local exceededRight = posHalf.X > (parentPos.X + parentSize.X)
			local exceededTop = posHalf.Y < parentPos.Y
			local exceededBottom = posHalf.Y > (parentPos.Y + parentSize.Y)
			local hasExceeded = exceededLeft or exceededRight or exceededTop or exceededBottom
			if hasExceeded ~= isOutsideParent then
				isOutsideParent = hasExceeded
				updateVisibility()
			end
			if parentInstance:IsA("ScrollingFrame") and previousScroller ~= parentInstance then
				previousScroller = parentInstance
				local connection = parentInstance:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
					checkIfOutsideParentXBounds()
				end)
				cloneJanitor:add(connection, "Disconnect", "TrackUtilityScroller-"..ourUID)
			end
		end)
	end

	local camera = workspace.CurrentCamera
	local additionalOffsetX = instance:GetAttribute("AdditionalOffsetX") or 0
	local function trackProperty(property)
		local absoluteProperty = "Absolute"..property
		local function updateProperty()
			local cloneValue = clone[absoluteProperty]
			local absoluteValue = UDim2.fromOffset(cloneValue.X, cloneValue.Y)
			if property == "Position" then

				
				local SIDE_PADDING = 4
				local limitX = camera.ViewportSize.X - instance.AbsoluteSize.X - SIDE_PADDING
				local inputX = absoluteValue.X.Offset
				if inputX < SIDE_PADDING then
					inputX = SIDE_PADDING
				elseif inputX > limitX then
					inputX = limitX
				end
				absoluteValue = UDim2.fromOffset(inputX, absoluteValue.Y.Offset)

				
				
				local topbarInset = GuiService.TopbarInset
				local viewportWidth = workspace.CurrentCamera.ViewportSize.X
				local guiWidth = screenGui.AbsoluteSize.X
				local guiOffset = screenGui.AbsolutePosition.X
				
				local oldTopbarCenterOffset = 0
				local offsetX = if Icon.isOldTopbar then guiOffset else viewportWidth - guiWidth - oldTopbarCenterOffset
				
				
				offsetX -= additionalOffsetX
				absoluteValue += UDim2.fromOffset(-offsetX, topbarInset.Height)

				
				checkIfOutsideParentXBounds()

			end
			instance[property] = absoluteValue
		end
		
		
		local updatePropertyStaggered = Utility.createStagger(0.01, updateProperty)
		cloneJanitor:add(clone:GetPropertyChangedSignal(absoluteProperty):Connect(updatePropertyStaggered))
		cloneJanitor:add(clone:GetAttributeChangedSignal("ForceUpdate"):Connect(function()
			updatePropertyStaggered()
		end))

		
		
		
		
		
		
		
		
		local updatePropertyPatch = Utility.createStagger(0.5, updateProperty, true)
		cloneJanitor:add(clone:GetPropertyChangedSignal(absoluteProperty):Connect(updatePropertyPatch))
		
		
		
		
		if property == "Position" then
			cloneJanitor:add(screenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				updatePropertyStaggered()
			end))
		end

	end
	task.delay(0.1, checkIfOutsideParentXBounds)
	checkIfOutsideParentXBounds()
	updateVisibility()
	trackProperty("Position")
	
	
	cloneJanitor:add(instance:GetPropertyChangedSignal("Visible"):Connect(function()
		
		
	end))

	
	local shouldTrackCloneSize = instance:GetAttribute("TrackCloneSize")
	if shouldTrackCloneSize then
		trackProperty("Size")
	else
		cloneJanitor:add(instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			local absolute = instance.AbsoluteSize
			clone.Size = UDim2.fromOffset(absolute.X, absolute.Y)
		end))
	end

	return clone
end

function Utility.joinFeature(originalIcon, parentIcon, iconsArray, scrollingFrameOrFrame)

	
	local joinJanitor = originalIcon.joinJanitor
	joinJanitor:clean()
	if not scrollingFrameOrFrame then
		originalIcon:leave()
		return
	end
	originalIcon.parentIconUID = parentIcon.UID
	originalIcon.joinedFrame = scrollingFrameOrFrame
	local function updateAlignent()
		local parentAlignment = parentIcon.alignment
		if parentAlignment == "Center" then
			parentAlignment = "Left"
		end
		originalIcon:setAlignment(parentAlignment, true)
	end
	joinJanitor:add(parentIcon.alignmentChanged:Connect(updateAlignent))
	updateAlignent()
	originalIcon:modifyTheme({"IconButton", "BackgroundTransparency", 1}, "JoinModification")
	originalIcon:modifyTheme({"ClickRegion", "Active", false}, "JoinModification")
	if parentIcon.childModifications then
		
		
		
		task.defer(function()
			originalIcon:modifyTheme(parentIcon.childModifications, parentIcon.childModificationsUID)
		end)
	end
	
	local clickRegion = originalIcon:getInstance("ClickRegion")
	local function makeSelectable()
		clickRegion.Selectable = parentIcon.isSelected
	end
	joinJanitor:add(parentIcon.toggled:Connect(makeSelectable))
	task.defer(makeSelectable)
	joinJanitor:add(function()
		clickRegion.Selectable = true
	end)
	

	
	
	local originalIconUID = originalIcon.UID
	table.insert(iconsArray, originalIconUID)
	parentIcon:autoDeselect(false)
	parentIcon.childIconsDict[originalIconUID] = true
	if not parentIcon.isEnabled then
		parentIcon:setEnabled(true)
	end
	originalIcon.joinedParent:Fire(parentIcon)

	
	
	joinJanitor:add(function()
		local joinedFrame = originalIcon.joinedFrame
		if not joinedFrame then
			return
		end
		for i, iconUID in pairs(iconsArray) do
			if iconUID == originalIconUID then
				table.remove(iconsArray, i)
				break
			end
		end
		local Icon = require(originalIcon.iconModule)
		local parentIcon = Icon.getIconByUID(originalIcon.parentIconUID)
		if not parentIcon then
			return
		end
		originalIcon:setAlignment(originalIcon.originalAlignment)
		originalIcon.parentIconUID = false
		originalIcon.joinedFrame = false
		
		originalIcon:removeModification("JoinModification")
		
		local parentHasNoChildren = true
		local parentChildIcons = parentIcon.childIconsDict
		parentChildIcons[originalIconUID] = nil
		for childIconUID, _ in pairs(parentChildIcons) do
			parentHasNoChildren = false
			break
		end
		if parentHasNoChildren and not parentIcon.isAnOverflow then
			parentIcon:setEnabled(false)
		end
		updateAlignent()

	end)

end

return Utility
end)
local node_29 = Node('VERSION', 'ModuleScript', function(script, require)
local VERSION = {}

VERSION.appVersion = "v3.4.0"
VERSION.latestVersion = nil :: string?

function VERSION.getLatestVersion(): string?
	local DEVELOPMENT_PLACE_ID = 117501901079852
	local latestVersion = VERSION.latestVersion
	if latestVersion then
		return latestVersion
	end
	local placeName = ""
	while true do
		local success, hdDevelopmentDetails = pcall(function()
			return game:GetService("MarketplaceService"):GetProductInfo(DEVELOPMENT_PLACE_ID)
		end)
		if success and hdDevelopmentDetails then
			placeName = hdDevelopmentDetails.Name
			break
		end
		task.wait(1)
	end
	latestVersion = string.match(placeName, "^TopbarPlus (.*)$")
	if latestVersion then
		latestVersion = latestVersion:gsub("%s+", "") 
	end
	VERSION.latestVersion = latestVersion
	return latestVersion
end

function VERSION.getAppVersion()
	return VERSION.appVersion
end

function VERSION.isUpToDate()
	local latestVersion = VERSION.getLatestVersion()
	local appVersion = VERSION.getAppVersion()
	return latestVersion ~= nil and latestVersion == appVersion
end

return VERSION
end)
local node_30 = Node('topbarplus', 'ModuleScript', function(script, require)
return require(script.Parent._Index["1foreverhd_topbarplus@3.4.0"]["topbarplus"])
end)
local node_31 = Node('satchel', 'ModuleScript', function(script, require)
local ContextActionService = game:GetService("ContextActionService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local VRService = game:GetService("VRService")
local Players = game:GetService("Players")
local PlayerGui: Instance = Players.LocalPlayer:WaitForChild("PlayerGui")

local BackpackScript = {}

BackpackScript.OpenClose = nil :: any 
BackpackScript.IsOpen = false :: boolean
BackpackScript.StateChanged = Instance.new("BindableEvent") :: BindableEvent 

BackpackScript.ModuleName = "Backpack" :: string
BackpackScript.KeepVRTopbarOpen = true :: boolean
BackpackScript.VRIsExclusive = true :: boolean
BackpackScript.VRClosesNonExclusive = true :: boolean

BackpackScript.BackpackEmpty = Instance.new("BindableEvent") :: BindableEvent 
BackpackScript.BackpackEmpty.Name = "BackpackEmpty"

BackpackScript.BackpackItemAdded = Instance.new("BindableEvent") :: BindableEvent 
BackpackScript.BackpackItemAdded.Name = "BackpackAdded"

BackpackScript.BackpackItemRemoved = Instance.new("BindableEvent") :: BindableEvent 
BackpackScript.BackpackItemRemoved.Name = "BackpackRemoved"

local targetScript: ModuleScript = script

require(script.Attribution)

local PREFERRED_TRANSPARENCY: number = GuiService.PreferredTransparency or 1

local LEGACY_EDGE_ENABLED: boolean = not targetScript:GetAttribute("OutlineEquipBorder") or false 
local LEGACY_PADDING_ENABLED: boolean = targetScript:GetAttribute("InsetIconPadding") 

local BACKGROUND_TRANSPARENCY_DEFAULT: number = targetScript:GetAttribute("BackgroundTransparency") or 0.3
local BACKGROUND_TRANSPARENCY: number = BACKGROUND_TRANSPARENCY_DEFAULT * PREFERRED_TRANSPARENCY
local BACKGROUND_CORNER_RADIUS: UDim = UDim.new(0, 8)
local BACKGROUND_COLOR: Color3 = targetScript:GetAttribute("BackgroundColor3")
	or Color3.new(25 / 255, 27 / 255, 29 / 255)

local SLOT_EQUIP_COLOR: Color3 = targetScript:GetAttribute("EquipBorderColor3") or Color3.new(0 / 255, 162 / 255, 1)
local SLOT_LOCKED_TRANSPARENCY_DEFAULT: number = targetScript:GetAttribute("BackgroundTransparency") or 0.3 
local SLOT_LOCKED_TRANSPARENCY: number = SLOT_LOCKED_TRANSPARENCY_DEFAULT * PREFERRED_TRANSPARENCY
local SLOT_EQUIP_THICKNESS: number = targetScript:GetAttribute("EquipBorderSizePixel") or 5 
local SLOT_CORNER_RADIUS: UDim = targetScript:GetAttribute("CornerRadius") or UDim.new(0, 8)
local SLOT_BORDER_COLOR: Color3 = Color3.new(1, 1, 1) 

local TOOLTIP_CORNER_RADIUS: UDim = SLOT_CORNER_RADIUS - UDim.new(0, 5) or UDim.new(0, 3)
local TOOLTIP_BACKGROUND_COLOR: Color3 = targetScript:GetAttribute("BackgroundColor3")
	or Color3.new(25 / 255, 27 / 255, 29 / 255)
local TOOLTIP_PADDING: number = 4
local TOOLTIP_HEIGHT: number = 16
local TOOLTIP_OFFSET: number = -5 

local ARROW_IMAGE_OPEN: string = "rbxasset://textures/ui/TopBar/inventoryOn.png"
local ARROW_IMAGE_CLOSE: string = "rbxasset://textures/ui/TopBar/inventoryOff.png"

local HOTBAR_SLOTS_FULL: number = 10 
local HOTBAR_SLOTS_VR: number = 6
local HOTBAR_SLOTS_MINI: number = 6 
local HOTBAR_SLOTS_WIDTH_CUTOFF: number = 1024 

local INVENTORY_ROWS_FULL: number = 4
local INVENTORY_ROWS_VR: number = 3
local INVENTORY_ROWS_MINI: number = 2
local INVENTORY_HEADER_SIZE: number = 40
local INVENTORY_ARROWS_BUFFER_VR: number = 40

local TEXT_COLOR: Color3 = targetScript:GetAttribute("TextColor3") or Color3.new(1, 1, 1)
local TEXT_STROKE_TRANSPARENCY: number = targetScript:GetAttribute("TextStrokeTransparency") or 0.5
local TEXT_STROKE_COLOR: Color3 = targetScript:GetAttribute("TextStrokeColor3") or Color3.new(0, 0, 0)

local SEARCH_BACKGROUND_COLOR: Color3 = Color3.new(25 / 255, 27 / 255, 29 / 255)
local SEARCH_BACKGROUND_TRANSPARENCY_DEFAULT: number = 0.2
local SEARCH_BACKGROUND_TRANSPARENCY: number = SEARCH_BACKGROUND_TRANSPARENCY_DEFAULT * PREFERRED_TRANSPARENCY
local SEARCH_BORDER_COLOR: Color3 = Color3.new(1, 1, 1)
local SEARCH_BORDER_TRANSPARENCY: number = 0.8
local SEARCH_BORDER_THICKNESS: number = 1
local SEARCH_TEXT_PLACEHOLDER: string = "Search"
local SEARCH_TEXT_OFFSET: number = 8
local SEARCH_TEXT: string = ""
local SEARCH_CORNER_RADIUS: UDim = UDim.new(0, 3)
local SEARCH_IMAGE_X: string = "rbxasset://textures/ui/InspectMenu/x.png"
local SEARCH_BUFFER_PIXELS: number = 5
local SEARCH_WIDTH_PIXELS: number = 200

local FONT_FAMILY: Font = targetScript:GetAttribute("FontFace")
	or Font.new("rbxasset://fonts/families/BuilderSans.json")
local FONT_SIZE: number = targetScript:GetAttribute("TextSize") or 16
local DROP_HOTKEY_VALUE: number = Enum.KeyCode.Backspace.Value
local ZERO_KEY_VALUE: number = Enum.KeyCode.Zero.Value
local DOUBLE_CLICK_TIME: number = 0.5
local ICON_BUFFER_PIXELS: number = 5
local ICON_SIZE_PIXELS: number = 60

local MOUSE_INPUT_TYPES: { [Enum.UserInputType]: boolean } =
	{ 
		[Enum.UserInputType.MouseButton1] = true,
		[Enum.UserInputType.MouseButton2] = true,
		[Enum.UserInputType.MouseButton3] = true,
		[Enum.UserInputType.MouseMovement] = true,
		[Enum.UserInputType.MouseWheel] = true,
	}

local GAMEPAD_INPUT_TYPES: { [Enum.UserInputType]: boolean } =
	{ 
		[Enum.UserInputType.Gamepad1] = true,
		[Enum.UserInputType.Gamepad2] = true,
		[Enum.UserInputType.Gamepad3] = true,
		[Enum.UserInputType.Gamepad4] = true,
		[Enum.UserInputType.Gamepad5] = true,
		[Enum.UserInputType.Gamepad6] = true,
		[Enum.UserInputType.Gamepad7] = true,
		[Enum.UserInputType.Gamepad8] = true,
	}

local BackpackEnabled: boolean = true

local Icon: any = require(script.Parent.topbarplus)

local inventoryIcon: any = Icon.new()
	:setName("Inventory")
	:setImage(ARROW_IMAGE_OPEN, "Selected")
	:setImage(ARROW_IMAGE_CLOSE, "Deselected")
	:setImageScale(1)
	:setCaption("Inventory")
	:bindToggleKey(Enum.KeyCode.Backquote)
	:autoDeselect(false)
	:setOrder(-1)

inventoryIcon.toggled:Connect(function(): ()
	if not GuiService.MenuIsOpen then
		BackpackScript.OpenClose()
	end
end)

local BackpackGui: ScreenGui = Instance.new("ScreenGui")
BackpackGui.DisplayOrder = 120
BackpackGui.IgnoreGuiInset = true
BackpackGui.ResetOnSpawn = false
BackpackGui.Name = "BackpackGui"
BackpackGui.Parent = PlayerGui

local IsTenFootInterface: boolean = GuiService:IsTenFootInterface()
if IsTenFootInterface then
	ICON_SIZE_PIXELS = 100
	FONT_SIZE = 24
end

local GamepadActionsBound: boolean = false

local IS_PHONE: boolean = UserInputService.TouchEnabled
	and workspace.CurrentCamera.ViewportSize.X < HOTBAR_SLOTS_WIDTH_CUTOFF

local Player: Player = Players.LocalPlayer

local MainFrame: Frame = nil
local HotbarFrame: Frame = nil
local InventoryFrame: Frame = nil
local VRInventorySelector: any = nil
local ScrollingFrame: ScrollingFrame = nil
local UIGridFrame: Frame = nil
local UIGridLayout: UIGridLayout = nil
local ScrollUpInventoryButton: any = nil
local ScrollDownInventoryButton: any = nil
local changeToolFunc: any = nil

local Character: Model = Player.Character or Player.CharacterAdded:Wait()
local Humanoid: any = Character:WaitForChild("Humanoid")
local Backpack: Instance = Player:WaitForChild("Backpack")

local Slots = {} 
local LowestEmptySlot: any = nil
local SlotsByTool = {} 
local HotkeyFns = {} 
local Dragging: { boolean } = {} 
local FullHotbarSlots: number = 0 
local ActiveHopper = nil 
local StarterToolFound: boolean = false 
local WholeThingEnabled: boolean = false
local TextBoxFocused: boolean = false 
local ViewingSearchResults: boolean = false 

local CharConns: { RBXScriptConnection } = {} 
local GamepadEnabled: boolean = false 

local IsVR: boolean = VRService.VREnabled 
local NumberOfHotbarSlots: number = IsVR and HOTBAR_SLOTS_VR or (IS_PHONE and HOTBAR_SLOTS_MINI or HOTBAR_SLOTS_FULL) 
local NumberOfInventoryRows: number = IsVR and INVENTORY_ROWS_VR
	or (IS_PHONE and INVENTORY_ROWS_MINI or INVENTORY_ROWS_FULL) 
local BackpackPanel = nil
local lastEquippedSlot: any = nil

local function EvaluateBackpackPanelVisibility(enabled: boolean): boolean
	return enabled and inventoryIcon.enabled and BackpackEnabled and VRService.VREnabled
end

local function ShowVRBackpackPopup(): ()
	if BackpackPanel and EvaluateBackpackPanelVisibility(true) then
		BackpackPanel:ForceShowForSeconds(2)
	end
end

local function FindLowestEmpty(): number?
	for i: number = 1, NumberOfHotbarSlots do
		local slot: any = Slots[i]
		if not slot.Tool then
			return slot
		end
	end
	return nil
end

local function isInventoryEmpty(): boolean
	for i: number = NumberOfHotbarSlots + 1, #Slots do
		local slot: any = Slots[i]
		if slot and slot.Tool then
			return false
		end
	end
	return true
end

BackpackScript.IsInventoryEmpty = isInventoryEmpty

local function UseGazeSelection(): boolean
	return false 
end

local function AdjustHotbarFrames(): ()
	local inventoryOpen: boolean = InventoryFrame.Visible 
	local visualTotal: number = inventoryOpen and NumberOfHotbarSlots or FullHotbarSlots
	local visualIndex: number = 0

	for i: number = 1, NumberOfHotbarSlots do
		local slot: any = Slots[i]
		if slot.Tool or inventoryOpen then
			visualIndex = visualIndex + 1
			slot:Readjust(visualIndex, visualTotal)
			slot.Frame.Visible = true
		else
			slot.Frame.Visible = false
		end
	end
end

local function UpdateScrollingFrameCanvasSize(): ()
	local countX: number = math.floor(ScrollingFrame.AbsoluteSize.X / (ICON_SIZE_PIXELS + ICON_BUFFER_PIXELS))
	local maxRow: number = math.ceil((#UIGridFrame:GetChildren() - 1) / countX)
	local canvasSizeY: number = maxRow * (ICON_SIZE_PIXELS + ICON_BUFFER_PIXELS) + ICON_BUFFER_PIXELS
	ScrollingFrame.CanvasSize = UDim2.fromOffset(0, canvasSizeY)
end

local function AdjustInventoryFrames(): ()
	for i: number = NumberOfHotbarSlots + 1, #Slots do
		local slot: any = Slots[i]
		slot.Frame.LayoutOrder = slot.Index
		slot.Frame.Visible = (slot.Tool ~= nil)
	end
	UpdateScrollingFrameCanvasSize()
end

local function UpdateBackpackLayout(): ()
	HotbarFrame.Size = UDim2.new(
		0,
		ICON_BUFFER_PIXELS + (NumberOfHotbarSlots * (ICON_SIZE_PIXELS + ICON_BUFFER_PIXELS)),
		0,
		ICON_BUFFER_PIXELS + ICON_SIZE_PIXELS + ICON_BUFFER_PIXELS
	)
	HotbarFrame.Position = UDim2.new(0.5, -HotbarFrame.Size.X.Offset / 2, 1, -HotbarFrame.Size.Y.Offset)
	InventoryFrame.Size = UDim2.new(
		0,
		HotbarFrame.Size.X.Offset,
		0,
		(HotbarFrame.Size.Y.Offset * NumberOfInventoryRows)
			+ INVENTORY_HEADER_SIZE
			+ (IsVR and 2 * INVENTORY_ARROWS_BUFFER_VR or 0)
	)
	InventoryFrame.Position = UDim2.new(
		0.5,
		-InventoryFrame.Size.X.Offset / 2,
		1,
		HotbarFrame.Position.Y.Offset - InventoryFrame.Size.Y.Offset
	)

	ScrollingFrame.Size = UDim2.new(
		1,
		ScrollingFrame.ScrollBarThickness + 1,
		1,
		-INVENTORY_HEADER_SIZE - (IsVR and 2 * INVENTORY_ARROWS_BUFFER_VR or 0)
	)
	ScrollingFrame.Position = UDim2.fromOffset(0, INVENTORY_HEADER_SIZE + (IsVR and INVENTORY_ARROWS_BUFFER_VR or 0))
	AdjustHotbarFrames()
	AdjustInventoryFrames()
end

local function Clamp(low: number, high: number, num: number): number
	return math.min(high, math.max(low, num))
end

local function CheckBounds(guiObject: GuiObject, x: number, y: number): boolean
	local pos: Vector2 = guiObject.AbsolutePosition
	local size: Vector2 = guiObject.AbsoluteSize
	return (x > pos.X and x <= pos.X + size.X and y > pos.Y and y <= pos.Y + size.Y)
end

local function GetOffset(guiObject: GuiObject, point: Vector2): number
	local centerPoint: Vector2 = guiObject.AbsolutePosition + (guiObject.AbsoluteSize / 2)
	return (centerPoint - point).Magnitude
end

local function DisableActiveHopper(): () 
	ActiveHopper:ToggleSelect()
	SlotsByTool[ActiveHopper]:UpdateEquipView()
	ActiveHopper = nil :: any
end

local function UnequipAllTools(): () 
	if Humanoid then
		Humanoid:UnequipTools()
		if ActiveHopper then
			DisableActiveHopper()
		end
	end
end

local function EquipNewTool(tool: Tool): () 
	UnequipAllTools()
	Humanoid:EquipTool(tool) 
	
end

local function IsEquipped(tool: Tool): boolean
	return tool and tool.Parent == Character 
end

local function MakeSlot(parent: Instance, initIndex: number?): GuiObject
	local index: number = initIndex or (#Slots + 1)

	

	local slot: any = {}
	slot.Tool = nil :: any
	slot.Index = index :: number
	slot.Frame = nil :: any

	local SlotFrame: any = nil
	local FakeSlotFrame: Frame = nil
	local ToolIcon: ImageLabel = nil
	local ToolName: TextLabel = nil
	local ToolChangeConn: any = nil
	local HighlightFrame: any = nil 
	local SelectionObj: ImageLabel = nil

	
	local ToolTip: TextLabel = nil
	local SlotNumber: TextLabel = nil

	

	
	local function UpdateSlotFading(): ()
		SlotFrame.SelectionImageObject = nil
		SlotFrame.BackgroundTransparency = SlotFrame.Draggable and 0 or SLOT_LOCKED_TRANSPARENCY
	end

	
	function slot:Readjust(visualIndex: number, visualTotal: number): ...any 
		local centered: number = HotbarFrame.Size.X.Offset / 2
		local sizePlus: number = ICON_BUFFER_PIXELS + ICON_SIZE_PIXELS
		local midpointish: number = (visualTotal / 2) + 0.5
		local factor: number = visualIndex - midpointish
		SlotFrame.Position =
			UDim2.fromOffset(centered - (ICON_SIZE_PIXELS / 2) + (sizePlus * factor), ICON_BUFFER_PIXELS)
	end

	
	function slot:Fill(tool: Tool): ...any
		
		if not tool then
			return self:Clear()
		end

		self.Tool = tool :: Tool

		
		local function assignToolData(): ()
			local icon: string = tool.TextureId
			ToolIcon.Image = icon

			if icon ~= "" then
				
				ToolName.Visible = false
			else
				ToolName.Visible = true
			end

			ToolName.Text = tool.Name

			
			if ToolTip and tool:IsA("Tool") then 
				ToolTip.Text = tool.ToolTip
				ToolTip.Size = UDim2.fromOffset(0, TOOLTIP_HEIGHT)
				ToolTip.Position = UDim2.new(0.5, 0, 0, TOOLTIP_OFFSET)
			end
		end
		assignToolData()

		
		if ToolChangeConn then
			ToolChangeConn:Disconnect()
			ToolChangeConn = nil
		end

		
		ToolChangeConn = tool.Changed:Connect(function(property: string): ()
			if property == "TextureId" or property == "Name" or property == "ToolTip" then
				assignToolData()
			end
		end)

		local hotbarSlot: boolean = (self.Index <= NumberOfHotbarSlots)
		local inventoryOpen: boolean = InventoryFrame.Visible

		if (not hotbarSlot or inventoryOpen) and not UserInputService.VREnabled then
			SlotFrame.Draggable = true
		end

		self:UpdateEquipView()

		if hotbarSlot then
			FullHotbarSlots = FullHotbarSlots + 1
			
			if WholeThingEnabled and FullHotbarSlots >= 1 and not GamepadActionsBound then
				
				GamepadActionsBound = true
				ContextActionService:BindAction(
					"BackpackHotbarEquip",
					changeToolFunc,
					false,
					Enum.KeyCode.ButtonL1,
					Enum.KeyCode.ButtonR1
				)
			end
		end

		SlotsByTool[tool] = self
		LowestEmptySlot = FindLowestEmpty()
	end

	
	function slot:Clear(): ...any
		if not self.Tool then
			return
		end

		
		if ToolChangeConn then
			ToolChangeConn:Disconnect()
			ToolChangeConn = nil
		end

		ToolIcon.Image = ""
		ToolName.Text = ""
		if ToolTip then
			ToolTip.Text = ""
			ToolTip.Visible = false
		end
		SlotFrame.Draggable = false

		self:UpdateEquipView(true) 

		if self.Index <= NumberOfHotbarSlots then
			FullHotbarSlots = FullHotbarSlots - 1
			if FullHotbarSlots < 1 then
				
				GamepadActionsBound = false
				ContextActionService:UnbindAction("BackpackHotbarEquip")
			end
		end

		SlotsByTool[self.Tool] = nil
		self.Tool = nil
		LowestEmptySlot = FindLowestEmpty()
	end

	function slot:UpdateEquipView(unequippedOverride: boolean?): ...any
		local override = unequippedOverride or false
		if not override and IsEquipped(self.Tool) then 
			lastEquippedSlot = slot
			if not HighlightFrame then
				HighlightFrame = Instance.new("UIStroke")
				HighlightFrame.Name = "Border"
				HighlightFrame.Thickness = SLOT_EQUIP_THICKNESS
				HighlightFrame.Color = SLOT_EQUIP_COLOR
				HighlightFrame.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			end
			if LEGACY_EDGE_ENABLED == true then
				HighlightFrame.Parent = ToolIcon
			else
				HighlightFrame.Parent = SlotFrame
			end
		else 
			if HighlightFrame then
				HighlightFrame.Parent = nil
			end
		end
		UpdateSlotFading()
	end

	function slot:IsEquipped(): boolean
		return IsEquipped(self.Tool)
	end

	function slot:Delete(): ...any
		SlotFrame:Destroy() 
		table.remove(Slots, self.Index)
		local newSize: number = #Slots

		
		for slotIndex: number = self.Index :: number, newSize :: number do
			Slots[slotIndex]:SlideBack()
		end

		UpdateScrollingFrameCanvasSize()
	end

	function slot:Swap(targetSlot: any): ...any 
		local myTool: any, otherTool: any = self.Tool, targetSlot.Tool
		self:Clear()
		if otherTool then 
			targetSlot:Clear()
			self:Fill(otherTool)
		end
		if myTool then
			targetSlot:Fill(myTool)
		else
			targetSlot:Clear()
		end
	end

	function slot:SlideBack(): ...any 
		self.Index = self.Index - 1
		SlotFrame.Name = self.Index
		SlotFrame.LayoutOrder = self.Index
	end

	function slot:TurnNumber(on: boolean): ...any
		if SlotNumber then
			SlotNumber.Visible = on
		end
	end

	function slot:SetClickability(on: boolean): ...any 
		if self.Tool then
			if UserInputService.VREnabled then
				SlotFrame.Draggable = false
			else
				SlotFrame.Draggable = not on
			end
			UpdateSlotFading()
		end
	end

	function slot:CheckTerms(terms: any): number
		local hits: number = 0
		local function checkEm(str: string, term: any): ()
			local _, n: number = str:lower():gsub(term, "")
			hits = hits + n
		end
		local tool: Tool = self.Tool
		if tool then
			for term: any in pairs(terms) do
				checkEm(ToolName.Text, term)
				if tool:IsA("Tool") then 
					local toolTipText: string = ToolTip and ToolTip.Text or ""
					checkEm(toolTipText, term)
				end
			end
		end
		return hits
	end

	
	function slot:Select(): ...any
		local tool: Tool = slot.Tool
		if tool then
			if IsEquipped(tool) then 
				UnequipAllTools()
			elseif tool.Parent == Backpack then
				EquipNewTool(tool)
			end
		end
	end

	

	SlotFrame = Instance.new("TextButton")
	SlotFrame.Name = tostring(index)
	SlotFrame.BackgroundColor3 = BACKGROUND_COLOR
	SlotFrame.BorderColor3 = SLOT_BORDER_COLOR
	SlotFrame.Text = ""
	SlotFrame.BorderSizePixel = 0
	SlotFrame.Size = UDim2.fromOffset(ICON_SIZE_PIXELS, ICON_SIZE_PIXELS)
	SlotFrame.Active = true
	SlotFrame.Draggable = false
	SlotFrame.BackgroundTransparency = SLOT_LOCKED_TRANSPARENCY
	SlotFrame.MouseButton1Click:Connect(function(): ()
		changeSlot(slot)
	end)
	local searchFrameCorner: UICorner = Instance.new("UICorner")
	searchFrameCorner.Name = "Corner"
	searchFrameCorner.CornerRadius = SLOT_CORNER_RADIUS
	searchFrameCorner.Parent = SlotFrame
	slot.Frame = SlotFrame

	do
		local selectionObjectClipper: Frame = Instance.new("Frame")
		selectionObjectClipper.Name = "SelectionObjectClipper"
		selectionObjectClipper.BackgroundTransparency = 1
		selectionObjectClipper.Visible = false
		selectionObjectClipper.Parent = SlotFrame

		SelectionObj = Instance.new("ImageLabel")
		SelectionObj.Name = "Selector"
		SelectionObj.BackgroundTransparency = 1
		SelectionObj.Size = UDim2.fromScale(1, 1)
		SelectionObj.Image = "rbxasset://textures/ui/Keyboard/key_selection_9slice.png"
		SelectionObj.ScaleType = Enum.ScaleType.Slice
		SelectionObj.SliceCenter = Rect.new(12, 12, 52, 52)
		SelectionObj.Parent = selectionObjectClipper
	end

	ToolIcon = Instance.new("ImageLabel")
	ToolIcon.BackgroundTransparency = 1
	ToolIcon.Name = "Icon"
	ToolIcon.Size = UDim2.fromScale(1, 1)
	ToolIcon.Position = UDim2.fromScale(0.5, 0.5)
	ToolIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	if LEGACY_PADDING_ENABLED == true then
		ToolIcon.Size = UDim2.new(1, -SLOT_EQUIP_THICKNESS * 2, 1, -SLOT_EQUIP_THICKNESS * 2)
	else
		ToolIcon.Size = UDim2.fromScale(1, 1)
	end
	ToolIcon.Parent = SlotFrame

	local ToolIconCorner: UICorner = Instance.new("UICorner")
	ToolIconCorner.Name = "Corner"
	if LEGACY_PADDING_ENABLED == true then
		ToolIconCorner.CornerRadius = SLOT_CORNER_RADIUS - UDim.new(0, SLOT_EQUIP_THICKNESS)
	else
		ToolIconCorner.CornerRadius = SLOT_CORNER_RADIUS
	end
	ToolIconCorner.Parent = ToolIcon

	ToolName = Instance.new("TextLabel")
	ToolName.BackgroundTransparency = 1
	ToolName.Name = "ToolName"
	ToolName.Text = ""
	ToolName.TextColor3 = TEXT_COLOR
	ToolName.TextStrokeTransparency = TEXT_STROKE_TRANSPARENCY
	ToolName.TextStrokeColor3 = TEXT_STROKE_COLOR
	ToolName.FontFace = Font.new(FONT_FAMILY.Family, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	ToolName.TextSize = FONT_SIZE
	ToolName.Size = UDim2.new(1, -SLOT_EQUIP_THICKNESS * 2, 1, -SLOT_EQUIP_THICKNESS * 2)
	ToolName.Position = UDim2.fromScale(0.5, 0.5)
	ToolName.AnchorPoint = Vector2.new(0.5, 0.5)
	ToolName.TextWrapped = true
	ToolName.TextTruncate = Enum.TextTruncate.AtEnd
	ToolName.Parent = SlotFrame

	slot.Frame.LayoutOrder = slot.Index

	if index <= NumberOfHotbarSlots then 
		
		ToolTip = Instance.new("TextLabel")
		ToolTip.Name = "ToolTip"
		ToolTip.Text = ""
		ToolTip.Size = UDim2.fromScale(1, 1)
		ToolTip.TextColor3 = TEXT_COLOR
		ToolTip.TextStrokeTransparency = TEXT_STROKE_TRANSPARENCY
		ToolTip.TextStrokeColor3 = TEXT_STROKE_COLOR
		ToolTip.FontFace = Font.new(FONT_FAMILY.Family, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
		ToolTip.TextSize = FONT_SIZE
		ToolTip.ZIndex = 2
		ToolTip.TextWrapped = false
		ToolTip.TextYAlignment = Enum.TextYAlignment.Center
		ToolTip.BackgroundColor3 = TOOLTIP_BACKGROUND_COLOR
		ToolTip.BackgroundTransparency = SLOT_LOCKED_TRANSPARENCY
		ToolTip.AnchorPoint = Vector2.new(0.5, 1)
		ToolTip.BorderSizePixel = 0
		ToolTip.Visible = false
		ToolTip.AutomaticSize = Enum.AutomaticSize.X
		ToolTip.Parent = SlotFrame

		local ToolTipCorner: UICorner = Instance.new("UICorner")
		ToolTipCorner.Name = "Corner"
		ToolTipCorner.CornerRadius = TOOLTIP_CORNER_RADIUS
		ToolTipCorner.Parent = ToolTip

		local ToolTipPadding: UIPadding = Instance.new("UIPadding")
		ToolTipPadding.PaddingLeft = UDim.new(0, TOOLTIP_PADDING)
		ToolTipPadding.PaddingRight = UDim.new(0, TOOLTIP_PADDING)
		ToolTipPadding.PaddingTop = UDim.new(0, TOOLTIP_PADDING)
		ToolTipPadding.PaddingBottom = UDim.new(0, TOOLTIP_PADDING)
		ToolTipPadding.Parent = ToolTip
		SlotFrame.MouseEnter:Connect(function(): ()
			if ToolTip.Text ~= "" then
				ToolTip.Visible = true
			end
		end)
		SlotFrame.MouseLeave:Connect(function(): ()
			ToolTip.Visible = false
		end)

		function slot:MoveToInventory(): ...any
			if slot.Index <= NumberOfHotbarSlots then 
				local tool: any = slot.Tool
				self:Clear() 
				local newSlot: any = MakeSlot(UIGridFrame)
				newSlot:Fill(tool)
				if IsEquipped(tool) then 
					UnequipAllTools()
				end
				
				if ViewingSearchResults then
					newSlot.Frame.Visible = false
					newSlot.Parent = InventoryFrame
				end
			end
		end

		
		if index < 10 or index == NumberOfHotbarSlots then 
			local slotNum: number = (index < 10) and index or 0
			SlotNumber = Instance.new("TextLabel")
			SlotNumber.BackgroundTransparency = 1
			SlotNumber.Name = "Number"
			SlotNumber.TextColor3 = TEXT_COLOR
			SlotNumber.TextStrokeTransparency = TEXT_STROKE_TRANSPARENCY
			SlotNumber.TextStrokeColor3 = TEXT_STROKE_COLOR
			SlotNumber.TextSize = FONT_SIZE
			SlotNumber.Text = tostring(slotNum)
			SlotNumber.FontFace = Font.new(FONT_FAMILY.Family, Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
			SlotNumber.Size = UDim2.fromScale(0.4, 0.4)
			SlotNumber.Visible = false
			SlotNumber.Parent = SlotFrame
			HotkeyFns[ZERO_KEY_VALUE + slotNum] = slot.Select
		end
	end

	do 
		local startPoint: UDim2 = SlotFrame.Position
		local lastUpTime: number = 0
		local startParent: any = nil

		SlotFrame.DragBegin:Connect(function(dragPoint: UDim2): ()
			Dragging[SlotFrame] = true
			startPoint = dragPoint

			SlotFrame.BorderSizePixel = 2
			inventoryIcon:lock()

			
			SlotFrame.ZIndex = 2
			ToolIcon.ZIndex = 2
			ToolName.ZIndex = 2
			SlotFrame.Parent.ZIndex = 2
			if SlotNumber then
				SlotNumber.ZIndex = 2
			end
			
			
			
			
			
			

			
			startParent = SlotFrame.Parent
			if startParent == UIGridFrame then
				local newPosition: UDim2 = UDim2.new(
					0,
					SlotFrame.AbsolutePosition.X - InventoryFrame.AbsolutePosition.X,
					0,
					SlotFrame.AbsolutePosition.Y - InventoryFrame.AbsolutePosition.Y
				)
				SlotFrame.Parent = InventoryFrame
				SlotFrame.Position = newPosition

				FakeSlotFrame = Instance.new("Frame")
				FakeSlotFrame.Name = "FakeSlot"
				FakeSlotFrame.LayoutOrder = SlotFrame.LayoutOrder
				FakeSlotFrame.Size = SlotFrame.Size
				FakeSlotFrame.BackgroundTransparency = 1
				FakeSlotFrame.Parent = UIGridFrame
			end
		end)

		SlotFrame.DragStopped:Connect(function(x: number, y: number): ()
			if FakeSlotFrame then
				FakeSlotFrame:Destroy()
			end

			local now: number = os.clock()

			SlotFrame.Position = startPoint
			SlotFrame.Parent = startParent

			SlotFrame.BorderSizePixel = 0
			inventoryIcon:unlock()

			
			SlotFrame.ZIndex = 1
			ToolIcon.ZIndex = 1
			ToolName.ZIndex = 1
			startParent.ZIndex = 1

			if SlotNumber then
				SlotNumber.ZIndex = 1
			end
			
			
			
			
			
			

			Dragging[SlotFrame] = nil

			
			if not slot.Tool then
				return
			end

			
			if CheckBounds(InventoryFrame, x, y) then
				if slot.Index <= NumberOfHotbarSlots then
					slot:MoveToInventory()
				end
				
				if slot.Index > NumberOfHotbarSlots and now - lastUpTime < DOUBLE_CLICK_TIME then
					if LowestEmptySlot then
						local myTool: any = slot.Tool
						slot:Clear()
						LowestEmptySlot:Fill(myTool)
						slot:Delete()
					end
					now = 0 
				end
			elseif CheckBounds(HotbarFrame, x, y) then
				local closest: { number } = { math.huge, nil :: any }
				for i: number = 1, NumberOfHotbarSlots do
					local otherSlot: any = Slots[i]
					local offset: number = GetOffset(otherSlot.Frame, Vector2.new(x, y))
					if offset < closest[1] then
						closest = { offset, otherSlot }
					end
				end
				local closestSlot: any = closest[2]
				if closestSlot ~= slot then
					slot:Swap(closestSlot)
					if slot.Index > NumberOfHotbarSlots then
						local tool: Tool = slot.Tool
						if not tool then 
							slot:Delete()
						else 
							if IsEquipped(tool) then 
								UnequipAllTools()
							end
							
							if ViewingSearchResults then
								slot.Frame.Visible = false
								slot.Frame.Parent = InventoryFrame
							end
						end
					end
				end
			else
				
				
				
				
				
				if slot.Index <= NumberOfHotbarSlots then
					slot:MoveToInventory() 
				end
			end

			lastUpTime = now
		end)
	end

	
	SlotFrame.Parent = parent
	Slots[index] = slot

	if index > NumberOfHotbarSlots then
		UpdateScrollingFrameCanvasSize()
		
		if InventoryFrame.Visible and not ViewingSearchResults then
			local offset: number = ScrollingFrame.CanvasSize.Y.Offset - ScrollingFrame.AbsoluteSize.Y
			ScrollingFrame.CanvasPosition = Vector2.new(0, math.max(0, offset))
		end
	end

	return slot
end

local function OnChildAdded(child: Instance): () 
	if not child:IsA("Tool") and not child:IsA("HopperBin") then 
		if child:IsA("Humanoid") and child.Parent == Character then
			Humanoid = child
		end
		return
	end
	local tool: any = child

	if tool.Parent == Character then
		ShowVRBackpackPopup()
	end

	if ActiveHopper and tool.Parent == Character then 
		DisableActiveHopper()
	end

	
	if not StarterToolFound and tool.Parent == Character and not SlotsByTool[tool] then
		local starterGear: Instance? = Player:FindFirstChild("StarterGear")
		if starterGear then
			if starterGear:FindFirstChild(tool.Name) then
				StarterToolFound = true
				local slot: any = LowestEmptySlot or MakeSlot(UIGridFrame)
				for i: number = slot.Index, 1, -1 do
					local curr = Slots[i] 
					local pIndex: number = i - 1
					if pIndex > 0 then
						local prev = Slots[pIndex] 
						prev:Swap(curr)
					else
						curr:Fill(tool)
					end
				end
				
				for _, children: Instance in pairs(Character:GetChildren()) do
					if children:IsA("Tool") and children ~= tool then
						children.Parent = Backpack
					end
				end
				AdjustHotbarFrames()
				return 
			end
		end
	end

	
	local slot: any = SlotsByTool[tool]
	if slot then
		slot:UpdateEquipView()
	else 
		slot = LowestEmptySlot or MakeSlot(UIGridFrame)
		slot:Fill(tool)
		if slot.Index <= NumberOfHotbarSlots and not InventoryFrame.Visible then
			AdjustHotbarFrames()
		end
		if tool:IsA("HopperBin") then 
			if tool.Active then
				UnequipAllTools()
				ActiveHopper = tool
			end
		end
	end

	BackpackScript.BackpackItemAdded:Fire()
end

local function OnChildRemoved(child: Instance): () 
	if not child:IsA("Tool") and not child:IsA("HopperBin") then 
		return
	end
	local tool: Tool | any = child

	ShowVRBackpackPopup()

	
	local newParent: any = tool.Parent
	if newParent == Character or newParent == Backpack then
		return
	end

	local slot: any = SlotsByTool[tool]
	if slot then
		slot:Clear()
		if slot.Index > NumberOfHotbarSlots then 
			slot:Delete()
		elseif not InventoryFrame.Visible then
			AdjustHotbarFrames()
		end
	end

	if tool :: any == ActiveHopper then 
		ActiveHopper = nil :: any
	end

	BackpackScript.BackpackItemRemoved:Fire()
	if isInventoryEmpty() then
		BackpackScript.BackpackEmpty:Fire()
	end
end

local function OnCharacterAdded(character: Model): ()
	
	for i: number = #Slots, 1, -1 do
		local slot = Slots[i]
		if slot.Tool then
			slot:Clear()
		end
		if i > NumberOfHotbarSlots then
			slot:Delete()
		end
	end
	ActiveHopper = nil :: any 

	
	for _, conn: RBXScriptConnection in pairs(CharConns) do
		conn:Disconnect()
	end
	CharConns = {}

	
	Character = character
	table.insert(CharConns, character.ChildRemoved:Connect(OnChildRemoved))
	table.insert(CharConns, character.ChildAdded:Connect(OnChildAdded))
	for _, child: Instance in pairs(character:GetChildren()) do
		OnChildAdded(child)
	end
	

	
	Backpack = Player:WaitForChild("Backpack")
	table.insert(CharConns, Backpack.ChildRemoved:Connect(OnChildRemoved))
	table.insert(CharConns, Backpack.ChildAdded:Connect(OnChildAdded))
	for _, child: Instance in pairs(Backpack:GetChildren()) do
		OnChildAdded(child)
	end

	AdjustHotbarFrames()
end

local function OnInputBegan(input: InputObject, isProcessed: boolean): ()
	local ChatInputBarConfiguration =
		TextChatService:FindFirstChildOfClass("ChatInputBarConfiguration") :: ChatInputBarConfiguration
	
	if
		input.UserInputType == Enum.UserInputType.Keyboard
		and not TextBoxFocused
		and not ChatInputBarConfiguration.IsFocused
		and (WholeThingEnabled or input.KeyCode.Value == DROP_HOTKEY_VALUE)
	then
		local hotkeyBehavior: any = HotkeyFns[input.KeyCode.Value]
		if hotkeyBehavior then
			hotkeyBehavior(isProcessed)
		end
	end

	local inputType: Enum.UserInputType = input.UserInputType
	if not isProcessed then
		if inputType == Enum.UserInputType.MouseButton1 or inputType == Enum.UserInputType.Touch then
			if InventoryFrame.Visible then
				inventoryIcon:deselect()
			end
		end
	end
end

local function OnUISChanged(): ()
	
	if UserInputService:GetLastInputType() == Enum.UserInputType.Touch then
		for i: number = 1, NumberOfHotbarSlots do
			Slots[i]:TurnNumber(false)
		end
		return
	end

	
	if UserInputService:GetLastInputType() == Enum.UserInputType.Keyboard then
		for i: number = 1, NumberOfHotbarSlots do
			Slots[i]:TurnNumber(true)
		end
		return
	end

	
	for _, mouse: any in pairs(MOUSE_INPUT_TYPES) do
		if UserInputService:GetLastInputType() == mouse then
			for i: number = 1, NumberOfHotbarSlots do
				Slots[i]:TurnNumber(true)
			end
			return
		end
	end

	
	for _, gamepad: any in pairs(GAMEPAD_INPUT_TYPES) do
		if UserInputService:GetLastInputType() == gamepad then
			for i: number = 1, NumberOfHotbarSlots do
				Slots[i]:TurnNumber(false)
			end
			return
		end
	end
end

local lastChangeToolInputObject: InputObject = nil
local lastChangeToolInputTime: number = nil
local maxEquipDeltaTime: number = 0.06
local noOpFunc = function() end

function unbindAllGamepadEquipActions(): ()
	ContextActionService:UnbindAction("BackpackHasGamepadFocus")
	ContextActionService:UnbindAction("BackpackCloseInventory")
end

changeToolFunc = function(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject): ()
	if inputState ~= Enum.UserInputState.Begin then
		return
	end

	if lastChangeToolInputObject then
		if
			(
				lastChangeToolInputObject.KeyCode == Enum.KeyCode.ButtonR1
				and inputObject.KeyCode == Enum.KeyCode.ButtonL1
			)
			or (
				lastChangeToolInputObject.KeyCode == Enum.KeyCode.ButtonL1
				and inputObject.KeyCode == Enum.KeyCode.ButtonR1
			)
		then
			if (os.clock() - lastChangeToolInputTime) <= maxEquipDeltaTime then
				UnequipAllTools()
				lastChangeToolInputObject = inputObject
				lastChangeToolInputTime = os.clock()
				return
			end
		end
	end

	lastChangeToolInputObject = inputObject
	lastChangeToolInputTime = os.clock()

	task.delay(maxEquipDeltaTime, function(): ()
		if lastChangeToolInputObject ~= inputObject then
			return
		end

		local moveDirection: number = 0
		if inputObject.KeyCode == Enum.KeyCode.ButtonL1 then
			moveDirection = -1
		else
			moveDirection = 1
		end

		for i: number = 1, NumberOfHotbarSlots do
			local hotbarSlot: any = Slots[i]
			if hotbarSlot:IsEquipped() then
				local newSlotPosition: number = moveDirection + i
				local hitEdge: boolean = false
				if newSlotPosition > NumberOfHotbarSlots then
					newSlotPosition = 1
					hitEdge = true
				elseif newSlotPosition < 1 then
					newSlotPosition = NumberOfHotbarSlots
					hitEdge = true
				end

				local origNewSlotPos: number = newSlotPosition
				while not Slots[newSlotPosition].Tool do
					newSlotPosition = newSlotPosition + moveDirection
					if newSlotPosition == origNewSlotPos then
						return
					end

					if newSlotPosition > NumberOfHotbarSlots then
						newSlotPosition = 1
						hitEdge = true
					elseif newSlotPosition < 1 then
						newSlotPosition = NumberOfHotbarSlots
						hitEdge = true
					end
				end

				if hitEdge then
					UnequipAllTools()
					lastEquippedSlot = nil
				else
					Slots[newSlotPosition]:Select()
				end
				return
			end
		end

		if lastEquippedSlot and lastEquippedSlot.Tool then
			lastEquippedSlot:Select()
			return
		end

		local startIndex: number = moveDirection == -1 and NumberOfHotbarSlots or 1
		local endIndex: number = moveDirection == -1 and 1 or NumberOfHotbarSlots
		for i: number = startIndex, endIndex, moveDirection do
			if Slots[i].Tool then
				Slots[i]:Select()
				return
			end
		end
	end)
end

function getGamepadSwapSlot(): any
	for i: number = 1, #Slots do
		if Slots[i].Frame.BorderSizePixel > 0 then
			return Slots[i]
		end
	end
	return
end

function changeSlot(slot: any): ()
	local swapInVr: boolean = not VRService.VREnabled or InventoryFrame.Visible

	if slot.Frame == GuiService.SelectedObject and swapInVr then
		local currentlySelectedSlot: any = getGamepadSwapSlot()

		if currentlySelectedSlot then
			currentlySelectedSlot.Frame.BorderSizePixel = 0
			if currentlySelectedSlot ~= slot then
				slot:Swap(currentlySelectedSlot)
				VRInventorySelector.SelectionImageObject.Visible = false

				if slot.Index > NumberOfHotbarSlots and not slot.Tool then
					if GuiService.SelectedObject == slot.Frame then
						GuiService.SelectedObject = currentlySelectedSlot.Frame
					end
					slot:Delete()
				end

				if currentlySelectedSlot.Index > NumberOfHotbarSlots and not currentlySelectedSlot.Tool then
					if GuiService.SelectedObject == currentlySelectedSlot.Frame then
						GuiService.SelectedObject = slot.Frame
					end
					currentlySelectedSlot:Delete()
				end
			end
		else
			local startSize: UDim2 = slot.Frame.Size
			local startPosition: UDim2 = slot.Frame.Position
			slot.Frame:TweenSizeAndPosition(
				startSize + UDim2.fromOffset(10, 10),
				startPosition - UDim2.fromOffset(5, 5),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.1,
				true,
				function(): ()
					slot.Frame:TweenSizeAndPosition(
						startSize,
						startPosition,
						Enum.EasingDirection.In,
						Enum.EasingStyle.Quad,
						0.1,
						true
					)
				end
			)
			slot.Frame.BorderSizePixel = 3
			VRInventorySelector.SelectionImageObject.Visible = true
		end
	else
		slot:Select()
		VRInventorySelector.SelectionImageObject.Visible = false
	end
end

function vrMoveSlotToInventory(): ()
	if not VRService.VREnabled then
		return
	end

	local currentlySelectedSlot: any = getGamepadSwapSlot()
	if currentlySelectedSlot and currentlySelectedSlot.Tool then
		currentlySelectedSlot.Frame.BorderSizePixel = 0
		currentlySelectedSlot:MoveToInventory()
		VRInventorySelector.SelectionImageObject.Visible = false
	end
end

function enableGamepadInventoryControl(): ()
	local goBackOneLevel = function(): ()
		
		
		

		local selectedSlot: any = getGamepadSwapSlot()
		if selectedSlot then
			
			local selectedSlot: any = getGamepadSwapSlot()
			if selectedSlot then
				selectedSlot.Frame.BorderSizePixel = 0
				return
			end
		elseif InventoryFrame.Visible then
			inventoryIcon:deselect()
		end
	end

	ContextActionService:BindAction("BackpackHasGamepadFocus", noOpFunc, false, Enum.UserInputType.Gamepad1)
	ContextActionService:BindAction(
		"BackpackCloseInventory",
		goBackOneLevel,
		false,
		Enum.KeyCode.ButtonB,
		Enum.KeyCode.ButtonStart
	)

	
	if not UseGazeSelection() then
		GuiService.SelectedObject = HotbarFrame:FindFirstChild("1")
	end
end

function disableGamepadInventoryControl(): ()
	unbindAllGamepadEquipActions()

	for i: number = 1, NumberOfHotbarSlots do
		local hotbarSlot: any = Slots[i]
		if hotbarSlot and hotbarSlot.Frame then
			hotbarSlot.Frame.BorderSizePixel = 0
		end
	end

	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(MainFrame) then
		GuiService.SelectedObject = nil
	end
end

local function bindBackpackHotbarAction(): ()
	if WholeThingEnabled and not GamepadActionsBound then
		GamepadActionsBound = true
		ContextActionService:BindAction(
			"BackpackHotbarEquip",
			changeToolFunc,
			false,
			Enum.KeyCode.ButtonL1,
			Enum.KeyCode.ButtonR1
		)
	end
end

local function unbindBackpackHotbarAction(): ()
	disableGamepadInventoryControl()
	GamepadActionsBound = false
	ContextActionService:UnbindAction("BackpackHotbarEquip")
end

function gamepadDisconnected(): ()
	GamepadEnabled = false
	disableGamepadInventoryControl()
end

function gamepadConnected(): ()
	GamepadEnabled = true
	GuiService:AddSelectionParent("BackpackSelection", MainFrame)

	if FullHotbarSlots >= 1 then
		bindBackpackHotbarAction()
	end

	if InventoryFrame.Visible then
		enableGamepadInventoryControl()
	end
end

local function OnIconChanged(enabled: boolean): ()
	
	local success, _topbarEnabled = pcall(function()
		return enabled and StarterGui:GetCore("TopbarEnabled")
	end)

	if not success then
		return
	end

	WholeThingEnabled = enabled
	MainFrame.Visible = enabled

	
	
	
	
	
	
	
	

	if enabled then
		if FullHotbarSlots >= 1 then
			bindBackpackHotbarAction()
		end
	else
		unbindBackpackHotbarAction()
	end
end

local function MakeVRRoundButton(name: string, image: string): (ImageButton, ImageLabel, ImageLabel)
	local newButton: ImageButton = Instance.new("ImageButton")
	newButton.BackgroundTransparency = 1
	newButton.Name = name
	newButton.Size = UDim2.fromOffset(40, 40)
	newButton.Image = "rbxasset://textures/ui/Keyboard/close_button_background.png"

	local buttonIcon: ImageLabel = Instance.new("ImageLabel")
	buttonIcon.Name = "Icon"
	buttonIcon.BackgroundTransparency = 1
	buttonIcon.Size = UDim2.fromScale(0.5, 0.5)
	buttonIcon.Position = UDim2.fromScale(0.25, 0.25)
	buttonIcon.Image = image
	buttonIcon.Parent = newButton

	local buttonSelectionObject: ImageLabel = Instance.new("ImageLabel")
	buttonSelectionObject.BackgroundTransparency = 1
	buttonSelectionObject.Name = "Selection"
	buttonSelectionObject.Size = UDim2.fromScale(0.9, 0.9)
	buttonSelectionObject.Position = UDim2.fromScale(0.05, 0.05)
	buttonSelectionObject.Image = "rbxasset://textures/ui/Keyboard/close_button_selection.png"
	newButton.SelectionImageObject = buttonSelectionObject

	return newButton, buttonIcon, buttonSelectionObject
end

MainFrame = Instance.new("Frame")
MainFrame.BackgroundTransparency = 1
MainFrame.Name = "Backpack"
MainFrame.Size = UDim2.fromScale(1, 1)
MainFrame.Visible = false
MainFrame.Parent = BackpackGui

HotbarFrame = Instance.new("Frame")
HotbarFrame.BackgroundTransparency = 1
HotbarFrame.Name = "Hotbar"
HotbarFrame.Size = UDim2.fromScale(1, 1)
HotbarFrame.Parent = MainFrame

for index: number = 1, NumberOfHotbarSlots do
	local slot: any = MakeSlot(HotbarFrame, index)
	slot.Frame.Visible = false

	if not LowestEmptySlot then
		LowestEmptySlot = slot
	end
end

local LeftBumperButton: ImageLabel = Instance.new("ImageLabel")
LeftBumperButton.BackgroundTransparency = 1
LeftBumperButton.Name = "LeftBumper"
LeftBumperButton.Size = UDim2.fromOffset(40, 40)
LeftBumperButton.Position = UDim2.new(0, -LeftBumperButton.Size.X.Offset, 0.5, -LeftBumperButton.Size.Y.Offset / 2)

local RightBumperButton: ImageLabel = Instance.new("ImageLabel")
RightBumperButton.BackgroundTransparency = 1
RightBumperButton.Name = "RightBumper"
RightBumperButton.Size = UDim2.fromOffset(40, 40)
RightBumperButton.Position = UDim2.new(1, 0, 0.5, -RightBumperButton.Size.Y.Offset / 2)

InventoryFrame = Instance.new("Frame")
InventoryFrame.Name = "Inventory"
InventoryFrame.Size = UDim2.fromScale(1, 1)
InventoryFrame.BackgroundTransparency = BACKGROUND_TRANSPARENCY
InventoryFrame.BackgroundColor3 = BACKGROUND_COLOR
InventoryFrame.Active = true
InventoryFrame.Visible = false
InventoryFrame.Parent = MainFrame

local corner: UICorner = Instance.new("UICorner")
corner.Name = "Corner"
corner.CornerRadius = BACKGROUND_CORNER_RADIUS
corner.Parent = InventoryFrame

VRInventorySelector = Instance.new("TextButton")
VRInventorySelector.Name = "VRInventorySelector"
VRInventorySelector.Position = UDim2.new(0, 0, 0, 0)
VRInventorySelector.Size = UDim2.fromScale(1, 1)
VRInventorySelector.BackgroundTransparency = 1
VRInventorySelector.Text = ""
VRInventorySelector.Parent = InventoryFrame

local selectorImage: ImageLabel = Instance.new("ImageLabel")
selectorImage.BackgroundTransparency = 1
selectorImage.Name = "Selector"
selectorImage.Size = UDim2.fromScale(1, 1)
selectorImage.Image = "rbxasset://textures/ui/Keyboard/key_selection_9slice.png"
selectorImage.ScaleType = Enum.ScaleType.Slice
selectorImage.SliceCenter = Rect.new(12, 12, 52, 52)
selectorImage.Visible = false
VRInventorySelector.SelectionImageObject = selectorImage

VRInventorySelector.MouseButton1Click:Connect(function(): ()
	vrMoveSlotToInventory()
end)

ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.Name = "ScrollingFrame"
ScrollingFrame.Size = UDim2.fromScale(1, 1)
ScrollingFrame.Selectable = false
ScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 8
ScrollingFrame.ScrollBarImageColor3 = Color3.new(1, 1, 1)
ScrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.Parent = InventoryFrame

UIGridFrame = Instance.new("Frame")
UIGridFrame.BackgroundTransparency = 1
UIGridFrame.Name = "UIGridFrame"
UIGridFrame.Selectable = false
UIGridFrame.Size = UDim2.new(1, -(ICON_BUFFER_PIXELS * 2), 1, 0)
UIGridFrame.Position = UDim2.fromOffset(ICON_BUFFER_PIXELS, 0)
UIGridFrame.Parent = ScrollingFrame

UIGridLayout = Instance.new("UIGridLayout")
UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIGridLayout.CellSize = UDim2.fromOffset(ICON_SIZE_PIXELS, ICON_SIZE_PIXELS)
UIGridLayout.CellPadding = UDim2.fromOffset(ICON_BUFFER_PIXELS, ICON_BUFFER_PIXELS)
UIGridLayout.Parent = UIGridFrame

ScrollUpInventoryButton = MakeVRRoundButton("ScrollUpButton", "rbxasset://textures/ui/Backpack/ScrollUpArrow.png")
ScrollUpInventoryButton.Size = UDim2.fromOffset(34, 34)
ScrollUpInventoryButton.Position =
	UDim2.new(0.5, -ScrollUpInventoryButton.Size.X.Offset / 2, 0, INVENTORY_HEADER_SIZE + 3)
ScrollUpInventoryButton.Icon.Position = ScrollUpInventoryButton.Icon.Position - UDim2.fromOffset(0, 2)
ScrollUpInventoryButton.MouseButton1Click:Connect(function(): ()
	ScrollingFrame.CanvasPosition = Vector2.new(
		ScrollingFrame.CanvasPosition.X,
		Clamp(
			0,
			ScrollingFrame.CanvasSize.Y.Offset - ScrollingFrame.AbsoluteWindowSize.Y,
			ScrollingFrame.CanvasPosition.Y - (ICON_BUFFER_PIXELS + ICON_SIZE_PIXELS)
		)
	)
end)

ScrollDownInventoryButton = MakeVRRoundButton("ScrollDownButton", "rbxasset://textures/ui/Backpack/ScrollUpArrow.png")
ScrollDownInventoryButton.Rotation = 180
ScrollDownInventoryButton.Icon.Position = ScrollDownInventoryButton.Icon.Position - UDim2.fromOffset(0, 2)
ScrollDownInventoryButton.Size = UDim2.fromOffset(34, 34)
ScrollDownInventoryButton.Position =
	UDim2.new(0.5, -ScrollDownInventoryButton.Size.X.Offset / 2, 1, -ScrollDownInventoryButton.Size.Y.Offset - 3)
ScrollDownInventoryButton.MouseButton1Click:Connect(function(): ()
	ScrollingFrame.CanvasPosition = Vector2.new(
		ScrollingFrame.CanvasPosition.X,
		Clamp(
			0,
			ScrollingFrame.CanvasSize.Y.Offset - ScrollingFrame.AbsoluteWindowSize.Y,
			ScrollingFrame.CanvasPosition.Y + (ICON_BUFFER_PIXELS + ICON_SIZE_PIXELS)
		)
	)
end)

ScrollingFrame.Changed:Connect(function(prop: string): ()
	if prop == "AbsoluteWindowSize" or prop == "CanvasPosition" or prop == "CanvasSize" then
		local canScrollUp: boolean = ScrollingFrame.CanvasPosition.Y ~= 0
		local canScrollDown: boolean = ScrollingFrame.CanvasPosition.Y
			< ScrollingFrame.CanvasSize.Y.Offset - ScrollingFrame.AbsoluteWindowSize.Y

		ScrollUpInventoryButton.Visible = canScrollUp
		ScrollDownInventoryButton.Visible = canScrollDown
	end
end)

UpdateBackpackLayout()

local gamepadHintsFrame: Frame = Instance.new("Frame")
gamepadHintsFrame.Name = "GamepadHintsFrame"
gamepadHintsFrame.Size = UDim2.fromOffset(HotbarFrame.Size.X.Offset, (IsTenFootInterface and 95 or 60))
gamepadHintsFrame.BackgroundTransparency = BACKGROUND_TRANSPARENCY
gamepadHintsFrame.BackgroundColor3 = BACKGROUND_COLOR
gamepadHintsFrame.Visible = false
gamepadHintsFrame.Parent = MainFrame

local gamepadHintsFrameLayout: UIListLayout = Instance.new("UIListLayout")
gamepadHintsFrameLayout.Name = "Layout"
gamepadHintsFrameLayout.Padding = UDim.new(0, 25)
gamepadHintsFrameLayout.FillDirection = Enum.FillDirection.Horizontal
gamepadHintsFrameLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
gamepadHintsFrameLayout.SortOrder = Enum.SortOrder.LayoutOrder
gamepadHintsFrameLayout.Parent = gamepadHintsFrame

local gamepadHintsFrameCorner: UICorner = Instance.new("UICorner")
gamepadHintsFrameCorner.Name = "Corner"
gamepadHintsFrameCorner.CornerRadius = BACKGROUND_CORNER_RADIUS
gamepadHintsFrameCorner.Parent = gamepadHintsFrame

local function addGamepadHint(hintImageString: string, hintTextString: string): ()
	local hintFrame: Frame = Instance.new("Frame")
	hintFrame.Name = "HintFrame"
	hintFrame.AutomaticSize = Enum.AutomaticSize.XY
	hintFrame.BackgroundTransparency = 1
	hintFrame.Parent = gamepadHintsFrame

	local hintLayout: UIListLayout = Instance.new("UIListLayout")
	hintLayout.Name = "Layout"
	hintLayout.Padding = (IsTenFootInterface and UDim.new(0, 20) or UDim.new(0, 12))
	hintLayout.FillDirection = Enum.FillDirection.Horizontal
	hintLayout.SortOrder = Enum.SortOrder.LayoutOrder
	hintLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	hintLayout.Parent = hintFrame

	local hintImage: ImageLabel = Instance.new("ImageLabel")
	hintImage.Name = "HintImage"
	hintImage.Size = (IsTenFootInterface and UDim2.fromOffset(60, 60) or UDim2.fromOffset(30, 30))
	hintImage.BackgroundTransparency = 1
	hintImage.Image = hintImageString
	hintImage.Parent = hintFrame

	local hintText: TextLabel = Instance.new("TextLabel")
	hintText.Name = "HintText"
	hintText.AutomaticSize = Enum.AutomaticSize.XY
	hintText.FontFace = Font.new(FONT_FAMILY.Family, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	hintText.TextSize = (IsTenFootInterface and 32 or 19)
	hintText.BackgroundTransparency = 1
	hintText.Text = hintTextString
	hintText.TextColor3 = Color3.new(1, 1, 1)
	hintText.TextXAlignment = Enum.TextXAlignment.Left
	hintText.TextYAlignment = Enum.TextYAlignment.Center
	hintText.TextWrapped = true
	hintText.Parent = hintFrame

	local textSizeConstraint: UITextSizeConstraint = Instance.new("UITextSizeConstraint")
	textSizeConstraint.MaxTextSize = hintText.TextSize
	textSizeConstraint.Parent = hintText
end

addGamepadHint(UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonX), "Remove From Hotbar")
addGamepadHint(UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonA), "Select/Swap")
addGamepadHint(UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonB), "Close Backpack")

local function resizeGamepadHintsFrame(): ()
	gamepadHintsFrame.Size =
		UDim2.new(HotbarFrame.Size.X.Scale, HotbarFrame.Size.X.Offset, 0, (IsTenFootInterface and 95 or 60))
	gamepadHintsFrame.Position = UDim2.new(
		HotbarFrame.Position.X.Scale,
		HotbarFrame.Position.X.Offset,
		InventoryFrame.Position.Y.Scale,
		InventoryFrame.Position.Y.Offset - gamepadHintsFrame.Size.Y.Offset - ICON_BUFFER_PIXELS
	)

	local spaceTaken: number = 0

	local gamepadHints: { Instance } = gamepadHintsFrame:GetChildren()
	local filteredGamepadHints: any = {}

	for _, child: Instance in pairs(gamepadHints) do
		if child:IsA("GuiObject") then
			table.insert(filteredGamepadHints, child)
		end
	end

	
	for guiObjects = 1, #filteredGamepadHints do
		if filteredGamepadHints[guiObjects]:IsA("GuiObject") then
			filteredGamepadHints[guiObjects].Size = UDim2.new(1, 0, 1, -5)
			filteredGamepadHints[guiObjects].Position = UDim2.new(0, 0, 0, 0)
			spaceTaken = spaceTaken
				+ (
					filteredGamepadHints[guiObjects].HintText.Position.X.Offset
					+ filteredGamepadHints[guiObjects].HintText.TextBounds.X
				)
		end
	end

	
	local spaceBetweenElements: number = (gamepadHintsFrame.AbsoluteSize.X - spaceTaken) / (#filteredGamepadHints - 1)
	for i: number = 1, #filteredGamepadHints do
		filteredGamepadHints[i].Position = (
			i == 1 and UDim2.new(0, 0, 0, 0)
			or UDim2.new(
				0,
				filteredGamepadHints[i - 1].Position.X.Offset
					+ filteredGamepadHints[i - 1].Size.X.Offset
					+ spaceBetweenElements,
				0,
				0
			)
		)
		filteredGamepadHints[i].Size = UDim2.new(
			0,
			(filteredGamepadHints[i].HintText.Position.X.Offset + filteredGamepadHints[i].HintText.TextBounds.X),
			1,
			-5
		)
	end
end

local searchFrame: Frame = Instance.new("Frame")
do 
	searchFrame.Name = "Search"
	searchFrame.BackgroundColor3 = SEARCH_BACKGROUND_COLOR
	searchFrame.BackgroundTransparency = SEARCH_BACKGROUND_TRANSPARENCY
	searchFrame.Size = UDim2.new(
		0,
		SEARCH_WIDTH_PIXELS - (SEARCH_BUFFER_PIXELS * 2),
		0,
		INVENTORY_HEADER_SIZE - (SEARCH_BUFFER_PIXELS * 2)
	)
	searchFrame.Position = UDim2.new(1, -searchFrame.Size.X.Offset - SEARCH_BUFFER_PIXELS, 0, SEARCH_BUFFER_PIXELS)
	searchFrame.Parent = InventoryFrame

	local searchFrameCorner: UICorner = Instance.new("UICorner")
	searchFrameCorner.Name = "Corner"
	searchFrameCorner.CornerRadius = SEARCH_CORNER_RADIUS
	searchFrameCorner.Parent = searchFrame

	local searchFrameBorder: UIStroke = Instance.new("UIStroke")
	searchFrameBorder.Name = "Border"
	searchFrameBorder.Color = SEARCH_BORDER_COLOR
	searchFrameBorder.Thickness = SEARCH_BORDER_THICKNESS
	searchFrameBorder.Transparency = SEARCH_BORDER_TRANSPARENCY
	searchFrameBorder.Parent = searchFrame

	local searchBox: TextBox = Instance.new("TextBox")
	searchBox.BackgroundTransparency = 1
	searchBox.Name = "TextBox"
	searchBox.Text = ""
	searchBox.TextColor3 = TEXT_COLOR
	searchBox.TextStrokeTransparency = TEXT_STROKE_TRANSPARENCY
	searchBox.TextStrokeColor3 = TEXT_STROKE_COLOR
	searchBox.FontFace = Font.new(FONT_FAMILY.Family, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	searchBox.PlaceholderText = SEARCH_TEXT_PLACEHOLDER
	searchBox.TextColor3 = TEXT_COLOR
	searchBox.TextTransparency = TEXT_STROKE_TRANSPARENCY
	searchBox.TextStrokeColor3 = TEXT_STROKE_COLOR
	searchBox.ClearTextOnFocus = false
	searchBox.TextTruncate = Enum.TextTruncate.AtEnd
	searchBox.TextSize = FONT_SIZE
	searchBox.TextXAlignment = Enum.TextXAlignment.Left
	searchBox.TextYAlignment = Enum.TextYAlignment.Center
	searchBox.Size = UDim2.new(
		0,
		(SEARCH_WIDTH_PIXELS - (SEARCH_BUFFER_PIXELS * 2)) - (SEARCH_TEXT_OFFSET * 2) - 20,
		0,
		INVENTORY_HEADER_SIZE - (SEARCH_BUFFER_PIXELS * 2) - (SEARCH_TEXT_OFFSET * 2)
	)
	searchBox.AnchorPoint = Vector2.new(0, 0.5)
	searchBox.Position = UDim2.new(0, SEARCH_TEXT_OFFSET, 0.5, 0)
	searchBox.ZIndex = 2
	searchBox.Parent = searchFrame

	local xButton: TextButton = Instance.new("TextButton")
	xButton.Name = "X"
	xButton.Text = ""
	xButton.Size = UDim2.fromOffset(30, 30)
	xButton.Position = UDim2.new(1, -xButton.Size.X.Offset, 0.5, -xButton.Size.Y.Offset / 2)
	xButton.ZIndex = 4
	xButton.Visible = false
	xButton.BackgroundTransparency = 1
	xButton.Parent = searchFrame

	local xImage: ImageButton = Instance.new("ImageButton")
	xImage.Name = "X"
	xImage.Image = SEARCH_IMAGE_X
	xImage.BackgroundTransparency = 1
	xImage.Size = UDim2.new(
		0,
		searchFrame.Size.Y.Offset - (SEARCH_BUFFER_PIXELS * 4),
		0,
		searchFrame.Size.Y.Offset - (SEARCH_BUFFER_PIXELS * 4)
	)
	xImage.AnchorPoint = Vector2.new(0.5, 0.5)
	xImage.Position = UDim2.fromScale(0.5, 0.5)
	xImage.ZIndex = 1
	xImage.BorderSizePixel = 0
	xImage.Parent = xButton

	local function search(): ()
		local terms: { [string]: boolean } = {}
		for word: string in searchBox.Text:gmatch("%S+") do
			terms[word:lower()] = true
		end

		local hitTable = {}
		for i: number = NumberOfHotbarSlots + 1, #Slots do 
			local slot = Slots[i]
			local hits: any = slot:CheckTerms(terms)
			table.insert(hitTable, { slot, hits })
			slot.Frame.Visible = false
			slot.Frame.Parent = InventoryFrame
		end

		table.sort(hitTable, function(left: any, right: any): boolean
			return left[2] > right[2]
		end)
		ViewingSearchResults = true

		local hitCount: number = 0
		for _, data in ipairs(hitTable) do
			local slot, hits: any = data[1], data[2]
			if hits > 0 then
				slot.Frame.Visible = true
				slot.Frame.Parent = UIGridFrame
				slot.Frame.LayoutOrder = NumberOfHotbarSlots + hitCount
				hitCount = hitCount + 1
			end
		end

		ScrollingFrame.CanvasPosition = Vector2.new(0, 0)
		UpdateScrollingFrameCanvasSize()

		xButton.ZIndex = 3
	end

	local function clearResults(): ()
		if xButton.ZIndex > 0 then
			ViewingSearchResults = false
			for i: number = NumberOfHotbarSlots + 1, #Slots do
				local slot = Slots[i]
				slot.Frame.LayoutOrder = slot.Index
				slot.Frame.Parent = UIGridFrame
				slot.Frame.Visible = true
			end
			xButton.ZIndex = 0
		end
		UpdateScrollingFrameCanvasSize()
	end

	local function reset(): ()
		clearResults()
		searchBox.Text = ""
	end

	local function onChanged(property: string): ()
		if property == "Text" then
			local text: string = searchBox.Text
			if text == "" then
				searchBox.TextTransparency = TEXT_STROKE_TRANSPARENCY
				clearResults()
			elseif text ~= SEARCH_TEXT then
				searchBox.TextTransparency = 0
				search()
			end
			xButton.Visible = text ~= "" and text ~= SEARCH_TEXT
		end
	end

	local function focusLost(enterPressed: boolean): ()
		if enterPressed then
			
			search()
		end
	end

	xButton.MouseButton1Click:Connect(reset)
	searchBox.Changed:Connect(onChanged)
	searchBox.FocusLost:Connect(focusLost)

	BackpackScript.StateChanged.Event:Connect(function(isNowOpen: boolean): ()
		

		if not isNowOpen then
			reset()
		end
	end)

	HotkeyFns[Enum.KeyCode.Escape.Value] = function(isProcessed: any): ()
		if isProcessed then 
			reset()
		end
	end
	local function detectGamepad(lastInputType: Enum.UserInputType): ()
		if lastInputType == Enum.UserInputType.Gamepad1 and not UserInputService.VREnabled then
			searchFrame.Visible = false
		else
			searchFrame.Visible = true
		end
	end
	UserInputService.LastInputTypeChanged:Connect(detectGamepad)
end

GuiService.MenuOpened:Connect(function(): ()
	BackpackGui.Enabled = false
	inventoryIcon:setEnabled(false)
end)

GuiService.MenuClosed:Connect(function(): ()
	BackpackGui.Enabled = true
	inventoryIcon:setEnabled(true)
end)

do 
	
	local removeHotBarSlot = function(name: string, state: Enum.UserInputState, input: InputObject): ()
		if state ~= Enum.UserInputState.Begin then
			return
		end
		if not GuiService.SelectedObject then
			return
		end

		for i: number = 1, NumberOfHotbarSlots do
			if Slots[i].Frame == GuiService.SelectedObject and Slots[i].Tool then
				Slots[i]:MoveToInventory()
				return
			end
		end
	end

	local function openClose(): ()
		if not next(Dragging) then 
			InventoryFrame.Visible = not InventoryFrame.Visible
			local nowOpen: boolean = InventoryFrame.Visible
			AdjustHotbarFrames()
			HotbarFrame.Active = not HotbarFrame.Active
			for i: number = 1, NumberOfHotbarSlots do
				Slots[i]:SetClickability(not nowOpen)
			end
		end

		if InventoryFrame.Visible then
			if GamepadEnabled then
				if GAMEPAD_INPUT_TYPES[UserInputService:GetLastInputType()] then
					resizeGamepadHintsFrame()
					gamepadHintsFrame.Visible = not UserInputService.VREnabled
				end
				enableGamepadInventoryControl()
			end
			if BackpackPanel and VRService.VREnabled then
				BackpackPanel:SetVisible(true)
				BackpackPanel:RequestPositionUpdate()
			end
		else
			if GamepadEnabled then
				gamepadHintsFrame.Visible = false
			end
			disableGamepadInventoryControl()
		end

		if InventoryFrame.Visible then
			ContextActionService:BindAction("BackpackRemoveSlot", removeHotBarSlot, false, Enum.KeyCode.ButtonX)
		else
			ContextActionService:UnbindAction("BackpackRemoveSlot")
		end

		BackpackScript.IsOpen = InventoryFrame.Visible
		BackpackScript.StateChanged:Fire(InventoryFrame.Visible)
	end

	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	BackpackScript.OpenClose = openClose 
end

while not Player do
	task.wait()
	Player = Players.LocalPlayer
end

Player.CharacterAdded:Connect(OnCharacterAdded)
if Player.Character then
	OnCharacterAdded(Player.Character)
end

do 
	
	UserInputService.InputBegan:Connect(OnInputBegan)

	
	UserInputService.TextBoxFocused:Connect(function(): ()
		TextBoxFocused = true
	end)
	UserInputService.TextBoxFocusReleased:Connect(function(): ()
		TextBoxFocused = false
	end)

	
	HotkeyFns[DROP_HOTKEY_VALUE] = function(): () 
		if ActiveHopper then
			UnequipAllTools()
		end
	end

	
	UserInputService.LastInputTypeChanged:Connect(OnUISChanged)
	OnUISChanged()

	
	if UserInputService:GetGamepadConnected(Enum.UserInputType.Gamepad1) then
		gamepadConnected()
	end
	UserInputService.GamepadConnected:Connect(function(gamepadEnum: Enum.UserInputType): ()
		if gamepadEnum == Enum.UserInputType.Gamepad1 then
			gamepadConnected()
		end
	end)
	UserInputService.GamepadDisconnected:Connect(function(gamepadEnum: Enum.UserInputType): ()
		if gamepadEnum == Enum.UserInputType.Gamepad1 then
			gamepadDisconnected()
		end
	end)
end

function BackpackScript:SetBackpackEnabled(Enabled: boolean): ()
	BackpackEnabled = Enabled
end

function BackpackScript:IsOpened(): boolean
	return BackpackScript.IsOpen
end

function BackpackScript:GetBackpackEnabled(): boolean
	return BackpackEnabled
end

function BackpackScript:GetStateChangedEvent(): BindableEvent
	return BackpackScript.StateChanged
end

RunService.Heartbeat:Connect(function(): ()
	OnIconChanged(BackpackEnabled)
end)

local function OnPreferredTransparencyChanged(): ()
	local preferredTransparency: number = GuiService.PreferredTransparency

	BACKGROUND_TRANSPARENCY = BACKGROUND_TRANSPARENCY_DEFAULT * preferredTransparency
	InventoryFrame.BackgroundTransparency = BACKGROUND_TRANSPARENCY

	SLOT_LOCKED_TRANSPARENCY = SLOT_LOCKED_TRANSPARENCY_DEFAULT * preferredTransparency
	for _, slot in ipairs(Slots) do
		slot.Frame.BackgroundTransparency = SLOT_LOCKED_TRANSPARENCY
	end

	SEARCH_BACKGROUND_TRANSPARENCY = SEARCH_BACKGROUND_TRANSPARENCY_DEFAULT * preferredTransparency
	searchFrame.BackgroundTransparency = SEARCH_BACKGROUND_TRANSPARENCY
end
GuiService:GetPropertyChangedSignal("PreferredTransparency"):Connect(OnPreferredTransparencyChanged)

return BackpackScript
end)
local node_32 = Node('Attribution', 'ModuleScript', function(script, require)
--[[
	Satchel is subject to the terms of the Mozilla Public License, v. 2.0.

	This script serves as the license notice for Satchel to meet MPL requirements. 

	By using Satchel, you are required to do one of the following:
		1. Keep the Attribution script unmodified and enabled
		2. Credit Satchel in your experience description by name and creator (@WinnersTakesAll)
		3. Have a DevForum topic linked in your experience description, crediting Satchel with the above

	Thank you for supporting Satchel. For more, consider sponsoring Satchel to support its development. 
]]

local RunService = game:GetService("RunService")

if not RunService:IsStudio() then
	print("Converted By C00l_Ch4os")
end

return {}
end)
local node_33 = Node('ThumbnailCamera', 'Camera', nil)
local node_34 = Node('Part', 'Part', nil)
local node_35 = Node('Decal', 'Decal', nil)
AddChild(node_6, node_7)
AddChild(node_8, node_9)
AddChild(node_8, node_10)
AddChild(node_8, node_11)
AddChild(node_8, node_12)
AddChild(node_8, node_13)
AddChild(node_8, node_14)
AddChild(node_8, node_15)
AddChild(node_8, node_16)
AddChild(node_6, node_8)
AddChild(node_17, node_18)
AddChild(node_17, node_19)
AddChild(node_20, node_21)
AddChild(node_20, node_22)
AddChild(node_17, node_20)
AddChild(node_6, node_17)
AddChild(node_23, node_24)
AddChild(node_23, node_25)
AddChild(node_6, node_23)
AddChild(node_6, node_26)
AddChild(node_6, node_27)
AddChild(node_6, node_28)
AddChild(node_6, node_29)
AddChild(node_5, node_6)
AddChild(node_4, node_5)
AddChild(node_3, node_4)
AddChild(node_3, node_30)
AddChild(node_31, node_32)
AddChild(node_3, node_31)
AddChild(node_2, node_3)
AddChild(node_1, node_2)
AddChild(node_0, node_1)
AddChild(node_34, node_35)
AddChild(node_33, node_34)
AddChild(node_0, node_33)
requireNode(node_1)