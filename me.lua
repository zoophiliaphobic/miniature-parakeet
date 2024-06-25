local plr = game.Players.LocalPlayer
local us = game:GetService("UserInputService")
local runs = game:GetService("RunService")
local utgsettings = plr:WaitForChild("Options")
local playergui = plr:WaitForChild("PlayerGui")
local debugstatsgui = playergui:WaitForChild("Debug")
local movementstats = debugstatsgui:WaitForChild("TextLabel")
local currentmap = workspace:WaitForChild("CurrentMap")
local olddebugmenu = plr.PlayerGui:WaitForChild("testing"):WaitForChild("DebugMenu")
local codemodifiers = plr.Modifiers.Code
local playerrole = plr.PlayerRole
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/zoophiliaphobic/psychic-octo-pancake/main/library.lua"))()
local window = library.createwindow({title="welcome! press ` to close/open"})

local rayparams = RaycastParams.new()
rayparams.RespectCanCollide = true

local hurtfulparts = {}
local fakehurtparts = {}

local randomtitles = {
    "riker give me dev role",
    "jasper give me developer",
    "/give me admin",
    "iamroie2b mode activated",
    "they added wallrunning",
    "new route discovered??",
    "pro mods",
    "utg destroyer!!",
    "tagmin 2.0",
    "telob gui",
    "created by telob ;)",
    "acq gui",
    "created by acq ;)",
    "competitive tag league gui",
    "utghub",
    "ultimate utg gui",
    "deluxe premium advanced untitled tag game graphical user interface",
    "utg gui",
    "revamp",
    "cheat_engine.exe",
    "utg://hacks",
    "vote slasher you noobs",
    "/btools all",
    "this cost $25 btw",
    "pingus",
    "whereabouts gui :)",
    "stop banning me",
    "report!! hacker!!",
    "hey there",
}

window.visibilitychanged = function(opened)
    if opened then
        window.changetitle(randomtitles[math.random(1,#randomtitles)])
    end
end

local tab_hacks = window.createtab({title="hacks"})
local tab_mods = window.createtab({title="modifications"})
local tab_sounds = window.createtab({title="sounds"})
local tab_fun = window.createtab({title="fun stuff"})

local tab_fun_toggle_emotemove = tab_fun.newtoggle({title="move while emoting"})
local tab_fun_toggle_movelean = tab_fun.newtoggle({
    title="disable movement leaning",
    onclick = function(val)
        local char = plr.Character

        if char then
            local leanscript = char.scripts.visuals.MomentumLeaning
            leanscript.Disabled = val
        end
    end
})
local tab_fun_toggle_expswing = tab_fun.newtoggle({
    title="experimental swinging",
    onclick=function(val)
        local map = currentmap:FindFirstChildOfClass("Folder")

        if map then
            for i,v in pairs(map:GetDescendants()) do
                if v:GetAttribute("SwingBar") then
                    v.Name = val and "ExperimentalSwingbar" or "Part"
                end
            end
        end
    end
})
tab_fun.newbutton({
    title = "open old debug menu",
    onclick = function()
        olddebugmenu.Visible = not olddebugmenu.Visible
    end
})
local tab_fun_toggle_slowmotion = tab_fun.newtoggle({title="slow motion"})

local tab_fun_slider_cloneamt = tab_fun.newslider({
    title = "parkour script duplicate amount",
    min=1,
    max=500,
    increment = 1,
    default = 1,
})

tab_fun.newbutton({
    title = "start duplicating parkour scripts",
    onclick = function()
        local char = plr.Character

        if char then
            local parkourscript = char.scripts.movement.Parkour

            for i=1,tab_fun_slider_cloneamt.getvalue() do
                parkourscript:Clone().Parent = char.scripts.movement
            end 
        end
    end
})

tab_fun.newbutton({
    title = "delete duplicated parkour scripts",
    onclick = function()
        local char = plr.Character

        if char then
            local mvm = char.scripts.movement
            local safescript = mvm.Parkour
            for i,v in pairs(mvm:GetChildren()) do
                if v.Name == "Parkour" and v ~= safescript then
                    v:Destroy()
                end
            end 
        end
    end
})

local roleswithsounds = {
    Crown = "play crown sounds",
    FunnyBomb = "play screaming sounds",
    Dead = "play ouch sounds",
    Slasher = "play slasher sounds",
    TheStalker = "play ahh fresh meat sound",
    PatientZero = "play patient zero sounds",
    Employee = "play walkie-talkie sounds",
    REALLYFAST = "play car revving sounds",
    pingus = "play pingus sounds",
}

local tab_sounds_slider_delay = tab_sounds.newslider({
    title = "delay between sounds",
    min=0,
    max=5,
    increment = 0.05,
    default = 1,
})

local tab_sounds_toggle_muterole = tab_sounds.newtoggle({title="mute role changed noise"})

for rolename,fakename in pairs(roleswithsounds) do
    local isenabled = false

    tab_sounds.newtoggle({
        title = fakename,
        color = Color3.fromRGB(190,135,90),
    onclick = function(val)
        local prevrole = playerrole.Value
        isenabled = val

        while isenabled do
            playerrole.Value = rolename
            playerrole.Value = "Random"
            task.wait(tab_sounds_slider_delay.getvalue())
        end
        playerrole.Value = prevrole
    end})
end

local tab_hacks_toggle_staticvault = tab_hacks.newtoggle({title="enable static vault height"})
local tab_hacks_toggle_accuratevault = tab_hacks.newtoggle({title="accurate static vault"})
local tab_hacks_slider_staticvault = tab_hacks.newslider({
    title = "static vault height",
    min=1.5,
    max=2.75,
    increment = 0.01,
    default = 1.5,
})
local tab_hacks_toggle_spoofvault = tab_hacks.newtoggle({title="spoof vaulting debug"})
local tab_hacks_toggle_lowvault = tab_hacks.newtoggle({title="allow <1.5 stud vault",
onclick=function(bool)
    tab_hacks_slider_staticvault.setmin(bool and 0 or 1.5)
end})

local tab_hacks_toggle_autovault = tab_hacks.newtoggle({title="auto vault (innaccurate) (must have always show vault raycast enabled)"})
local tab_hacks_slider_autovaultheight = tab_hacks.newslider({
    title = "auto vault height",
    min=0,
    max=2.75,
    increment = 0.01,
    default = 1,
})

local vaultraypart
local tab_hacks_toggle_showvaultray
tab_hacks_toggle_showvaultray = tab_hacks.newtoggle({title="always show vault raycast",
onclick=function(bool)
    if bool then
        local camera = workspace.CurrentCamera
        local vaultraydir = Vector3.new(0,-3.25,0)
        local ysize = math.abs(vaultraydir.Y)

        vaultraypart = Instance.new("Part")
        vaultraypart.Anchored = true
        vaultraypart.CanCollide = false
        vaultraypart.CanQuery = false
        vaultraypart.Transparency = 1
        vaultraypart.Size = Vector3.new(0.1,ysize,0.1)
       
        local lineadornment = Instance.new("LineHandleAdornment",vaultraypart)
        lineadornment.Color3 = Color3.fromRGB(255,0,255)
        lineadornment.Length = 3.25
        lineadornment.Thickness = 3
        lineadornment.Adornee = vaultraypart
        lineadornment.CFrame = CFrame.new(0,ysize/2,0)*CFrame.Angles(math.rad(-90),0,0)
        lineadornment.AlwaysOnTop = true
        vaultraypart.Parent = workspace

        local function updateposition()
            local char = plr.Character
            local root = char.HumanoidRootPart
            local piv = root.CFrame
            local vaulyraystartpos = (piv.Position+piv.LookVector*2+Vector3.new(0,2.75,0))

            local startray = workspace:Raycast(piv.Position+Vector3.new(0,1.25,0),piv.LookVector*2,rayparams)

            if startray and startray.Instance and startray.Instance.Transparency < 1 then
                vaulyraystartpos = (piv.Position+(piv.LookVector*(startray.Distance+0.05))+Vector3.new(0,2.75,0))
            end
            vaultraypart.Position = vaulyraystartpos-Vector3.new(0,ysize/2,0)

            local vaultray = workspace:Raycast(vaulyraystartpos,vaultraydir,rayparams)

            if vaultray then
                local estmvaultheight = ysize-vaultray.Distance-0.5
                --warn("estimated vault: ".. tostring(estmvaultheight))
                
                if tab_hacks_toggle_autovault.getvalue() and estmvaultheight >= tab_hacks_slider_autovaultheight.getvalue() then
                    keypress("Space")
                    task.wait(0.1)
                    keyrelease("Space")
                end
            end
        end
        updateposition()

        local camchangedcon
        camchangedcon = camera.Changed:Connect(function()
            updateposition()
            
            if not tab_hacks_toggle_showvaultray.getvalue() then
                camchangedcon:Disconnect()
            end
        end)
    else
        if vaultraypart then
            vaultraypart:Destroy()
            vaultraypart = nil
        end
    end
end})

local tab_hacks_toggle_teleroll = tab_hacks.newtoggle({title="teleport roll"})
local tab_hacks_toggle_velroll = tab_hacks.newtoggle({title="velocity roll"})
local tab_hacks_toggle_autoroll = tab_hacks.newtoggle({title="automatic roll"})
local tab_hacks_toggle_antifreeze = tab_hacks.newtoggle({title="anti-freeze"})
local tab_hacks_toggle_contactdmg = tab_hacks.newtoggle({
    title="disable contact damage",
    onclick=function(bool)
    local map = currentmap:FindFirstChildOfClass("Folder")   

    if map then
        if bool then
            for i,v in pairs(map:GetDescendants()) do
                local fakepart = v:Clone()
                fakepart:SetAttribute("ContactDamage",nil)

                table.insert(hurtfulparts,{part=v,parent=v.Parent})
                table.insert(fakehurtparts,fakepart)

                fakepart.Parent = v.Parent
                v.Parent = nil
            end
        else
            for i,v in pairs(hurtfulparts) do
                v.part.Parent = v.parent
            end

            for i,v in pairs(fakehurtparts) do
                v:Destroy()
            end
            table.clear(fakehurtparts)
        end
    end
end})

local tab_hacks_toggle_staticswing =tab_hacks.newtoggle({title="enable static swing percent"})
local tab_hacks_slider_staticswing = tab_hacks.newslider({
    title = "static swing percentage",
    min=100,
    max=225.74,
    increment = 0.01,
    default = 100,
})

local slidermodifiers = {
    JumpPowerMultiplier = {"jump power multplier",0,5},
    WalkSpeedMultiplier = {"walking speed multplier",0,5},
    AccelerationMultiplier = {"acceleration multiplier",0,10},
    TagCooldown = {"tag cooldown multiplier",0,2},
    RangeMultiplier = {"range multplier",0,10},
    MomentumMultiplier = {"momentum multiplier",0,10},
    GravityMultiplier = {"gravity multiplier",0,2},
    RailGrindMultiplier = {"rail speed multplier",0,3},
    RollSpeedMultiplier = {"roll speed multplier",0,5},
    RollBoostMultiplier = {"roll jump boost multplier",0,5},
    WindowSmashMultiplier = {"window smash boost multiplier",-5,1},
}

local togglemodifiers = {
    EnableWallrunning = "wallrun everywhere",
    EnableParrying = "enable parrying (does nothing)",
    DisableRailGrinding = "disable rails",
    DisableSwingBars = "disable swing bars",
    DisableRolling = "disable rolling",
    DisableWindowSmashing = "disable window smashing",
    DisableSprinting = "disable sprinting",
    DisableSliding = "disable sliding",
    DisableVaulting = "disable vaulting",
}

for modname,v in pairs(slidermodifiers) do
    tab_mods.newslider({
        title = v[1],
        min = v[2],
        max = v[3],
        increment = 0.1,
        default = 1,
    onchanged = function(val)
        codemodifiers:SetAttribute(modname,val)
    end})
end

for modname,fakename in pairs(togglemodifiers) do
    tab_mods.newtoggle({
        title = fakename,
    onclick = function(val)
        codemodifiers:SetAttribute(modname,val)
    end})
end

function characteradded(char)
    local scripts = char:WaitForChild("scripts") 
    local emotescript = scripts:WaitForChild("animation"):WaitForChild("Emotes")
    local momentumleanscript = scripts:WaitForChild("visuals"):WaitForChild("MomentumLeaning")
    local root = char:WaitForChild("HumanoidRootPart")
    rayparams.FilterDescendantsInstances = {char}

    local function limbadded(v)
        v.Changed:Connect(function()
            if tab_hacks_toggle_antifreeze.getvalue() and not tab_fun_toggle_slowmotion.getvalue() then
                v.Anchored = false
            end
        end)
    end

    if tab_fun_toggle_movelean.getvalue() then
        momentumleanscript.Disabled = true
    end

    char.Changed:Connect(function()
        if char:GetAttribute("Emoting") and tab_fun_toggle_emotemove.getvalue() then
            task.wait()
            emotescript.Disabled = true
            emotescript.Disabled = false
        end
    end)

    root.ChildAdded:Connect(function(v)
        if (v.Name == "Vault" or v.Name == "HighVault") and tab_hacks_toggle_staticvault.getvalue() then
            task.wait()
            local isaccurate = tab_hacks_toggle_accuratevault.getvalue()
            local vel = char.PrimaryPart.AssemblyLinearVelocity
            local height = math.clamp(tab_hacks_slider_staticvault.getvalue(),1,math.huge)

            local txt = movementstats.Text
            local findstart = string.find(txt,"vault height")
            local findend = string.find(txt,"roll ms")-2
            local actualheight = tonumber(string.sub(txt,findstart+14,findend-6))

            if isaccurate then
                local offset = height-actualheight
                task.spawn(function()
                    for i=1,10 do
                        char:PivotTo(char:GetPivot()-Vector3.new(0,offset/10,0))
                        task.wait()
                    end
                end)
            end

            local yvelocity = (height <= 1.5 and 30) or 19.51*(height^1.02417)

            if tab_hacks_toggle_lowvault.getvalue() then
                yvelocity = 19.51*(height^1.02417)
            end

            -- char.PrimaryPart.AssemblyLinearVelocity = Vector3.new(vel.X*1,
            -- height <= 1.5 and 30 or -0.6532+19.9402*height
            -- ,vel.Z*1)
            --char.PrimaryPart.AssemblyLinearVelocity = Vector3.new(vel.X*1,(2*height)^2+(4*height)+24,vel.Z*1)
            
            char.PrimaryPart.AssemblyLinearVelocity = Vector3.new(vel.X*1,yvelocity,vel.Z*1)
        end

        if v.Name == "SwingBar" and tab_hacks_toggle_staticswing.getvalue() then
            local swingval = tab_hacks_slider_staticswing.getvalue()
            local mult = 1-math.floor((225.74-swingval)/(125.74)*100)/100
            local vel = root.AssemblyLinearVelocity
            root.AssemblyLinearVelocity = Vector3.new(vel.X,-(25+(55*mult)),vel.Z)
            task.wait()
            root.AssemblyLinearVelocity = Vector3.new(vel.X,vel.Y,vel.Z)
        end
    end)

    for i,v in pairs(char:GetChildren()) do
        if v:IsA("BasePart") then
            limbadded(v)
        end
    end

    char.ChildAdded:Connect(function(v)
        if v:IsA("BasePart") then
            limbadded(v)
        end
    end)
end

function mapadded(map)
    local function instanceadded(v)
        if tab_fun_toggle_expswing.getvalue() and v:GetAttribute("SwingBar") then
            v.Name = "ExperimentalSwingbar"
        end

        if v:GetAttribute("ContactDamage") then
            if tab_hacks_toggle_contactdmg.getvalue() then
                local fakepart = v:Clone()
                fakepart:SetAttribute("ContactDamage",nil)

                table.insert(hurtfulparts,{part=v,parent=v.Parent})
                table.insert(fakehurtparts,fakepart)

                fakepart.Parent = v.Parent
                v.Parent = nil
            end
        end
    end
    table.clear(hurtfulparts)
    table.clear(fakehurtparts)

    for i,v in pairs(map:GetDescendants()) do
        instanceadded(v)
    end

    map.DescendantAdded:Connect(instanceadded)
end

plr.CharacterAdded:Connect(function(char)
    characteradded(char)
end)

if plr.Character then
    characteradded(plr.Character)
end

currentmap.ChildAdded:Connect(function(v)
    mapadded(v)
end)

workspace.ChildAdded:Connect(function(v)
    if tab_sounds_toggle_muterole.getvalue() and v:IsA("Sound") and v.Name == "RoleChange" then
        v.Volume = 0
    end
end)

debugstatsgui:WaitForChild("PrintList").ChildAdded:Connect(function(v)
    if v:IsA("TextLabel") then
        if v.Text:find("studs") then
            if tab_hacks_toggle_spoofvault.getvalue() then
                local height = tab_hacks_slider_staticvault.getvalue()
                v.Text = string.format("%.2f",height) .." studs"
                
                if height >= 2.75 then
                    local rainbow = game.ReplicatedStorage.UIAssets.Rainbow:Clone()
                    rainbow.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0,Color3.new(1,0.482,0.482)),
                        ColorSequenceKeypoint.new(0.1,Color3.new(1,0.705,0.290)),
                        ColorSequenceKeypoint.new(0.2,Color3.new(0.878,1,0.396)),
                        ColorSequenceKeypoint.new(0.3,Color3.new(0.588,1,0.474)),
                        ColorSequenceKeypoint.new(0.4,Color3.new(0.380,1,0.627)),
                        ColorSequenceKeypoint.new(0.5,Color3.new(0.498,1,1)),
                        ColorSequenceKeypoint.new(0.6,Color3.new(0.482,0.698,1)),
                        ColorSequenceKeypoint.new(0.7,Color3.new(0.631,0.537,1)),
                        ColorSequenceKeypoint.new(0.8,Color3.new(0.901,0.552,1)),
                        ColorSequenceKeypoint.new(0.9,Color3.new(1,0.576,0.839)),
                        ColorSequenceKeypoint.new(1,Color3.new(1,0.588,0.588)),
                    })
                    rainbow.Rotation = 6
                    rainbow.Parent = v
                    v.TextColor3 = Color3.fromRGB(255,255,255)
                elseif height >= 2 then
                    v.TextColor3 = Color3.fromRGB(80,255,179)
                else
                    v.TextColor3 = Color3.fromRGB(225,255,226)
                end
            end
        end
    end
end)

local fakemovementstats = movementstats:Clone()
fakemovementstats.Parent = debugstatsgui

local lastvaultvalue = nil
local fakestuds = nil
local debounce = false

local debugstatsoption = utgsettings:WaitForChild("Misc"):WaitForChild("DebugMode")
movementstats.Changed:Connect(function()
    if debounce then
        debounce = false
        return
    end

    local txt = movementstats.Text
    local findstart = string.find(txt,"vault height")
    local findend = string.find(txt,"roll ms")-2
    local studs = string.sub(txt,findstart+14,findend-6)

    if tab_hacks_toggle_spoofvault.getvalue() and debugstatsoption.Value then
        movementstats.Visible = false
        fakemovementstats.Visible = true

        if lastvaultvalue ~= studs or not fakestuds then      
            fakestuds = string.format("%.2f",tab_hacks_slider_staticvault.getvalue()) .." studs"
        end

        fakemovementstats.Text = string.sub(txt,0,findstart-2).. "\nvault height: ".. fakestuds .. string.sub(txt,findend+1,txt:len())
    else
        movementstats.Visible = debugstatsoption.Value
        fakemovementstats.Visible = false
    end
    
    lastvaultvalue = tostring(studs)
end)

us.InputBegan:Connect(function(key,pro)
    if not pro and key.KeyCode == Enum.KeyCode.C then
        local char = plr.Character
        local prim = char:FindFirstChild("HumanoidRootPart")

        if char and prim then 
            if tab_hacks_toggle_teleroll.getvalue() then
                local pivot = char:GetPivot()
                local ray = workspace:Raycast(pivot.Position,Vector3.new(0,-200,0),rayparams)

                if ray then
                    local vel = prim.AssemblyLinearVelocity
                    prim.AssemblyLinearVelocity = Vector3.new(vel.X,-50,vel.Z)
                    char:PivotTo(CFrame.new(ray.Position+Vector3.new(0,5,0))*pivot.Rotation)
                end
            end

            if tab_hacks_toggle_velroll.getvalue() then
                local vel = prim.AssemblyLinearVelocity
                
                if vel.Y > -50 then
                    prim.AssemblyLinearVelocity = Vector3.new(vel.X,-50,vel.Z)
                end
            end
        end
    end
end)

local otherframecheck = false
local stoprollchecking = false
local tickatautoroll = 0
runs.RenderStepped:Connect(function()
    local char = plr.Character
    otherframecheck = not otherframecheck

    if tab_hacks_toggle_autoroll.getvalue() and char and tick()>tickatautoroll+0.1 then
        local prim = char:FindFirstChild("HumanoidRootPart")
        local vel = prim.AssemblyLinearVelocity

        if vel.Y <= -42 and not stoprollchecking then
            local overflow = (math.clamp(vel.Y,-math.huge,-45)/-45)-1
            local raydist = -6-(overflow/1.9)
            local ray = workspace:Raycast(prim.Position,Vector3.new(0,raydist,0),rayparams)

            if ray then
                stoprollchecking = true
                tickatautoroll = tick()
                keypress("C")
                task.wait()
                keyrelease("C")
            end
        else
            stoprollchecking = false
        end
    end

    if tab_fun_toggle_slowmotion.getvalue() and char then
        local prim = char:FindFirstChild("HumanoidRootPart")
        
        if char:GetAttribute("Frozen") then
            if not tab_hacks_toggle_antifreeze.getvalue() then
                return
            end
        end

        if otherframecheck then
            prim.Anchored = true
        else
            for i,v in pairs(char:GetChildren()) do
                if v:IsA("BasePart") then
                    v.Anchored = false
                end
            end
        end
    end
end)
