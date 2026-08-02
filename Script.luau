--[[
	[- 更新日志 -]
1. 文件资源管理器 + 适配studio文件系统

2. 代码更改，修复bug

3. 全面优化移动端适配

4. 优化框选表现，不再异常卡顿
]]

--[[
	[- 待更新 -]
1. Menu:Insert() 插入实例

2. 属性编辑器

3. 更多菜单选项

]]

-- [-[ 初始化环境 ]-]


const StudioFileTest = {
	Folder = {
		Folder = {

		},
		["Lol.mp3"] = "",
		["Lol.mp4"] = "",
		["test.txt"] = "Hello txtfile",
	},
	["Main.lua"] = [[print("hello world")]],
}


const GuiInsert = game:GetService("GuiService"):GetGuiInset().Y

const Players = game:GetService("Players")
const Player = Players.LocalPlayer
const Mouse = Player:GetMouse()
const RunService = game:GetService("RunService")
const IsStudio = RunService:IsStudio()
const UserInputService = game:GetService("UserInputService")


const DexFilePath = "Dex(Obi_xieO)/"
const UrlFilePath = DexFilePath.."UrlCache/"

const RandomNameLength = 25

_G.DexEnvironment = _G.DexEnvironment or {}
const DexEnv = _G.DexEnvironment

DexEnv.ExploitFunctions = {}
setmetatable(DexEnv.ExploitFunctions, {
	__index = function(t, i)
		if getgenv then
			return getgenv()[i]
		else
			if IsStudio then
				return nil
			end
			const Func = loadstring("return "..i)()
			return Func
		end
	end,
})

DexEnv.genv = {}

const function RegisterFunction(Name, Function)
	if DexEnv.ExploitFunctions[Name] then
		DexEnv.genv[Name] = DexEnv.ExploitFunctions[Name]
		return
	end

	DexEnv.genv[Name] = newcclosure and newcclosure(Function) or Function
end
DexEnv.Ui = DexEnv.Ui or {}
for i,v in pairs(DexEnv.Ui) do
	v:Destroy()
end

DexEnv.Connections = DexEnv.Connections or {}
for i,v in pairs(DexEnv.Connections) do
	v:Disconnect()
end

-- [-[ 环境注册 ]-]
RegisterFunction("setclipboard",function(str)
	warn("Set Clipboard: \n"..str)
end)

RegisterFunction("newcclosure",function(Function)
	return Function
end)

RegisterFunction("cloneref",function(obj)
	const newobj : typeof(obj) = setmetatable({},{
		__index = function(t,k)
			return obj[k]
		end,
		__newindex = function(t,k,v)
			obj[k] = v
		end,
		__tostring = function()
			return tostring(obj)
		end,
		__metatable = false,
	})

	return newobj
end)

if IsStudio then
	RegisterFunction("decompile",function(script)
		return script.Source
	end)
	
	local function AssignParents(tbl, parent)
		if parent then
			setmetatable(tbl,{
				__index = function(t,k)
					if k == "Info" then
						return parent
					end

					return rawget(t,k)
				end,
			})
		end

		for i,v in pairs(tbl) do
			if typeof(v) == "table" then
				AssignParents(v, {Index = i, Parent = tbl})
			end
		end
	end

	AssignParents(StudioFileTest)

	local function GetPath(Folder,FileName)
		local Path = ""
		if FileName then
			Path = "/"..FileName
		end

		while Folder do
			local Info = Folder.Info

			if Info then
				Path = "/"..Info.Index..Path
			else
				break
			end

			Folder = Info.Parent
		end

		Path = Path:sub(2)

		return Path
	end


	local function get(path)
		local args = path:split("/")
		local f = StudioFileTest
		for i = 1,#args do
			local str = args[i]
			if str == "" then
				break
			end
			f = f[str]
		end
		return f
	end

	RegisterFunction("readfile",function(path)
		return get(path)
	end)

	RegisterFunction("writefile",function(path,data)
		local args = path:split("/")

		while args[#args] == "" do
			args[#args] = nil
		end

		local arg = args[#args]
		args[#args] = nil

		local f = get(path)

		f[arg] = data
	end)

	RegisterFunction("isfile",function(path)
		return typeof(get(path)) == "string"
	end)

	RegisterFunction("isfolder",function(path)
		return typeof(get(path)) == "table"
	end)

	RegisterFunction("listfiles",function(path)
		if not DexEnv.genv.isfolder(path) then warn("Path is not folder") end

		local f = get(path)

		local tb = {}

		local folderpath = GetPath(f)

		if folderpath == "" then
			for i,v in pairs(f) do
				table.insert(tb,i)
			end
		else
			for i,v in pairs(f) do
				table.insert(tb,folderpath.."/"..i)
			end
		end

		return tb
	end)
end

if game.GetObjects then
	RegisterFunction("getobjects",function(...)
		return game:GetObjects(...)
	end)
end

RegisterFunction("clonefunction",function(Function)
	return Function
end)
if (getrawmetatable and hookfunction) or hookmetamethod then
	RegisterFunction("hookmetamethod",function(obj,method,callback)
		const Metatable = getrawmetatable(obj)
		if not Metatable[method] then
			return
		end

		const OldMethod = hookfunction(Metatable[method],function(...)
			return callback(...)
		end)

		return OldMethod
	end)
end
RegisterFunction("gethui",function()
	if game:GetService("CoreGui") then
		local HiddenGui = game:GetService("CoreGui"):FindFirstChild("Dex_Hidden")
		if HiddenGui then
			return HiddenGui
		end

		local Gui = Instance.new("Folder",game:GetService("CoreGui"))
		Gui.Name = "Dex_Hidden"
		return Gui
	else
		Player:Kick("没有安全UI环境，尝试更换注入器")
	end
end)

if not IsStudio then
	for i,v in pairs(getgenv()) do
		DexEnv.genv[i] = v
	end
end

-- [-[ 全局函数 ]-]
function ImportRBXM(FileRBXM : string)
	return DexEnv.genv.getobjects(game,getcustomasset(FileRBXM))[1]
end

function GetLength(Table)
	local Length = 0
	for _,_ in pairs(Table) do
		Length = Length + 1
	end
	return Length
end

function IsModel(Obj)
	if typeof(Obj) == "table" and Obj.Obj then
		Obj = Obj.Obj
	end
	return Obj:IsA("Model") or Obj:IsA("BasePart")
end

function RandomString(len : number)
	local result = ""

	for i=1,len do
		result = result..string.char(math.random(1,255))
	end

	return result
end

function isService(ClassName)
	if typeof(ClassName) == "table" and ClassName.Obj then
		ClassName = ClassName.Obj.ClassName
	end
	local sus,err = pcall(function()
		return game:GetService(ClassName)
	end)

	if sus and err then
		return true
	end

	return false
end

function CanChangeParent(obj)
	return isService(obj.ClassName) or obj.ClassName == "DataModel"
end

function PointInArea(Point,LeftTop,RightBottom)
	if Point.X >= LeftTop.X and Point.X <= RightBottom.X then
		if Point.Y >= LeftTop.Y and Point.Y <= RightBottom.Y then
			return true
		end
	end
end

function crc32(inputString)
	if not inputString or inputString == "" then
		return 0
	end

	local crc = 0xFFFFFFFF
	local poly = 0xEDB88320

	for i = 1, #inputString do
		local byte = string.byte(inputString, i)
		crc = bit32.bxor(crc, byte)

		for _ = 1, 8 do
			if bit32.band(crc, 1) == 1 then
				crc = bit32.bxor(bit32.rshift(crc, 1), poly)
			else
				crc = bit32.rshift(crc, 1)
			end
		end
	end

	return string.format("%08X", bit32.bnot(crc))
end

function HttpGet(Url,Cache)
	if IsStudio then
		local Returnvalue

		Returnvalue = game:GetService("ReplicatedStorage").RemoteFunction:InvokeServer(Url)

		return Returnvalue
	else
		local Returnvalue

		if Cache then
			local n = crc32(Url)

			if isfile(UrlFilePath..n) then
				return readfile(UrlFilePath..n)
			end

			print(Url)

			Returnvalue = game:HttpGet(Url)

			writefile(UrlFilePath..n,Returnvalue)
		else
			Returnvalue = game:HttpGet(Url)
		end

		return Returnvalue
	end
end

function EscapeForLuaString(str)
	str = string.gsub(str, "\\", "\\\\")
	str = string.gsub(str, '"', '\\"')
	str = string.gsub(str, "'", "\\'")
	str = string.gsub(str, "\n", "\\n")
	str = string.gsub(str, "\r", "\\r")
	str = string.gsub(str, "\t", "\\t")
	str = string.gsub(str, "%[", "\\[")
	str = string.gsub(str, "%]", "\\]")
	return str
end

function GetPath(Obj)
	local Path = ""

	while Obj do
		local Parent = Obj.Parent

		local NewName = EscapeForLuaString(Obj.Name)

		if isService(Obj.ClassName) and game:GetService(Obj.ClassName) == Obj then
			Path = `game:GetService("{Obj.ClassName}"){Path}`
			break
		elseif Obj == DexEnv.genv.gethui() then
			Path = `gethui(){Path}`
			break
		elseif Obj == Player then
			Path = `game:GetService("Players").LocalPlayer{Path}`
			break
		else
			if Parent then
				if isService(Parent.ClassName) then
					Path = `:WaitForChild("{NewName}"){Path}`
					Obj = Parent
					continue
				end

				const Target = Parent:FindFirstChild(NewName)

				if Target and Target ~= Obj then
					const index = table.find(Parent:GetChildren(), Obj)

					local ffc = [[
local ffc = function(parent, name, index)
	local C = 0
	for index, v in ipars(parent:GetChildren()) do
		if v.ClassName == name then
			C += 1
			if C == index then
				return v
			end
		end
	end
end
					
					
]]
					local i = 0		
					for index, child in Parent:GetChildren() do
						if child.Name == NewName then
							i += 1
						end

						if child == Obj then
							break
						end
					end

					Path = `{ffc}ffc({GetPath(Parent)}, "{NewName}", {i})`
					break
				end
			else
				local GetNil = [[
local getNil = function(name, class)
	for _, v in next, getnilinstances() do
		if v.ClassName == class and v.Name == name then
			return v
		end
	end
end
					
					
]]

				Path = `{GetNil}\n\ngetNil("{NewName}", "{Obj.ClassName}"){Path}`

				break
			end

			if string.match(Obj.Name,"^[%a_][%w_]*$") then
				Path = `.{Obj.Name}{Path}`
			else
				Path = `["{NewName}"]{Path}`
			end
		end

		Obj = Parent
	end

	return Path
end

const Urls = {
	IconMap = {
		"https://raw.githubusercontent.com/qian-cheng-awa/Dex-/refs/heads/Remake/ClassIconMap.PNG",
		true,
		function() return "rbxassetid://135148380892747" end,
	},
	RawRMD = {
		"https://raw.githubusercontent.com/CloneTrooper1019/Roblox-Client-Tracker/roblox/ReflectionMetadata.xml",
		false,
		function() return require(script.RMD) end
	},
	FileIconMap = {
		"https://raw.githubusercontent.com/qian-cheng-awa/Dex-/refs/heads/Remake/FileExplorerIcons.png",
		true,
		function() return "rbxassetid://102278811949320" end,
	},
}


const Modules = {
	ParseXML = (function()
		local func = function()
			-- Only exists to parse RMD
			-- from https://github.com/jonathanpoelen/xmlparser

			local string, print, pairs = string, print, pairs

			-- http://lua-users.org/wiki/StringTrim
			local trim = function(s:string)
				local from = s:match"^%s*()"
				return from > #s and "" or s:match(".*%S", from)
			end

			local gtchar = string.byte('>', 1)
			local slashchar = string.byte('/', 1)
			local D = string.byte('D', 1)
			local E = string.byte('E', 1)

			function parse(s, evalEntities)
				-- remove comments
				s = s:gsub('<!%-%-(.-)%-%->', '')

				local entities, tentities = {},{}

				if evalEntities then
					local pos = s:find('<[_%w]')
					if pos then
						s:sub(1, pos):gsub('<!ENTITY%s+([_%w]+)%s+(.)(.-)%2', function(name, q, entity)
							entities[#entities+1] = {name=name, value=entity}
						end)
						tentities = createEntityTable(entities)
						s = replaceEntities(s:sub(pos), tentities)
					end
				end

				local t, l = {}, {}

				local addtext = function(txt)
					txt = txt:match'^%s*(.*%S)' or ''
					if #txt ~= 0 then
						t[#t+1] = {text=txt}
					end		
				end

				s:gsub('<([?!/]?)([-:_%w]+)%s*(/?>?)([^<]*)', function(type, name, closed, txt)
					-- open
					if #type == 0 then
						local a = {}
						if #closed == 0 then
							local len = 0
							for all,aname,_,value,starttxt in string.gmatch(txt, "(.-([-_%w]+)%s*=%s*(.)(.-)%3%s*(/?>?))") do
								len = len + #all
								a[aname] = value
								if #starttxt ~= 0 then
									txt = txt:sub(len+1)
									closed = starttxt
									break
								end
							end
						end
						t[#t+1] = {tag=name, attrs=a, children={}}

						if closed:byte(1) ~= slashchar then
							l[#l+1] = t
							t = t[#t].children
						end

						addtext(txt)
						-- close
					elseif '/' == type then
						t = l[#l]
						l[#l] = nil

						addtext(txt)
						-- ENTITY
					elseif '!' == type then
						if E == name:byte(1) then
							txt:gsub('([_%w]+)%s+(.)(.-)%2', function(name, q, entity)
								entities[#entities+1] = {name=name, value=entity}
							end, 1)
						end
						-- elseif '?' == type then
						--	 print('?	' .. name .. ' // ' .. attrs .. '$$')
						-- elseif '-' == type then
						--	 print('comment	' .. name .. ' // ' .. attrs .. '$$')
						-- else
						--	 print('o	' .. #p .. ' // ' .. name .. ' // ' .. attrs .. '$$')
					end
				end)

				return {children=t, entities=entities, tentities=tentities}
			end

			function parseText(txt)
				return parse(txt)
			end

			function defaultEntityTable()
				return { quot='"', apos='\'', lt='<', gt='>', amp='&', tab='\t', nbsp=' ', }
			end

			function replaceEntities(s, entities)
				return s:gsub('&([^;]+);', entities)
			end

			function createEntityTable(docEntities, resultEntities)
				entities = resultEntities or defaultEntityTable()
				for _,e in pairs(docEntities) do
					e.value = replaceEntities(e.value, entities)
					entities[e.name] = e.value
				end
				return entities
			end

			return parseText
		end
		local newEnv = setmetatable({},{__index = getfenv()})
		setfenv(func,newEnv)
		return func()
	end)()
}

-- [-[ UI ]-]
local MainUi



do

	local DexMainUi = Instance.new("ScreenGui")
	DexMainUi.ResetOnSpawn = false
	DexMainUi.IgnoreGuiInset = true
	DexMainUi.Name = "DexMainUi"
	DexMainUi.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local Explorer = Instance.new("Frame")
	Explorer.AnchorPoint = Vector2.new(1, 0)
	Explorer.Parent = DexMainUi
	Explorer.Name = "Explorer"
	Explorer.Position = UDim2.fromScale(1, 0)
	Explorer.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Explorer.Size = UDim2.new(0, 300, 0.5, 0)
	Explorer.BorderSizePixel = 0
	Explorer.BackgroundColor3 = Color3.fromRGB(18, 18, 22)

	local ScrollingFrame = Instance.new("ScrollingFrame")
	ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(96, 102, 115)
	ScrollingFrame.Active = true
	ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.XY
	ScrollingFrame.ScrollBarThickness = 10
	ScrollingFrame.Parent = Explorer
	ScrollingFrame.Size = UDim2.fromScale(1, 1)
	ScrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	ScrollingFrame.HorizontalScrollBarInset = Enum.ScrollBarInset.Always
	ScrollingFrame.ElasticBehavior = Enum.ElasticBehavior.Never
	ScrollingFrame.BackgroundTransparency = 1
	ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ScrollingFrame.BorderSizePixel = 0
	ScrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Parent = ScrollingFrame
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local Scroll = Instance.new("Folder")
	Scroll.Name = "Scroll"
	Scroll.Parent = Explorer

	local Right = Instance.new("Frame")
	Right.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Right.AnchorPoint = Vector2.new(1, 0)
	Right.Parent = Scroll
	Right.BackgroundTransparency = 1
	Right.Position = UDim2.fromScale(1, 0)
	Right.Name = "Right"
	Right.Size = UDim2.new(0, 6, 1, 0)
	Right.BorderSizePixel = 0
	Right.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local UIStroke = Instance.new("UIStroke")
	UIStroke.Enabled = false
	UIStroke.Transparency = 0.75
	UIStroke.Parent = Right
	UIStroke.Color = Color3.fromRGB(255, 255, 255)

	local Down = Instance.new("Frame")
	Down.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Down.AnchorPoint = Vector2.new(0, 1)
	Down.Parent = Scroll
	Down.BackgroundTransparency = 1
	Down.Position = UDim2.fromScale(0, 1)
	Down.Name = "Down"
	Down.Size = UDim2.new(1, 0, 0, 6)
	Down.BorderSizePixel = 0
	Down.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local UIStroke = Instance.new("UIStroke")
	UIStroke.Enabled = false
	UIStroke.Transparency = 0.75
	UIStroke.Parent = Down
	UIStroke.Color = Color3.fromRGB(255, 255, 255)

	local Properties = Instance.new("Frame")
	Properties.AnchorPoint = Vector2.new(1, 1)
	Properties.Parent = DexMainUi
	Properties.Name = "Properties"
	Properties.Position = UDim2.fromScale(1, 1)
	Properties.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Properties.Size = UDim2.new(0, 300, 0.5, 0)
	Properties.BorderSizePixel = 0
	Properties.BackgroundColor3 = Color3.fromRGB(18, 18, 22)



	MainUi = DexMainUi
	DexEnv.Ui["Main"] = MainUi
end

-- [-[ Class图标 ]-]

Modules.IconMap = {
	Classes = {
		Icons = {
			Accessory = 1,
			Actor = 2,
			AdGui = 3,
			AdPortal = 4,
			AirController = 5,
			AlignOrientation = 6,
			AlignPosition = 7,
			AngularVelocity = 8,
			Animation = 9,
			AnimationConstraint = 10,
			AnimationController = 11,
			AnimationFromVideoCreatorService = 12,
			Animator = 13,
			ArcHandles = 14,
			Atmosphere = 15,
			Attachment = 16,
			AudioAnalyzer = 17,
			AudioChannelMixer = 18,
			AudioChannelSplitter = 19,
			AudioChorus = 20,
			AudioCompressor = 21,
			AudioDeviceInput = 22,
			AudioDeviceOutput = 23,
			AudioDistortion = 24,
			AudioEcho = 25,
			AudioEmitter = 26,
			AudioEqualizer = 27,
			AudioFader = 28,
			AudioFilter = 29,
			AudioFlanger = 30,
			AudioGate = 31,
			AudioLimiter = 32,
			AudioListener = 33,
			AudioPitchShifter = 34,
			AudioPlayer = 35,
			AudioRecorder = 36,
			AudioReverb = 37,
			AudioTextToSpeech = 38,
			AuroraScript = 39,
			AvatarEditorService = 40,
			AvatarSettings = 41,
			Backpack = 42,
			BallSocketConstraint = 43,
			BasePlate = 44,
			Beam = 45,
			BillboardGui = 46,
			BindableEvent = 47,
			BindableFunction = 48,
			BlockMesh = 49,
			BloomEffect = 50,
			BlurEffect = 51,
			BodyAngularVelocity = 52,
			BodyColors = 53,
			BodyForce = 54,
			BodyGyro = 55,
			BodyPosition = 56,
			BodyThrust = 57,
			BodyVelocity = 58,
			Bone = 59,
			BoolValue = 60,
			BoxHandleAdornment = 61,
			Breakpoint = 62,
			BrickColorValue = 63,
			BubbleChatConfiguration = 64,
			Buggaroo = 65,
			Camera = 66,
			CanvasGroup = 67,
			CFrameValue = 68,
			ChannelTabsConfiguration = 69,
			CharacterControllerManager = 70,
			CharacterMesh = 71,
			Chat = 72,
			ChatInputBarConfiguration = 73,
			ChatWindowConfiguration = 74,
			ChorusSoundEffect = 75,
			Class = 76,
			Cleanup = 77,
			ClickDetector = 78,
			ClientReplicator = 79,
			ClimbController = 80,
			Clouds = 81,
			Color = 82,
			ColorCorrectionEffect = 83,
			CompressorSoundEffect = 84,
			ConeHandleAdornment = 85,
			Configuration = 86,
			Constant = 87,
			Constructor = 88,
			Controller = 89,
			CoreGui = 90,
			CornerWedgePart = 91,
			CylinderHandleAdornment = 92,
			CylindricalConstraint = 93,
			Decal = 94,
			DepthOfFieldEffect = 95,
			Dialog = 96,
			DialogChoice = 97,
			DistortionSoundEffect = 98,
			DragDetector = 99,
			EchoSoundEffect = 100,
			EditableImage = 101,
			EditableMesh = 102,
			Enum = 103,
			EnumMember = 104,
			EqualizerSoundEffect = 105,
			Event = 106,
			Explosion = 107,
			FaceControls = 108,
			Field = 109,
			File = 110,
			Fire = 111,
			FlangeSoundEffect = 112,
			Folder = 113,
			ForceField = 114,
			Frame = 115,
			Function = 116,
			GameSettings = 117,
			GroundController = 118,
			Handles = 119,
			HapticEffect = 120,
			HapticService = 121,
			HeightmapImporterService = 122,
			Highlight = 123,
			HingeConstraint = 124,
			Humanoid = 125,
			HumanoidDescription = 126,
			IKControl = 127,
			ImageButton = 128,
			ImageHandleAdornment = 129,
			ImageLabel = 130,
			InputAction = 131,
			InputBinding = 132,
			InputContext = 133,
			Interface = 134,
			IntersectOperation = 135,
			Keyword = 136,
			Lighting = 137,
			LinearVelocity = 138,
			LineForce = 139,
			LineHandleAdornment = 140,
			LocalFile = 141,
			LocalizationService = 142,
			LocalizationTable = 143,
			LocalScript = 144,
			MaterialService = 145,
			MaterialVariant = 146,
			MemoryStoreService = 147,
			MeshPart = 148,
			Meshparts = 149,
			MessagingService = 150,
			Method = 151,
			Model = 152,
			Modelgroups = 153,
			Module = 154,
			ModuleScript = 155,
			Motor6D = 156,
			NegateOperation = 157,
			NetworkClient = 158,
			NoCollisionConstraint = 159,
			Operator = 160,
			PackageLink = 161,
			Pants = 162,
			Part = 163,
			ParticleEmitter = 164,
			Path2D = 165,
			PathfindingLink = 166,
			PathfindingModifier = 167,
			PathfindingService = 168,
			PitchShiftSoundEffect = 169,
			Place = 170,
			Placeholder = 171,
			Plane = 172,
			PlaneConstraint = 173,
			Player = 174,
			Players = 175,
			PluginGuiService = 176,
			PointLight = 177,
			PrismaticConstraint = 178,
			Property = 179,
			ProximityPrompt = 180,
			PublishService = 181,
			Reference = 182,
			RemoteEvent = 183,
			RemoteFunction = 184,
			RenderingTest = 185,
			ReplicatedFirst = 186,
			ReplicatedScriptService = 187,
			ReplicatedStorage = 188,
			ReverbSoundEffect = 189,
			RigidConstraint = 190,
			RobloxPluginGuiService = 191,
			RocketPropulsion = 192,
			RodConstraint = 193,
			RopeConstraint = 194,
			Rotate = 195,
			ScreenGui = 196,
			Script = 197,
			ScrollingFrame = 198,
			Seat = 199,
			Selected_Workspace = 200,
			SelectionBox = 201,
			SelectionSphere = 202,
			ServerScriptService = 203,
			ServerStorage = 204,
			Service = 205,
			Shirt = 206,
			ShirtGraphic = 207,
			SkinnedMeshPart = 208,
			Sky = 209,
			Smoke = 210,
			Snap = 211,
			Snippet = 212,
			SocialService = 213,
			Sound = 214,
			SoundEffect = 215,
			SoundGroup = 216,
			SoundService = 217,
			Sparkles = 218,
			SpawnLocation = 219,
			SpecialMesh = 220,
			SphereHandleAdornment = 221,
			SpotLight = 222,
			SpringConstraint = 223,
			StandalonePluginScripts = 224,
			StarterCharacterScripts = 225,
			StarterGui = 226,
			StarterPack = 227,
			StarterPlayer = 228,
			StarterPlayerScripts = 229,
			Struct = 230,
			StyleDerive = 231,
			StyleLink = 232,
			StyleRule = 233,
			StyleSheet = 234,
			SunRaysEffect = 235,
			SurfaceAppearance = 236,
			SurfaceGui = 237,
			SurfaceLight = 238,
			SurfaceSelection = 239,
			SwimController = 240,
			TaskScheduler = 241,
			Team = 242,
			Teams = 243,
			Terrain = 244,
			TerrainDetail = 245,
			TestService = 246,
			TextBox = 247,
			TextBoxService = 248,
			TextButton = 249,
			TextChannel = 250,
			TextChatCommand = 251,
			TextChatService = 252,
			TextLabel = 253,
			TextString = 254,
			Texture = 255,
			Tool = 256,
			Torque = 257,
			TorsionSpringConstraint = 258,
			Trail = 259,
			TremoloSoundEffect = 260,
			TrussPart = 261,
			TypeParameter = 262,
			UGCValidationService = 263,
			UIAspectRatioConstraint = 264,
			UICorner = 265,
			UIDragDetector = 266,
			UIFlexItem = 267,
			UIGradient = 268,
			UIGridLayout = 269,
			UIListLayout = 270,
			UIPadding = 271,
			UIPageLayout = 272,
			UIScale = 273,
			UISizeConstraint = 274,
			UIStroke = 275,
			UITableLayout = 276,
			UITextSizeConstraint = 277,
			UnionOperation = 278,
			Unit = 279,
			UniversalConstraint = 280,
			UnreliableRemoteEvent = 281,
			UpdateAvailable = 282,
			UserService = 283,
			Value = 284,
			Variable = 285,
			VectorForce = 286,
			VehicleSeat = 287,
			VideoDisplay = 288,
			VideoFrame = 289,
			VideoPlayer = 290,
			ViewportFrame = 291,
			VirtualUser = 292,
			VoiceChannel = 293,
			Voicechat = 294,
			VoiceChatService = 295,
			VRService = 296,
			WedgePart = 297,
			Weld = 298,
			WeldConstraint = 299,
			Wire = 300,
			WireframeHandleAdornment = 301,
			Workspace = 302,
			WorldModel = 303,
			WrapDeformer = 304,
			WrapLayer = 305,
			WrapTarget = 306,

			Color3Value = 284,
			IntValue = 284,
			NumberValue = 284,
			ObjectValue = 284,
			RayValue = 284,
			StringValue = 284,
			Vector3Value = 284,
		},
		IconSize = 32,
		Witdh = 18,
		Height = 18,
	},
	Files = {
		Icons = {
			["cmd"] = 14,
			["exe"] = 15,
			["dll"] = 16,
			["doc"] = 17,
			["docx"] = 18,
			["drv"] = 19,
			["flv"] = 21,
			["go"] = 22,
			["html"] = 23,
			["img"] = 24,
			["iso"] = 25,
			["java"] = 26,
			["m4a"] = 27,
			["mkv"] = 28,
			["mov"] = 29,
			["mp3"] = 30,
			["mp4"] = 31,
			["mpeg"] = 32,
			["msi"] = 33,
			["nfo"] = 34,
			["odp"] = 35,
			["ods"] = 36,
			["odt"] = 37,
			["ogg"] = 38,
			["pdf"] = 39,
			["php"] = 40,
			["placeholder"] = 9,
			["ppt"] = 41,
			["pptx"] = 42,
			["psd"] = 43,
			["py"] = 44,
			["rar"] = 45,
			["rb"] = 46,
			["rs"] = 47,
			["rtf"] = 48,
			["sys"] = 49,
			["txt"] = 50,
			["torrent"] = 51,
			["wav"] = 1,
			["wma"] = 2,
			["wmv"] = 3,
			["xls"] = 4,
			["xlsx"] = 5,
			["yaml"] = 6,
			["yml"] = 7,
			["zip"] = 8
		},
		IconsType = {
			html = 1,
			audio = 2,
			xls = 4,
			video = 10,
			cmd = 14,
			exe = 15,
			txt = 50,
			zip = 8,
			dll = 16,
		},
		types = {
			cmd = {
				"bat",
				"cmd",
			},
			html = {
				"htm",
				"html",
			},
			exe = {
				"exe",
				"com",
				"msi",
			},
			zip = {
				"7z",
				"rar",
				"zip",
				"tar",
			},
			audio = {
				"m4a",
				"mp3",
				"wma",
				"wav",
				"ogg",
			},
			video = {
				"3gp",
				"avi",
				"flv",
				"mkv",
				"mov",
				"mp4",
				"mpeg",
			},
			txt = {
				"toml",
				"txt",
				"lua",
				"text",
				"json",
			},
			dll = {
				"dll",
				"sys",
				"ini",
				"drv"
			}
		},
		IconSize = 64,
		Witdh = 7,
		Height = 8,
	}
}

const IconMap = Modules.IconMap

function IconMap:Init()
	const ClassMapPng = Modules.InitModules["IconMap"]
	const FileIconMapPng = Modules.InitModules["FileIconMap"]

	if IsStudio then
		IconMap.Classes.Map = Urls.IconMap[3]()
	else
		IconMap.Classes.Map = getcustomasset(UrlFilePath..crc32(Urls.IconMap[1]))
	end

	if IsStudio then
		IconMap.Files.Map = Urls.FileIconMap[3]()
	else
		IconMap.Files.Map = getcustomasset(UrlFilePath..crc32(Urls.FileIconMap[1]))
	end

	function IconMap:Apply(Image,Id,Size,Offset)
		Image.ImageRectOffset = Offset
		Image.ImageRectSize = Size
		Image.Image = Id
	end

	function IconMap:GetIcon(Image,Map,Index)
		if not Map.Icons or not Map.IconSize or not Map.Map then
			return ""
		end

		Image.Image = Map.Map

		const IconSize = Vector2.new(Map.IconSize,Map.IconSize)

		local X = Index % Map.Witdh
		local Y = Index//Map.Witdh

		IconMap:Apply(Image,Map.Map,IconSize,Vector2.new(
			IconSize.X * X,
			IconSize.Y * Y
			))
	end

	function IconMap:GetClassIcon(Image : ImageLabel , ClassName : string)
		const index = (IconMap.Classes.Icons[ClassName] or (isService(ClassName) and IconMap.Classes.Icons.Service) or IconMap.Classes.Icons.Placeholder) - 1

		if index then
			return IconMap:GetIcon(Image,IconMap.Classes,index)
		else
			return ""
		end
	end

	function IconMap:GetFileMap(Image : ImageLabel , FileType : string)
		if FileType == "folder" then
			return IconMap:GetClassIcon(Image,"Folder")
		end

		local index = (IconMap.Files.Icons[FileType] or IconMap.Files.Icons.placeholder) - 1

		for i,v in pairs(IconMap.Files.types) do
			if table.find(v,FileType) then
				index = IconMap.Files.IconsType[i] - 1
			end
		end

		if index then
			return IconMap:GetIcon(Image,IconMap.Files,index)
		else
			return ""
		end
	end
end

-- [-[ 文件资源管理器 ]-]

local FileExplorerUi

do
	local FileExplorer = Instance.new("ScreenGui")
	FileExplorer.Name = "FileExplorer"
	FileExplorer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local MainFrame = Instance.new("Frame")
	MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	MainFrame.Parent = FileExplorer
	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	MainFrame.Size = UDim2.fromOffset(600, 400)
	MainFrame.Name = "MainFrame"
	MainFrame.Position = UDim2.fromScale(0.5, 0.5)
	MainFrame.BorderSizePixel = 0
	MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local UICorner = Instance.new("UICorner")
	UICorner.TopLeftRadius = UDim.new(0, 5)
	UICorner.Parent = MainFrame
	UICorner.TopRightRadius = UDim.new(0, 5)
	UICorner.BottomRightRadius = UDim.new(0, 5)
	UICorner.CornerRadius = UDim.new(0, 5)
	UICorner.BottomLeftRadius = UDim.new(0, 5)

	local UIShadow = Instance.new("UIShadow")
	UIShadow.Parent = MainFrame
	UIShadow.Transparency = 0.85
	UIShadow.BlurRadius = UDim.new(0, 5)

	local Topbar = Instance.new("Frame")
	Topbar.Parent = MainFrame
	Topbar.Size = UDim2.new(1, 0, 0, 30)
	Topbar.Name = "Topbar"
	Topbar.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Topbar.BorderSizePixel = 0
	Topbar.BackgroundColor3 = Color3.fromRGB(245, 247, 250)

	local UICorner = Instance.new("UICorner")
	UICorner.TopLeftRadius = UDim.new(0, 5)
	UICorner.Parent = Topbar
	UICorner.TopRightRadius = UDim.new(0, 5)
	UICorner.BottomRightRadius = UDim.new(0, 5)
	UICorner.CornerRadius = UDim.new(0, 5)
	UICorner.BottomLeftRadius = UDim.new(0, 5)

	local Frame = Instance.new("Frame")
	Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Frame.AnchorPoint = Vector2.new(1, 1)
	Frame.Parent = Topbar
	Frame.Size = UDim2.fromScale(1, 0.5)
	Frame.Position = UDim2.fromScale(1, 1)
	Frame.BorderSizePixel = 0
	Frame.BackgroundColor3 = Color3.fromRGB(245, 247, 250)

	local Close = Instance.new("TextButton")
	Close.FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json",Enum.FontWeight.ExtraLight,Enum.FontStyle.Normal)
	Close.Parent = Topbar
	Close.AnchorPoint = Vector2.new(1, 1)
	Close.SizeConstraint = Enum.SizeConstraint.RelativeYY
	Close.Size = UDim2.fromScale(1, 1)
	Close.Name = "Close"
	Close.TextColor3 = Color3.fromRGB(0, 0, 0)
	Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Close.Text = "x"
	Close.BorderSizePixel = 0
	Close.TextWrapped = true
	Close.BackgroundTransparency = 1
	Close.Position = UDim2.fromScale(1, 1)
	Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Close.TextScaled = true

	local Path = Instance.new("Frame")
	Path.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Path.Parent = MainFrame
	Path.Position = UDim2.new(0.025, 0, 0, 40)
	Path.Name = "Path"
	Path.Size = UDim2.new(0.7, 0, 0, 30)
	Path.BorderSizePixel = 0
	Path.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local UIStroke = Instance.new("UIStroke")
	UIStroke.Parent = Path
	UIStroke.Transparency = 0.75

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Parent = Path
	UIListLayout.Padding = UDim.new(0, 2)
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local Search = Instance.new("Frame")
	Search.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Search.Parent = MainFrame
	Search.AnchorPoint = Vector2.new(1, 0)
	Search.Size = UDim2.new(0.25, 0, 0, 30)
	Search.Name = "Search"
	Search.Position = UDim2.new(0.985, 0, 0, 40)
	Search.BorderSizePixel = 0
	Search.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local UIStroke = Instance.new("UIStroke")
	UIStroke.Parent = Search
	UIStroke.Transparency = 0.75

	local TextBox = Instance.new("TextBox")
	TextBox.Parent = Search
	TextBox.PlaceholderText = "Search in ..."
	TextBox.TextSize = 16
	TextBox.Size = UDim2.fromScale(1, 1)
	TextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
	TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextBox.Text = ""
	TextBox.BorderSizePixel = 0
	TextBox.Font = Enum.Font.SourceSans
	TextBox.BackgroundTransparency = 1
	TextBox.TextXAlignment = Enum.TextXAlignment.Left
	TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local UIPadding = Instance.new("UIPadding")
	UIPadding.PaddingLeft = UDim.new(0.05, 0)
	UIPadding.Parent = TextBox

	local Files = Instance.new("Frame")
	Files.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Files.Parent = MainFrame
	Files.Size = UDim2.new(1, 0, 1, -155)
	Files.AnchorPoint = Vector2.new(0.5, 1)
	Files.BorderSizePixel = 0
	Files.Name = "Files"
	Files.Position = UDim2.new(0.5, 0, 1, -50)
	Files.ZIndex = 10
	Files.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local UIStroke = Instance.new("UIStroke")
	UIStroke.Parent = Files

	local ScrollingFrame = Instance.new("ScrollingFrame")
	ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
	ScrollingFrame.Active = true
	ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.XY
	ScrollingFrame.Position = UDim2.fromOffset(5, 0)
	ScrollingFrame.ScrollBarThickness = 5
	ScrollingFrame.Parent = Files
	ScrollingFrame.Size = UDim2.new(1, -10, 1.1, -50)
	ScrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	ScrollingFrame.BorderSizePixel = 0
	ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ScrollingFrame.HorizontalScrollBarInset = Enum.ScrollBarInset.Always
	ScrollingFrame.ElasticBehavior = Enum.ElasticBehavior.Never
	ScrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Parent = ScrollingFrame
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local Sort = Instance.new("Frame")
	Sort.LayoutOrder = -999
	Sort.ClipsDescendants = true
	Sort.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Sort.Parent = ScrollingFrame
	Sort.Name = "Sort"
	Sort.AutomaticSize = Enum.AutomaticSize.X
	Sort.Size = UDim2.new(1, 0, 0, 26)
	Sort.BackgroundTransparency = 1
	Sort.BorderSizePixel = 0
	Sort.ZIndex = 0
	Sort.BackgroundColor3 = Color3.fromRGB(225, 225, 225)

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Parent = Sort
	UIListLayout.Padding = UDim.new(0, 1)
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal

	local NameSort = Instance.new("TextButton")
	NameSort.Parent = Sort
	NameSort.TextSize = 14
	NameSort.Size = UDim2.new(0, 350, 1, 0)
	NameSort.TextColor3 = Color3.fromRGB(0, 0, 0)
	NameSort.BorderColor3 = Color3.fromRGB(0, 0, 0)
	NameSort.Text = "Name"
	NameSort.Name = "NameSort"
	NameSort.Font = Enum.Font.SourceSans
	NameSort.BackgroundTransparency = 1
	NameSort.TextXAlignment = Enum.TextXAlignment.Left
	NameSort.BorderSizePixel = 0
	NameSort.BackgroundColor3 = Color3.fromRGB(94, 225, 255)

	local UIPadding = Instance.new("UIPadding")
	UIPadding.Parent = NameSort
	UIPadding.PaddingRight = UDim.new(0, 5)
	UIPadding.PaddingLeft = UDim.new(0, 5)

	local Up = Instance.new("TextLabel")
	Up.Visible = false
	Up.FontFace = Font.new("rbxassetid://12187360881",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Up.Parent = NameSort
	Up.AnchorPoint = Vector2.new(0.5, 0)
	Up.ZIndex = 10
	Up.TextSize = 20
	Up.Size = UDim2.fromOffset(10, 10)
	Up.Name = "Up"
	Up.TextColor3 = Color3.fromRGB(0, 0, 0)
	Up.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Up.Text = ">"
	Up.Rotation = -90
	Up.BackgroundTransparency = 1
	Up.Position = UDim2.fromScale(0.5, 0)
	Up.BorderSizePixel = 0
	Up.Visible = false
	Up.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local Down = Instance.new("TextLabel")
	Down.FontFace = Font.new("rbxassetid://12187360881",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Down.Parent = NameSort
	Down.AnchorPoint = Vector2.new(0.5, 1)
	Down.ZIndex = 10
	Down.TextSize = 20
	Down.Size = UDim2.fromOffset(10, 10)
	Down.Name = "Down"
	Down.TextColor3 = Color3.fromRGB(0, 0, 0)
	Down.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Down.Text = ">"
	Down.Rotation = 90
	Down.BackgroundTransparency = 1
	Down.Position = UDim2.fromScale(0.5, 1)
	Down.BorderSizePixel = 0
	Down.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local UIStroke = Instance.new("UIStroke")
	UIStroke.Color = Color3.fromRGB(200, 200, 200)
	UIStroke.Parent = NameSort
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local TypeSort = Instance.new("TextButton")
	TypeSort.Parent = Sort
	TypeSort.TextSize = 14
	TypeSort.Size = UDim2.new(0, 250, 1, 0)
	TypeSort.TextColor3 = Color3.fromRGB(0, 0, 0)
	TypeSort.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TypeSort.Text = "Type"
	TypeSort.Name = "TypeSort"
	TypeSort.Font = Enum.Font.SourceSans
	TypeSort.BackgroundTransparency = 1
	TypeSort.TextXAlignment = Enum.TextXAlignment.Left
	TypeSort.BorderSizePixel = 0
	TypeSort.BackgroundColor3 = Color3.fromRGB(94, 225, 255)

	local UIPadding = Instance.new("UIPadding")
	UIPadding.Parent = TypeSort
	UIPadding.PaddingRight = UDim.new(0, 5)
	UIPadding.PaddingLeft = UDim.new(0, 5)

	local Down = Instance.new("TextLabel")
	Down.FontFace = Font.new("rbxassetid://12187360881",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Down.Parent = TypeSort
	Down.AnchorPoint = Vector2.new(0.5, 1)
	Down.ZIndex = 10
	Down.TextSize = 20
	Down.Size = UDim2.fromOffset(10, 10)
	Down.Name = "Down"
	Down.TextColor3 = Color3.fromRGB(0, 0, 0)
	Down.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Down.Text = ">"
	Down.Rotation = 90
	Down.BackgroundTransparency = 1
	Down.Position = UDim2.fromScale(0.5, 1)
	Down.BorderSizePixel = 0
	Down.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local Up = Instance.new("TextLabel")
	Up.Visible = false
	Up.FontFace = Font.new("rbxassetid://12187360881",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Up.Parent = TypeSort
	Up.AnchorPoint = Vector2.new(0.5, 0)
	Up.ZIndex = 10
	Up.TextSize = 20
	Up.Size = UDim2.fromOffset(10, 10)
	Up.Name = "Up"
	Up.TextColor3 = Color3.fromRGB(0, 0, 0)
	Up.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Up.Text = ">"
	Up.Rotation = -90
	Up.BackgroundTransparency = 1
	Up.Position = UDim2.fromScale(0.5, 0)
	Up.BorderSizePixel = 0
	Up.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local UIStroke = Instance.new("UIStroke")
	UIStroke.Color = Color3.fromRGB(200, 200, 200)
	UIStroke.Parent = TypeSort
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local Buttons = Instance.new("Frame")
	Buttons.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Buttons.Parent = MainFrame
	Buttons.Position = UDim2.fromOffset(0, 80)
	Buttons.Name = "Buttons"
	Buttons.Size = UDim2.new(1, 0, 0, 25)
	Buttons.BorderSizePixel = 0
	Buttons.BackgroundColor3 = Color3.fromRGB(240, 242, 245)

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Parent = Buttons
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local NewFolder = Instance.new("TextButton")
	NewFolder.Parent = Buttons
	NewFolder.TextSize = 14
	NewFolder.Size = UDim2.fromScale(0, 1)
	NewFolder.TextColor3 = Color3.fromRGB(0, 0, 99)
	NewFolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
	NewFolder.Text = "Create New Folder"
	NewFolder.Name = "NewFolder"
	NewFolder.Font = Enum.Font.SourceSans
	NewFolder.BackgroundTransparency = 1
	NewFolder.BorderSizePixel = 0
	NewFolder.BackgroundColor3 = Color3.fromRGB(94, 225, 255)
	NewFolder.AutomaticSize = Enum.AutomaticSize.X

	local UIPadding = Instance.new("UIPadding")
	UIPadding.Parent = NewFolder
	UIPadding.PaddingRight = UDim.new(0, 10)
	UIPadding.PaddingLeft = UDim.new(0, 10)

	local Hoving = Instance.new("UIStroke")
	Hoving.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Hoving.Name = "Hoving"
	Hoving.Color = Color3.fromRGB(0, 0, 255)
	Hoving.Parent = NewFolder
	Hoving.Enabled = false

	local UIPadding = Instance.new("UIPadding")
	UIPadding.Parent = Buttons
	UIPadding.PaddingRight = UDim.new(0, 5)
	UIPadding.PaddingLeft = UDim.new(0, 5)

	local Refresh = Instance.new("TextButton")
	Refresh.LayoutOrder = -1
	Refresh.Parent = Buttons
	Refresh.TextSize = 14
	Refresh.Size = UDim2.fromScale(0, 1)
	Refresh.TextColor3 = Color3.fromRGB(0, 0, 99)
	Refresh.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Refresh.Text = "Refresh"
	Refresh.Name = "Refresh"
	Refresh.Font = Enum.Font.SourceSans
	Refresh.BackgroundTransparency = 1
	Refresh.BorderSizePixel = 0
	Refresh.BackgroundColor3 = Color3.fromRGB(94, 225, 255)
	Refresh.AutomaticSize = Enum.AutomaticSize.X

	local UIPadding = Instance.new("UIPadding")
	UIPadding.Parent = Refresh
	UIPadding.PaddingRight = UDim.new(0, 10)
	UIPadding.PaddingLeft = UDim.new(0, 10)

	local Hoving = Instance.new("UIStroke")
	Hoving.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Hoving.Name = "Hoving"
	Hoving.Color = Color3.fromRGB(0, 0, 255)
	Hoving.Parent = Refresh
	Hoving.Enabled = false

	local Selected = Instance.new("Frame")
	Selected.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Selected.Parent = MainFrame
	Selected.Size = UDim2.new(1, 0, 0, 75)
	Selected.AnchorPoint = Vector2.new(1, 1)
	Selected.BorderSizePixel = 0
	Selected.Name = "Selected"
	Selected.Position = UDim2.fromScale(1, 1)
	Selected.ZIndex = 999
	Selected.BackgroundColor3 = Color3.fromRGB(245, 247, 250)

	local TextLabel = Instance.new("TextLabel")
	TextLabel.Parent = Selected
	TextLabel.TextSize = 16
	TextLabel.Size = UDim2.fromOffset(100, 20)
	TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel.Text = "File Name(N):"
	TextLabel.Font = Enum.Font.SourceSans
	TextLabel.BackgroundTransparency = 1
	TextLabel.Position = UDim2.fromOffset(0, 10)
	TextLabel.BorderSizePixel = 0
	TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local FileName = Instance.new("TextBox")
	FileName.Parent = Selected
	FileName.TextTruncate = Enum.TextTruncate.AtEnd
	FileName.TextSize = 16
	FileName.Size = UDim2.new(1, -250, 0, 20)
	FileName.TextColor3 = Color3.fromRGB(0, 0, 0)
	FileName.BorderColor3 = Color3.fromRGB(0, 0, 0)
	FileName.Text = "Main.lua"
	FileName.ClearTextOnFocus = false
	FileName.Position = UDim2.fromOffset(100, 10)
	FileName.BorderSizePixel = 0
	FileName.Font = Enum.Font.SourceSans
	FileName.Name = "FileName"
	FileName.TextXAlignment = Enum.TextXAlignment.Left
	FileName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	FileName.CursorPosition = -1

	local UIStroke = Instance.new("UIStroke")
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Parent = FileName

	local UIPadding = Instance.new("UIPadding")
	UIPadding.Parent = FileName
	UIPadding.PaddingRight = UDim.new(0, 5)
	UIPadding.PaddingLeft = UDim.new(0, 5)

	local FileType = Instance.new("TextLabel")
	FileType.Parent = Selected
	FileType.AnchorPoint = Vector2.new(1, 0)
	FileType.TextTruncate = Enum.TextTruncate.AtEnd
	FileType.TextSize = 14
	FileType.Size = UDim2.fromOffset(130, 20)
	FileType.TextColor3 = Color3.fromRGB(0, 0, 0)
	FileType.BorderColor3 = Color3.fromRGB(0, 0, 0)
	FileType.Text = "*.lua;"
	FileType.BorderSizePixel = 0
	FileType.Position = UDim2.new(1, -10, 0, 10)
	FileType.Font = Enum.Font.SourceSans
	FileType.Name = "FileType"
	FileType.TextXAlignment = Enum.TextXAlignment.Left
	FileType.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local UIStroke = Instance.new("UIStroke")
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Transparency = 0.75
	UIStroke.Parent = FileType

	local UIPadding = Instance.new("UIPadding")
	UIPadding.Parent = FileType
	UIPadding.PaddingRight = UDim.new(0, 5)
	UIPadding.PaddingLeft = UDim.new(0, 5)

	local Open = Instance.new("TextButton")
	Open.Parent = Selected
	Open.AnchorPoint = Vector2.new(1, 0)
	Open.TextSize = 14
	Open.Size = UDim2.fromOffset(60, 22)
	Open.TextColor3 = Color3.fromRGB(0, 0, 0)
	Open.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Open.Text = "Open"
	Open.Name = "Open"
	Open.Font = Enum.Font.SourceSans
	Open.BackgroundTransparency = 1
	Open.Position = UDim2.fromScale(0.8666390180587769, 0.5400000214576721)
	Open.BorderSizePixel = 0
	Open.BackgroundColor3 = Color3.fromRGB(94, 225, 255)

	local UIStroke = Instance.new("UIStroke")
	UIStroke.Color = Color3.fromRGB(0, 0, 255)
	UIStroke.Transparency = 0.5
	UIStroke.Parent = Open
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local Cancel = Instance.new("TextButton")
	Cancel.Parent = Selected
	Cancel.AnchorPoint = Vector2.new(1, 0)
	Cancel.TextSize = 14
	Cancel.Size = UDim2.fromOffset(60, 22)
	Cancel.TextColor3 = Color3.fromRGB(0, 0, 0)
	Cancel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Cancel.Text = "Cancel"
	Cancel.Name = "Cancel"
	Cancel.Font = Enum.Font.SourceSans
	Cancel.BackgroundTransparency = 1
	Cancel.Position = UDim2.fromScale(0.983111560344696, 0.5400000214576721)
	Cancel.BorderSizePixel = 0
	Cancel.BackgroundColor3 = Color3.fromRGB(94, 225, 255)

	local Normal = Instance.new("UIStroke")
	Normal.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Normal.Transparency = 0.75
	Normal.Name = "Normal"
	Normal.Parent = Cancel

	local Hoving = Instance.new("UIStroke")
	Hoving.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Hoving.Transparency = 0.5
	Hoving.Name = "Hoving"
	Hoving.Color = Color3.fromRGB(0, 0, 255)
	Hoving.Parent = Cancel
	Hoving.Enabled = false

	local UISizeConstraint = Instance.new("UISizeConstraint")
	UISizeConstraint.MinSize = Vector2.new(0, 250)
	UISizeConstraint.Parent = MainFrame

	local TextButton = Instance.new("TextButton")
	TextButton.Parent = FileExplorer
	TextButton.AnchorPoint = Vector2.new(0.5, 0.5)
	TextButton.ZIndex = -1
	TextButton.TextSize = 14
	TextButton.Size = UDim2.fromScale(3, 3)
	TextButton.Modal = true
	TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextButton.Text = ""
	TextButton.Transparency = 1
	TextButton.BorderSizePixel = 0
	TextButton.Font = Enum.Font.SourceSans
	TextButton.BackgroundTransparency = 1
	TextButton.Position = UDim2.fromScale(0.5, 0.5)
	TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
	TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)


	FileExplorerUi = FileExplorer
	FileExplorerUi.Parent = DexEnv.genv.gethui()
	FileExplorerUi.Enabled = false
	DexEnv.Ui["FE"] = FileExplorerUi
end

local FileEntryFrame
do

	local FileEntry = Instance.new("Frame")
	FileEntry.BackgroundTransparency = 1
	FileEntry.Name = "FileEntry"
	FileEntry.BorderColor3 = Color3.fromRGB(0, 0, 0)
	FileEntry.Size = UDim2.fromOffset(600, 20)
	FileEntry.BorderSizePixel = 0
	FileEntry.BackgroundColor3 = Color3.fromRGB(94, 225, 255)

	local UiStroke = Instance.new("UIStroke")
	UiStroke.Color = Color3.fromRGB(0, 0, 0)
	UiStroke.Parent = FileEntry
	UiStroke.Enabled = false
	UiStroke.Name = "Selected"
	UiStroke.Thickness = 1

	local Icon = Instance.new("ImageLabel")
	Icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Icon.Parent = FileEntry
	Icon.Name = "Icon"
	Icon.Image = "rbxassetid://102278811949320"
	Icon.BackgroundTransparency = 1
	Icon.Position = UDim2.fromOffset(10, 1)
	Icon.Size = UDim2.fromOffset(18, 18)
	Icon.ImageRectSize = Vector2.new(64, 64)
	Icon.BorderSizePixel = 0
	Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local FileName = Instance.new("TextLabel")
	FileName.TextColor3 = Color3.fromRGB(50, 50, 50)
	FileName.BorderColor3 = Color3.fromRGB(0, 0, 0)
	FileName.Text = "file.mp4"
	FileName.Parent = FileEntry
	FileName.Name = "FileName"
	FileName.TextTruncate = Enum.TextTruncate.AtEnd
	FileName.Size = UDim2.new(0, 300, 1, 0)
	FileName.Font = Enum.Font.SourceSans
	FileName.BackgroundTransparency = 1
	FileName.TextXAlignment = Enum.TextXAlignment.Left
	FileName.Position = UDim2.fromOffset(35, 0)
	FileName.BorderSizePixel = 0
	FileName.TextSize = 18
	FileName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local FileType = Instance.new("TextLabel")
	FileType.TextColor3 = Color3.fromRGB(50, 50, 50)
	FileType.BorderColor3 = Color3.fromRGB(0, 0, 0)
	FileType.Text = "MP4 File"
	FileType.Parent = FileEntry
	FileType.Name = "FileType"
	FileType.Size = UDim2.new(0, 200, 1, 0)
	FileType.Font = Enum.Font.SourceSans
	FileType.BackgroundTransparency = 1
	FileType.TextXAlignment = Enum.TextXAlignment.Left
	FileType.Position = UDim2.fromOffset(355, 0)
	FileType.BorderSizePixel = 0
	FileType.TextSize = 14
	FileType.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	FileEntryFrame = FileEntry
end

local FilePathEntryFrame

do

	local FilePathEntry = Instance.new("Frame")
	FilePathEntry.Name = "FilePathEntry"
	FilePathEntry.Size = UDim2.fromScale(0, 1)
	FilePathEntry.BorderColor3 = Color3.fromRGB(0, 0, 0)
	FilePathEntry.BorderSizePixel = 0
	FilePathEntry.AutomaticSize = Enum.AutomaticSize.X
	FilePathEntry.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local EntryName = Instance.new("TextButton")
	EntryName.TextColor3 = Color3.fromRGB(0, 0, 0)
	EntryName.BorderColor3 = Color3.fromRGB(0, 0, 0)
	EntryName.Text = "Workspace"
	EntryName.Parent = FilePathEntry
	EntryName.AutoButtonColor = false
	EntryName.Name = "EntryName"
	EntryName.Font = Enum.Font.SourceSans
	EntryName.BackgroundTransparency = 1
	EntryName.Size = UDim2.fromScale(0, 1)
	EntryName.BorderSizePixel = 0
	EntryName.AutomaticSize = Enum.AutomaticSize.X
	EntryName.TextSize = 14
	EntryName.BackgroundColor3 = Color3.fromRGB(94, 225, 255)

	local TextButton = Instance.new("TextButton")
	TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
	TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextButton.Text = ">"
	TextButton.Parent = EntryName
	TextButton.AnchorPoint = Vector2.new(1, 1)
	TextButton.Font = Enum.Font.SourceSans
	TextButton.BackgroundTransparency = 1
	TextButton.Position = UDim2.new(1, 15, 1, 0)
	TextButton.Size = UDim2.new(0, 10, 1, 0)
	TextButton.BorderSizePixel = 0
	TextButton.TextSize = 14
	TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local UIStroke = Instance.new("UIStroke")
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Parent = TextButton
	UIStroke.Name = "Hoving"
	UIStroke.Enabled = false

	local UIPadding = Instance.new("UIPadding")
	UIPadding.Parent = EntryName
	UIPadding.PaddingRight = UDim.new(0, 15)
	UIPadding.PaddingLeft = UDim.new(0, 5)

	local UIStroke = Instance.new("UIStroke")
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Parent = EntryName
	UIStroke.Name = "Hoving"
	UIStroke.Enabled = false

	FilePathEntryFrame = FilePathEntry
end

Modules.FileExplorer = {
	ButtonEffects = {},
	CurrentPath = nil :: string,
	Selected = {} :: {File},
	MultipleSelect = false,
	Uis = {},
	FileTypes = {}:: {string},
}

type File = {
	Name: string,
	Type: string,
	Path: string,
}

local FileExplorer = Modules.FileExplorer

function FileExplorer:Init()
	local FilesScrollingFrame = FileExplorerUi.MainFrame.Files.ScrollingFrame
	local FileSelectedFrame = FileExplorerUi.MainFrame.Selected
	local FilePathFrames = FileExplorerUi.MainFrame.Path

	local function ButtonEffect(Button:TextButton)
		local NewButtonEffect = {}

		function NewButtonEffect.Hover()
			if Button:GetAttribute("Selected") then return end
			Button.BackgroundTransparency = .75
			local Stroke = Button:FindFirstChild("Hoving")
			if Stroke and Stroke:IsA("UIStroke") then
				Stroke.Enabled = true
			end

			local NormalStroke = Button:FindFirstChild("Normal")
			if NormalStroke and NormalStroke:IsA("UIStroke") then
				NormalStroke.Enabled = false
			end
		end

		function NewButtonEffect.Leave()
			if Button:GetAttribute("Selected") then return end
			Button.BackgroundTransparency = 1
			local Stroke = Button:FindFirstChild("Hoving")
			if Stroke and Stroke:IsA("UIStroke") then
				Stroke.Enabled = false
			end

			local NormalStroke = Button:FindFirstChild("Normal")
			if NormalStroke and NormalStroke:IsA("UIStroke") then
				NormalStroke.Enabled = true
			end
		end

		local a = Button.MouseEnter:Connect(NewButtonEffect.Hover)
		local b = Button.MouseLeave:Connect(NewButtonEffect.Leave)

		Button.Destroying:Once(function()
			Modules.FileExplorer.ButtonEffects[Button] = nil
			a:Disconnect()
			b:Disconnect()
		end)

		Modules.FileExplorer.ButtonEffects[Button] = NewButtonEffect
	end

	function FileExplorer:FileType(FilePath)
		if DexEnv.genv.isfolder(FilePath) then
			return "folder"
		end

		local FileName = FileExplorer:FileName(FilePath)
		return (string.match(FileName, "%.(%w+)$") or ""):lower()
	end

	function FileExplorer:FileName(Path)
		return string.match(Path, "([^/\\]+)$") or Path
	end

	local function UpdateSelected()
		for i,v in pairs(FileExplorer.Uis) do
			v.BackgroundTransparency = 1
			v.Selected.Enabled = false
			v:SetAttribute("Selected", nil)
		end

		if GetLength(FileExplorer.Selected) > 1 then
			local str = ""
			for i,v in pairs(FileExplorer.Selected) do
				str = str..v.Name..", "

				local ui = FileExplorer.Uis[v.Path]
				if ui then
					ui.BackgroundTransparency = .5
					ui.Selected.Enabled = true
					ui:SetAttribute("Selected", true)
				end
			end
			str = str:sub(1, -2)
			FileSelectedFrame.FileName.Text = str
		elseif GetLength(FileExplorer.Selected) == 1 then
			local _,File:File = next(FileExplorer.Selected)

			FileSelectedFrame.FileName.Text = File.Name

			local ui = FileExplorer.Uis[File.Path]
			if ui then
				ui.BackgroundTransparency = .5
				ui.Selected.Enabled = true
				ui:SetAttribute("Selected", true)
			end
		else
			FileSelectedFrame.FileName.Text = ""
		end

		if #FileExplorer.FileTypes >= 1 then
			local str = ""
			for i,v in pairs(FileExplorer.FileTypes) do
				str = str.."*."..v..";"
			end

			FileSelectedFrame.FileType.Text = str
		else
			FileSelectedFrame.FileType.Text = "*.*(All Files)"
		end
	end

	function FileExplorer:SelectFile(FilePath)
		if FileExplorer.MultipleSelect then
			if FileExplorer.Selected[FilePath] then
				FileExplorer.Selected[FilePath] = nil
			end
		elseif not FileExplorer.Selected[FilePath] then
			FileExplorer.Selected = {}
		end

		local Name = FileExplorer:FileName(FilePath)
		local Type = FileExplorer:FileType(FilePath)

		FileExplorer.Selected[FilePath] = {
			Name = Name,
			Path = FilePath,
			Type = Type,
		}::File

		UpdateSelected()
	end

	function FileExplorer:NewFile(FilePath)
		local FileName = FileExplorer:FileName(FilePath)
		local FileType = FileExplorer:FileType(FilePath)

		local NewFileEntry = FileEntryFrame:Clone()
		NewFileEntry.FileName.Text = FileName
		if FileType == "" then
			NewFileEntry.FileType.Text = "File"
		elseif FileType == "folder" then
			NewFileEntry.FileType.Text = "Folder"
		else
			NewFileEntry.FileType.Text = FileType:upper().." File"
		end

		Modules.IconMap:GetFileMap(NewFileEntry.Icon, FileType)
		NewFileEntry.Parent = FilesScrollingFrame

		ButtonEffect(NewFileEntry)

		local LastClick = tick()

		local a;a = NewFileEntry.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				if tick() - LastClick < .5 and not FileExplorer.MultipleSelect then
					FileExplorer:Done()
					return
				end

				LastClick = tick()
				FileExplorer:SelectFile(FilePath)
			end
		end)

		NewFileEntry.Destroying:Once(function()
			FileExplorer.Uis[FilePath] = nil
			a:Disconnect()
		end)

		FileExplorer.Uis[FilePath] = NewFileEntry
	end

	local WaitEvent = Instance.new("BindableEvent")
	local WaitEvent2 = Instance.new("BindableEvent")

	function FileExplorer:FilesSort(Table, NameDown, TypeDown)
		local nt = {}
		local function SortBy(a, b)
			local NameA = a.Name or ""
			local NameB = b.Name or ""
			local TypeA = a.Type or ""
			local TypeB = b.Type or ""

			local IsFolderA = a.IsFolder or (a.Type == "folder")
			local IsFolderB = b.IsFolder or (b.Type == "folder")

			if IsFolderA ~= IsFolderB then
				return IsFolderA
			end

			if TypeDown ~= nil then
				if TypeA ~= TypeB then
					if TypeDown then
						return TypeA > TypeB
					else
						return TypeA < TypeB
					end
				end
			end

			if NameDown ~= nil then
				if NameA ~= NameB then
					if NameDown then
						return NameA > NameB
					else
						return NameA < NameB
					end
				end
			end

			return false
		end

		table.sort(Table, SortBy)

		nt = Table
		return nt
	end
	function FileExplorer:Open()
		FileExplorerUi.Enabled = true

		FileSelectedFrame.FileName.Text = ""
		FileSelectedFrame.FileType.Text = ""

		for i,v in pairs(FileExplorer.ButtonEffects) do
			v.Leave()
		end

		FileExplorer:JumpTo("")

		UpdateSelected()

		local a;a = FileSelectedFrame.Open.MouseButton1Click:Connect(function()
			FileExplorer:Done()
		end)

		WaitEvent.Event:Wait()

		local tbl = {}
		for i,v in pairs(FileExplorer.Selected) do
			if DexEnv.genv.isfile(i) then
				table.insert(tbl, i)
			end
		end

		WaitEvent2:Fire()

		return tbl
	end

	function FileExplorer:Close()
		WaitEvent:Fire()

		FileExplorerUi.Enabled = false

		FileExplorer.Selected = {}

		FileExplorer.FileTypes = {}
	end

	function FileExplorer:Done()
		if GetLength(FileExplorer.Selected) == 1 then
			local _,File:File = next(FileExplorer.Selected)
			if DexEnv.genv.isfolder(File.Path) then
				FileExplorer:JumpTo(File.Path)
				return
			end
		elseif GetLength(FileExplorer.Selected) > 1 then
			for i,v in pairs(FileExplorer.Selected) do
				if DexEnv.genv.isfolder(v.Path) then
					return
				end
			end
		end

		WaitEvent:Fire()
		WaitEvent2.Event:Wait()

		FileExplorer:Close()
	end

	function FileExplorer:File(...)
		local Types = {...}
		FileExplorer.FileTypes = Types

		return FileExplorer:Open()
	end

	function FileExplorer:JumpTo(Path)
		warn("Jump to "..Path)
		for i,v in ipairs(FilePathFrames:GetChildren()) do
			if v.Name ~= "Default" and v:IsA("Frame") then
				v:Destroy()
			end
		end

		for i,v in ipairs(FilesScrollingFrame:GetChildren()) do
			if v.Name ~= "Sort" and v:IsA("Frame") then
				v:Destroy()
			end
		end

		if DexEnv.genv.isfolder(Path) then
			local Files : {string} = DexEnv.genv.listfiles(Path)

			local FilesTable = {}

			for _,FilePath in pairs(Files) do
				table.insert(FilesTable,{
					Name = FileExplorer:FileName(FilePath),
					Path = FilePath,
					Type = FileExplorer:FileType(FilePath),
				}::File)
			end

			FileExplorer:FilesSort(FilesTable,true,true)

			for _,FileT in pairs(FilesTable) do
				FileExplorer:NewFile(FileT.Path)
			end

			local PathTable = string.split(Path, "/")

			for i = 1,#PathTable do
				local FolderName = PathTable[i]
				if FolderName == "" then continue end
				local NewPathFrame = FilePathEntryFrame:Clone()
				NewPathFrame.Parent = FilePathFrames
				NewPathFrame.EntryName.Text = FolderName

				local CurrentPath = ""

				for l = 1,i do
					CurrentPath = CurrentPath..PathTable[l].."/"
				end

				CurrentPath = CurrentPath:sub(1,#CurrentPath-1)

				local a;a = NewPathFrame.EntryName.MouseButton1Click:Connect(function()
					FileExplorer:JumpTo(CurrentPath)
				end)

				NewPathFrame.Destroying:Once(function()
					a:Disconnect()
				end)

				ButtonEffect(NewPathFrame.EntryName)
				ButtonEffect(NewPathFrame.EntryName.TextButton)
			end
		end
	end

	local DefaultPath = FilePathEntryFrame:Clone()
	DefaultPath.Parent = FilePathFrames
	DefaultPath.EntryName.Text = "Executor"
	DefaultPath.Name = "Default"

	local DefaultPath = FilePathEntryFrame:Clone()
	DefaultPath.Parent = FilePathFrames
	DefaultPath.EntryName.Text = "Workspace(C:)"
	DefaultPath.Name = "Default"
	DefaultPath.EntryName.MouseButton1Click:Connect(function()
		FileExplorer:JumpTo("")
	end)

	ButtonEffect(DefaultPath.EntryName)
	ButtonEffect(DefaultPath.EntryName.TextButton)
	ButtonEffect(FilesScrollingFrame.Sort.NameSort)
	ButtonEffect(FilesScrollingFrame.Sort.TypeSort)
	ButtonEffect(FileSelectedFrame.Open)
	ButtonEffect(FileSelectedFrame.Cancel)
	ButtonEffect(FileExplorerUi.MainFrame.Buttons.NewFolder)
	ButtonEffect(FileExplorerUi.MainFrame.Buttons.Refresh)


	FileSelectedFrame.Cancel.MouseButton1Click:Connect(function()
		FileExplorer:Close()
	end)
	FileExplorerUi.MainFrame.Topbar.Close.MouseButton1Click:Connect(function()
		FileExplorer:Close()
	end)
end

-- [-[ 小菜单 ]-]

local MenuUi
local MenuEntryFrame
local MenuDividerFrame

do
	local Menu = Instance.new("Frame")
	Menu.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Menu.Size = UDim2.fromOffset(150, 0)
	Menu.Name = "Menu"
	Menu.BorderSizePixel = 0
	Menu.AutomaticSize = Enum.AutomaticSize.Y
	Menu.BackgroundColor3 = Color3.fromRGB(18, 18, 22)

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Parent = Menu
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local UIStroke = Instance.new("UIStroke")
	UIStroke.Color = Color3.fromRGB(50, 50, 50)
	UIStroke.Parent = Menu

	local UIShadow = Instance.new("UIShadow")
	UIShadow.Offset = UDim2.fromOffset(2, 2)
	UIShadow.Transparency = 0.5
	UIShadow.Parent = Menu
	UIShadow.BlurRadius = UDim.new(0, 3)


	MenuUi = Menu
end

do
	local MenuEntry = Instance.new("Frame")
	MenuEntry.BorderColor3 = Color3.fromRGB(0, 0, 0)
	MenuEntry.Name = "MenuEntry"
	MenuEntry.BackgroundTransparency = 1
	MenuEntry.Size = UDim2.new(1, 0, 0, 20)
	MenuEntry.BorderSizePixel = 0
	MenuEntry.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local ImageLabel = Instance.new("ImageLabel")
	ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ImageLabel.Parent = MenuEntry
	ImageLabel.Size = UDim2.fromOffset(18, 18)
	ImageLabel.BackgroundTransparency = 1
	ImageLabel.Position = UDim2.fromOffset(2, 1)
	ImageLabel.BorderSizePixel = 0
	ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local TextLabel = Instance.new("TextLabel")
	TextLabel.Parent = MenuEntry
	TextLabel.TextTruncate = Enum.TextTruncate.AtEnd
	TextLabel.Font = Enum.Font.SourceSans
	TextLabel.TextSize = 16
	TextLabel.Size = UDim2.fromOffset(100, 20)
	TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	TextLabel.Position = UDim2.fromOffset(24, 0)
	TextLabel.BackgroundTransparency = 1
	TextLabel.TextXAlignment = Enum.TextXAlignment.Left
	TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local TextButton = Instance.new("TextButton")
	TextButton.Parent = MenuEntry
	TextButton.Size = UDim2.fromOffset(20, 20)
	TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextButton.Text = "▲"
	TextButton.AutoButtonColor = false
	TextButton.Rotation = -90
	TextButton.BackgroundTransparency = 1
	TextButton.Position = UDim2.fromOffset(130, 0)
	TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextButton.TextScaled = true

	local UIPadding = Instance.new("UIPadding")
	UIPadding.PaddingTop = UDim.new(0.25, 0)
	UIPadding.PaddingBottom = UDim.new(0.25, 0)
	UIPadding.Parent = TextButton
	UIPadding.PaddingRight = UDim.new(0.25, 0)
	UIPadding.PaddingLeft = UDim.new(0.25, 0)


	local Hit = Instance.new("TextButton")
	Hit.Parent = MenuEntry
	Hit.Size = UDim2.fromScale(1, 1)
	Hit.Text = ""
	Hit.Name = "Hit"
	Hit.BackgroundTransparency = 1


	MenuEntryFrame = MenuEntry
end

do
	local MenuDivider = Instance.new("Frame")
	MenuDivider.BorderColor3 = Color3.fromRGB(0, 0, 0)
	MenuDivider.Name = "MenuDivider"
	MenuDivider.BackgroundTransparency = 1
	MenuDivider.Size = UDim2.new(1, 0, 0, 10)
	MenuDivider.BorderSizePixel = 0
	MenuDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local Frame = Instance.new("Frame")
	Frame.Parent = MenuDivider
	Frame.Size = UDim2.new(1, -26, 0, 1)
	Frame.BackgroundTransparency = 0.95
	Frame.Position = UDim2.new(0,24,.5,0)
	Frame.AnchorPoint = Vector2.new(0, 0.5)
	Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	MenuDividerFrame = MenuDivider
end


Modules.Menu = {}
local Menu = Modules.Menu

type MenuEntryArg = {
	Name: string,
	CallBack: () -> (),
	Icon: string?,
	Parent: MenuEntryArg?,
	Children: { MenuEntryArg }?,
	IsDrivider: boolean?,
	Exluded: (ClassName : string) -> boolean?,
	ExludedMulti: (Selected : {ExplorerNode}) -> boolean?,
	ExludedAll: (Selected : {ExplorerNode}) -> boolean?,
	DisibledMulti : boolean?,
}

function Menu:Init()
	Menu.Values = {}

	Menu.Uis = {}
	Menu.Hoving = {}

	Menu.MenuEntries = {
		Instance = {
			{
				Name = "Cut",
				CallBack = function(Selected)
					Menu.Values.Copies = {}

					for Node,_ in Selected do
						if isService(Node.Obj.ClassName) then continue end
						table.insert(Menu.Values.Copies,{
							Parent = Node.Obj.Parent,
							Obj = Node.Obj:Clone()
						})
						Node.Obj:Destroy()
					end
				end,
				Exluded = isService,
			},
			{
				Name = "Copy",
				CallBack = function(Selected)
					Menu.Values.Copies = {}

					for Node,_ in Selected do
						if isService(Node.Obj.ClassName) then continue end
						table.insert(Menu.Values.Copies,{
							Parent = Node.Obj.Parent,
							Obj = Node.Obj:Clone()
						})
					end
				end,
				Exluded = isService,
			},
			{
				Name = "Copy As",
				Children = {
					{
						Name = "Copy Path",
						CallBack = function(Selected)
							local str = ""
							for Node,_ in Selected do
								local Path = GetPath(Node.Obj)

								if str ~= "" then
									str = str .. "\n"
								end

								str = str .. Path
							end

							DexEnv.genv.setclipboard(str)
						end,
					}
				},
			},
			{
				IsDrivider = true,
			},
			{
				Name = "Paste to",
				CallBack = function(Selected)
					for _,Obj in Menu.Values.Copies do
						for Node,_ in Selected do
							local Clone = Obj.Obj:Clone()
							Clone.Parent = Node.Obj
						end
					end
				end,
				ExludedAll = function(ClassName)
					if not Menu.Values.Copies then
						return true
					end

					return #Menu.Values.Copies == 0
				end,
			},
			{
				Name = "Paste to origin",
				CallBack = function(Selected)
					for _,Obj in Menu.Values.Copies do
						local Clone = Obj.Obj:Clone()
						if Obj.Parent then
							Clone.Parent = Obj.Parent
						end
					end
				end,
				ExludedAll = function(ClassName)
					if not Menu.Values.Copies then
						return true
					end

					local HasParent = false

					for i,v in Menu.Values.Copies do
						if v.Parent then
							HasParent = true
						end
					end

					return #Menu.Values.Copies == 0 or not HasParent
				end,
			},
			{
				Name = "Duplicate",
				CallBack = function(Selected)
					for Node,_ in Selected do
						if isService(Node.Obj.ClassName) then continue end
						local Clone = Node.Obj:Clone()
						Clone.Parent = Node.Obj.Parent
					end
				end,
				Exluded = isService,
			},
			{
				Name = "Delete",
				CallBack = function(Selected)
					for Node,_ in Selected do
						if isService(Node.Obj.ClassName) then continue end
						Node.Obj:Destroy()
					end
				end,
				Exluded = isService,
			},
			{
				Name = "Rename",
				CallBack = function(Selected)
					select(-2,next(Selected)):Rename()
				end,
				Exluded1 = function(Selected)
					return #Selected > 1
				end,
			},
			{
				IsDrivider = true,
			},
			{
				Name = "Group to model",
				CallBack = function(Selected)
					local Model = Instance.new("Model")
					local Node,_ = next(Selected)
					Model.Parent = Node.Obj.Parent

					for Node,_ in Selected do
						if isService(Node.Obj.ClassName) then continue end
						Node.Obj.Parent = Model
					end
					
					local ModelNode = Modules.Explorer.ObjAdded(Model)
					
					Modules.Explorer.ObjSelect(ModelNode)
					Modules.Explorer:JumpTo(ModelNode)
				end,
				Exluded = isService
			},
			{
				Name = "Group to folder",
				CallBack = function(Selected)
					local Folder = Instance.new("Folder")
					local Node,_ = next(Selected)
					Folder.Parent = Node.Obj.Parent

					for Node,_ in Selected do
						if isService(Node.Obj.ClassName) then continue end
						Node.Obj.Parent = Folder
					end
					
					local FolderNode = Modules.Explorer.ObjAdded(Folder)

					Modules.Explorer.ObjSelect(FolderNode)
					Modules.Explorer:JumpTo(FolderNode)
				end,
				Exluded = isService
			},
			{
				Name = "Ungroup",
				CallBack = function(Selected)
					local s = Selected
					
					local n = {}
					
					for Node,_ in s do
						if Node.Obj:IsA("Model") or Node.Obj:IsA("Folder") then
							for _,v in Node.Obj:GetChildren() do
								if not CanChangeParent(v) then continue end
								
								local Node1 = Modules.Explorer.Nodes[v]
								
								v.Parent = Node.Obj.Parent
								
								Modules.Explorer:RefreshNode(Node1)
								Modules.Explorer.SetSelect(Node1,true)
							end
							
							table.insert(n,Node.Obj)
						end
					end
					
					task.defer(function()
						for _,v in n do
							v:Destroy()
						end
						
						local Node,_ = next(Selected)

						Modules.Explorer:JumpTo(Node)
					end)
				end,
				ExludedMulti = function(Selected)
					local HasGroup = false
					for Node,_ in Selected do
						if Node.Obj:IsA("Model") or Node.Obj:IsA("Folder") then
							HasGroup = true
						end
					end

					return not HasGroup
				end,
			},
			{
				Name = "Insert",
				Children = {
					[1] = {
						Name = "Insert object",
						CallBack = function(Selected)
							local Clone = Menu:Insert()

							if Clone then
								for Node,_ in Selected do
									Clone:Clone().Parent = Node.Obj
								end
							end
						end,
					},

					[2] = {
						Name = "Insert rbxm",
						CallBack = function(Selected)
							local Files = FileExplorer:File("rbxm","rbxmx")

							if Files[1] then
								local Clone = ImportRBXM(Files[1])
								if Clone then

									for Node,_ in Selected do
										Clone:Clone().Parent = Node.Obj
									end
								end
							end
						end,

						ExludedAll = function()
							return not getcustomasset or not game.GetObjects
						end,
					}
				}
			},
			{
				IsDrivider = true,
				DisibledMulti = true,
				Exluded = function(a)
					return not IsModel(a)
				end,
			},
			{
				Name = "Teleport to ...",
				DisibledMulti = true,
				Exluded = function(a)
					return not IsModel(a)
				end,
				CallBack = function(Selected)
					local Node,_ = next(Selected)
					local Obj = Node.Obj
					
					if Player and Player.Character then
						Player.Character:PivotTo(Obj:GetPivot())
					end
				end,
			},
			{
				Name = "View Model",
				DisibledMulti = true,
				Exluded = function(a)
					return not IsModel(a)
				end,
				CallBack = function(Selected)
					local Node,_ = next(Selected)
					local Obj = Node.Obj
					
					if Menu.Values.CameraSubject then
						workspace.CurrentCamera.CameraSubject = Menu.Values.CameraSubject
						Menu.Values.CameraSubject = nil
					else
						Menu.Values.CameraSubject = workspace.CurrentCamera.CameraSubject
						workspace.CurrentCamera.CameraSubject = Obj
					end
				end,
			}
		}::{MenuEntryArg},
		Player = {
			{
				IsDrivider = true
			},
			{
				Name = "Select Character",
				CallBack = function(Selected)
					Modules.Explorer.ClearSelect()
					
					for Node,_ in pairs(Selected) do
						if Node.Obj:IsA("Player") and Node.Obj.Character then
							local CharacterNode = Modules.Explorer.Nodes[Node.Obj.Character]
							Modules.Explorer:ExpandAllParent(CharacterNode)
							Modules.Explorer.SetSelect(CharacterNode,true)
						end
					end
					
					if next(Selected) then
						Modules.Explorer:JumpTo(next(Selected))
					end
				end,
			},
			{
				Name = "Teleport To",
				CallBack = function(Selected)
					local Node,_ = next(Selected)
					local Obj = Node.Obj
					
					if Obj:IsA("Player") and Obj.Character then
						if Player and Player.Character then
							Player.Character:PivotTo(Obj.Character:GetPivot())
						end
					end
				end,
				DisibledMulti = true,
			}
		}::{MenuEntryArg}
	}
	
	table.insert(Menu.MenuEntries.Instance,{
		IsDrivider = true
	})
	table.insert(Menu.MenuEntries.Instance,{
		Name = "Refresh Node",
		CallBack = function(Selected)
			for Node,_ in pairs(Selected) do
				Modules.Explorer:RefreshUi(Node)
			end
		end,
	})
	table.insert(Menu.MenuEntries.Instance,{
		Name = "Refresh All",
		CallBack = function(Selected)
			for obj,Node in pairs(Modules.Explorer.Roots) do
				Modules.Explorer:RefreshUi(Node)
			end
		end,
	})
	table.insert(Menu.MenuEntries.Instance,{
		Name = "Expand All",
		CallBack = function(Selected)
			for Node,_ in pairs(Selected) do
				Modules.Explorer:ExpandAll(Node)
			end
		end,
	})
	table.insert(Menu.MenuEntries.Instance,{
		Name = "UnExpand All",
		CallBack = function(Selected)
			for Node,_ in pairs(Selected) do
				Modules.Explorer:UnExpandAll(Node)
			end
		end,
	})
	table.insert(Menu.MenuEntries.Instance,{
		Name = "Set Root",
		CallBack = function(Selected)
			for Node,_ in pairs(Selected) do
				if Node.Root then continue end
				Modules.Explorer:NewRoot(Node.Obj)
			end
		end,
		Exluded = function(Node)
			return Node.Root
		end,
		ExludedMulti = function(Selected)
			for Node,_ in pairs(Selected) do
				if not Node.Root then
					return false
				end
			end
			return true
		end,
	})
	table.insert(Menu.MenuEntries.Instance,{
		Name = "UnSet Root",
		CallBack = function(Selected)
			for Node,_ in pairs(Selected) do
				if not Node.Root then continue end
				Modules.Explorer:RemoveRoot(Node.Obj)
			end
		end,
		ExludedMulti = function(Selected)
			for Node,_ in pairs(Selected) do
				if Node.Root then return false end
			end
			return true
		end,
		Exluded = function(Node)
			return not Node.Root
		end,
	})



	function Menu:AddDivider(Menu)
		local NewDivider = MenuDividerFrame:Clone()
		NewDivider.Parent = Menu

		return NewDivider
	end

	function Menu:AddEntry(MenuUi,Args : MenuEntryArg,Selected : { ExplorerNode },Index)
		if Args.ExludedAll and Args.ExludedAll() then return end
		
		if GetLength(Selected) == 1 then
			local Node,_ = next(Selected)

			if Args.Exluded and Args.Exluded(Node) then return end
		elseif GetLength(Selected) > 1 then
			if Args.DisibledMulti then return end
			if Args.ExludedMulti and Args.ExludedMulti(Selected) then return end
		end
		
		if Args.IsDrivider then
			Menu:AddDivider(MenuUi)
			return
		end
		
		local NewEntry = MenuEntryFrame:Clone()

		NewEntry.Name = Args.Name
		NewEntry.Parent = MenuUi
		NewEntry.TextLabel.Text = Args.Name

		if Args.Icon then
			NewEntry.ImageLabel.Image = Args.Icon
		end

		local Connections = {}

		local Time = tick()

		Connections[1] = NewEntry.MouseEnter:Connect(function()
			local NewTime = tick()
			Time = NewTime
			NewEntry.BackgroundTransparency = .9

			Menu.Hoving[Index] = NewEntry

			task.delay(Args.Children and .25 or 1,function()
				if Menu.Hoving[Index] == NewEntry and Time == NewTime then
					if Menu.Uis[Index+1] then
						Menu.Uis[Index+1]:Destroy()
						Menu.Uis[Index+1] = nil
					end

					if Args.Children and #Args.Children > 0 then
						local Ui = Menu:CreateUi(UDim2.fromOffset(NewEntry.AbsolutePosition.X,NewEntry.AbsolutePosition.Y+GuiInsert) - UDim2.fromOffset(MenuUi.Size.X.Offset, 0),Args.Children,Selected,Index + 1)

						MenuUi.Destroying:Once(function()
							Ui:Destroy()
							Args.Ui = nil
						end)

						Args.Ui = Ui
						
						Ui.Destroying:Once(function()
							Args.Ui = nil
						end)
					end
				end
			end)
		end)

		Connections[2] = NewEntry.MouseLeave:Connect(function()
			NewEntry.BackgroundTransparency = 1

			if Menu.Hoving[Index] == NewEntry then
				Menu.Hoving[Index] = nil
			end
		end)

		if Args.Children then
			NewEntry.TextButton.Visible = true
			
			Connections[3] = NewEntry.Hit.MouseButton1Click:Connect(function()
				if Menu.Uis[Index+1] then
					Menu.Uis[Index+1]:Destroy()
					Menu.Uis[Index+1] = nil
				end
				if Args.Children and #Args.Children > 0 then
					local Ui = Menu:CreateUi(UDim2.fromOffset(NewEntry.AbsolutePosition.X,NewEntry.AbsolutePosition.Y+GuiInsert) - UDim2.fromOffset(MenuUi.Size.X.Offset, 0),Args.Children,Selected,Index + 1)
					MenuUi.Destroying:Once(function()
						Ui:Destroy()
						Args.Ui = nil
					end)

					Args.Ui = Ui
					
					Ui.Destroying:Once(function()
						Args.Ui = nil
					end)
				end
			end)
		else
			NewEntry.TextButton.Visible = false

			if Args.CallBack then
				Connections[3] = NewEntry.Hit.MouseButton1Click:Connect(function()
					Args.CallBack(table.clone(Selected),NewEntry)

					if Menu.Uis[1] then
						Menu.Uis[1]:Destroy()
					end
				end)
			end
		end

		Connections[4] = NewEntry.Destroying:Connect(function()
			for i,v in pairs(Connections) do
				v:Disconnect()
			end
		end)
	end

	function Menu:CreateUi(Position,Args : { MenuEntryArg },Selected : { ExplorerNode },Index)
		Index = Index or 1

		local NewUi = MenuUi:Clone()
		NewUi.Parent = MainUi
		NewUi.ZIndex = 1146
		NewUi.Active = true

		if Position then
			NewUi.Position = Position
		end

		for i,v in pairs(Args) do
			Menu:AddEntry(NewUi,v,Selected,Index)
		end

		local RightBottom = NewUi.AbsolutePosition + NewUi.AbsoluteSize

		local ArchorPoint = Vector2.new(0,0)

		if RightBottom.X > MainUi.AbsoluteSize.X then
			ArchorPoint += Vector2.new(1,0)
		end

		if RightBottom.Y > MainUi.AbsoluteSize.Y then
			ArchorPoint += Vector2.new(0,1)
		end

		NewUi.AnchorPoint = ArchorPoint

		Menu.Uis[Index] = NewUi

		return NewUi
	end

	function Menu:Show(Selected : { ExplorerNode })
		local NewButton = Instance.new("TextLabel",MainUi)
		NewButton.ZIndex = 1145
		NewButton.Size = UDim2.new(1,0,1,0)
		NewButton.BackgroundTransparency = 1
		NewButton.Text = ""

		local NeedToDisplay = {}

		for Node,_ in pairs(Selected) do
			for i,v in pairs(Menu.MenuEntries) do
				if Node.Obj:IsA(i) then
					NeedToDisplay[i] = v
				end
			end
		end

		local FinalDisplay = {}

		for i,v in pairs(NeedToDisplay) do
			for i,v in pairs(v) do
				table.insert(FinalDisplay,v)
			end
		end

		local Ui = Menu:CreateUi(UDim2.fromOffset(Mouse.X,Mouse.Y+GuiInsert),FinalDisplay,Selected)

		NeedToDisplay = nil
		FinalDisplay = nil

		local a

		local Event = Instance.new("BindableEvent")

		Ui.Destroying:Once(function()
			if NewButton then
				NewButton:Destroy()
			end

			Event:Fire()

			a:Disconnect()
		end)

		a=NewButton.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton2 then
				Ui:Destroy()
			end
		end)

		Event.Event:Wait()
		Event:Destroy()
	end
end

-- [-[ 资源管理器 ]-]

local EntryFrame
local MoveFrame
local MultipleSelect

do
	local MultipleSelectFrame = Instance.new("Frame")
	MultipleSelectFrame.Name = "MultipleSelectFrame"
	MultipleSelectFrame.Visible = false
	MultipleSelectFrame.BackgroundTransparency = 0.5
	MultipleSelectFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	MultipleSelectFrame.BorderSizePixel = 0
	MultipleSelectFrame.ZIndex = 999
	MultipleSelectFrame.BackgroundColor3 = Color3.fromRGB(0, 115, 255)

	local UIStroke = Instance.new("UIStroke")
	UIStroke.Thickness = 2
	UIStroke.Parent = MultipleSelectFrame
	UIStroke.Color = Color3.fromRGB(0, 145, 255)

	local UICorner = Instance.new("UICorner")
	UICorner.Parent = MultipleSelectFrame
	UICorner.CornerRadius = UDim.new(0, 2)

	MultipleSelect = MultipleSelectFrame
	MultipleSelect.Parent = MainUi
end

do

	local NewEntry = Instance.new("Frame")
	NewEntry.Name = "NewEntry"
	NewEntry.BackgroundTransparency = 1
	NewEntry.Size = UDim2.new(1, 0, 0, 18)
	NewEntry.BorderColor3 = Color3.fromRGB(0, 0, 0)
	NewEntry.BorderSizePixel = 0
	NewEntry.AutomaticSize = Enum.AutomaticSize.XY
	NewEntry.BackgroundColor3 = Color3.fromRGB(0, 0, 255)

	local Children = Instance.new("Folder")
	Children.Name = "Children"
	Children.Parent = NewEntry

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Parent = Children
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local PlaceHolder = Instance.new("ImageLabel")
	PlaceHolder.ImageTransparency = 1
	PlaceHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
	PlaceHolder.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	PlaceHolder.BackgroundTransparency = 1
	PlaceHolder.Parent = Children
	PlaceHolder.Name = "PlaceHolder"
	PlaceHolder.Size = UDim2.fromOffset(0, 18)
	PlaceHolder.BorderSizePixel = 0
	PlaceHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local Main = Instance.new("Folder")
	Main.Name = "Main"
	Main.Parent = NewEntry

	local MainFrame = Instance.new("Frame")
	MainFrame.Parent = Main
	MainFrame.Name = "MainFrame"
	MainFrame.BackgroundTransparency = 1
	MainFrame.Size = UDim2.fromOffset(0, 18)
	MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	MainFrame.BorderSizePixel = 0
	MainFrame.AutomaticSize = Enum.AutomaticSize.X
	MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local ImageLabel = Instance.new("ImageLabel")
	ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ImageLabel.Parent = MainFrame
	ImageLabel.Size = UDim2.fromOffset(16, 16)
	ImageLabel.Image = "rbxassetid://135148380892747"
	ImageLabel.BackgroundTransparency = 1
	ImageLabel.ImageRectSize = Vector2.new(32, 32)
	ImageLabel.SizeConstraint = Enum.SizeConstraint.RelativeXX
	ImageLabel.Position = UDim2.fromOffset(19, 1)
	ImageLabel.BorderSizePixel = 0
	ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local TextButton = Instance.new("TextButton")
	TextButton.TextWrapped = true
	TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextButton.Text = "▲"
	TextButton.Parent = MainFrame
	TextButton.Rotation = 90
	TextButton.Font = Enum.Font.SourceSans
	TextButton.BackgroundTransparency = 1
	TextButton.Size = UDim2.fromOffset(18, 18)
	TextButton.BorderSizePixel = 0
	TextButton.TextSize = 14
	TextButton.TextScaled = true
	TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local UIPadding = Instance.new("UIPadding")
	UIPadding.PaddingTop = UDim.new(0.25, 0)
	UIPadding.PaddingBottom = UDim.new(0.25, 0)
	UIPadding.Parent = TextButton
	UIPadding.PaddingRight = UDim.new(0.25, 0)
	UIPadding.PaddingLeft = UDim.new(0.25, 0)

	local TextLabel = Instance.new("TextLabel")
	TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel.Text = "Labelaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
	TextLabel.Parent = MainFrame
	TextLabel.Size = UDim2.fromOffset(0, 18)
	TextLabel.Position = UDim2.fromOffset(40, 0)
	TextLabel.Font = Enum.Font.SourceSans
	TextLabel.BackgroundTransparency = 1
	TextLabel.TextXAlignment = Enum.TextXAlignment.Left
	TextLabel.BorderSizePixel = 0
	TextLabel.AutomaticSize = Enum.AutomaticSize.X
	TextLabel.TextSize = 16
	TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local Rename = Instance.new("TextBox")
	Rename.ClearTextOnFocus = false
	Rename.Visible = false
	Rename.TextColor3 = Color3.fromRGB(200, 200, 200)
	Rename.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Rename.Parent = TextLabel
	Rename.Size = UDim2.new(1, 8, 1, 0)
	Rename.AnchorPoint = Vector2.new(0.5, 0)
	Rename.Font = Enum.Font.SourceSans
	Rename.Name = "Rename"
	Rename.TextXAlignment = Enum.TextXAlignment.Left
	Rename.Position = UDim2.fromScale(0.5, 0)
	Rename.BorderSizePixel = 0
	Rename.TextSize = 16
	Rename.BackgroundColor3 = Color3.fromRGB(18, 18, 22)

	local UICorner = Instance.new("UICorner")
	UICorner.Parent = Rename
	UICorner.CornerRadius = UDim.new(0, 5)

	local UIPadding = Instance.new("UIPadding")
	UIPadding.Parent = Rename
	UIPadding.PaddingRight = UDim.new(0, 4)
	UIPadding.PaddingLeft = UDim.new(0, 4)

	local UIStroke = Instance.new("UIStroke")
	UIStroke.Color = Color3.fromRGB(1, 90, 255)
	UIStroke.Parent = Rename
	UIStroke.Thickness = 2
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local Lines = Instance.new("Frame")
	Lines.LayoutOrder = -999
	Lines.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Lines.Parent = Main
	Lines.BackgroundTransparency = 1
	Lines.Name = "Lines"
	Lines.Size = UDim2.fromOffset(0, 18)
	Lines.BorderSizePixel = 0
	Lines.AutomaticSize = Enum.AutomaticSize.X
	Lines.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Parent = Lines
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local Line = Instance.new("Frame")
	Line.Parent = UIListLayout
	Line.BackgroundTransparency = 1
	Line.Name = "Line"
	Line.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Line.Size = UDim2.fromOffset(18, 18)
	Line.BorderSizePixel = 0
	Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local Frame = Instance.new("Frame")
	Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	Frame.Parent = Line
	Frame.BackgroundTransparency = 0.75
	Frame.Position = UDim2.fromScale(0.5, 0.5)
	Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Frame.Size = UDim2.new(0, 1, 1, 0)
	Frame.BorderSizePixel = 0
	Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Parent = Main
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local Hover = Instance.new("Frame")
	Hover.Visible = false
	Hover.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Hover.Parent = NewEntry
	Hover.BackgroundTransparency = 0.8999999761581421
	Hover.Name = "Hover"
	Hover.Size = UDim2.new(1, 0, 0, 18)
	Hover.ZIndex = -999
	Hover.BorderSizePixel = 0
	Hover.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local UICorner = Instance.new("UICorner")
	UICorner.Parent = Hover
	UICorner.CornerRadius = UDim.new(0, 5)

	local Select = Instance.new("Frame")
	Select.Visible = false
	Select.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Select.Parent = NewEntry
	Select.BackgroundTransparency = 0.75
	Select.Name = "Select"
	Select.Size = UDim2.fromScale(1, 1)
	Select.ZIndex = -999
	Select.BorderSizePixel = 0
	Select.BackgroundColor3 = Color3.fromRGB(0, 0, 255)

	local SelectFrame2 = Instance.new("Frame")
	SelectFrame2.Parent = Select
	SelectFrame2.Name = "SelectFrame2"
	SelectFrame2.Size = UDim2.new(1, 0, 0, 18)
	SelectFrame2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	SelectFrame2.ZIndex = -999
	SelectFrame2.BorderSizePixel = 0
	SelectFrame2.BackgroundColor3 = Color3.fromRGB(20, 20, 255)

	local UICorner = Instance.new("UICorner")
	UICorner.Parent = SelectFrame2
	UICorner.CornerRadius = UDim.new(0, 5)

	local UICorner = Instance.new("UICorner")
	UICorner.Parent = Select
	UICorner.CornerRadius = UDim.new(0, 5)

	local Hit = Instance.new("TextButton")
	Hit.TextColor3 = Color3.fromRGB(0, 0, 0)
	Hit.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Hit.Text = ""
	Hit.Parent = NewEntry
	Hit.Name = "Hit"
	Hit.Font = Enum.Font.SourceSans
	Hit.BackgroundTransparency = 1
	Hit.BorderSizePixel = 0
	Hit.Size = UDim2.new(1, 0, 0, 18)
	Hit.ZIndex = -9999
	Hit.TextSize = 14
	Hit.BackgroundColor3 = Color3.fromRGB(255, 255, 255)



	EntryFrame = NewEntry
end

do
	local Move = Instance.new("Frame")
	Move.Parent = MainUi
	Move.Visible = false
	Move.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Move.Name = "Move"
	Move.Position = UDim2.fromScale(0.32903021574020386, 0.426367849111557)
	Move.Size = UDim2.fromOffset(0, 23)
	Move.BorderSizePixel = 0
	Move.ZIndex = 999
	Move.AutomaticSize = Enum.AutomaticSize.X
	Move.BackgroundColor3 = Color3.fromRGB(15, 17, 22)

	local TextLabel = Instance.new("TextLabel")
	TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel.Text = "Workspace"
	TextLabel.Parent = Move
	TextLabel.Size = UDim2.fromScale(0, 1)
	TextLabel.Position = UDim2.fromOffset(24, 0)
	TextLabel.Font = Enum.Font.SourceSans
	TextLabel.BackgroundTransparency = 1
	TextLabel.TextXAlignment = Enum.TextXAlignment.Left
	TextLabel.BorderSizePixel = 0
	TextLabel.AutomaticSize = Enum.AutomaticSize.X
	TextLabel.TextSize = 16
	TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local UIPadding = Instance.new("UIPadding")
	UIPadding.PaddingRight = UDim.new(0, 4)
	UIPadding.Parent = TextLabel

	local UICorner = Instance.new("UICorner")
	UICorner.Parent = Move
	UICorner.CornerRadius = UDim.new(0, 5)

	local ImageButton = Instance.new("ImageButton")
	ImageButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ImageButton.Parent = Move
	ImageButton.Size = UDim2.fromOffset(16, 16)
	ImageButton.AutoButtonColor = false
	ImageButton.AnchorPoint = Vector2.new(0, 0.5)
	ImageButton.Image = "rbxassetid://135148380892747"
	ImageButton.BackgroundTransparency = 1
	ImageButton.ImageRectSize = Vector2.new(32, 32)
	ImageButton.SizeConstraint = Enum.SizeConstraint.RelativeXX
	ImageButton.Position = UDim2.new(0, 5, 0.5, 0)
	ImageButton.BorderSizePixel = 0
	ImageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	MoveFrame = Move
end


type ExplorerNode = {
	Parent : ExplorerNode,
	Children : {ExplorerNode},
	Obj : Instance,
	Del : boolean,
	Ui : Frame, --EntryFrame
	Rename : () -> (),
	DisplayName : string,
	DisibleChangeConnection : boolean,
}

Modules.Explorer = {
	Nodes = {},
	Expanded = {},

	Uis = {},

	Selected = {} :: {ExplorerNode},
	MultipleSelect = false,
	Hoving = nil :: ExplorerNode,
}

const Explorer = Modules.Explorer

function Explorer:Init()
	const RMD = Modules.InitModules["RMD"]
	const maxNameWidth,maxDepth,count = 0,1,1
	const expanded = Explorer.Expanded
	const ExplorerUi = MainUi.Explorer

	const explorerOrders = {}

	local idCounter = 0

	function Explorer.NodeSorter(a,b)
		if a.Del or b.Del then return false end -- Ghost node

		local aClass = a.Class
		local bClass = b.Class
		if not aClass then aClass = a.Obj.ClassName a.Class = aClass end
		if not bClass then bClass = b.Obj.ClassName b.Class = bClass end

		local aOrder = explorerOrders[aClass]
		local bOrder = explorerOrders[bClass]
		if not aOrder then aOrder = RMD.Classes[aClass] and tonumber(RMD.Classes[aClass].ExplorerOrder) or 9999 explorerOrders[aClass] = aOrder end
		if not bOrder then bOrder = RMD.Classes[bClass] and tonumber(RMD.Classes[bClass].ExplorerOrder) or 9999 explorerOrders[bClass] = bOrder end

		if aOrder ~= bOrder then
			return aOrder < bOrder
		else
			local aName,bName = tostring(a.Obj),tostring(b.Obj)
			if aName ~= bName then
				return aName < bName
			elseif aClass ~= bClass then
				return aClass < bClass
			else
				local aId = a.Id if not aId then aId = idCounter idCounter = (idCounter+0.001)%999999999 a.Id = aId end
				local bId = b.Id if not bId then bId = idCounter idCounter = (idCounter+0.001)%999999999 b.Id = bId end
				return aId < bId
			end
		end
	end

	function Explorer.NodeDepth(node)
		if node.Root then
			return 0
		end

		local depth = 0

		local cur = node

		while cur and not cur.Root do
			cur = cur.Parent
			depth = depth + 1
		end

		return depth
	end

	const function sort(root)
		table.sort(root.Children,Explorer.NodeSorter)
	end

	const function EntryUpdate(Entry,Obj)
		if typeof(Entry)=="table" then Entry = Entry.Ui end
		if not Entry or not Entry:FindFirstChild("Main") then
			return
		end

		if not Obj and not Explorer.Uis[Entry] then
			return
		end

		local Node : ExplorerNode

		if Obj then
			Node = Explorer.Nodes[Obj]
		else
			Node = Explorer.Uis[Entry]
			Obj = Node.Obj
		end

		if not Node then
			return
		end

		Entry.Main.MainFrame.TextLabel.Text = Node.DisplayName or Obj.Name

		local NoRootChild = 0

		for i,v in ipairs(Node.Children) do
			if v.Root then
				continue
			end

			NoRootChild = NoRootChild + 1
		end

		Entry.Main.MainFrame.TextButton.Visible = NoRootChild > 0
		Entry.Main.MainFrame.TextButton.Rotation = expanded[Node] and 180 or 90

		IconMap:GetClassIcon(Entry.Main.MainFrame.ImageLabel,Obj.ClassName)

		const depth = Explorer.NodeDepth(Node)
		const LinesFrame = Entry.Main.Lines

		for i,v in ipairs(LinesFrame:GetChildren()) do
			if v:IsA("Frame") then
				v:Destroy()
			end
		end

		for i=1,depth do
			local NewLine = LinesFrame.UIListLayout.Line:Clone()
			NewLine.Parent = LinesFrame
		end

		if Explorer.Selected[Node] then
			Entry.Select.Visible = true
		else
			Entry.Select.Visible = false
		end
	end

	const function SetSelect(Node,Selected)
		if Selected then
			Explorer.Selected[Node] = true
		else
			Explorer.Selected[Node] = nil
		end

		if Node.Ui then
			EntryUpdate(Node.Ui,Node.Obj)
		end
	end

	const function ClearSelect(Exclude)
		Exclude = Exclude or {}
		for i,v in pairs(Explorer.Selected) do
			if Exclude[i] or not Explorer.Selected[i] then
				continue
			end
			SetSelect(i,false)
		end
	end

	const function ObjSelect(Node)
		if not Explorer.Selected[Node] then

			if not Explorer.MultipleSelect then
				ClearSelect()
			end

			SetSelect(Node,true)
		else
			if Explorer.MultipleSelect then
				SetSelect(Node,false)
			else
				ClearSelect()

				SetSelect(Node,true)
			end
		end
	end

	Explorer.SetSelect = SetSelect
	Explorer.ObjSelect = ObjSelect
	Explorer.ClearSelect = ClearSelect

	const function CreateNewEntry(Node,DisplayName)
		const NewEntry = EntryFrame:Clone()
		const Button = NewEntry.Main.MainFrame.TextButton

		const Connections = {}

		table.insert(Connections,Button.MouseButton1Click:Connect(function()
			if expanded[Node] then
				Explorer:UnExpand(Node)
			else
				Explorer:Expand(Node)
			end
		end))

		EntryUpdate(NewEntry,Node.Obj)

		Node.Ui = NewEntry

		Explorer.Uis[NewEntry] = Node

		table.insert(Connections,NewEntry.Destroying:Connect(function()
			if Node.Ui and Node.Ui == NewEntry then
				Node.Ui = nil
			end
			for i,v in ipairs(Connections) do
				v:Disconnect()
			end
			Explorer.Uis[NewEntry] = nil
		end))

		local LabelHoving = false

		local MenuHold = false


		table.insert(Connections,NewEntry.Hit.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				if MultipleSelect.Visible then return end
				local MenuHoldTick = tick()

				if not (LabelHoving and GetLength(Explorer.Selected) > 1) and not MultipleSelect.Visible then
					ObjSelect(Node)
				end

				if not LabelHoving then
					local firstpos = input.Position
					local MousePosition = Vector2.new(Mouse.X, Mouse.Y)
					local CanvasPosition = ExplorerUi.ScrollingFrame.CanvasPosition
					local FirstPosition = MousePosition + Vector2.new(CanvasPosition.X, CanvasPosition.Y)

					local Dragging = false
					local StartDrag = false
					local SelectedNodes = {}

					local ScrollingFrame = ExplorerUi.ScrollingFrame
					local MultipleSelect = MultipleSelect

					local NodeCache = {}
					local CacheVersion = 0
					local LastCacheUpdate = 0
					local CACHE_REFRESH_INTERVAL = 0.1
					
					local function Find(frame)
						for i,v in ipairs(NodeCache) do
							if v.frame == frame then
								return i
							end
						end
					end

					local function UpdateNodeCache(force)
						local currentTime = tick()
						if not force and (currentTime - LastCacheUpdate) < CACHE_REFRESH_INTERVAL then
							return
						end

						LastCacheUpdate = currentTime
						CacheVersion = CacheVersion + 1

						local canvasPos = ScrollingFrame.CanvasPosition
						local viewTop = ScrollingFrame.AbsolutePosition.Y
						local viewBottom = viewTop + ScrollingFrame.AbsoluteSize.Y

						local BUFFER = 200
						local visibleTop = viewTop - BUFFER
						local visibleBottom = viewBottom + BUFFER

						local newCache = {}
						local cacheIndex = 1

						for v, Node in pairs(Explorer.Uis) do
							if v:IsA("Frame") then
								local absPos = v.AbsolutePosition
								local nodeTop = absPos.Y + GuiInsert
								local nodeBottom = absPos.Y + 18 + GuiInsert

								if (nodeBottom >= visibleTop and nodeTop <= visibleBottom) or Find(v) then
									newCache[cacheIndex] = {
										node = Node,
										frame = v,
										top = nodeTop,
										bottom = nodeBottom,
										centerY = absPos.Y + GuiInsert,
										ref = v
									}
									cacheIndex = cacheIndex + 1
								end
							end
						end

						NodeCache = newCache
					end

					UpdateNodeCache(true)

					local function UpdateSelection(top, bottom, currentSelected)
						local newSelected = {}
						local needFullUpdate = false

						if #NodeCache == 0 or CacheVersion == 0 then
							UpdateNodeCache(true)
						end

						for _, cache in ipairs(NodeCache) do
							if not cache.frame or not cache.frame.Parent then
								needFullUpdate = true
								break
							end

							local centerY = cache.centerY
							local centerYBottom = cache.bottom

							local isSelected = (centerY > top and centerY < bottom) or 
								(centerYBottom > top and centerYBottom < bottom)

							if isSelected then
								SetSelect(cache.node, true)
								newSelected[cache.node] = true
							end
						end

						if needFullUpdate then
							UpdateNodeCache(true)
							return UpdateSelection(top, bottom, currentSelected)
						end

						for node, _ in pairs(currentSelected) do
							if not newSelected[node] then
								SetSelect(node, false)
							end
						end

						return newSelected
					end



					local lastUpdateTime = 0
					local UPDATE_INTERVAL = 0.033
					local frameCount = 0

					local function CheckMovement()
						local currentMousePos = Vector2.new(Mouse.X, Mouse.Y)

						if Dragging then
							ScrollingFrame.ScrollingEnabled = false
							ScrollingFrame:SetAttribute("AutoScrolling", "Muilt")
							ScrollingFrame:SetAttribute("Disibled", true)

							local canvasPos = ScrollingFrame.CanvasPosition
							local inputPos = currentMousePos + Vector2.new(canvasPos.X, canvasPos.Y)

							canvasPos = ScrollingFrame.CanvasPosition

							local offset = UDim2.fromOffset(
								inputPos.X - FirstPosition.X,
								inputPos.Y - FirstPosition.Y
							)

							local firstPos = UDim2.fromOffset(
								FirstPosition.X - canvasPos.X,
								FirstPosition.Y + GuiInsert - canvasPos.Y
							)

							MultipleSelect.Size = offset
							MultipleSelect.Position = firstPos
							MultipleSelect.Visible = true

							local top = firstPos.Y.Offset
							local bottom = firstPos.Y.Offset + offset.Y.Offset
							if offset.Y.Offset < 0 then
								top, bottom = bottom, top
							end

							local currentTime = tick()
							frameCount = frameCount + 1

							if currentTime - lastUpdateTime >= UPDATE_INTERVAL then
								lastUpdateTime = currentTime

								if frameCount % 5 == 0 then
									UpdateNodeCache(false)
								end

								SelectedNodes = UpdateSelection(top, bottom, SelectedNodes)
							end

							return
						end

						if MultipleSelect.Visible then return end
						
						if input.UserInputType == Enum.UserInputType.Touch then
							if tick() - MenuHoldTick > 0.5 and 
								(currentMousePos - Vector2.new(firstpos.X, firstpos.Y)).Magnitude < 5 then
								StartDrag = true
								return
							elseif not StartDrag then return
							end
						end

						if (currentMousePos - Vector2.new(firstpos.X, firstpos.Y)).Magnitude > 3 then
							Dragging = true
							UpdateNodeCache(true)
						end
					end

					local ScrollListener
					ScrollListener = ScrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
						if Dragging then
							task.defer(function()
								UpdateNodeCache(true)
							end)
						end
					end)

					local Movement = RunService.Heartbeat:Connect(function(dt)
						CheckMovement()
					end)

					local InputEnded;InputEnded = UserInputService.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or 
							input.UserInputType == Enum.UserInputType.Touch then

							if Dragging then
								MultipleSelect.Visible = false
								Dragging = false

								local canvasPos = ScrollingFrame.CanvasPosition
								local inputPos = Vector2.new(Mouse.X, Mouse.Y) + Vector2.new(canvasPos.X, canvasPos.Y)
								local offset = UDim2.fromOffset(
									inputPos.X - FirstPosition.X,
									inputPos.Y - FirstPosition.Y
								)
								local firstPos = UDim2.fromOffset(
									FirstPosition.X - canvasPos.X,
									FirstPosition.Y + GuiInsert - canvasPos.Y
								)
								local top = firstPos.Y.Offset
								local bottom = firstPos.Y.Offset + offset.Y.Offset
								if offset.Y.Offset < 0 then top, bottom = bottom, top end

								UpdateNodeCache(true)
								SelectedNodes = UpdateSelection(top, bottom, SelectedNodes)
							elseif tick() - MenuHoldTick >= 0.5 then
								if (input.Position - firstpos).Magnitude < 5 then
									task.defer(function()
										MenuHold = true
										Explorer:ShowMenu()
										MenuHold = false
									end)
								end
							end

							ScrollingFrame.ScrollingEnabled = true
							ScrollingFrame:SetAttribute("Disibled", nil)
							ScrollingFrame:SetAttribute("AutoScrolling", nil)

							Movement:Disconnect()
							InputEnded:Disconnect()
							ScrollListener:Disconnect()

							-- 清理
							NodeCache = {}
							SelectedNodes = {}
						end
					end)
				end
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
				if not Explorer.Selected[Node] and not MultipleSelect.Visible then
					ObjSelect(Node)
				end
			end
		end))

		local DoubleClick = false
		local LastClick = tick()

		table.insert(Connections,NewEntry.Hit.MouseButton1Click:Connect(function()
			if tick() - LastClick < 0.5 then
				DoubleClick = true

				if Explorer.Expanded[Node] then
					Explorer:UnExpand(Node)
				else
					Explorer:Expand(Node)
				end

				local tic = tick()

				LastClick = tic

				task.delay(.5,function()
					if LastClick == tic then
						DoubleClick = false
					end
				end)

				return
			elseif not DoubleClick then
				LastClick = tick()
			else
				DoubleClick = false
			end
		end))

		table.insert(Connections,NewEntry.Hit.MouseButton2Click:Connect(function()
			Explorer:ShowMenu()
		end))

		if not Node.DisplayName then
			table.insert(Connections,Node.Obj:GetPropertyChangedSignal("Name"):Connect(function()
				if Node.Ui then
					EntryUpdate(Node.Ui,Node.Obj)
				end
			end))
		end

		table.insert(Connections,Node.Obj.Destroying:Connect(function()
			NewEntry:Destroy()
			return
		end))

		local function LabelConnectFunction(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				if MultipleSelect.Visible then
					return
				end
				local IsSelected = Explorer.Selected[Node]
				local HoldTime = tick()
				LabelHoving = true
				local FirstPos = input.Position
				local Movement,Movement2,InputEnded
				local Dragging = false

				local function CheckMovement(input)
					if MultipleSelect.Visible then return end
					if Dragging then
						ExplorerUi.ScrollingFrame.ScrollingEnabled = false
						ExplorerUi.ScrollingFrame:SetAttribute("AutoScrolling", "Label")
						ExplorerUi.ScrollingFrame:SetAttribute("Disibled", true)
						MoveFrame.Position = UDim2.fromOffset(input.Position.X,input.Position.Y+68)

						local Selected = 0
						for _, Node in pairs(Explorer.Selected) do
							Selected += 1
						end

						if Selected == 1 then
							MoveFrame.TextLabel.Text = Node.Obj.Name
							MoveFrame.TextLabel.Position = UDim2.fromOffset(24,0)
							MoveFrame.TextLabel.UIPadding.PaddingLeft = UDim.new(0,0)
							MoveFrame.ImageButton.Visible = true
							IconMap:GetClassIcon(MoveFrame.ImageButton,Node.Obj.ClassName)
						else
							MoveFrame.ImageButton.Visible = false
							MoveFrame.TextLabel.Text = "Move "..Selected.." items"
							MoveFrame.TextLabel.Position = UDim2.fromOffset(0,0)
							MoveFrame.TextLabel.UIPadding.PaddingLeft = UDim.new(0,4)
						end

						MoveFrame.Visible = true
						return
					end

					if input.UserInputType == Enum.UserInputType.Touch then
						if (input.Position - FirstPos).Magnitude < 3 and tick()-HoldTime > .5 then
							Dragging = true
						end
					elseif (input.Position - FirstPos).Magnitude > 3 then
						Dragging = true
					end
				end

				Movement = UserInputService.InputChanged:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						CheckMovement(input)
					end
				end)

				Movement2 = UserInputService.TouchMoved:Connect(function(input)
					CheckMovement(input)
				end)

				InputEnded = UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then

						if Dragging then
							local Hoving = Explorer.Hoving
							if Hoving and Node ~= game and not Explorer.Selected[Hoving] then
								local ToSelect = {}

								for Node1, _ in pairs(Explorer.Selected) do
									local obj = Node1.Obj
									if obj:IsAncestorOf(Hoving.Obj) then continue end
									if table.find(Hoving.Obj:GetChildren(),obj) then continue end
									if not CanChangeParent(obj) then continue end
									
									Node1.Obj.Parent = Hoving.Obj
								end
								
								local Node1,_ = next(Explorer.Selected)
								
								task.defer(function()
									Explorer:Expand(Hoving)
									
									Explorer:JumpTo(Node1)
								end)
							end

							ExplorerUi.ScrollingFrame:SetAttribute("AutoScrolling", nil)
							ExplorerUi.ScrollingFrame:SetAttribute("Disibled", nil)
						else
							if GetLength(Explorer.Selected) > 1 then
								if not MultipleSelect.Visible then
									ObjSelect(Node)
								end
							else
								if (input.Position - FirstPos).Magnitude < 5 then
									if not DoubleClick and not MenuHold and IsSelected then
										task.delay(.5,function()
											if not DoubleClick and not MenuHold then
												Node:Rename()
											end

											if DoubleClick then
												DoubleClick = false
											end
										end)
									end
								end
							end
						end

						MoveFrame.Visible = false
						LabelHoving = false

						Movement:Disconnect()
						Movement2:Disconnect()
						InputEnded:Disconnect()
					end
				end)
			end
		end

		table.insert(Connections,NewEntry.Main.MainFrame.TextLabel.InputBegan:Connect(LabelConnectFunction))
		table.insert(Connections,NewEntry.Main.MainFrame.ImageLabel.InputBegan:Connect(LabelConnectFunction))
		return NewEntry
	end

	local function Refresh(v)
		if v.Ui then
			EntryUpdate(v.Ui,v.Obj)
		end
		if not v.Children then return end

		for i, v in ipairs(v.Children) do
			Refresh(v)
		end
	end

	function Explorer:RefreshNode(Node1)
		local Obj = Node1.Obj
		local OldParent = Node1.Parent

		local OldIndex = table.find(OldParent.Children,Node1)
		if OldIndex then
			table.remove(OldParent.Children,OldIndex)
		end
		
		if OldParent.Ui then
			EntryUpdate(OldParent)
		end

		local NewParent = Node1.Obj.Parent
		local NewParentNode = Explorer.Nodes[NewParent]
		
		if NewParentNode then
			table.insert(NewParentNode.Children,Node1)
			Node1.Parent = NewParentNode

			if NewParentNode.Ui then
				if expanded[NewParentNode] then
					if not Node1.Ui then
						local Newui = CreateNewEntry(Node1)
						Node1.Ui = Newui
						Newui.Parent = NewParentNode.Ui.Children
					end
					
					Refresh(Node1)
				elseif Node1.Ui then
					Node1.Ui:Destroy()
				end
			end

			EntryUpdate(NewParentNode)
		else
			Node1.Parent = nil
		end
	end
	
	function Explorer:JumpTo(Node)
		local Ui = Node.Ui
		if not Ui then return end
		
		local Position = Ui.AbsolutePosition.Y
		
		local Scroll = ExplorerUi.ScrollingFrame
		
		local ScrollPosition =  Scroll.AbsolutePosition.Y
		local ScrollSize = Scroll.AbsoluteSize.Y
		
		if Position < ScrollPosition or Position > ScrollPosition + ScrollSize then
			Scroll.CanvasPosition = Vector2.new(0,Position - Scroll.AbsolutePosition.Y - Scroll.AbsoluteSize.Y/2)
		end
	end

	function Explorer:RefreshUi(Node)
		if not expanded[Node] then
			return "Alr has"
		end

		if not Node.Ui or not Node.Ui:FindFirstChild("Children") then
			return "No ui"
		end

		local NoRootChild = 0

		for i,v in ipairs(Node.Children) do
			if v.Root then
				continue
			end

			NoRootChild = NoRootChild + 1
		end

		if NoRootChild == 0 then
			Explorer:UnExpand(Node)
		end

		Node.Ui.Main.MainFrame.TextButton.Rotation = 180

		sort(Node)

		for i, childUi in ipairs(Node.Ui.Children:GetChildren()) do
			if childUi:IsA("Frame") then
				if Explorer.Uis[childUi] then
					Explorer.Uis[childUi].Ui = nil
				end
				
				childUi:Destroy()
			end
		end
		
		for i, v in ipairs(Node.Children) do
			if v.Root or v.Ui then
				continue
			end

			local NewEntry = CreateNewEntry(v)
			NewEntry.Parent = Node.Ui.Children
			v.Ui = NewEntry

			if expanded[v] then
				Explorer:RefreshUi(v)
			end
		end
	end

	function Explorer.ObjAdded(Obj, Root)
		local existing = Explorer.Nodes[Obj]
		if existing then return existing end

		if not Obj.Parent and Obj ~= game then
			return
		end

		local ParentNode = Explorer.Nodes[Obj.Parent]

		local Node : ExplorerNode = {
			Obj = Obj,
			Parent = ParentNode,
			Children = {},
			Rename = function(self:ExplorerNode)
				local Ui = self.Ui

				if Ui then
					local CurrentName = self.Obj.Name

					local TextBox:TextBox = Ui.Main.MainFrame.TextLabel.Rename

					TextBox.Text = CurrentName
					TextBox.Visible = true

					TextBox:CaptureFocus()

					local a;a = TextBox.FocusLost:Connect(function()
						CurrentName = TextBox.Text
						if self.Obj.Name ~= CurrentName then
							self.Obj.Name = CurrentName
						end

						TextBox.Visible = false
						a:Disconnect()
					end)
				end
			end,
			Root = Root == "true",
		}

		if ParentNode then
			table.insert(ParentNode.Children,Node)
		elseif not Node.Root then
			Explorer.ObjAdded(Obj.Parent)

			ParentNode = Explorer.Nodes[Obj.Parent]

			Node.Parent = ParentNode

			table.insert(ParentNode.Children,Node)
		end

		Explorer.Nodes[Obj] = Node

		for i, v in ipairs(Obj:GetChildren()) do
			Explorer.ObjAdded(v)
		end

		if ParentNode and ParentNode.Ui then
			EntryUpdate(ParentNode.Ui,ParentNode.Obj)

			if expanded[ParentNode] then
				local Newui = CreateNewEntry(Node)
				
				Node.Ui = Newui
				
				Newui.Parent = ParentNode.Ui.Children
			end
			--Explorer:RefreshUi(ParentNode)
		end

		Node.Connection = Obj:GetPropertyChangedSignal("Parent"):Connect(function()
			if not Obj.Parent or not Explorer.Nodes[Obj] then return end
			
			Explorer:RefreshNode(Node)
		end)

		return Node
	end

	function Explorer.ObjRemoved(Obj)
		local Node = Explorer.Nodes[Obj]
		if not Node then return end

		local ParentNode = Node.Parent
		if ParentNode then
			local idx = table.find(ParentNode.Children, Node)
			if idx then table.remove(ParentNode.Children, idx) end
			if ParentNode.Ui then
				--Explorer:RefreshUi(ParentNode)
				EntryUpdate(ParentNode.Ui,ParentNode.Obj)
			end
		end

		if Node.Ui then Node.Ui:Destroy() end

		for i,v in pairs(Node.Children) do
			Explorer.ObjRemoved(v.Obj)
		end

		Explorer.Nodes[Obj] = nil

		if Explorer.Hoving == Node then Explorer.Hoving = nil end
		if Explorer.Selected[Node] then Explorer.Selected[Node] = nil end

		if Node.Connection then
			Node.Connection:Disconnect()
		end

		Node = nil
	end

	function Explorer:Expand(Node, forceRefresh)
		if typeof(Node) == "Instance" then
			Node = Explorer.Nodes[Node]
		end
		if not forceRefresh and expanded[Node] then
			return "Alr has"
		end
		expanded[Node] = true
		local err = Explorer:RefreshUi(Node)
		EntryUpdate(Node.Ui, Node.Obj)
		return err
	end
	
	function Explorer:ExpandAll(Node)
		if typeof(Node) == "Instance" then
			Node = Explorer.Nodes[Node]
		end
		Explorer:Expand(Node)
		for i,v in ipairs(Node.Children) do
			Explorer:ExpandAll(v)
		end
	end
	
	function Explorer:UnExpandAll(Node)
		if typeof(Node) == "Instance" then
			Node = Explorer.Nodes[Node]
		end
		
		Explorer:UnExpand(Node)
		for i,v in ipairs(Node.Children) do
			Explorer:UnExpand(v)
		end
	end

	function Explorer:ExpandAllParent(Node)
		if typeof(Node) == "Instance" then
			Node = Explorer.Nodes[Node]
		end

		local par = Node.Parent
		
		while par do
			if not expanded[par] then
				Explorer:Expand(par)
			end
			par = par.Parent
		end

		--Explorer:Expand(Node)
	end

	function Explorer:UnExpand(Node)
		if typeof(Node) == "Instance" then
			Node = Explorer.Nodes[Node]
		end
		expanded[Node] = nil

		if Node.Ui and Node.Ui:FindFirstChild("Children") then
			for i,v in ipairs(Node.Ui.Children:GetChildren()) do
				if v:IsA("Frame") then
					v:Destroy()
				end
			end

			EntryUpdate(Node.Ui,Node.Obj)
		end
	end

	function Explorer:ShowMenu()
		local Selected = Explorer.Selected

		if GetLength(Selected) == 0 then
			return
		end

		Menu:Show(Selected)
	end

	Explorer.Roots = {}

	function Explorer:NewRoot(Obj,DisplayName,Expand)
		Explorer.ObjAdded(Obj,"true")

		local Node = Explorer.Nodes[Obj]
		Node.Root = true
		Node.DisplayName = DisplayName

		Explorer.Roots[Obj] = Node

		if Node.Parent then
			Explorer:RefreshUi(Node.Parent)
		end

		local NewEntry = CreateNewEntry(Node)
		NewEntry.Parent = ExplorerUi.ScrollingFrame
		Node.Ui = NewEntry

		for i,v in pairs(Obj:GetDescendants()) do
			Explorer.ObjAdded(v)
		end

		table.insert(DexEnv.Connections,Obj.DescendantAdded:Connect(Explorer.ObjAdded))
		table.insert(DexEnv.Connections,Obj.DescendantRemoving:Connect(Explorer.ObjRemoved))


		if Expand then
			Explorer:Expand(Obj)
		end
	end

	function Explorer:RemoveRoot(Obj)
		local Node = Explorer.Nodes[Obj]
		if not Node or not Explorer.Roots[Obj] then warn("No node") return end

		Node.Root = nil
		Explorer.Roots[Obj] = nil

		if Node.Ui then
			Node.Ui:Destroy()
		end

		if Node.Parent then
			EntryUpdate(Node.Parent.Ui,Node.Parent.Obj)

			Explorer:RefreshUi(Node.Parent)
		end
	end
	Explorer:NewRoot(Player,`LocalPlayer({Player.Name})`)
	
	Explorer:NewRoot(game,`game({game.Name})`,true)

	Explorer:NewRoot(DexEnv.genv.gethui(),`HiddenGui({DexEnv.genv.gethui().Name})`)
	
	const ScrollBarFrame = ExplorerUi.Scroll

	local HovingScrollBar = false
	local ScrollDragging = false

	ScrollBarFrame.Right.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			ScrollDragging = true
			local a;a = ScrollBarFrame.Right.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					ScrollDragging = false
					a:Disconnect()
				end
			end)
		end
	end)
	ScrollBarFrame.Down.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			ScrollDragging = true
			local a;a = ScrollBarFrame.Down.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					ScrollDragging = false
				end
			end)
		end
	end)

	ExplorerUi.MouseEnter:Connect(function()
		local a;a = UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				ExplorerUi.ScrollingFrame.ScrollingEnabled = false
				local Delta = input.Position.Z

				if Delta and Delta ~= 0 then
					ExplorerUi.ScrollingFrame.CanvasPosition += Vector2.new(0,-Delta*18*3)
				end

				ExplorerUi.ScrollingFrame.ScrollingEnabled = true
			end
		end)

		local b;b = ExplorerUi.MouseLeave:Connect(function()
			a:Disconnect()
			b:Disconnect()
		end)
	end)

	table.insert(DexEnv.Connections,UserInputService.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			ExplorerUi.ScrollingFrame.ScrollingEnabled = false
		end
	end))

	table.insert(DexEnv.Connections,UserInputService.TouchMoved:Connect(function()
		if not ExplorerUi.ScrollingFrame:GetAttribute("Disibled") then
			ExplorerUi.ScrollingFrame.ScrollingEnabled = true
		end
	end))

	table.insert(DexEnv.Connections,RunService.RenderStepped:Connect(function(deltaTime : number)
		if ExplorerUi.ScrollingFrame:GetAttribute("AutoScrolling") then
			local ScrollingFrame = ExplorerUi.ScrollingFrame
			local yTop = ScrollingFrame.AbsolutePosition.Y-- + GuiInsert
			local yBottom = yTop + ScrollingFrame.AbsoluteSize.Y

			local mouseY = Mouse.Y
			local canvasPos = ScrollingFrame.CanvasPosition
			
			local M = .25

			local newCanvasY = canvasPos.Y
			local shouldScroll = false
			
			local Top = 20
			local Bottom = 20

			if mouseY <= yTop + Top then
				local scrollAmount = ((yTop + Top) - mouseY) * M
				newCanvasY = canvasPos.Y - scrollAmount
				shouldScroll = true
			elseif mouseY >= yBottom - Bottom then
				local scrollAmount = (mouseY - (yBottom - Bottom)) * M
				newCanvasY = canvasPos.Y + scrollAmount
				shouldScroll = true
			end

			if shouldScroll then
				if newCanvasY ~= canvasPos.Y then
					ScrollingFrame.CanvasPosition = Vector2.new(canvasPos.X, newCanvasY)
				end
			end
		end

		local MousePosition = Vector2.new(Mouse.X,Mouse.Y)
		local HaveHover = false

		if ScrollDragging then
			HovingScrollBar = true
		else
			if PointInArea(MousePosition,ScrollBarFrame.Right.AbsolutePosition,ScrollBarFrame.Right.AbsolutePosition+ScrollBarFrame.Right.AbsoluteSize) then
				HovingScrollBar = true
				if not ExplorerUi.ScrollingFrame:GetAttribute("Disibled") then
					ExplorerUi.ScrollingFrame.ScrollingEnabled = true
				end
			elseif PointInArea(MousePosition,ScrollBarFrame.Down.AbsolutePosition,ScrollBarFrame.Down.AbsolutePosition+ScrollBarFrame.Down.AbsoluteSize) then
				HovingScrollBar = true
				if not ExplorerUi.ScrollingFrame:GetAttribute("Disibled") then
					ExplorerUi.ScrollingFrame.ScrollingEnabled = true
				end
			else
				HovingScrollBar = false
				ScrollBarFrame.Right.UIStroke.Enabled = false
				ScrollBarFrame.Down.UIStroke.Enabled = false
			end
		end

		if not HovingScrollBar then
			for frame,node in pairs(Explorer.Uis) do
				if PointInArea(MousePosition,frame.AbsolutePosition,frame.AbsolutePosition+Vector2.new(frame.AbsoluteSize.X,18)) then
					HaveHover = true
					if Explorer.Hoving and Explorer.Hoving ~= node then
						local Entry = Explorer.Hoving.Ui
						if Entry then
							Entry.Hover.Visible = false
						end
					end

					frame.Hover.Visible = true
					Explorer.Hoving = node
					ExplorerUi.ScrollingFrame.ScrollingEnabled = false
					break
				end
			end
		end

		if not HaveHover then
			if Explorer.Hoving then
				local Entry = Explorer.Hoving.Ui
				if Entry then
					Entry.Hover.Visible = false
				end
				Explorer.Hoving = nil
			end

			if not ExplorerUi.ScrollingFrame:GetAttribute("Disibled") then
				ExplorerUi.ScrollingFrame.ScrollingEnabled = true
			end
		end
	end))
end

-- [-[ 初始化 ]-]

function Modules:FetchRMD()
	local parsed = Modules.ParseXML(Modules.InitModules.RawRMD)
	local classList = parsed.children[1].children[1].children
	local enumList = parsed.children[1].children[2].children
	local propertyOrders = {}

	local classes,enums = {},{}
	for _,class in pairs(classList) do
		local className = ""
		for _,child in pairs(class.children) do
			if child.tag == "Properties" then
				local data = {Properties = {}, Functions = {}}
				local props = child.children
				for _,prop in pairs(props) do
					local name = prop.attrs.name
					name = name:sub(1,1):upper()..name:sub(2)
					data[name] = prop.children[1].text
				end
				className = data.Name
				classes[className] = data
			elseif child.attrs.class == "ReflectionMetadataProperties" then
				local members = child.children
				for _,member in pairs(members) do
					if member.attrs.class == "ReflectionMetadataMember" then
						local data = {}
						if member.children[1].tag == "Properties" then
							local props = member.children[1].children
							for _,prop in pairs(props) do
								if prop.attrs then
									local name = prop.attrs.name
									name = name:sub(1,1):upper()..name:sub(2)
									data[name] = prop.children[1].text
								end
							end
							if data.PropertyOrder then
								local orders = propertyOrders[className]
								if not orders then orders = {} propertyOrders[className] = orders end
								orders[data.Name] = tonumber(data.PropertyOrder)
							end
							classes[className].Properties[data.Name] = data
						end
					end
				end
			elseif child.attrs.class == "ReflectionMetadataFunctions" then
				local members = child.children
				for _,member in pairs(members) do
					if member.attrs.class == "ReflectionMetadataMember" then
						local data = {}
						if member.children[1].tag == "Properties" then
							local props = member.children[1].children
							for _,prop in pairs(props) do
								if prop.attrs then
									local name = prop.attrs.name
									name = name:sub(1,1):upper()..name:sub(2)
									data[name] = prop.children[1].text
								end
							end
							classes[className].Functions[data.Name] = data
						end
					end
				end
			end
		end
	end

	for _,enum in pairs(enumList) do
		local enumName = ""
		for _,child in pairs(enum.children) do
			if child.tag == "Properties" then
				local data = {Items = {}}
				local props = child.children
				for _,prop in pairs(props) do
					local name = prop.attrs.name
					name = name:sub(1,1):upper()..name:sub(2)
					data[name] = prop.children[1].text
				end
				enumName = data.Name
				enums[enumName] = data
			elseif child.attrs.class == "ReflectionMetadataEnumItem" then
				local data = {}
				if child.children[1].tag == "Properties" then
					local props = child.children[1].children
					for _,prop in pairs(props) do
						local name = prop.attrs.name
						name = name:sub(1,1):upper()..name:sub(2)
						data[name] = prop.children[1].text
					end
					enums[enumName].Items[data.Name] = data
				end
			end
		end
	end

	return {Classes = classes, Enums = enums, PropertyOrders = propertyOrders}
end

function Modules:Init()
	Modules.InitModules = {}
	warn("Install Module")

	for i,v in pairs(Urls) do
		if v[3] and IsStudio then
			Modules.InitModules[i] = v[3]()
			continue
		end
		Modules.InitModules[i] = HttpGet(v[1],v[2])
	end

	warn("注入RMD")

	Modules.InitModules.RMD = Modules:FetchRMD()

	print("注入菜单")

	Modules.Menu:Init()

	print("注入文件资源管理器")

	Modules.FileExplorer:Init()

	warn("IconMap Init")
	Modules.IconMap:Init()

	warn("Explorer Init")

	MainUi.Parent = DexEnv.genv.gethui()
	Modules.Explorer:Init()
end

Modules:Init()

return Modules
