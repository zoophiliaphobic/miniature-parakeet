local plr = game.Players.LocalPlayer
local mouse = plr:GetMouse()
local char = plr.Character or plr.CharacterAdded:Wait()

-- local rollms = -10/1000

-- print(1.3 + ((0.1 - math.clamp(rollms,-math.huge,0.1)) * 3.5) ^ 0.85)

local hum = char and char:FindFirstChildOfClass("Humanoid")
local root = char and char:FindFirstChild("HumanoidRootPart")
local head = char and char:FindFirstChild("Head")
local camera = workspace.CurrentCamera

local role = plr:WaitForChild("PlayerRole")

local playergui = plr:WaitForChild("PlayerGui")
local debugui = nil
local debugvalues = nil
local debugprint = nil
local fakevalues = nil

local modscc = plr:WaitForChild("Modifiers")
local modifiersfolder = modscc:WaitForChild("VIP")
local codemodifiersfolder = modscc:WaitForChild("Code")

local currentmapfolder = workspace:WaitForChild("CurrentMap")

local us = game:GetService("UserInputService")
local rep = game:GetService("ReplicatedStorage")
local runs = game:GetService("RunService")
local mps = game:GetService("MarketplaceService")

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/zoophiliaphobic/psychic-octo-pancake/main/library.lua"))()
local window = library.createwindow({title="welcome! press ` to close/open"})

local UTGenemymatrix = {
    ["All"] = {"Neutral"},

    ["Runner"] = {"Frozen"},

    ["Freezer"] = {"Runner","Frozen"},
    ["Chiller"] = {"Runner"},

    ["RedCaptain"] = {"BlueCaptain","BlueTeam"},
    ["BlueCaptain"] = {"RedCaptain","RedTeam"},

    ["BlueTeam"] = {"RedTeam","GreenTeam","YellowTeam","OrangeTeam","PurpleTeam","FrozenBlue"},
    ["RedTeam"] = {"BlueTeam","GreenTeam","YellowTeam","OrangeTeam","PurpleTeam","FrozenRed"},
    ["GreenTeam"] = {"BlueTeam","RedTeam","YellowTeam","OrangeTeam","PurpleTeam"},
    ["YellowTeam"] = {"BlueTeam","GreenTeam","RedTeam","OrangeTeam","PurpleTeam"},
    ["OrangeTeam"] = {"BlueTeam","GreenTeam","RedTeam","YellowTeam","PurpleTeam"},
    ["PurpleTeam"] = {"BlueTeam","GreenTeam","RedTeam","OrangeTeam","YellowTeam"},

    ["BlueTeamPaintball"] = {"RedTeamPaintball","GreenTeamPaintball","YellowTeamPaintball"},
    ["RedTeamPaintball"] = {"BlueTeamPaintball","GreenTeamPaintball","YellowTeamPaintball"},
    ["GreenTeamPaintball"] = {"BlueTeamPaintball","RedTeamPaintball","YellowTeamPaintball"},
    ["YellowTeamPaintball"] = {"BlueTeamPaintball","GreenTeamPaintball","RedTeamPaintball"},

    ["FFATagger"] = {"FFATagger"},

    ["Tagger"] = {"Runner"},   
    ["CompDyingTagger"] = {"Runner"},   
    ["RunnerTagger"] = {"Runner"},  

    ["Slasher"] = {"Runner","Chiller","Juggernaut","Survivor"},
    ["HiddenSlasher"] = {"Survivor"},
    ["Haunter"] = {"Survivor"},
    
    ["Seeker"] = {"Hider"},

    ["Juggernaut"] = {"Runner","Hunter","Infected"},

    ["Medic"] = {"PatientZero","InfectedRunner","Infected"},
    ["PatientZero"] = {"Runner","Juggernaut","Frozen","Medic"},
    ["Infected"] = {"Runner","Juggernaut","Frozen","Medic"},
    ["JumpingInfected"] = {"Runner"},
    ["FastInfected"] = {"Runner"},
    ["BigInfected"] = {"Runner"},
    ["CloakInfected"] = {"Runner"},
    ["BabyInfected"] = {"Runner"},

    ["Crown"] = {"Frozen"},
    ["Peasant"] = {"Crown","Knight"},
    ["Knight"] = {"Peasant"},
    ["pingus"] = {"Runner"},

    ["Dead"] = {"Crown"},

    ["Eliminator"] = {"Runner"},

    ["Bomb"] = {"Runner","Crown"},
    ["FunnyBomb"] = {"Runner"},
    ["HotPotato"] = {"Runner"},
    ["SubspaceBomb"] = {"Runner"},
}

function getenemies(rolename)
    local enemies = {}
    local minimumamt = #UTGenemymatrix["All"]

    for rolecate,emtbl in pairs(UTGenemymatrix) do
        if rolecate == rolename or rolecate == "All" then
            for _,v in pairs(emtbl) do
                table.insert(enemies,v)
            end
        end
    end

    if #enemies <= minimumamt then
        for i,v in pairs(playerhighlights:GetChildren()) do
            if v.Name ~= rolename and #v:GetChildren() > 0 then
                table.insert(enemies,v.Name)
            end
        end
    end
    
    return enemies
end

function getmultipliedmodifier(attname,default)
    local val = default or 1

    for i,v in pairs(modscc:GetChildren()) do
        local amt = v:GetAttribute(attname)

        if amt then
            val *= amt
        end
    end

    return val
end

local nocolconstraints = {}
function disableplrcollision()
    if char then
        for _,who in pairs(game.Players:GetPlayers()) do
            local hc = who.Character

            if hc then
                for _,enemylimb in pairs(hc:GetChildren()) do
                    if enemylimb:IsA("BasePart") then
                        for _,limb in pairs(char:GetChildren()) do
                            if limb:IsA("BasePart") then
                                local colcons = Instance.new("NoCollisionConstraint")
                                colcons.Part0 = limb
                                colcons.Part1 = enemylimb
                                colcons.Parent = limb
                                table.insert(nocolconstraints,colcons)
                            end
                        end
                    end
                end
            end
        end
    end
end

function getactualvaultheight()
    local txt = debugvalues.Text
    local find = string.find(txt,"vault height:")
    local cut = string.sub(txt,find+14,find+17)
    return tonumber(cut)
end

local vaultparams = RaycastParams.new()
vaultparams.CollisionGroup = "Player"
vaultparams.FilterDescendantsInstances = {char}
vaultparams.FilterType = Enum.RaycastFilterType.Exclude

local tab_hacks = window.createtab({title="hacks"})
local tab_mods = window.createtab({title="modifications"})
local tab_sounds = window.createtab({title="sounds"})
local tab_importing = window.createtab({title="importing"})

local flags = {
    staticvaultactive = false,
    staticvaultheight = 1.5,
    staticvaultspoof = false,
    staticvaultinnacurate = false,
    staticshowreal = false,
    antinullvault = false,

    svdetectladders = false,
    svladderstrength = 0.5,
    svladdercurve = 1,

    showvaultcast = false,
    autovault = false,
    autovaultheight = 2.5,

    noknockback = false,
    nocollision = false,
    antifreeze = false,
    bhop = false,
    holdjump = false,
    nomovelock = false,

    staticrollactive = false,
    staticrollms = 8.33,
    staticrollspoof = false,
    staticrollshowreal = false,

    staticswingactive = false,
    staticswingpercent = 100,
    uncapswings = false,

    aimassistactive = false,
    aimassiststrength = 0.5,

    ownsmisprintpasses = nil,

    movewhileemoting = false,
    emotemove = false,

    mapmodelid = nil,
    mapdoswings = false,
    mapnoinvis = false,
}

tab_hacks.newlabel({title="-- vault hacks --"})

tab_hacks.newlabel({title="you must have debug: show values enabled for this to work until i decide to fix it"})

tab_hacks.newtoggle({title="enable static vault",onclick=function(val)
    flags.staticvaultactive = val
end})

tab_hacks.newslider({title="static vault height",min=0,max=2.75,default=flags.staticvaultheight,increment=0.01,onchanged=function(val)
    flags.staticvaultheight = tonumber(val)
end})

tab_hacks.newtoggle({title="spoof static vault height",onclick=function(val)
    flags.staticvaultspoof = val
end})

tab_hacks.newtoggle({title="show real vault height",onclick=function(val)
    flags.staticshowreal = val
end})

tab_hacks.newtoggle({title="innacurate static vault",onclick=function(val)
    flags.staticvaultinnacurate = val
end})

tab_hacks.newtoggle({title="anti-null-vault (pls revamp)",onclick=function(val)
    flags.antinullvault = val

    if head then
        head.CanCollide = not val
    end
end})

tab_hacks.newtoggle({title="SV detect quick vaulting",onclick=function(val)
    flags.svdetectladders = val
end})

tab_hacks.newslider({title="SV detecting strength",min=0,max=2,default=flags.svladderstrength,increment=0.01,onchanged=function(val)
    flags.svladderstrength = tonumber(val)
end})

tab_hacks.newslider({title="SV detecting curve",min=0.5,max=3,default=flags.svladdercurve,increment=0.01,onchanged=function(val)
    flags.svladdercurve = tonumber(val)
end})

local fakeray = Instance.new("Part")
fakeray.Anchored = true
fakeray.CanCollide = false
fakeray.CanTouch = false
fakeray.CanQuery = false
fakeray.Size = Vector3.new(0.1,3.25,0.1)
fakeray.Transparency = 1

local lineadornment = Instance.new("LineHandleAdornment")
lineadornment.Length = fakeray.Size.Y
lineadornment.Color3 = Color3.new(1,0,1)
lineadornment.Thickness = 3
lineadornment.Adornee = fakeray
lineadornment.CFrame = CFrame.new(0,fakeray.Size.Y/2,0)*CFrame.Angles(math.rad(-90),0,0)
lineadornment.AlwaysOnTop = true
lineadornment.Parent = fakeray

tab_hacks.newtoggle({title="always show vault ray",onclick=function(val)
    flags.showvaultcast = val

    fakeray.Parent = val and workspace or nil
end})

tab_hacks.newtoggle({title="enable auto-vault",onclick=function(val)
    flags.autovault = val
end})

tab_hacks.newslider({title="auto-vault height",min=0,max=2.75,default=flags.autovaultheight,increment=0.01,onchanged=function(val)
    flags.autovaultheight = tonumber(val)
end})

tab_hacks.newlabel({title="-- character --"})

tab_hacks.newtoggle({title="no knockback",onclick=function(val)
    flags.noknockback = val
end})

tab_hacks.newtoggle({title="disable player collision",onclick=function(val)
    flags.nocollision = val

    if val then
        disableplrcollision()
    else
        for i,v in pairs(nocolconstraints) do
            v:Destroy()
        end
        table.clear(nocolconstraints)
    end
end})

tab_hacks.newtoggle({title="bhop",onclick=function(val)
    flags.bhop = val
end})

tab_hacks.newtoggle({title="hold auto-jump",onclick=function(val)
    flags.holdjump = val
end})

tab_hacks.newtoggle({title="never lock move vector",onclick=function(val)
    flags.nomovelock = val
end})

tab_hacks.newtoggle({title="never lock ignore non-roll",onclick=function(val)
    flags.lockslide = val
end})

tab_hacks.newtoggle({title="anti-freeze",onclick=function(val)
    flags.antifreeze = val
end})

tab_hacks.newslider({title="fake lag in milliseconds",min=0,max=1000,default=0,increment=0.1,onchanged=function(val)
    settings().Network.IncomingReplicationLag = val/1000
end})

tab_hacks.newlabel({title="-- rolling --"})

tab_hacks.newtoggle({title="enable static roll ms (not done)",onclick=function(val)
    flags.staticrollactive = val
end})

tab_hacks.newslider({title="static roll ms (not done)",min=0,max=1300,default=flags.staticrollms,increment=0.01,onchanged=function(val)
    flags.staticrollms = tonumber(val)
end})

tab_hacks.newtoggle({title="spoof roll ms",onclick=function(val)
    flags.staticrollspoof = val
end})

tab_hacks.newtoggle({title="show real roll ms",onclick=function(val)
    flags.staticrollshowreal = val
end})

tab_hacks.newlabel({title="-- swingbars --"})

tab_hacks.newtoggle({title="enable static swing",onclick=function(val)
    flags.staticswingactive = val
end})

tab_hacks.newslider({title="static swing height",min=100,max=225.74,default=flags.staticswingpercent,increment=0.01,onchanged=function(val)
    flags.staticswingpercent = tonumber(val)
end})

tab_hacks.newtoggle({title="uncap swing percent",onclick=function(val)
    flags.uncapswings = val
end})

tab_hacks.newlabel({title="-- aiming --"})

tab_hacks.newtoggle({title="enable aim assist",onclick=function(val)
    flags.aimassistactive = val
end})

tab_hacks.newslider({title="aim assist strength",min=0,max=1,default=flags.aimassiststrength,increment=0.01,onchanged=function(val)
    flags.aimassiststrength = tonumber(val)
end})

tab_hacks.newlabel({title="-- visuals --"})

tab_hacks.newtoggle({title="show misprints",onclick=function(val)
    local owned = flags.ownedmisprintpasses
    if not owned then
        flags.ownsmisprintpasses = {[1]=plr:GetAttribute("triplevotes"),[2]=plr:GetAttribute("triplevotesLegacy")}
    end

    if val then
        plr:SetAttribute("triplevotes",true)
        plr:SetAttribute("triplevotesLegacy",true)
    else
        plr:SetAttribute("triplevotes",owned[1] or false)
        plr:SetAttribute("triplevotesLegacy",owned[2] or false)
    end
end})

tab_hacks.newlabel({title="-- fun stuff --"})

local movewhileemotingconnection
tab_hacks.newtoggle({title="move while emoting",onclick=function(val)
    flags.movewhileemoting = val

    if val then
        movewhileemotingconnection = runs.RenderStepped:Connect(function()
            if char and char:GetAttribute("Emoting") then
                local wspeed = 32*getmultipliedmodifier("RunSpeedMultiplier")
                local jpower = 28*getmultipliedmodifier("JumpPowerMultiplier")
                
                hum.WalkSpeed = wspeed
                hum.JumpPower = jpower
            end
        end)
    else
        if movewhileemotingconnection then
            movewhileemotingconnection:Disconnect()
            movewhileemotingconnection = nil
        end
    end
end})

tab_hacks.newtoggle({title="glide mode",onclick=function(val)
    flags.emotemove = val
end})

local modifications = {
    [1] = {
        label = "base",
        contents = {
            [1] = {att="RunSpeedMultiplier", title="running speed multiplier",min=0,max=10,default=1,increment=0.01},
            [2] = {att="WalkSpeedMultiplier", title="walking speed multiplier",min=0,max=10,default=1,increment=0.01},
            [3] = {att="JumpPowerMultiplier", title="jump power multiplier",min=0,max=10,default=1,increment=0.01},
            [4] = {att="AccelerationMultiplier", title="acceleration multiplier",min=0,max=100,default=1,increment=0.01},
            [5] = {att="GravityMultiplier", title="gravity multiplier",min=0,max=10,default=1,increment=0.01},
        },
    },
    [2] = {
        label = "tagging",
        contents = {
            [1] = {att="RangeMultiplier", title="range multiplier",min=0,max=10,default=1,increment=0.01},
            [2] = {att="TagCooldown", title="tag cooldown multiplier",min=0,max=1,default=1,increment=0.01},
            [3] = {att="TagRaySpread", title="tag cast size",min=0,max=10,default=1,increment=0.01},
            [4] = {att="TagRayNumber", title="tag ray amount",min=0,max=100,default=9,increment=1},
            [5] = {att="TagRayRows", title="tag ray circle rows",min=0,max=10,default=1,increment=1},
        }
    },
    [3] = {
        label = "momentum",
        contents = {
            [1] = {att="MomentumMultiplier", title="base momentum multiplier",min=0,max=10,default=1,increment=0.01},
            [2] = {att="MomentumSpeed", title="momentum speed multiplier",min=0,max=10,default=1,increment=0.01},
            [3] = {att="MomentumDecay", title="momentum ground decay multiplier",min=0,max=2,default=1,increment=0.01},
            [4] = {att="MomentumMidair", title="momentum mid-air decay multiplier",min=0,max=2,default=1,increment=0.01},
        }
    },
    [4] = {
        label = "vaulting",
        contents = {
            [1] = {att="VaultMomentumMultiplier", title="vault momentum multiplier",min=0,max=10,default=1,increment=0.01},
            [2] = {att="VaultStackingMomentumMultiplier", title="vault stacking momentum multiplier",min=0,max=10,default=1,increment=0.01},
            [3] = {att="VaultCooldown", title="vault cooldown",min=0,max=1,default=0.1,increment=0.01},
        }
    },
    [5] = {
        label = "rolling",
        contents = {
            [1] = {att="RollSpeedMultiplier", title="roll speed multiplier",min=0,max=10,default=1,increment=0.01},
            [2] = {att="RollBoostMultiplier", title="roll jump multiplier",min=0,max=10,default=1,increment=0.01},
            [3] = {att="RollCooldown", title="roll cooldown",min=0,max=1,default=0,increment=0.01},
        }
    },
    [6] = {
        label = "sliding",
        contents = {
            [1] = {att="SlideSpeedMultiplier", title="slide speed multiplier",min=0,max=10,default=1,increment=0.01},
            [2] = {att="SlideJumpMultiplier", title="slide jump power multiplier",min=0,max=10,default=1,increment=0.01},
            [3] = {att="SlideLengthMultiplier", title="slide length multiplier",min=0,max=10,default=1,increment=0.01},
            [4] = {att="SlideSteerMultiplier", title="slide tuning multiplier",min=0,max=10,default=1,increment=0.01},
            [5] = {att="SlopesMultiplier", title="slide slope boost multiplier",min=0,max=10,default=1,increment=0.01},
            [6] = {att="SlideCooldown", title="slide cooldown",min=0,max=1,default=0,increment=0.01},
        }
    },
    [7] = {
        label = "rails",
        contents = {
            [1] = {att="RailGrindMultiplier", title="rail speed multiplier",min=0,max=10,default=1,increment=0.01},
            [2] = {att="RailGrindCooldown", title="rail cooldown",min=0,max=1,default=0,increment=0.01},
        }
    },
    [8] = {
        label = "swingbars",
        contents = {
            [1] = {att="SwingBarMultiplier", title="swingbar multiplier",min=0,max=10,default=1,increment=0.01},
            [2] = {att="SwingBarCooldown", title="swingbar cooldown",min=0,max=1,default=0,increment=0.01},
        }
    },
    [9] = {
        label = "ziplines",
        contents = {
            [1] = {att="ZiplineCooldown", title="zipline cooldown",min=0,max=1,default=0.5,increment=0.01},
        }
    },
    [10] = {
        label = "wallrunning",
        contents = {
            [1] = {att="WallrunCooldown", title="wallrun cooldown",min=0,max=1,default=0.66,increment=0.01},
        }
    },
    [11] = {
        label = "windows",
        contents = {
            [1] = {att="WindowSmashMultiplier", title="window smash slow-down multiplier",min=-10,max=2,default=1,increment=0.01},
            [2] = {att="WindowSmashCooldown", title="window smash cooldown",min=0,max=1,default=0,increment=0.01},
        }
    },
    
    [12] = {
        label = "friction",
        contents = {
            [1] = {att="FrictionMultiplier", title="base friction multiplier",min=0,max=10,default=1,increment=0.01},
            [2] = {att="FrictionSpeed", title="friction slow-down multiplier",min=0,max=10,default=1,increment=0.01},
            [3] = {att="FrictionDecay", title="friction ground decay multiplier",min=0,max=2,default=1,increment=0.01},
            [4] = {att="FrictionMidair", title="friction mid-air decay multiplier",min=0,max=2,default=1,increment=0.01},
        }
    },
    [13] = {
        label = "other",
        contents = {
            [1] = {att="JumpCooldown", title="jump cooldown",min=0,max=1,default=0.1,increment=0.01},
            [2] = {att="TurnSmoothing", title="turn smoothing",min=0,max=2,default=0,increment=0.01},
        }
    },
}

for _,tbl in pairs(modifications) do
    tab_mods.newlabel({title="-- ".. tbl.label .." --"})

    for _,options in pairs(tbl.contents) do
        local opts = {title=options.title,min=options.min,max=options.max,default=options.default,increment=options.increment,onchanged=function(val)
            modifiersfolder:SetAttribute(options.att,tonumber(val))
        end}
        tab_mods.newslider(opts)
    end
end

tab_importing.newlabel({title="-- maps --"})

local modelstatuslabel
local modelcanbeloaded = false
tab_importing.newtextbox({title="model id",onchanged=function(val)
    local txt = tostring(val)
    txt = tonumber(txt)

    local chngdisplaytxt = "model not found"

    modelcanbeloaded = false
    if txt then
        local success,_ = pcall(function() mps:GetProductInfo(txt,Enum.InfoType.Asset) end)
        local info = success and mps:GetProductInfo(txt,Enum.InfoType.Asset)

        if info then
            if info.AssetTypeId == 10 then
                if info.IsPublicDomain == true then
                    modelcanbeloaded = true
                    chngdisplaytxt = "model found: ".. tostring(info.Name)
                else
                    chngdisplaytxt = "model is not public"
                end
            else
                chngdisplaytxt = "asset is not a model"
            end
        else
            chngdisplaytxt = "model does not exist"
        end
    end
    modelstatuslabel.changetitle("> ".. chngdisplaytxt)

    flags.mapmodelid = txt
end})

modelstatuslabel = tab_importing.newlabel({title="> model not found"})

function tptorandomspawn()
    if char then
        local spawns = {}
        for _,v in pairs(currentmapfolder:GetDescendants()) do
            if v:IsA("SpawnLocation") then
                table.insert(spawns,v.CFrame+Vector3.new(0,v.Size.Y/2,0))
            end
        end

        if #spawns > 0 then
            local rng = spawns[math.random(1,#spawns)]
            char:PivotTo(rng+Vector3.new(0,6,0))
        else

        end
    end
end

tab_importing.newbutton({title="import map",onclick=function()
    if modelcanbeloaded then
        local instances = game:GetObjects("rbxassetid://".. tostring(flags.mapmodelid))

        if instances and #instances > 0 then
            currentmapfolder:ClearAllChildren()

            local totalinstances = 0
            for _,v in pairs(instances) do
                totalinstances += #v:GetDescendants()
                v.Parent = currentmapfolder
            end

            local countedinstances = 0
            for _,v in pairs(instances:GetDescendants()) do
                countedinstances += 1
                print(countedinstances .."/".. totalinstances)
            end
            tptorandomspawn()
        end
    end  
end})

tab_importing.newbutton({title="teleport to spawn",onclick=function()
    tptorandomspawn()
end})

tab_importing.newbutton({title="hide spawns",onclick=function()
    for _,v in pairs(currentmapfolder:GetDescendants()) do
        if v:IsA("SpawnLocation") then
            v.Transparency = 1
            v.CanCollide = false
            v.CanQuery = false
            v.CanTouch = false
            
            local decal = v:FindFirstChildOfClass("Decal")

            if decal then
                decal:Destroy()
            end
        end
    end
end})

tab_importing.newtoggle({title="detect swingbars",onclick=function(val)
    flags.mapdoswings = val
end})

tab_importing.newtoggle({title="remove invisible parts",onclick=function(val)
    flags.mapnoinvis = val
end})

local lastswingfallvel = 25
local vaulthistory = {}
local svladdershrink = 1
function rootinstanceadded(v)
    if v:IsA("Sound") then
        if v.Name == "Vault" or v.Name == "HighVault" then
            local accvh = nil

            if #vaulthistory >= 2 then
                table.sort(vaulthistory,function(a,b)
                    return a.ticktime > b.ticktime
                end)
            end

            if flags.staticvaultactive then
                local svh = flags.staticvaultheight
                local vel = root.AssemblyLinearVelocity
                local fakevel = math.clamp(30*svh/1.5,30,math.huge)

                if svh >= 2.5 then
                    v.SoundId = "rbxassetid://17775430987"
                else
                    v.SoundId = "rbxassetid://14054617616"
                end
                v:Play()
                
                runs.Stepped:Wait()
                accvh = getactualvaultheight()

                if flags.svdetectladders and #vaulthistory > 0 then
                    local strength = flags.svladderstrength
                    local nowtick = tick()
                    local shrinkness = 1

                    for _,v in pairs(vaulthistory) do
                        local secsover = nowtick-v.ticktime
                        if secsover <= strength then
                            local percentover = (strength-secsover)/strength
                            local negativity = ((strength/3)*percentover)^flags.svladdercurve
                            shrinkness = math.clamp(shrinkness-negativity,0,1)
                        end
                    end

                    svladdershrink = shrinkness
                    svh = flags.staticvaultheight*shrinkness
                    fakevel = math.clamp(30*svh/1.5,30,math.huge)
                end

                root.AssemblyLinearVelocity = Vector3.new(vel.X,fakevel,vel.Z)-root.CFrame.LookVector*2

                if not flags.staticvaultinnacurate then
                    local studsoff = accvh-svh

                    for i=1,10 do
                        char:PivotTo(char:GetPivot()+Vector3.new(0,studsoff/10,0))
                        task.wait()
                    end
                end
            end

            if not accvh then
                runs.Stepped:Wait()
                accvh = getactualvaultheight()
            end

            table.insert(vaulthistory,{
                ticktime = tick(),
                height = accvh,
            })
        elseif v.Name == "SwingBar" then
            if flags.staticswingactive then
                local pp = flags.staticswingpercent/100
                local velneeded = 25*pp^(1/0.7)
                local vel = root.AssemblyLinearVelocity

                root.AssemblyLinearVelocity = Vector3.new(vel.X,-velneeded,vel.Z)
            end

            if flags.uncapswings then
                lastswingfallvel = -root.AssemblyLinearVelocity.Y
                local percentage = (math.clamp(lastswingfallvel,25,math.huge) / 25) ^ 0.7 -- (math.clamp(-root.AssemblyLinearVelocity.Y,25,80) / 25) ^ 0.7

                if lastswingfallvel > 80 then
                    local overshoot = lastswingfallvel/80
                    codemodifiersfolder:SetAttribute("SwingBarMultiplier",overshoot)
                end
                task.wait(0.4)
                codemodifiersfolder:SetAttribute("SwingBarMultiplier",nil)
            end
        end
    elseif v:IsA("BodyVelocity") then
        if v.Name == "TagBodyVelocity" then
            if flags.noknockback then
                v.MaxForce = Vector3.new(0,0,0)
                v.Velocity = Vector3.new(0,0,0)
            end
        end
    end
end

function charadded(cc)
    if cc then
        char = cc
        hum = cc:WaitForChild("Humanoid")
        root = cc:WaitForChild("HumanoidRootPart")
        head = cc:WaitForChild("Head")
        camera = workspace.CurrentCamera
        
        debugui = playergui:WaitForChild("Debug")
        debugvalues = debugui:WaitForChild("TextLabel")
        debugprint = debugui:WaitForChild("PrintList")
        fakevalues = debugvalues:Clone()

        local values = char:WaitForChild("values")
        local lockmovevector = values:WaitForChild("LockMoveVector")

        vaultparams.FilterDescendantsInstances = {char}
        root.ChildAdded:Connect(rootinstanceadded)

        hum.StateChanged:Connect(function(_,humstate)
            if flags.bhop then
                if humstate == Enum.HumanoidStateType.Landed then
                    hum:SetAttribute("HasJumped",false)
                end
            end
        end)

        lockmovevector.Changed:Connect(function()
            if flags.nomovelock then
                if flags.lockslide and char:GetAttribute("Sliding") then
                    return
                end

                lockmovevector.Value = false
            end
        end)
        
        char.AttributeChanged:Connect(function(att)
            if att == "Frozen" and char:GetAttribute(att) then
                if flags.antifreeze then
                    char:SetAttribute("Frozen",false)
                    root.Anchored = false
                    
                    local block = root:WaitForChild("FrozenBlock")
                    block.CanCollide = false
                end
            end
        end)

        if flags.nocollision then
            disableplrcollision()
        end
    end
end

charadded(char)
plr.CharacterAdded:Connect(charadded)

function enemyadded(who)
    local hc = who.Character or who.CharacterAdded:Wait()

    if hc then
        local function limbadded(enemylimb)
            if char and flags.nocollision then
                for _,limb in pairs(char:GetChildren()) do
                    if limb:IsA("BasePart") then
                        local colcons = Instance.new("NoCollisionConstraint")
                        colcons.Part0 = limb
                        colcons.Part1 = enemylimb
                        colcons.Parent = limb
                        table.insert(nocolconstraints,colcons)
                    end
                end
            end
        end

        for i,v in pairs(hc:GetChildren()) do
            if v:IsA("BasePart") then
                limbadded(v)
            end
        end
        
        hc.ChildAdded:Connect(function(v)
            if v:IsA("BasePart") then
                limbadded(v)
            end
        end)
    end
end

for i,v in pairs(game.Players:GetPlayers()) do
    if v ~= plr then
        task.spawn(function()
            enemyadded(v)
        end)
    end
end

game.Players.PlayerAdded:Connect(enemyadded)

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
    "yall dont know me",
    "get this guy in #exploiter-reports",
    -- "this {user} guy looks weird",
    -- "hello {user} :)",
    -- "{user} gui",
    -- "@{user}",
    --"1v1 me {user}",
    "wire me $30 for the premium gui",
    "infinite tags generator",
    "snarp",
    "wiser actually sucks 1v1 me scrub",
    "@colde ban this guy",
    --"{user} is the real ultimateutgplayer",
    "thx to chamber for helping me",
    "credits to blazing for this gui",
    "new debug menu sucks",
    '"they added wallrunning" ahh gui',
    ":steam-happy:",
    "if only we had remote spy...",
    "S tier gui",
    "def sux",
    "chamber is my opp",
    "pingus gui",
    "colde gui",
    "nerd gui",
    "if only we had hookfunction...",
    "3% unc!",
    "nust gui",
    "nimbus is my goat",
    "cobalt blue is my GOAT",
    "utg mods smell",
    "redekbo best dev",
    "rikergui",
    "enable S+ mode",
    "compgui",
    "shoutout to utg comp",
    "whens tas coming out",
    "whens ultra-utg coming out",
    "/debt all",
    "now with anti-anti-cheat!",
}

window.visibilitychanged = function(opened)
    if opened then
        local newtitle = randomtitles[math.random(1,#randomtitles)]
        newtitle = string.gsub(newtitle,"{user}",plr.DisplayName)
        window.changetitle(newtitle)
    end
end

debugprint.ChildAdded:Connect(function(v)
    if v:IsA("TextLabel") then
        if v.Text:find("studs") then
            if flags.staticvaultspoof then
                local function updtxt()
                    local multi = flags.svdetectladders and svladdershrink or 1
                    local svh = tonumber(flags.staticvaultheight)*multi
                    local vtxt = string.format("%.2f",svh) .." studs"

                    if flags.staticshowreal then
                        vtxt = vtxt.." (".. string.format("%.2f",getactualvaultheight())..")"
                    end
                    v.Text = vtxt
                    
                    if svh >= 2.75 then
                        if not v:FindFirstChild("Rainbow") then
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
                        end

                        v.TextColor3 = Color3.fromRGB(255,255,255)
                    elseif svh >= 2 then
                        v.TextColor3 = Color3.fromRGB(80,255,179)

                        if v:FindFirstChild("Rainbow") then
                            v.Rainbow:Destroy()
                        end
                    else
                        v.TextColor3 = Color3.fromRGB(255,255,226)

                        if v:FindFirstChild("Rainbow") then
                            v.Rainbow:Destroy()
                        end
                    end
                end

                updtxt()
                runs.Stepped:Wait()
                updtxt()
            end
        elseif v.Text:find("%%") then
            if flags.uncapswings then
                local percentage = (math.clamp(lastswingfallvel,25,math.huge) / 25) ^ 0.7 
                local sat = (percentage - 1 + 0.001)/1.8

                v.TextColor3 = Color3.fromHSV(0.74+sat/2,0.15+sat,1)
                v.Text = string.format("%.2f%%",percentage*100)
            end
        end
    end
end)

fakevalues.Parent = debugui
rep.Events.ui.FadeIn:Destroy()
debugvalues.Changed:Connect(function()
    local showfake = debugvalues.Visible and flags.staticvaultspoof
    local faketxt = debugvalues.Text
    fakevalues.Visible = showfake
    debugvalues.TextTransparency = showfake and 1 or 0

    if flags.staticvaultspoof then
        local svh = tostring(flags.staticvaultheight)*svladdershrink
        local find = string.find(faketxt,"vault height:")
        local half1 = string.sub(faketxt,0,find+13)
        local half2 = string.sub(faketxt,find+18,faketxt:len())

        faketxt = half1.. string.format("%.2f",svh) ..half2
    end
    fakevalues.Text = faketxt
end)

runs.Stepped:Connect(function()
    local svc = flags.showvaultcast
    local autov = flags.autovault
    local anti = flags.antinullvault
    local holdj = flags.holdjump
    local emoter = flags.emotemove
    local assact = flags.aimassistactive

    if svc or autov then
        local preray
        local ray
        
        for step=0.5,2,0.25 do
            if not ray then
                preray = Ray.new(root.Position+root.CFrame.LookVector*step+root.CFrame.UpVector*2.75,-root.CFrame.UpVector*3.25)
                ray = workspace:Raycast(preray.Origin,preray.Direction,vaultparams)
            end
        end
    
        if ray then
            local height = math.abs(ray.Position.Y-root.Position.Y)

            if autov and height >= flags.autovaultheight then
                print("auto vaulted")
                task.spawn(function()
                    keypress("Space")
                    task.wait(0.1)
                    keyrelease("Space")
                end)
            end
        end

        if svc then
            fakeray.Position = preray.Origin-Vector3.new(0,fakeray.Size.Y/2,0)
        end
    end

    if anti then
        if char and head then
            head.CanCollide = false
        end
    end

    if holdj then
        if hum then
            hum:SetAttribute("HasJumped",false)
        end
    end

    if emoter then
        if char and hum and root then
            local vel = root.AssemblyLinearVelocity
            if vel.Magnitude > 0 then
                local wspeed = math.max(32*getmultipliedmodifier("RunSpeedMultiplier"),hum.WalkSpeed)
                local noyvel = Vector3.new(vel.X,0,vel.Z)
                local unit = noyvel.Unit
                root.AssemblyLinearVelocity = Vector3.new(unit.X*wspeed,vel.Y,unit.Z*wspeed)
            end
        end
    end

    local setattsens = 1
    if assact then
        if root then
            local hit = mouse.Target

            if hit then
                local hc = hit:FindFirstAncestorOfClass("Model")

                if hc then
                    local hplr = game.Players:GetPlayerFromCharacter(hc)

                    if hplr and (hplr ~= plr) then
                        local hrole = hplr:FindFirstChild("PlayerRole")
                        local enemies = getenemies(role.Value)
                        
                        if table.find(enemies,hrole.Value) then
                            setattsens = 1-flags.aimassiststrength
                        end
                    end
                end
            end
        end
    end
    modifiersfolder:SetAttribute("MouseSensitivityMultiplier",setattsens)
end)
