-- [-[ 初始化环境 ]-]

--[[
	[- 待更新 -]
1. Menu:Insert() 插入实例

2. Menu:File(后缀...) 选择文件

3. 属性编辑器

4. 更多菜单选项

]]

const Players = game:GetService("Players")
const Player = Players.LocalPlayer
const Mouse = Player:GetMouse()
const RunService = game:GetService("RunService")
const IsStudio = RunService:IsStudio()
const UserInputService = game:GetService("UserInputService")
const SerializationService = game:GetService("SerializationService")

const RandomNameLength = 25

const DexEnv = _G.DexEnvironment or {}

if not _G.DexEnvironment then
	_G.DexEnvironment = DexEnv
end

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

-- [-[ 全局函数 ]-]
function ImportRBXM(FileRBXM : string)
	return DexEnv.genv.getobjects(getcustomasset("test.rbxm"))[1]
end

function GetLength(Table)
	local Length = 0
	for _,_ in pairs(Table) do
		Length = Length + 1
	end
	return Length
end

function RandomString(len : number)
	local result = ""

	for i=1,len do
		result = result..string.char(math.random(1,255))
	end

	return result
end

function isService(ClassName)
	local sus,err = pcall(function()
		return game:GetService(ClassName)
	end)

	if sus and err then
		return true
	end

	return false
end

function PointInArea(Point,LeftTop,RightBottom)
	if Point.X >= LeftTop.X and Point.X <= RightBottom.X then
		if Point.Y >= LeftTop.Y and Point.Y <= RightBottom.Y then
			return true
		end
	end
end

function HttpGet(Url,Cache)
	if IsStudio then
		local Returnvalue

		Returnvalue = game:GetService("ReplicatedStorage").RemoteFunction:InvokeServer(Url)

		return Returnvalue
	else
		local Returnvalue

		if Cache then
			if isfile(UrlFilePath..Url) then
				return readfile(UrlFilePath..Url)
			end

			Returnvalue = game:HttpGet(Url)

			writefile(UrlFilePath..Url,Returnvalue)
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
	}
}


const DexFilePath = "Dex(Obi_xieO)/"
const UrlFilePath = DexFilePath.."UrlCache/"
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
	ScrollingFrame.ScrollBarThickness = 5
	ScrollingFrame.Parent = Explorer
	ScrollingFrame.Size = UDim2.fromScale(1, 1)
	ScrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	ScrollingFrame.HorizontalScrollBarInset = Enum.ScrollBarInset.Always
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
end

-- [-[ Class图标 ]-]

Modules.IconMap = {
	Info = {
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
}

const IconMap = Modules.IconMap

function IconMap:Init()
	const MapPng = Modules.InitModules["IconMap"]

	if IsStudio then
		Modules.IconMap = Urls.IconMap[3]()
	else
		Modules.IconMap = getcustomasset(UrlFilePath..Urls.IconMap)
	end


	function IconMap:GetClassIcon(Image : ImageLabel , ClassName : string)
		
		const index = (IconMap.Info.Icons[ClassName] or (isService(ClassName) and IconMap.Info.Icons.Service) or IconMap.Info.Icons.Placeholder) - 1

		if index then
			Image.Image = Modules.IconMap
			
			const IconSize = Vector2.new(IconMap.Info.IconSize,IconMap.Info.IconSize)
			
			Image.ImageRectOffset = Vector2.new(
				IconSize.X * (index % IconMap.Info.Height),
				IconSize.Y * math.floor(index / IconMap.Info.Height)
			)
			
			Image.ImageRectSize = IconSize
		else
			return ""
		end
	end
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
	MenuEntry.Transparency = 1
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
	MenuDivider.Transparency = 1
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
}

function Menu:Init()
	Menu.Values = {}
	
	Menu.Uis = {}
	Menu.Hoving = {}
	
	Menu.MenuEntries = {
		Instance = {
			[1] = {
				Name = "Cut",
				CallBack = function(Selected)
					if not Menu.Values.Copies then
						Menu.Values.Copies = {}
					end
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
			[2] = {
				Name = "Copy",
				CallBack = function(Selected)
					if not Menu.Values.Copies then
						Menu.Values.Copies = {}
					end
					
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
			[3] = {
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
			[4] = {
				IsDrivider = true,
			},
			[5] = {
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
			[6] = {
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
			[7] = {
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
			[8] = {
				Name = "Delete",
				CallBack = function(Selected)
					for Node,_ in Selected do
						if isService(Node.Obj.ClassName) then continue end
						Node.Obj:Destroy()
					end
				end,
				Exluded = isService,
			},
			[9] = {
				Name = "Rename",
				CallBack = function(Selected)
					Selected[1]:Rename()
				end,
				Exluded1 = function(Selected)
					return #Selected > 1
				end,
			},
			[10] = {
				IsDrivider = true,
			},
			[11] = {
				Name = "Group to model",
				CallBack = function(Selected)
					local Model = Instance.new("Model")
					Model.Parent = Selected[1].Obj.Parent
					
					for Node,_ in Selected do
						if isService(Node.Obj.ClassName) then continue end
						Node.Obj.Parent = Model
					end
				end,
				Exluded = isService
			},
			[12] = {
				Name = "Group to folder",
				CallBack = function(Selected)
					local Folder = Instance.new("Folder")
					Folder.Parent = Selected[1].Obj.Parent
					
					for Node,_ in Selected do
						if isService(Node.Obj.ClassName) then continue end
						Node.Obj.Parent = Folder
					end
				end,
				Exluded = isService
			},
			[13] = {
				Name = "Ungroup",
				CallBack = function(Selected)
					for Node,_ in Selected do
						if Node.Obj:IsA("Model") or Node.Obj:IsA("Folder") then
							for _,v in Node.Obj:GetChildren() do
								v.Parent = Node.Obj.Parent
							end
							Node.Obj:Destroy()
						end
					end
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
			[14] = {
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
						Name = "Insert roblox model(rbxm)",
						CallBack = function(Selected)
							local File = Menu:File("rbxm","rbxmx")
							
							if File then
								local Clone = ImportRBXM(File)
								if Clone then
									
									for Node,_ in Selected do
										Clone:Clone().Parent = Node.Obj
									end
								end
							end
						end,
						
						ExludedAll = function()
							return getcustomasset and DexEnv.genv.getobjects
						end,
					}
				}
			},
		} :: {MenuEntryArg},
	}
	
	function Menu:AddDivider(Menu)
		local NewDivider = MenuDividerFrame:Clone()
		NewDivider.Parent = Menu
		
		return NewDivider
	end
	
	function Menu:AddEntry(MenuUi,Args : MenuEntryArg,Selected : { ExplorerNode },Index)
		if Args.IsDrivider then
			Menu:AddDivider(MenuUi)
			return
		end
		
		if Args.ExludedAll and Args.ExludedAll() then return end
		
		if GetLength(Selected) then
			local Node,_ = next(Selected)
			
			if Args.Exluded and Args.Exluded(Node.Obj.ClassName) then return end
		else
			if Args.ExludedMulti and Args.ExludedMulti(Selected) then return end
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
						local Ui = Menu:CreateUi(UDim2.fromOffset(NewEntry.AbsolutePosition.X,NewEntry.AbsolutePosition.Y+58) - UDim2.fromOffset(MenuUi.Size.X.Offset, 0),Args.Children,Selected,Index + 1)

						MenuUi.Destroying:Once(function()
							Ui:Destroy()
							Args.Ui = nil
						end)

						Args.Ui = Ui
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
		else
			NewEntry.TextButton.Visible = false
			
			if Args.CallBack then
				Connections[3] = NewEntry.Hit.MouseButton1Click:Connect(function()
					Args.CallBack(Selected,NewEntry)
					
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
		
		local Ui = Menu:CreateUi(UDim2.fromOffset(Mouse.X,Mouse.Y+58),FinalDisplay,Selected)
		
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
	MainFrame.Size = UDim2.fromScale(0, 1)
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
				local MenuHoldTick = tick()

				if not (LabelHoving and GetLength(Explorer.Selected) > 1) then
					ObjSelect(Node)
				end
				
				if not LabelHoving then
					local MousePosition = Vector2.new(Mouse.X,Mouse.Y)
					local CanvasPosition = ExplorerUi.ScrollingFrame.CanvasPosition
					local FirstPosition = MousePosition + Vector2.new(CanvasPosition.X,CanvasPosition.Y)

					local Movement,InputEnded
					local Dragging = false
					
					local tic = tick()

					const function CheckMovement()
						MousePosition = Vector2.new(Mouse.X,Mouse.Y)
						
						if Dragging then
							CanvasPosition = ExplorerUi.ScrollingFrame.CanvasPosition
							
							local InputPosition = MousePosition + Vector2.new(CanvasPosition.X,CanvasPosition.Y)
							
							const Offset = UDim2.fromOffset(
								InputPosition.X - FirstPosition.X,
								InputPosition.Y - FirstPosition.Y
							)
							
							const FirstPos = UDim2.fromOffset(
								FirstPosition.X - CanvasPosition.X,
								FirstPosition.Y+58 - CanvasPosition.Y
							)

							MultipleSelect.Size = Offset
							MultipleSelect.Position = FirstPos

							MultipleSelect.Visible = true
							
							local top = FirstPos.Y.Offset
							local bottom = FirstPos.Y.Offset + Offset.Y.Offset

							if Offset.Y.Offset < 0 then top, bottom = bottom, top end

							if tick() - tic > 0.0166 then
								tic = tick()
								local Seletedbythisfunction = {}
								
								for v, Node in pairs(Explorer.Uis) do
									if v:IsA("Frame") then
										local centerYBottom = v.AbsolutePosition.Y + 18 + 58
										local centerY = v.AbsolutePosition.Y + 58
										if (centerY > top and centerY < bottom) or
											(centerYBottom > top and centerYBottom < bottom)
										then
											SetSelect(Node, true)
											Seletedbythisfunction[Node] = true
										end
									end
								end
								
								ClearSelect(Seletedbythisfunction)
							end
							
							return
						end

						if (MousePosition - FirstPosition).Magnitude > 3 then
							Dragging = true
						end
					end

					Movement = RunService.RenderStepped:Connect(function(dt)
						CheckMovement()
					end)

					InputEnded = UserInputService.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							if Dragging then
								MultipleSelect.Visible = false

								Dragging = false
							elseif tick()-MenuHoldTick >= .5 then
								task.spawn(function()
									MenuHold = true
									Explorer:ShowMenu()
									MenuHold = false
								end)
							end
							
							Movement:Disconnect()
							InputEnded:Disconnect()
						end
					end)
				end
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
				if not Explorer.Selected[Node] then
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
				local IsSelected = Explorer.Selected[Node]
				LabelHoving = true
				local FirstPos = input.Position
				local Movement,Movement2,InputEnded
				local Dragging = false

				local function CheckMovement(input)
					if Dragging then
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
					if (input.Position - FirstPos).Magnitude > 3 then
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
									table.insert(ToSelect,Explorer:ChangeParent(Node1,Hoving))
								end

								ClearSelect()

								Explorer:Expand(Hoving)

								for _,Node1 in pairs(ToSelect) do
									SetSelect(Node1,true)
								end
							end
						else
							if GetLength(Explorer.Selected) > 1 then
								ObjSelect(Node)
							else
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
	
	function Explorer:ChangeParent(Node1,Node2)
		local Obj = Node1.Obj
		Obj.Parent = Node2.Obj
		
		Explorer.ObjRemoved(Node1.Obj)
		
		local NewNode = Explorer.ObjAdded(Obj)
		
		NewNode.Parent = Node2
		
		return NewNode
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
				childUi:Destroy()
			end
		end

		for i, v in ipairs(Node.Children) do
			if v.Root then
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

			Explorer:RefreshUi(ParentNode)
		end

		Node.Connection = Obj:GetPropertyChangedSignal("Parent"):Connect(function()
			if not Obj.Parent or not Explorer.Nodes[Obj] then return end
			if Obj.Parent == Explorer.Nodes[Obj].Parent.Obj then
				Node.Connection:Disconnect()
				return
			end

			Explorer.ObjRemoved(Obj)

			Explorer.ObjAdded(Obj)
			
			Node.Connection:Disconnect()
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
				Explorer:RefreshUi(ParentNode)
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
	
	function Explorer:ExpandAllParent(Node)
		if typeof(Node) == "Instance" then
			Node = Explorer.Nodes[Node]
		end

		local ancestors = {}
		local par = Node.Parent
		while par do
			table.insert(ancestors, par)
			par = par.Parent
		end

		for i = #ancestors, 1, -1 do
			Explorer:Expand(ancestors[i])
		end

		Explorer:Expand(Node)
	end
	
	function Explorer:UnExpand(Node)
		if typeof(Node) == "Instance" then
			Node = Explorer.Nodes[Node]
		end
		expanded[Node] = nil
		
		for i,v in ipairs(Node.Ui.Children:GetChildren()) do
			if v:IsA("Frame") then
				v:Destroy()
			end
		end
		
		EntryUpdate(Node.Ui,Node.Obj)
	end
	
	function Explorer:ShowMenu()
		local Selected = Explorer.Selected
		
		if GetLength(Selected) == 0 then
			return
		end
		
		Menu:Show(Selected)
	end
	
	if not DexEnv.DescendantAddedConnect then
		DexEnv.DescendantAddedConnect = {}
	else
		for i,v in pairs(DexEnv.DescendantAddedConnect) do
			v:Disconnect()
		end
	end
	
	if not DexEnv.DescendantRemovingConnect then
		DexEnv.DescendantRemovingConnect = {}
	else
		for i,v in pairs(DexEnv.DescendantRemovingConnect) do
			v:Disconnect()
		end
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

		table.insert(DexEnv.DescendantAddedConnect,Obj.DescendantAdded:Connect(Explorer.ObjAdded))
		table.insert(DexEnv.DescendantRemovingConnect,Obj.DescendantRemoving:Connect(Explorer.ObjRemoved))

		
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
	
	RunService.RenderStepped:Connect(function(deltaTime : number)
		local MousePosition = Vector2.new(Mouse.X,Mouse.Y)
		local HaveHover = false
		
		if ScrollDragging then
			HovingScrollBar = true
		else
			if PointInArea(MousePosition,ScrollBarFrame.Right.AbsolutePosition,ScrollBarFrame.Right.AbsolutePosition+ScrollBarFrame.Right.AbsoluteSize) then
				HovingScrollBar = true
				ScrollBarFrame.Right.UIStroke.Enabled = true
			elseif PointInArea(MousePosition,ScrollBarFrame.Down.AbsolutePosition,ScrollBarFrame.Down.AbsolutePosition+ScrollBarFrame.Down.AbsoluteSize) then
				HovingScrollBar = true
				ScrollBarFrame.Down.UIStroke.Enabled = true
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
			
			ExplorerUi.ScrollingFrame.ScrollingEnabled = true
		end
	end)
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
	
	warn("IconMap Init")
	Modules.IconMap:Init()
	
	warn("Explorer Init")
	
	MainUi.Parent = DexEnv.genv.gethui()
	Modules.Explorer:Init()
end

Modules:Init()

return Modules
