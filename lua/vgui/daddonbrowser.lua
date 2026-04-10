
local PANEL = {}
PANEL.Extensions = {

	-- fallback
	["error"] = {
		Icon       = "icon16/page_white.png",
		Initialize = function(container)
			local msg = vgui.Create("DLabel", container)
			msg:Dock(TOP)
			msg:SetText("Filetype not currently supported.")
			msg:SetDark(true)
		end,
		Browse     = function() end,
		RightClick = function()	end,
		Invalidate = function() end
	}
}

--- Component Initialization
-- Initializes the DAddonBrowser panel, creating the horizontal divider layout
-- and sidebar navigation, then loading all mounted addons into the tree.
function PANEL:Init()

	for k,v in pairs(file.Find("vgui/daddonbrowser/*", "LUA")) do

		local extension = include("vgui/daddonbrowser/" .. v)
		local extensionName = v:match("(.+)%..+$")

		self.Extensions[extensionName] = extension
	end

	for k,v in pairs(self.Extensions) do
		if (!v.Base) then continue end
		v.Base = self.Extensions[v.Base]
	end

	self.HorizontalDivider = vgui.Create("DHorizontalDivider", self)
	self.HorizontalDivider:Dock(FILL)
	self.HorizontalDivider:SetLeftMin(250)
	self.HorizontalDivider:SetLeftWidth(192)
	self.HorizontalDivider:SetRightMin(100)
	self.HorizontalDivider:SetDividerWidth(6)

	self.ContentNavBar = vgui.Create("ContentSidebar", self.HorizontalDivider)
	self.HorizontalDivider:SetLeft(self.ContentNavBar)

	self:CreateSearchBar()
	self:LoadAddons()
end

function PANEL:CreateSearchBar()

	local container = self.ContentNavBar:Add("DPanel")
	container:Dock(TOP)

	self.Search = container:Add("DTextEntry")
	self.Search:Dock(FILL)
	self.Search:DockMargin(0, 0, 0, 4)
	self.Search:SetPlaceholderText("#spawnmenu.search")
	self.Search.OnEnter = function(this, term)
		self:LoadAddons(term)
	end

	local searchButton = self.Search:Add("DImageButton")
	searchButton:SetImage("icon16/magnifier.png")
	searchButton:SetText("")
	searchButton:Dock(RIGHT)
	searchButton:DockMargin(4, 2, 4, 2)
	searchButton:SetSize(16, 16)
	searchButton:SetTooltip("#spawnmenu.press_search")
	searchButton.DoClick = function (this)
		self.Search:OnEnter(self.Search:GetText())
	end
end

--- Load Addons
-- Clears and repopulates the navigation tree with all currently installed addons,
-- sorted alphabetically by title. Unmounted addons are visually flagged.
function PANEL:LoadAddons(searchTerm)

	self.ContentNavBar.Tree:Clear()

	local addons = engine.GetAddons()
	table.sort(addons, function(a, b) return string.lower(a.title) < string.lower(b.title) end)

	for k,v in ipairs(addons) do

		if (searchTerm && !string.find(string.lower(v.title), string.lower(searchTerm), 1, true)) then
			continue
		end

		self:BuildAddonFolderNode(self.ContentNavBar.Tree, v.title, nil, v.title, v.mounted, v.wsid)
	end

	self:SetContent()
end

--- Build Addon Node
-- Recursively builds the file and folder nodes for a given addon directory.
-- @param path string The addon path or search path root used for file lookups.
-- @param dir string|nil The current subdirectory being scanned, or nil for the root.
-- @param name panel The parent tree node to attach children to.
function PANEL:BuildAddonNode(path, dir, name)

	local files, folders = file.Find(dir && (dir .. "/*") || "*", path)

	-- recurse addon folders.
	for k,v in ipairs(folders) do
		self:BuildAddonFolderNode(name, path, dir && (dir .. "/" .. v) || v, v)
	end

	-- build file node bindings.
	for k,v in ipairs(files) do
		self:BuildAddonFileNode(name, dir, v)
	end
end

--- Addon Folder Node Builder
-- Creates a collapsible folder node in the tree. Children are built lazily on
-- first expand and disposed on collapse to conserve memory. Provides a right-click
-- menu to copy the directory path to the clipboard.
-- @param parent panel The parent tree or node to attach this folder node to.
-- @param path string The addon path or search path root used for file lookups.
-- @param dir string|nil The subdirectory this node represents, or nil for the root.
-- @param name string The display label for the folder node.
-- @param mounted boolean|nil Whether the addon is mounted; unmounted addons show a warning icon.
-- @param wsid string Workshop id.
function PANEL:BuildAddonFolderNode(parent, path, dir, name, mounted, wsid)

	local node = parent:AddNode(name, (mounted == false) && "icon16/folder_delete.png" || nil)
	node:SetDoubleClickToOpen(false)

	node.DoClick = function(this)

		local wasExpanded = this:GetExpanded()

		-- dispose of child nodes when collapsing to save on memory.
		if (wasExpanded) then
			for k,v in pairs(this:GetChildNodes()) do
				v:Remove()
			end
		else
			if (!this.Built) then
				self:BuildAddonNode(path, dir, this)
			end
		end

		this.Built = !wasExpanded
	end

	node.DoRightClick = function(this)

		local menu = DermaMenu()

		if (wsid) then
			menu:AddOption("#spawnmenu.openaddononworkshop", function()
				steamworks.ViewFile(wsid)
			end):SetIcon("icon16/link_go.png")
		end

		menu:AddOption("#spawnmenu.menu.copy", function()
			SetClipboardText(dir || path)
		end):SetIcon("icon16/page_copy.png")

		menu:Open()
	end
end

--- Addon File Node Builder
-- Creates a file leaf in the tree, resolved to its appropriate extension
-- handler for icon display and content browsing. Provides a right-click menu
-- to copy the full file path to the clipboard.
-- @param parent panel The parent tree node to attach this file node to.
-- @param dir string The subdirectory containing this file.
-- @param name string The filename including extension.
function PANEL:BuildAddonFileNode(parent, dir, name)

	-- fetch file extension plugin for addon browser content.
	local extension = self.Extensions[string.GetExtensionFromFilename(name)] || self.Extensions["error"]
	local node = parent:AddNode(name, extension.Icon)

	node.DoClick = function(this)
		self:OpenAddonFile(extension, dir .. "/" .. name)
	end

	node.DoRightClick = function(this)

		this:DoClick()

		local menu = DermaMenu()

		menu:AddOption("#spawnmenu.menu.copy", function()
			SetClipboardText(dir .. "/" .. name)
		end):SetIcon("icon16/page_copy.png")

		extension.RightClick(menu, dir .. "/" .. name)

		menu:Open()
	end
end

--- Open Addon File Contents
-- Lazily build the extension's UI singleton context to display file data.
-- @param extension obj The extension object representing the file.
-- @param filePath string Full file path.
function PANEL:OpenAddonFile(extension, filePath)

	self:InvalidateExtensions()

	local base = extension.Base || extension

	if (!IsValid(base.Container)) then

		base.Container = vgui.Create("DPanel")

		base.FileName = vgui.Create("DLabel", base.Container)
		base.FileName:Dock(TOP)
		base.FileName:DockMargin(0, 0, 0, 5)
		base.FileName:SetDark(true)

		extension.Initialize(base.Container)
		self:SetContent(base.Container)
	end

	base.FileName:SetText(filePath)
	extension.Browse(filePath)
end

--- Content Loader
-- Replaces the right-hand content panel of the divider with the provided panel.
-- The previous content panel is fully removed to free memory.
-- @param content panel The new content panel to display on the right side.
function PANEL:SetContent(content)

	local currentContent = self.HorizontalDivider:GetRight()

	-- dispose of old content completely for memory.
	if (IsValid(currentContent)) then
		currentContent:Remove()
	end

	if (!IsValid(content)) then	return end

	-- display new content now.
	content:SetVisible(false)
	self.HorizontalDivider:SetRight(content)
	self.HorizontalDivider:InvalidateLayout(true)
	content:SetVisible(true)
end

--- Invalidation
-- Calls the Invalidate callback on every registered extension handler,
-- allowing extensions to clean up or reset any active state or UI they own.
function PANEL:InvalidateExtensions()
	for k,v in pairs(self.Extensions) do
		v.Invalidate()
	end
end

vgui.Register("DAddonBrowser", PANEL, "EditablePanel")

spawnmenu.AddCreationTab("GPeek", function()
	return vgui.Create("DAddonBrowser")
end, "icon16/gpeek.png", 999, "Browse addon content")