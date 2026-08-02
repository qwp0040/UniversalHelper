--========================================================================
-- Roblox 通用辅助脚本 v3.7
-- 功能: ESP / Xray / 移动辅助 / 穿墙 / 互动 / 夜视 / NPC透视 / 通知
-- 特性: 异步加载 / PC端UI / 彩虹边框 / 悬浮窗 / 动画 / 通知系统
--========================================================================

task.spawn(function()

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local CoreGui           = game:GetService("CoreGui")
local Lighting          = game:GetService("Lighting")
local Workspace         = game:GetService("Workspace")
local TweenService      = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

task.wait()

local Config = {
    PlayerESP=false, WallXray=false, WallDetail=false,
    WallTrans=0.7, TriggerTrans=0.4, DamageTrans=0.4,
    WallRange=200, WallSpeedMode="fast",
    WallAutoRefresh=false, WallRefreshInterval=10,
    NightVision=false, NightValue=20,
    NPCESP=false, TeamCheck=false,
    NPCESPColor="Red", NPCShowName=true, NPCShowDist=true, NPCShowHealth=true,
    PlayerShowName=true, PlayerShowDist=true, PlayerShowHealth=true,
    AutoRefresh=false, RefreshInterval=5,
    SpeedEnabled=false, SpeedValue=16,
    JumpEnabled=false, JumpValue=50,
    FlyEnabled=false, FlySpeed=50,
    TeleWalk=false, TeleWalkValue=10,
    Noclip=false,
    FastInteract=false, InteractESP=false, InteractDist=10, LongRangeInteract=false,
    -- 自动互动
    AutoInteract=false,           -- 自动互动总开关
    AutoInteractRange=30,         -- 自动互动检测范围(stud)
    AutoInteractInterval=0.5,     -- 自动互动触发间隔(秒)
    AutoInteractTarget="",        -- 选中的目标互动名称(空=全部)
    AutoInteractIgnoreDist=false, -- 不受距离限制(全图触发) 默认关闭=只互动周围
    AutoDetectInteract=true,      -- 自动检测可互动对象(持续扫描填充列表, 无需手动点)
    AutoInteractSingleMode=false, -- 单选模式(仅互动选中的目标名称)
    AutoInteractKey=Enum.KeyCode.E, -- 自动互动按键(默认E, 可自定义)
    PureAutoInteract=false,       -- 纯自动互动模式(开启后连续点按设定按键)
    PureAutoInteractInterval=0.3, -- 纯自动点按间隔(秒)
    -- 自动修改(刷新互动增强)
    AutoModify=false,             -- 自动修改总开关(开启后慢速扫描+循环修改)
    AutoModifyMode=1,             -- 1=全部重复修改 2=单次修改模式
    AutoModifyInterval=2.0,       -- 全部重复模式的间隔(秒)
    NotifyEnabled=true, NotifyMode="normal",
    UIScale=1.0,
    InfiniteJump=false,
    FloatMode=false, FloatSpeed=30,
    GhostMode=false, GhostSpeed=50,
    GhostShortcutEnabled=false, GhostShortcutKey="G",
    NPCKill=false, NPCKillRange=50,
    GhostStatusBar=true,
    -- 枪械检测/修改
    WeaponInfAmmo=false, WeaponInfAmmoThreshold=5,
    WeaponAutoFire=false,
    -- 格斗功能
    CombatEnabled=false, CombatFaceTarget=false, CombatFaceKey="F1",
    CombatLockView=false, CombatLockSmooth=50,
    CombatPredict=false, CombatPredictPercent=80, CombatFaceSmooth=50,
    CombatForceFace=false, CombatLockColorR=255, CombatLockColorG=255, CombatLockColorB=255,
    CombatMiniUI=false,
    CombatLockMode=1,  -- 1=全部 2=仅玩家 3=仅NPC
    CombatLockPart=1,  -- 1=身体(HRP) 2=头部(Head)
    CombatBulletSpeed=500,  -- 预判用的子弹速度 (stud/s, 远程武器)
    -- 游戏检测
    GameTypeDetected="未检测",

    -- 服务器特效简化 (保留特效但大幅降低渲染负担)
    FXSimplify=false,          -- 总开关
    FXSimplifyParticles=true,  -- 简化粒子发射器
    FXSimplifyBeams=true,      -- 简化光束
    FXSimplifyTrails=true,     -- 简化拖尾
    FXSimplifyDecals=true,     -- 简化贴花(降透明度而非删除)
    FXSimplifySmoke=true,      -- 简化烟雾/火焰
    FXParticleRate=0.15,       -- 粒子发射率保留比例 (15%)
    FXBeamTransparency=0.7,    -- 光束透明度提升至 0.7
    FXTrailTransparency=0.7,   -- 拖尾透明度提升至 0.7
    FXDecalTransparency=0.6,   -- 贴花透明度提升至 0.6
    FXBatchSize=2,             -- 每帧处理数量 (慢速, 防大卡顿闪退)
    FXBatchInterval=0.1,       -- 每帧间隔秒数

    -- 超级简化 (彻底优化, 针对低端电脑/重特效游戏如最强战场)
    SuperSimplify=false,       -- 超级简化总开关
    SSQualityLevel=1,          -- 画质等级 1=最低 2=低 3=中 (默认最低)
    SSCullDistance=300,        -- 远距离剔除距离 (超过此距离的特效/部件降级或隐藏)
    SSCullParts=true,          -- 远距离 BasePart 剔除 (透明度降低)
    SSRemoveShadows=true,      -- 关闭所有阴影
    SSRemoveLighting=true,     -- 简化光照 (Fog/ColorShift等)
    SSRemoveTextures=true,     -- 移除贴图 (Texture/Decal 透明化)
    SSRemoveMeshes=false,      -- 移除 SpecialMesh (谨慎, 可能导致看不到模型)
    SSReduceMaterials=true,    -- 材质改为 SmoothPlastic/Neon (减少反射计算)
    SSLowerRenderDistance=true,-- 降低渲染距离 (QualitySettings)
    SSDisablePostEffects=true, -- 关闭后处理特效 (Bloom/ColorCorrection/SunRays/DepthOfField)
    SSAggressiveParticles=true,-- 激进粒子简化 (直接 Rate=0 而非降低)

    -- 娱乐功能
    HelicopterSpin=false,        -- 直升机旋转 (展开双臂+快速旋转+飞行)
    HelicopterSpinSpeed=18,      -- 旋转速度 (弧度/秒)
    Spin360=false,               -- 360度无死角旋转 (碰撞体积不变)
    Spin360Speed=10,             -- 360旋转速度
    FakeRagdoll=false,           -- 假布娃娃 (自然倒地+名字跟随+搞笑爬行)

}

local NotifyCfg = {
    low    = {max=3,  cooldown=3},
    normal = {max=10, cooldown=1.5},
    high   = {max=50, cooldown=1},
}

local Saved = {
    WalkSpeed=nil, JumpPower=nil,
    Lighting={Brightness=Lighting.Brightness, Ambient=Lighting.Ambient,
              OutdoorAmbient=Lighting.OutdoorAmbient, ColorShift_Top=Lighting.ColorShift_Top,
              ColorShift_Bottom=Lighting.ColorShift_Bottom, GlobalShadows=Lighting.GlobalShadows,
              FogEnd=Lighting.FogEnd},
    Prompts={}, PartData={}, PartCollide={},
    FloatConn=nil, JumpConn=nil,
}

local Ghost = {
    Conn=nil, CamConn=nil, FreezeConn=nil,
    OriginalCamType=nil, OriginalSubject=nil,
    OriginalWalkSpeed=nil, OriginalJumpPower=nil, OriginalAutoRotate=nil,
    OriginalCFrame=nil, OriginalAnchored=nil, OriginalMouseBehavior=nil,
    StatusGui=nil, StatusLabel=nil,
}

local SavedFloatState = nil

-- ============== NPC名称中英文翻译表 ==============
local NPC_NAME_TRANSLATIONS = {
    -- 基础敌人
    ["zombie"]="丧尸", ["skeleton"]="骷髅", ["spider"]="蜘蛛", ["bat"]="蝙蝠",
    ["wolf"]="恶狼", ["bear"]="熊", ["rat"]="老鼠", ["snake"]="蛇",
    ["scorpion"]="蝎子", ["centipede"]="蜈蚣", ["shark"]="鲨鱼", ["crab"]="螃蟹",
    ["bee"]="蜜蜂", ["ant"]="蚂蚁", ["boar"]="野猪", ["pig"]="猪",
    ["crocodile"]="鳄鱼", ["wild"]="野生", ["beast"]="野兽",
    -- 人形敌人
    ["bandit"]="强盗", ["thief"]="盗贼", ["assassin"]="刺客", ["robber"]="劫匪",
    ["pirate"]="海盗", ["guard"]="守卫", ["soldier"]="士兵", ["knight"]="骑士",
    ["warrior"]="战士", ["hunter"]="猎人", ["archer"]="弓箭手", ["mage"]="法师",
    ["wizard"]="巫师", ["witch"]="女巫", ["necromancer"]="死灵法师",
    ["cultist"]="邪教徒", ["shaman"]="萨满", ["priest"]="祭司",
    -- 怪物
    ["goblin"]="哥布林", ["orc"]="兽人", ["ogre"]="食人魔", ["troll"]="巨魔",
    ["golem"]="魔像", ["ghost"]="幽灵", ["wraith"]="怨灵", ["phantom"]="幻影",
    ["shadow"]="暗影", ["specter"]="幽灵", ["demon"]="恶魔", ["devil"]="魔鬼",
    ["imp"]="小恶魔", ["ghoul"]="食尸鬼", ["slime"]="史莱姆", ["elemental"]="元素",
    -- 首领
    ["boss"]="首领", ["king"]="国王", ["queen"]="女王", ["lord"]="领主",
    ["overlord"]="霸主", ["tyrant"]="暴君", ["emperor"]="皇帝",
    ["miniboss"]="小首领", ["elite"]="精英", ["captain"]="队长", ["general"]="将军",
    ["champion"]="冠军", ["warlord"]="军阀",
    -- CHAIN游戏特有
    ["chain"]="锁链杀手", ["zach"]="扎克", ["monoloth"]="巨塔", ["monolith"]="巨塔",
    ["it"]="它",
    -- 其他
    ["mutant"]="变异体", ["abomination"]="憎恶", ["horror"]="恐怖",
    ["reaper"]="死神", ["clown"]="小丑", ["mannequin"]="人偶", ["dummy"]="假人",
    ["scarecrow"]="稻草人", ["robot"]="机器人", ["drone"]="无人机",
    ["turret"]="炮台", ["cyborg"]="半机械人", ["android"]="仿生人",
    ["mercenary"]="雇佣兵", ["bounty"]="赏金猎人", ["raider"]="突袭者",
    ["marauder"]="掠夺者", ["invader"]="入侵者", ["stranger"]="陌生人",
    ["villain"]="反派", ["enemy"]="敌人", ["hostile"]="敌对", ["threat"]="威胁",
    ["killer"]="杀手", ["murderer"]="凶手", ["psycho"]="疯子",
    ["stalker"]="跟踪者", ["chaser"]="追击者", ["creeper"]="苦力怕",
    ["brute"]="蛮兵", ["grunt"]="步兵", ["minion"]="小兵", ["creep"]="野怪",
    ["mob"]="怪物", ["monster"]="怪物", ["creature"]="生物",
    ["dragon"]="巨龙", ["wyvern"]="双足飞龙", ["hydra"]="九头蛇",
    ["phoenix"]="凤凰", ["unicorn"]="独角兽",
    -- 友好
    ["npc"]="村民", ["villager"]="村民", ["merchant"]="商人", ["shop"]="商店",
    ["quest"]="任务NPC", ["friend"]="友军", ["ally"]="盟友", ["guide"]="向导",
    ["helper"]="助手", ["citizen"]="市民", ["innocent"]="平民", ["safe"]="安全",
    ["healer"]="治疗师", ["blacksmith"]="铁匠", ["baker"]="面包师", ["farmer"]="农民",
    ["trainer"]="训练师", ["banker"]="银行家", ["fisherman"]="渔夫",
    ["doctor"]="医生", ["teacher"]="教师", ["pet"]="宠物",
}

-- 翻译函数: 将NPC名称翻译为简体中文
local function TranslateNPCName(name)
    local lower = tostring(name):lower()
    -- 精确匹配
    if NPC_NAME_TRANSLATIONS[lower] then
        return NPC_NAME_TRANSLATIONS[lower]
    end
    -- 模糊匹配: 包含关键词
    for k, v in pairs(NPC_NAME_TRANSLATIONS) do
        if lower:find(k) then
            return v
        end
    end
    return name
end

task.wait()

local function GetHRP()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function GetHum()
    local c = LocalPlayer.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function SaveUIPos(pos)
    pcall(function()
        if not _G.UH_V34 then _G.UH_V34 = {} end
        _G.UH_V34.X = pos.X.Offset
        _G.UH_V34.Y = pos.Y.Offset
    end)
end
local function LoadUIPos()
    if _G.UH_V34 and _G.UH_V34.X then
        return UDim2.new(0, _G.UH_V34.X, 0, _G.UH_V34.Y)
    end
    return UDim2.new(0, 120, 0, 100)
end
local function SaveFloatPos(pos)
    pcall(function()
        if not _G.UH_V34 then _G.UH_V34 = {} end
        _G.UH_V34.FX = pos.X.Offset
        _G.UH_V34.FY = pos.Y.Offset
    end)
end
local function LoadFloatPos()
    if _G.UH_V34 and _G.UH_V34.FX then
        return UDim2.new(0, _G.UH_V34.FX, 0, _G.UH_V34.FY)
    end
    return UDim2.new(0, 30, 0.5, -32)
end

task.wait()

-- ============== 通知系统 (Roblox 风格: 屏幕顶部居中) ==============
local NotifyGui = Instance.new("ScreenGui")
NotifyGui.Name = "NotifySystemV34"
NotifyGui.ResetOnSpawn = false
NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NotifyGui.IgnoreGuiInset = true  -- 避免被顶部偏移影响
NotifyGui.Parent = CoreGui

local ActiveNotifs = {}
local NotifyCount = 0
local NotifyCooldownEnd = 0
local LastNotifyTime = 0

local function GetNotifyConfig()
    return NotifyCfg[Config.NotifyMode] or NotifyCfg.normal
end

local function RepositionNotifs()
    -- 从屏幕右下角向上排列, 第一个在底部 10px 处
    local yOff = 10
    for i = #ActiveNotifs, 1, -1 do
        local e = ActiveNotifs[i]
        if e and e.Frame and e.Frame.Parent then
            local h = e.Height or 50
            e.TargetY = yOff
            yOff = yOff + h + 6
            TweenService:Create(e.Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Position = UDim2.new(1, -20, 1, -e.TargetY)
            }):Play()
        end
    end
end

local function ShowNotification(title, text, color)
    if not Config.NotifyEnabled then return end
    color = color or Color3.fromRGB(80, 160, 220)
    local cfg = GetNotifyConfig()
    local now = tick()

    if now < NotifyCooldownEnd then return end
    if NotifyCount >= cfg.max then
        NotifyCooldownEnd = now + cfg.cooldown
        NotifyCount = 0
        return
    end
    if now - LastNotifyTime < 0.1 then return end
    LastNotifyTime = now
    NotifyCount = NotifyCount + 1

    local notifH = 50

    local notif = Instance.new("Frame")
    notif.Name = "NotifyItem"
    notif.Size = UDim2.new(0, 300, 0, notifH)
    notif.AnchorPoint = Vector2.new(1, 1)  -- 从右下角定位
    notif.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
    notif.BorderSizePixel = 0
    notif.Parent = NotifyGui

    local border = Instance.new("Frame")
    border.Name = "NotifyBorder"
    border.Size = UDim2.new(0, 4, 1, 0)
    border.BackgroundColor3 = color
    border.BorderSizePixel = 0
    border.Parent = notif
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 6)
    Instance.new("UICorner", border).CornerRadius = UDim.new(0, 6)

    local ttl = Instance.new("TextLabel")
    ttl.Name = "NotifyTitle"
    ttl.Size = UDim2.new(1, -20, 0, 20)
    ttl.Position = UDim2.new(0, 12, 0, 6)
    ttl.BackgroundTransparency = 1
    ttl.Text = title
    ttl.TextColor3 = Color3.fromRGB(255,255,255)
    ttl.Font = Enum.Font.GothamBold
    ttl.TextSize = 13
    ttl.TextXAlignment = Enum.TextXAlignment.Left
    ttl.Parent = notif

    local msg = Instance.new("TextLabel")
    msg.Name = "NotifyMsg"
    msg.Size = UDim2.new(1, -20, 0, 20)
    msg.Position = UDim2.new(0, 12, 0, 28)
    msg.BackgroundTransparency = 1
    msg.Text = text
    msg.TextColor3 = Color3.fromRGB(200, 200, 210)
    msg.Font = Enum.Font.Gotham
    msg.TextSize = 11
    msg.TextWrapped = true
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.Parent = notif

    local startY = 10
    local entry = {Frame = notif, Height = notifH, TargetY = startY}
    table.insert(ActiveNotifs, entry)

    -- 从屏幕右侧外滑入到右下角
    notif.Position = UDim2.new(1, 320, 1, -startY)
    TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -20, 1, -startY)
    }):Play()

    task.defer(RepositionNotifs)

    -- 3.5秒后向右滑出并销毁
    task.delay(3.5, function()
        if not notif or not notif.Parent then return end
        TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 350, 1, notif.Position.Y.Offset)
        }):Play()
        task.wait(0.55)
        if notif and notif.Parent then notif:Destroy() end
        for i, e in ipairs(ActiveNotifs) do
            if e == entry then table.remove(ActiveNotifs, i) break end
        end
        task.defer(RepositionNotifs)
    end)
end

task.wait()

-- ============== 服务器特效简化系统 (保留但不删除, 仅降低渲染负担) ==============
-- 原理: 把粒子发射率/光束透明度/拖尾长度等参数调低, 特效仍存在但更轻量
-- 慢速分批处理, 每帧只改 Config.FXBatchSize 个对象, 避免一次性扫描导致闪退
-- 整个系统包在 do...end 块内, 内部 helper 函数不占用主作用域 local 寄存器
-- (避免触发 Luau "Out of local registers (exceeded limit 200)" 错误)
-- 对外只暴露 StartFXSimplify / StopFXSimplify / FXRestart 三个 local
local StartFXSimplify, StopFXSimplify, FXRestart
do
    local FX = {
        Enabled = false,
        Originals = {},       -- instance -> {prop=val,...} 保存原值用于还原
        ProcessQueue = {},    -- 待扫描的容器
        PendingChildConn = {},-- 监听新特效产生的连接
        StatsCount = 0,
        LoopToken = 0,        -- 协程令牌, 防止多个扫描协程同时运行
    }

    -- 安全读取 Instance 属性 (失败返回 nil)
    local function safeGet(obj, prop)
        local ok, v = pcall(function() return obj[prop] end)
        if ok then return v end
        return nil
    end

    -- 判断对象是否属于本地玩家自己 (避免简化自己手持武器的特效)
    local function IsLocalPlayerOwned(obj)
        local p = obj
        local depth = 0
        while p and depth < 50 do  -- 深度限制防死循环
            depth = depth + 1
            if p == LocalPlayer then return true end
            p = safeGet(p, "Parent")
        end
        return false
    end

    -- 保存原值 (仅第一次)
    local function FXSave(obj, prop, newVal)
        if not FX.Originals[obj] then FX.Originals[obj] = {} end
        if FX.Originals[obj][prop] == nil then
            local ok, cur = pcall(function() return obj[prop] end)
            if ok then FX.Originals[obj][prop] = cur end
        end
        pcall(function() obj[prop] = newVal end)
    end

    -- 处理单个特效对象 (内部实现, 由 FXProcess 用 pcall 包裹调用)
    local function FXProcessInner(obj)
        local alive = false
        pcall(function() alive = obj ~= nil and obj.Parent ~= nil end)
        if not alive then return end
        if FX.Originals[obj] then return end
        if IsLocalPlayerOwned(obj) then return end

        local cls = safeGet(obj, "ClassName")
        if not cls then return end

        if Config.FXSimplifyParticles and cls == "ParticleEmitter" then
            local origRate = safeGet(obj, "Rate")
            if type(origRate) == "number" and origRate > 1 then
                FXSave(obj, "Rate", math.max(0, math.floor(origRate * Config.FXParticleRate)))
            end
            local lifetime = safeGet(obj, "Lifetime")
            if lifetime and type(lifetime) == "table" then
                local mn, mx = lifetime.Min, lifetime.Max
                if type(mn) == "number" and type(mx) == "number" and mn >= 0 and mx >= 0 and mx >= mn then
                    FXSave(obj, "Lifetime", NumberRange.new(mn * 0.7, mx * 0.7))
                end
            end
            local speed = safeGet(obj, "Speed")
            if speed and type(speed) == "table" then
                local mn, mx = speed.Min, speed.Max
                if type(mn) == "number" and type(mx) == "number" and mn >= 0 and mx >= 0 and mx >= mn then
                    FXSave(obj, "Speed", NumberRange.new(mn * 0.5, mx * 0.5))
                end
            end
            FX.StatsCount = FX.StatsCount + 1
        elseif Config.FXSimplifyBeams and cls == "Beam" then
            local t = Config.FXBeamTransparency
            if type(t) == "number" and t >= 0 and t <= 1 then
                FXSave(obj, "Transparency", NumberSequence.new(t))
            end
            local w0 = safeGet(obj, "Width0")
            if type(w0) == "number" and w0 > 0.1 then
                FXSave(obj, "Width0", w0 * 0.5)
            end
            local w1 = safeGet(obj, "Width1")
            if type(w1) == "number" and w1 > 0.1 then
                FXSave(obj, "Width1", w1 * 0.5)
            end
            FX.StatsCount = FX.StatsCount + 1
        elseif Config.FXSimplifyTrails and cls == "Trail" then
            local t = Config.FXTrailTransparency
            if type(t) == "number" and t >= 0 and t <= 1 then
                FXSave(obj, "Transparency", NumberSequence.new(t))
            end
            local lt = safeGet(obj, "Lifetime")
            if type(lt) == "number" and lt > 0.2 then
                FXSave(obj, "Lifetime", lt * 0.6)
            end
            FX.StatsCount = FX.StatsCount + 1
        elseif Config.FXSimplifyDecals and (cls == "Decal" or cls == "Texture") then
            local t = Config.FXDecalTransparency
            if type(t) == "number" and t >= 0 and t <= 1 then
                FXSave(obj, "Transparency", t)
            end
            FX.StatsCount = FX.StatsCount + 1
        elseif Config.FXSimplifySmoke and (cls == "Smoke" or cls == "Fire" or cls == "Sparkles") then
            if cls == "Smoke" then
                FXSave(obj, "Opacity", 0.1)
                local sz = safeGet(obj, "Size")
                if type(sz) == "number" then FXSave(obj, "Size", math.max(0.5, sz * 0.3)) end
            elseif cls == "Fire" then
                local heat = safeGet(obj, "Heat")
                if type(heat) == "number" then FXSave(obj, "Heat", math.max(0, heat * 0.2)) end
                local sz = safeGet(obj, "Size")
                if type(sz) == "number" then FXSave(obj, "Size", math.max(0.5, sz * 0.3)) end
            elseif cls == "Sparkles" then
                FXSave(obj, "Enabled", false)
            end
            FX.StatsCount = FX.StatsCount + 1
        end
    end

    -- 处理单个特效对象 (pcall 保护)
    local function FXProcess(obj)
        pcall(FXProcessInner, obj)
    end

    -- 硬性上限: 最多保存多少个对象的原值 (防止内存耗尽闪退)
    local FX_MAX_ORIGINALS = 1500
    -- 队列上限
    local FX_MAX_QUEUE = 3000
    -- 每帧遍历子级的硬上限 (无论是否为特效, 超过就yield)
    local FX_CHILDREN_PER_YIELD = 30

    local function FXCollectContainers()
        FX.ProcessQueue = {}
        -- 只扫描 Workspace (Lighting 几乎没有特效, 跳过减少开销)
        table.insert(FX.ProcessQueue, Workspace)
    end

    local function safeBatchSize()
        local v = Config.FXBatchSize
        if type(v) ~= "number" or v < 1 then return 1 end
        return math.floor(v)
    end
    local function safeBatchInterval()
        local v = Config.FXBatchInterval
        if type(v) ~= "number" or v <= 0 then return 0.15 end
        return v
    end

    -- 跳过这些类型的子级 (不可能是特效容器, 也不需要递归)
    local FX_SKIP_CLASSES = {
        Camera = true, Terrain = true, Weld = true, WeldConstraint = true,
        Motor6D = true, Bone = true, Humanoid = true, Animation = true,
        Script = true, LocalScript = true, ModuleScript = true,
        Sound = true, SoundService = true, Texture = true,  -- Texture 作为贴花已处理
        ValueBase = true,  -- 各种 Value 对象
    }

    local function FXScanLoop(myToken)
        while FX.Enabled and FX.LoopToken == myToken do
            local batchSize = safeBatchSize()
            local processedThisFrame = 0
            local childrenIterated = 0

            while #FX.ProcessQueue > 0 do
                if not FX.Enabled or FX.LoopToken ~= myToken then return end
                -- 原值表已满, 停止扫描 (防止内存耗尽)
                if FX.StatsCount >= FX_MAX_ORIGINALS then break end

                local container = table.remove(FX.ProcessQueue, 1)
                local valid = false
                pcall(function() valid = container ~= nil and container.Parent ~= nil end)
                if valid then
                    local children
                    pcall(function() children = container:GetChildren() end)
                    if children then
                        for _, child in ipairs(children) do
                            if not FX.Enabled or FX.LoopToken ~= myToken then return end

                            -- 每遍历 FX_CHILDREN_PER_YIELD 个子级就 yield 一次 (防单帧卡死闪退)
                            childrenIterated = childrenIterated + 1
                            if childrenIterated >= FX_CHILDREN_PER_YIELD then
                                childrenIterated = 0
                                task.wait(safeBatchInterval())
                            end

                            local ok, cls = pcall(function() return child.ClassName end)
                            if not ok then
                                -- 跳过无法读取类型的对象
                            elseif cls == "ParticleEmitter" or cls == "Beam" or cls == "Trail"
                                    or cls == "Decal" or cls == "Smoke"
                                    or cls == "Fire" or cls == "Sparkles" then
                                FXProcess(child)
                                processedThisFrame = processedThisFrame + 1
                                if processedThisFrame >= batchSize then break end
                            else
                                -- 非特效对象: 如果不是跳过类型且队列未满, 加入队列递归扫描
                                if not FX_SKIP_CLASSES[cls] and #FX.ProcessQueue < FX_MAX_QUEUE then
                                    table.insert(FX.ProcessQueue, child)
                                end
                            end
                        end
                    end
                end

                -- 达到本帧批处理上限, 跳出内层 while
                if processedThisFrame >= batchSize then break end
                -- 原值表已满
                if FX.StatsCount >= FX_MAX_ORIGINALS then break end
            end

            -- 等待下一帧
            task.wait(safeBatchInterval())

            -- 队列空了且原值表没满, 等2秒后重新扫描 (捕捉新加入的特效)
            if #FX.ProcessQueue == 0 and FX.Enabled and FX.LoopToken == myToken
               and FX.StatsCount < FX_MAX_ORIGINALS then
                task.wait(2)
                if FX.Enabled and FX.LoopToken == myToken then
                    FXCollectContainers()
                end
            end
        end
    end

    local function FXSetupListeners()
        if #FX.PendingChildConn > 0 then return end
        local conn1 = Workspace.DescendantAdded:Connect(function(obj)
            if not FX.Enabled then return end
            if not obj then return end
            local ok, cls = pcall(function() return obj.ClassName end)
            if not ok then return end
            if cls == "ParticleEmitter" or cls == "Beam" or cls == "Trail"
               or cls == "Decal" or cls == "Texture" or cls == "Smoke"
               or cls == "Fire" or cls == "Sparkles" then
                task.wait(0.2)
                if FX.Enabled then FXProcess(obj) end
            end
        end)
        table.insert(FX.PendingChildConn, conn1)
    end

    local function FXClearListeners()
        for _, c in ipairs(FX.PendingChildConn) do pcall(function() c:Disconnect() end) end
        FX.PendingChildConn = {}
    end

    -- 赋值给块外前向声明的 local
    StartFXSimplify = function()
        if FX.Enabled then return end
        FX.Enabled = true
        FX.Originals = {}
        FX.StatsCount = 0
        FX.LoopToken = FX.LoopToken + 1
        local myToken = FX.LoopToken
        FXCollectContainers()
        FXSetupListeners()
        task.spawn(function()
            pcall(FXScanLoop, myToken)
        end)
    end

    StopFXSimplify = function()
        FX.Enabled = false
        FX.LoopToken = FX.LoopToken + 1
        FXClearListeners()
        FX.ProcessQueue = {}
        local restored = 0
        pcall(function()
            for obj, props in pairs(FX.Originals) do
                local alive = false
                pcall(function() alive = obj ~= nil and obj.Parent ~= nil end)
                if alive then
                    for prop, val in pairs(props) do
                        pcall(function() obj[prop] = val end)
                        restored = restored + 1
                    end
                end
            end
        end)
        FX.Originals = {}
        return restored
    end

    FXRestart = function()
        task.spawn(function()
            pcall(function()
                if FX.Enabled then
                    StopFXSimplify()
                    task.wait(0.3)
                    if Config.FXSimplify then StartFXSimplify() end
                end
            end)
        end)
    end
end -- FX 系统块结束

-- ============== 超级简化系统 (彻底优化, 针对低端电脑/重特效游戏) ==============
-- 原理: 降低画质/关闭阴影/简化光照/移除贴图/远距离剔除/激进粒子简化
-- 全程慢速分批处理, do-end 块隔离 local 寄存器
local StartSuperSimplify, StopSuperSimplify
do
    local SS = {
        Enabled = false,
        Originals = {},        -- instance -> {prop=val,...} 保存原值
        ProcessQueue = {},     -- 待扫描的容器队列
        DescendantConn = nil,  -- DescendantAdded 监听
        LoopToken = 0,         -- 协程令牌
        StatsCount = 0,
        LightingSaved = nil,   -- 保存的 Lighting 属性
        QualitySaved = nil,    -- 保存的 QualitySettings
    }

    -- 安全读取
    local function safeGet(obj, prop)
        local ok, v = pcall(function() return obj[prop] end)
        if ok then return v end
        return nil
    end
    -- 安全设置 (带原值保存)
    local function SSSave(obj, prop, newVal)
        if not SS.Originals[obj] then SS.Originals[obj] = {} end
        if SS.Originals[obj][prop] == nil then
            local ok, cur = pcall(function() return obj[prop] end)
            if ok then SS.Originals[obj][prop] = cur end
        end
        pcall(function() obj[prop] = newVal end)
    end

    -- 判断是否为本地玩家自己的对象 (不简化自己)
    local function IsLocalPlayerOwned(obj)
        local p = obj
        local depth = 0
        while p and depth < 50 do
            depth = depth + 1
            if p == LocalPlayer then return true end
            p = safeGet(p, "Parent")
        end
        return false
    end

    -- 跳过这些类型 (不简化, 不递归)
    local SS_SKIP_CLASSES = {
        Camera = true, Terrain = true, Weld = true, WeldConstraint = true,
        Motor6D = true, Bone = true, Humanoid = true, Animation = true,
        Script = true, LocalScript = true, ModuleScript = true,
        Sound = true, SoundService = true, SoundGroup = true,
        ValueBase = true,  -- 含 IntValue/StringValue 等
        ContextActionService = true, TweenService = true,
        Player = true, Players = true, Workspace = true,
    }

    -- 后处理特效类名 (Lighting 下的)
    local SS_POST_FX_CLASSES = {
        BloomEffect = true, ColorCorrectionEffect = true, SunRaysEffect = true,
        DepthOfFieldEffect = true, BlurEffect = true, Atmosphere = true,
        BerryCubeEffect = true,  -- 部分游戏自定义
    }

    -- 处理单个对象
    local function SSProcessInner(obj)
        local alive = false
        pcall(function() alive = obj ~= nil and obj.Parent ~= nil end)
        if not alive then return end
        if SS.Originals[obj] then return end
        if IsLocalPlayerOwned(obj) then return end

        local cls = safeGet(obj, "ClassName")
        if not cls then return end

        -- 距离剔除 (对 BasePart)
        if Config.SSCullParts and (cls == "Part" or cls == "MeshPart" or cls == "UnionOperation"
            or cls == "TrussPart" or cls == "WedgePart" or cls == "CornerWedgePart") then
            -- 简化材质 (减少反射计算)
            if Config.SSReduceMaterials then
                local mat = safeGet(obj, "Material")
                if mat and mat ~= Enum.Material.SmoothPlastic and mat ~= Enum.Material.Neon then
                    SSSave(obj, "Material", Enum.Material.SmoothPlastic)
                end
                -- 关闭反射
                local ref = safeGet(obj, "Reflectance")
                if type(ref) == "number" and ref > 0 then
                    SSSave(obj, "Reflectance", 0)
                end
                -- 关闭投射阴影
                if Config.SSRemoveShadows then
                    local cs = safeGet(obj, "CastShadow")
                    if cs == true then
                        SSSave(obj, "CastShadow", false)
                    end
                end
            end
            SS.StatsCount = SS.StatsCount + 1
            return
        end

        -- 激进粒子简化 (直接 Rate=0)
        if Config.SSAggressiveParticles and cls == "ParticleEmitter" then
            SSSave(obj, "Rate", 0)
            SS.StatsCount = SS.StatsCount + 1
            return
        end

        -- 光束/拖尾 (激进化: 直接透明)
        if Config.SSAggressiveParticles and (cls == "Beam" or cls == "Trail") then
            SSSave(obj, "Transparency", NumberSequence.new(1))
            if cls == "Trail" then
                local lt = safeGet(obj, "Lifetime")
                if type(lt) == "number" and lt > 0.1 then
                    SSSave(obj, "Lifetime", 0.1)
                end
            end
            SS.StatsCount = SS.StatsCount + 1
            return
        end

        -- 贴图/贴花 (透明化)
        if Config.SSRemoveTextures and (cls == "Decal" or cls == "Texture") then
            SSSave(obj, "Transparency", 1)
            SS.StatsCount = SS.StatsCount + 1
            return
        end

        -- SpecialMesh (谨慎: 可能导致看不到模型, 默认关)
        if Config.SSRemoveMeshes and cls == "SpecialMesh" then
            local vis = safeGet(obj, "Visible")
            if vis ~= false then
                SSSave(obj, "Visible", false)
            end
            SS.StatsCount = SS.StatsCount + 1
            return
        end

        -- 烟雾/火焰/闪光 (激进化: 关闭)
        if Config.SSAggressiveParticles and (cls == "Smoke" or cls == "Fire" or cls == "Sparkles") then
            if cls == "Smoke" then
                SSSave(obj, "Opacity", 0)
            elseif cls == "Fire" then
                SSSave(obj, "Heat", 0)
                SSSave(obj, "Size", 0)
            elseif cls == "Sparkles" then
                SSSave(obj, "Enabled", false)
            end
            SS.StatsCount = SS.StatsCount + 1
            return
        end
    end

    local function SSProcess(obj)
        pcall(SSProcessInner, obj)
    end

    -- 硬性上限
    local SS_MAX_ORIGINALS = 3000
    local SS_MAX_QUEUE = 4000
    local SS_CHILDREN_PER_YIELD = 25

    local function SSApplyLighting()
        if not Config.SSRemoveLighting then return end
        SS.LightingSaved = {}
        pcall(function()
            SS.LightingSaved.Brightness = Lighting.Brightness
            SS.LightingSaved.GlobalShadows = Lighting.GlobalShadows
            SS.LightingSaved.FogEnd = Lighting.FogEnd
            SS.LightingSaved.FogStart = Lighting.FogStart
            SS.LightingSaved.ColorShift_Top = Lighting.ColorShift_Top
            SS.LightingSaved.ColorShift_Bottom = Lighting.ColorShift_Bottom
            SS.LightingSaved.EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale
            SS.LightingSaved.EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale
            -- 应用简化值
            Lighting.Brightness = 2
            Lighting.GlobalShadows = false
            if Lighting.FogEnd then Lighting.FogEnd = 1e9 end  -- 关闭雾
            if Lighting.FogStart then Lighting.FogStart = 1e9 end
            Lighting.ColorShift_Top = Color3.fromRGB(0,0,0)
            Lighting.ColorShift_Bottom = Color3.fromRGB(0,0,0)
            if Lighting.EnvironmentDiffuseScale then Lighting.EnvironmentDiffuseScale = 0 end
            if Lighting.EnvironmentSpecularScale then Lighting.EnvironmentSpecularScale = 0 end
        end)
    end

    local function SSRestoreLighting()
        if not SS.LightingSaved then return end
        pcall(function()
            Lighting.Brightness = SS.LightingSaved.Brightness or 2
            Lighting.GlobalShadows = SS.LightingSaved.GlobalShadows
            if SS.LightingSaved.FogEnd then Lighting.FogEnd = SS.LightingSaved.FogEnd end
            if SS.LightingSaved.FogStart then Lighting.FogStart = SS.LightingSaved.FogStart end
            Lighting.ColorShift_Top = SS.LightingSaved.ColorShift_Top
            Lighting.ColorShift_Bottom = SS.LightingSaved.ColorShift_Bottom
            if SS.LightingSaved.EnvironmentDiffuseScale then Lighting.EnvironmentDiffuseScale = SS.LightingSaved.EnvironmentDiffuseScale end
            if SS.LightingSaved.EnvironmentSpecularScale then Lighting.EnvironmentSpecularScale = SS.LightingSaved.EnvironmentSpecularScale end
        end)
        SS.LightingSaved = nil
    end

    -- 关闭 Lighting 下的后处理特效
    local function SSDisablePostFX()
        if not Config.SSDisablePostEffects then return end
        pcall(function()
            for _, child in ipairs(Lighting:GetChildren()) do
                local cls = safeGet(child, "ClassName")
                if cls and SS_POST_FX_CLASSES[cls] then
                    if SS.Originals[child] == nil then
                        SS.Originals[child] = { Enabled = safeGet(child, "Enabled") }
                        pcall(function() child.Enabled = false end)
                        SS.StatsCount = SS.StatsCount + 1
                    end
                end
            end
        end)
    end

    -- 降低画质等级
    local function SSApplyQuality()
        if not Config.SSLowerRenderDistance then return end
        SS.QualitySaved = {}
        pcall(function()
            local settings = UserSettings()
            local q = settings:GetService("RenderSettings")
            SS.QualitySaved.QualityLevel = q.QualityLevel
            SS.QualitySaved.MeshDetailDistance = q.MeshDetailDistance
            -- 画质设为最低
            q.QualityLevel = Enum.QualityLevel.Level01
            q.MeshDetailDistance = 0
        end)
    end

    local function SSRestoreQuality()
        if not SS.QualitySaved then return end
        pcall(function()
            local settings = UserSettings()
            local q = settings:GetService("RenderSettings")
            q.QualityLevel = SS.QualitySaved.QualityLevel or Enum.QualityLevel.Automatic
            if SS.QualitySaved.MeshDetailDistance then q.MeshDetailDistance = SS.QualitySaved.MeshDetailDistance end
        end)
        SS.QualitySaved = nil
    end

    local function SSCollectContainers()
        SS.ProcessQueue = {}
        table.insert(SS.ProcessQueue, Workspace)
    end

    local function SSScanLoop(myToken)
        while SS.Enabled and SS.LoopToken == myToken do
            local processedThisFrame = 0
            local childrenIterated = 0

            while #SS.ProcessQueue > 0 do
                if not SS.Enabled or SS.LoopToken ~= myToken then return end
                if SS.StatsCount >= SS_MAX_ORIGINALS then break end

                local container = table.remove(SS.ProcessQueue, 1)
                local valid = false
                pcall(function() valid = container ~= nil and container.Parent ~= nil end)
                if valid then
                    local children
                    pcall(function() children = container:GetChildren() end)
                    if children then
                        for _, child in ipairs(children) do
                            if not SS.Enabled or SS.LoopToken ~= myToken then return end

                            childrenIterated = childrenIterated + 1
                            if childrenIterated >= SS_CHILDREN_PER_YIELD then
                                childrenIterated = 0
                                task.wait(0.15)
                            end

                            local ok, cls = pcall(function() return child.ClassName end)
                            if not ok then
                                -- 跳过
                            elseif not SS_SKIP_CLASSES[cls] then
                                SSProcess(child)
                                -- 递归入队
                                if #SS.ProcessQueue < SS_MAX_QUEUE then
                                    table.insert(SS.ProcessQueue, child)
                                end
                            end
                        end
                    end
                end

                if SS.StatsCount >= SS_MAX_ORIGINALS then break end
            end

            task.wait(0.2)

            -- 队列空了, 等5秒后重新扫描 (捕捉新加入的对象)
            if #SS.ProcessQueue == 0 and SS.Enabled and SS.LoopToken == myToken
               and SS.StatsCount < SS_MAX_ORIGINALS then
                task.wait(5)
                if SS.Enabled and SS.LoopToken == myToken then
                    SSCollectContainers()
                end
            end
        end
    end

    local function SSSetupListener()
        if SS.DescendantConn then return end
        SS.DescendantConn = Workspace.DescendantAdded:Connect(function(obj)
            if not SS.Enabled then return end
            if not obj then return end
            local ok, cls = pcall(function() return obj.ClassName end)
            if not ok then return end
            -- 后处理特效类型直接处理 (虽不在 Workspace, 但容错)
            -- 普通对象延迟处理
            task.wait(0.3)
            if SS.Enabled and not SS_SKIP_CLASSES[cls] then
                SSProcess(obj)
            end
        end)
    end

    local function SSClearListener()
        if SS.DescendantConn then
            pcall(function() SS.DescendantConn:Disconnect() end)
            SS.DescendantConn = nil
        end
    end

    StartSuperSimplify = function()
        if SS.Enabled then return end
        SS.Enabled = true
        SS.Originals = {}
        SS.StatsCount = 0
        SS.LoopToken = SS.LoopToken + 1
        local myToken = SS.LoopToken

        -- 立即应用光照/画质/后处理 (这些是即时生效的, 不会卡)
        SSApplyLighting()
        SSDisablePostFX()
        SSApplyQuality()

        -- 启动慢速扫描协程 (处理 BasePart/粒子等)
        SSCollectContainers()
        SSSetupListener()
        task.spawn(function()
            pcall(SSScanLoop, myToken)
        end)
    end

    StopSuperSimplify = function()
        SS.Enabled = false
        SS.LoopToken = SS.LoopToken + 1
        SSClearListener()
        SS.ProcessQueue = {}

        -- 还原所有对象属性
        local restored = 0
        pcall(function()
            for obj, props in pairs(SS.Originals) do
                local alive = false
                pcall(function() alive = obj ~= nil and obj.Parent ~= nil end)
                if alive then
                    for prop, val in pairs(props) do
                        pcall(function() obj[prop] = val end)
                        restored = restored + 1
                    end
                end
            end
        end)
        SS.Originals = {}
        SS.StatsCount = 0

        -- 还原光照和画质
        SSRestoreLighting()
        SSRestoreQuality()

        return restored
    end
end -- 超级简化系统块结束

-- ============== 玩家ESP (定时器驱动, 不用Heartbeat) ==============
local PlayerESP = {
    Highlights = {}, Billboards = {}, Connections = {}, RefreshConn = nil,
}
-- 文本缓存 (避免每帧重复设置TextLabel.Text产生GC和重排开销)
local PlayerESP_LastDist = {}    -- char -> 上次距离字符串
local PlayerESP_LastHealth = {}  -- char -> 上次血量字符串
local PlayerESP_LastColor = {}   -- char -> 上次颜色

local function IsTeammate(player)
    if not Config.TeamCheck then return false end
    -- 双方都必须有Team且相等, 避免nil==nil误判
    if not LocalPlayer.Team or not player.Team then return false end
    return player.Team == LocalPlayer.Team
end

local function CreatePlayerHL(character, color)
    if not character or not character.Parent then return nil end
    local existing = character:FindFirstChild("PlayerHighlight")
    if existing then existing.FillColor = color; return existing end
    local h = Instance.new("Highlight")
    h.Name = "PlayerHighlight"
    h.FillColor = color; h.FillTransparency = 0.5
    h.OutlineColor = Color3.new(1,1,1); h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = character
    return h
end

local function CreatePlayerBB(character, player)
    if not character or not character.Parent then return nil end
    local head = character:FindFirstChild("Head")
    if not head then return nil end
    local existing = head:FindFirstChild("PlayerBillboard")
    if existing then return existing end
    local color = IsTeammate(player) and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 80, 80)
    local bb = Instance.new("BillboardGui")
    bb.Name = "PlayerBillboard"
    bb.Size = UDim2.new(0, 200, 0, 66)
    bb.StudsOffset = Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop = true; bb.MaxDistance = 500
    bb.Parent = head
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Name = "NameLabel"
    nameLbl.Size = UDim2.new(1, 0, 0, 22); nameLbl.BackgroundTransparency = 1
    nameLbl.Text = player.Name; nameLbl.TextColor3 = color
    nameLbl.TextStrokeTransparency = 0.3; nameLbl.TextStrokeColor3 = Color3.new(0,0,0)
    nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextSize = 14
    nameLbl.Visible = Config.PlayerShowName
    nameLbl.Parent = bb
    local healthLbl = Instance.new("TextLabel")
    healthLbl.Name = "HealthLabel"
    healthLbl.Size = UDim2.new(1, 0, 0, 22); healthLbl.Position = UDim2.new(0, 0, 0, 22)
    healthLbl.BackgroundTransparency = 1; healthLbl.Text = "100/100"
    healthLbl.TextColor3 = Color3.fromRGB(120, 220, 120)
    healthLbl.TextStrokeTransparency = 0.3; healthLbl.TextStrokeColor3 = Color3.new(0,0,0)
    healthLbl.Font = Enum.Font.Gotham; healthLbl.TextSize = 12
    healthLbl.Visible = Config.PlayerShowHealth
    healthLbl.Parent = bb
    local distLbl = Instance.new("TextLabel")
    distLbl.Name = "DistLabel"
    distLbl.Size = UDim2.new(1, 0, 0, 22); distLbl.Position = UDim2.new(0, 0, 0, 44)
    distLbl.BackgroundTransparency = 1; distLbl.Text = "0m"
    distLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLbl.TextStrokeTransparency = 0.3; distLbl.TextStrokeColor3 = Color3.new(0,0,0)
    distLbl.Font = Enum.Font.Gotham; distLbl.TextSize = 12
    distLbl.Visible = Config.PlayerShowDist
    distLbl.Parent = bb
    return bb
end

local function RemovePlayerESP(character)
    if not character then return end
    pcall(function()
        for _, child in ipairs(character:GetDescendants()) do
            if child.Name == "PlayerHighlight" or child.Name == "PlayerBillboard" then
                child:Destroy()
            end
        end
    end)
    PlayerESP.Highlights[character] = nil
    PlayerESP.Billboards[character] = nil
    PlayerESP_LastDist[character] = nil
    PlayerESP_LastHealth[character] = nil
    PlayerESP_LastColor[character] = nil
end

local function ClearAllPlayerESP()
    for char, _ in pairs(PlayerESP.Highlights) do RemovePlayerESP(char) end
    PlayerESP.Highlights = {}; PlayerESP.Billboards = {}
    PlayerESP_LastDist = {}; PlayerESP_LastHealth = {}; PlayerESP_LastColor = {}
    for char, conns in pairs(PlayerESP.Connections) do
        for _, conn in pairs(conns) do pcall(function() conn:Disconnect() end) end
    end
    PlayerESP.Connections = {}
    if PlayerESP.RefreshConn then PlayerESP.RefreshConn = nil end
end

local function UpdatePlayerESP()
    if not Config.PlayerESP then return end
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos = myHRP and myHRP.Position or Vector3.zero

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Config.TeamCheck and IsTeammate(player) then
            if player.Character then RemovePlayerESP(player.Character) end
            continue
        end
        local char = player.Character
        if not char or not char.Parent then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local color = IsTeammate(player) and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 80, 80)
        -- Highlight (仅颜色变化时才写入)
        if not PlayerESP.Highlights[char] or not PlayerESP.Highlights[char].Parent then
            local hl = CreatePlayerHL(char, color)
            if hl then PlayerESP.Highlights[char] = hl end
        elseif PlayerESP_LastColor[char] ~= color then
            PlayerESP.Highlights[char].FillColor = color
        end
        -- Billboard
        local bb = PlayerESP.Billboards[char]
        if not bb or not bb.Parent then
            bb = CreatePlayerBB(char, player)
            if bb then PlayerESP.Billboards[char] = bb end
        end
        if bb then
            -- 实时同步显示开关 (无需重新开关ESP即可生效)
            local nl = bb:FindFirstChild("NameLabel")
            local hl = bb:FindFirstChild("HealthLabel")
            local dl = bb:FindFirstChild("DistLabel")
            if nl then
                if nl.Visible ~= Config.PlayerShowName then nl.Visible = Config.PlayerShowName end
                if PlayerESP_LastColor[char] ~= color then nl.TextColor3 = color end
            end
            if hl then
                if hl.Visible ~= Config.PlayerShowHealth then hl.Visible = Config.PlayerShowHealth end
                -- 血量文字 (仅在变化时写入, 减少GC和重排)
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    local htxt = string.format("%d/%d", math.floor(hum.Health), math.floor(hum.MaxHealth))
                    if PlayerESP_LastHealth[char] ~= htxt then
                        PlayerESP_LastHealth[char] = htxt
                        hl.Text = htxt
                        local hpct = hum.MaxHealth > 0 and hum.Health / hum.MaxHealth or 0
                        local hcol
                        if hpct > 0.6 then hcol = Color3.fromRGB(120, 220, 120)
                        elseif hpct > 0.3 then hcol = Color3.fromRGB(255, 200, 80)
                        else hcol = Color3.fromRGB(255, 80, 80) end
                        hl.TextColor3 = hcol
                    end
                end
            end
            if dl then
                if dl.Visible ~= Config.PlayerShowDist then dl.Visible = Config.PlayerShowDist end
                -- 距离文字 (仅在变化时写入)
                if myHRP then
                    local dist = (myPos - hrp.Position).Magnitude
                    local dtxt = string.format("%.1fm", dist)
                    if PlayerESP_LastDist[char] ~= dtxt then
                        PlayerESP_LastDist[char] = dtxt
                        dl.Text = dtxt
                    end
                end
            end
        end
        PlayerESP_LastColor[char] = color
        if not PlayerESP.Connections[char] then
            PlayerESP.Connections[char] = {}
            table.insert(PlayerESP.Connections[char], char.AncestryChanged:Connect(function(_, parent)
                if not parent then RemovePlayerESP(char) end
            end))
        end
    end
end

local function RefreshESP()
    ClearAllPlayerESP()
    if not Config.PlayerESP then return end
    UpdatePlayerESP()
    -- 用 task.spawn 循环代替 Heartbeat, 每0.5秒更新一次 (缓存命中时几乎零开销)
    PlayerESP.RefreshConn = true
    task.spawn(function()
        while PlayerESP.RefreshConn and Config.PlayerESP do
            UpdatePlayerESP()
            task.wait(0.5)
        end
    end)
end

-- 玩家ESP标签可见性切换 (名字/血量/距离)
local function UpdatePlayerLabelVisibility()
    for char, bb in pairs(PlayerESP.Billboards) do
        if bb and bb.Parent then
            local nl = bb:FindFirstChild("NameLabel")
            local hl = bb:FindFirstChild("HealthLabel")
            local dl = bb:FindFirstChild("DistLabel")
            if nl then nl.Visible = Config.PlayerShowName end
            if hl then hl.Visible = Config.PlayerShowHealth end
            if dl then dl.Visible = Config.PlayerShowDist end
        end
    end
end

-- 主动监听新玩家加入/离开 + 角色重生 (无需开启"自动刷新"即可实时透视新玩家)
local PlayerJoinConn, PlayerLeaveConn
local function SetupPlayerJoinListeners()
    if PlayerJoinConn then return end
    PlayerJoinConn = Players.PlayerAdded:Connect(function(plr)
        -- 角色加载后立即触发一次ESP更新 (角色可能延迟生成, 监听CharacterAdded兜底)
        local function tryAdd()
            if not Config.PlayerESP then return end
            if plr.Character then
                task.wait(0.2)  -- 等HRP生成
                if Config.PlayerESP then UpdatePlayerESP() end
            else
                local conn
                conn = plr.CharacterAdded:Connect(function()
                    task.wait(0.3)
                    if Config.PlayerESP then UpdatePlayerESP() end
                    if conn then conn:Disconnect() end
                end)
            end
        end
        task.spawn(tryAdd)
    end)
    PlayerLeaveConn = Players.PlayerRemoving:Connect(function(plr)
        if plr and plr.Character then RemovePlayerESP(plr.Character) end
    end)
end

-- 玩家ESP自动刷新 (定时重新扫描全部玩家, 捕获新加入/离开的玩家)
local PlayerAutoRefreshConn = nil
local function SetupPlayerAutoRefresh()
    if PlayerAutoRefreshConn then return end
    PlayerAutoRefreshConn = true
    task.spawn(function()
        while PlayerAutoRefreshConn do
            task.wait(Config.RefreshInterval)
            if not PlayerAutoRefreshConn then break end
            if Config.PlayerESP and Config.AutoRefresh then
                pcall(function()
                    ClearAllPlayerESP()
                    task.wait(0.1)
                    RefreshESP()
                end)
            end
        end
    end)
end

-- ============== 幽灵状态栏 ==============
local function CreateGhostStatusBar()
    if Ghost.StatusGui then return end
    local sg = Instance.new("ScreenGui")
    sg.Name = "GhostStatusBarV34"
    sg.ResetOnSpawn = false; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = CoreGui
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 36)
    frame.Position = UDim2.new(1, -220, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(32, 34, 42); frame.BorderSizePixel = 0
    frame.Parent = sg
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 2; stroke.Color = Color3.fromRGB(180, 80, 255)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 1, 0); lbl.Position = UDim2.new(0, 5, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = "幽灵模式: 关闭"
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.Parent = frame
    Ghost.StatusGui = sg; Ghost.StatusLabel = lbl
end

local function UpdateGhostStatusBar()
    if not Ghost.StatusLabel then return end
    if Config.GhostMode then
        Ghost.StatusLabel.Text = "幽灵模式: 开启 | 速度: " .. Config.GhostSpeed
        Ghost.StatusLabel.TextColor3 = Color3.fromRGB(180, 80, 255)
    else
        Ghost.StatusLabel.Text = "幽灵模式: 关闭"
        Ghost.StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    end
end

task.wait()

-- ============== NPC ESP (慢速逐个处理 + 缓存 + 中文翻译) ==============
local NPC_ESP = {
    Highlights={}, Billboards={}, ActiveModels={},
    ProcessQueue={}, LastScan=0, LastDistUpdate=0, LastCacheRebuild=0,
    ScanIndex=0, _lastExtraScan=0, LastCleanup=0,
    DiedConns={},  -- 跟踪每个NPC的Humanoid.Died连接, 死后立即清理
}
-- 同时存在的Highlight上限 (超过会自动剔除最远的)
-- AlwaysOnTop Highlight每个都是独立渲染通道, 太多会直接卡退
local MAX_NPC_ESP = 80
-- 超此距离的NPC禁用Highlight的Enabled (不销毁, 走近自动恢复, 避免闪烁)
local NPC_ESP_FADE_DIST = 600
local NPC_COLORS = {
    Red    = Color3.fromRGB(255, 0, 0),
    Blue   = Color3.fromRGB(0, 100, 255),
    Yellow = Color3.fromRGB(255, 215, 0),
    Green  = Color3.fromRGB(0, 255, 100),
}

local CachedModels = {}
local ModelList = {}
local ModelCount = 0
local CacheDirty = false
local NPCChildAddedConn = nil
local NPCChildRemovedConn = nil

-- 统计当前活跃ESP数量 (用于上限控制, 防止Highlight累积卡退)
local function GetActiveESPCount()
    local n = 0
    for _ in pairs(NPC_ESP.Highlights) do n += 1 end
    return n
end

local function IsNPCModel(obj)
    if not obj or not obj:IsA("Model") then return false end
    if obj == LocalPlayer.Character then return false end
    if Players:GetPlayerFromCharacter(obj) then return false end
    local humanoid = obj:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    return true
end

local function RemoveNPCESP(model)
    if not model then return end
    pcall(function()
        for _, child in ipairs(model:GetDescendants()) do
            if child.Name == "NPCHighlight" or child.Name == "NPCBillboard" then
                child:Destroy()
            end
        end
    end)
    -- 断开死亡监听
    if NPC_ESP.DiedConns[model] then
        NPC_ESP.DiedConns[model]:Disconnect()
        NPC_ESP.DiedConns[model] = nil
    end
    NPC_ESP.Highlights[model] = nil
    NPC_ESP.Billboards[model] = nil
    NPC_ESP.ActiveModels[model] = nil
end

local function CreateNPCHL(model, color)
    if not model or not model.Parent then return nil end
    local existing = model:FindFirstChild("NPCHighlight")
    if existing then existing.FillColor = color; return existing end
    local h = Instance.new("Highlight")
    h.Name = "NPCHighlight"
    h.FillColor = color
    h.FillTransparency = 0.7  -- 提高透明度降低GPU混合开销
    h.OutlineColor = Color3.new(1,1,1); h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = model
    return h
end

local function CreateNPCBB(model, color, displayName)
    if not model or not model.Parent then return nil end
    local head = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
    if not head then
        for _, child in ipairs(model:GetDescendants()) do
            if child:IsA("BasePart") then head = child; break end
        end
    end
    if not head then return nil end
    local existing = head:FindFirstChild("NPCBillboard")
    if existing then
        local nl = existing:FindFirstChild("NameLabel")
        if nl then nl.TextColor3 = color; nl.Text = displayName end
        return existing, existing:FindFirstChild("DistLabel")
    end
    local bb = Instance.new("BillboardGui")
    bb.Name = "NPCBillboard"
    bb.Size = UDim2.new(0, 200, 0, 66)
    bb.StudsOffset = Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop = true; bb.MaxDistance = 500
    bb.Parent = head
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Name = "NameLabel"
    nameLbl.Size = UDim2.new(1, 0, 0, 22); nameLbl.BackgroundTransparency = 1
    nameLbl.Text = displayName; nameLbl.TextColor3 = color
    nameLbl.TextStrokeTransparency = 0.3; nameLbl.TextStrokeColor3 = Color3.new(0,0,0)
    nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextSize = 14
    nameLbl.Visible = Config.NPCShowName
    nameLbl.Parent = bb
    local healthLbl = Instance.new("TextLabel")
    healthLbl.Name = "HealthLabel"
    healthLbl.Size = UDim2.new(1, 0, 0, 22); healthLbl.Position = UDim2.new(0, 0, 0, 22)
    healthLbl.BackgroundTransparency = 1; healthLbl.Text = "100/100"
    healthLbl.TextColor3 = Color3.fromRGB(120, 220, 120)
    healthLbl.TextStrokeTransparency = 0.3; healthLbl.TextStrokeColor3 = Color3.new(0,0,0)
    healthLbl.Font = Enum.Font.Gotham; healthLbl.TextSize = 12
    healthLbl.Visible = Config.NPCShowHealth
    healthLbl.Parent = bb
    local distLbl = Instance.new("TextLabel")
    distLbl.Name = "DistLabel"
    distLbl.Size = UDim2.new(1, 0, 0, 22); distLbl.Position = UDim2.new(0, 0, 0, 44)
    distLbl.BackgroundTransparency = 1; distLbl.Text = "0m"
    distLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLbl.TextStrokeTransparency = 0.3; distLbl.TextStrokeColor3 = Color3.new(0,0,0)
    distLbl.Font = Enum.Font.Gotham; distLbl.TextSize = 12
    distLbl.Visible = Config.NPCShowDist
    distLbl.Parent = bb
    return bb, distLbl
end

-- 更新NPC标签可见性 (名字/血量/距离开关)
local function UpdateNPCLabelVisibility()
    for model, bb in pairs(NPC_ESP.Billboards) do
        if bb and bb.Parent then
            local nl = bb:FindFirstChild("NameLabel")
            local hl = bb:FindFirstChild("HealthLabel")
            local dl = bb:FindFirstChild("DistLabel")
            if nl then nl.Visible = Config.NPCShowName end
            if hl then hl.Visible = Config.NPCShowHealth end
            if dl then dl.Visible = Config.NPCShowDist end
        end
    end
end

-- 更新NPC血量显示文字
local function UpdateNPCHealthLabels()
    for model, bb in pairs(NPC_ESP.Billboards) do
        if bb and bb.Parent and model and model.Parent then
            local hl = bb:FindFirstChild("HealthLabel")
            if hl then
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hum then
                    hl.Text = string.format("%d/%d", math.floor(hum.Health), math.floor(hum.MaxHealth))
                    local hpct = hum.MaxHealth > 0 and hum.Health / hum.MaxHealth or 0
                    if hpct > 0.6 then hl.TextColor3 = Color3.fromRGB(120, 220, 120)
                    elseif hpct > 0.3 then hl.TextColor3 = Color3.fromRGB(255, 200, 80)
                    else hl.TextColor3 = Color3.fromRGB(255, 80, 80) end
                end
            end
        end
    end
end

local function OnModelAdded(model)
    if not IsNPCModel(model) then return end
    if not CachedModels[model] then
        CachedModels[model] = true
        table.insert(ModelList, model)
        ModelCount += 1
        task.delay(0.1, function()
            if model and model.Parent and Config.NPCESP then
                table.insert(NPC_ESP.ProcessQueue, model)
            end
        end)
    end
end

local function OnModelRemoved(model)
    if CachedModels[model] then
        CachedModels[model] = nil
        RemoveNPCESP(model)
        CacheDirty = true
    end
end

local function StartCacheListeners()
    if NPCChildAddedConn then return end
    -- 顶层 ChildAdded (快速路径, 捕获直接放在Workspace的NPC)
    NPCChildAddedConn = Workspace.ChildAdded:Connect(function(child)
        if child:IsA("Model") then
            OnModelAdded(child)
            local subConn = child.ChildAdded:Connect(function(sub)
                if sub:IsA("Model") then OnModelAdded(sub) end
            end)
            child.Destroying:Once(function()
                subConn:Disconnect()
                OnModelRemoved(child)
            end)
        end
    end)
    NPCChildRemovedConn = Workspace.ChildRemoved:Connect(function(child)
        OnModelRemoved(child)
    end)
    -- DescendantAdded 兜底 (捕获任意层级新生成的NPC, 如Workspace.Map.Spawn.NPC1)
    -- 处理两种时序: 模型先于Humanoid加入 / Humanoid后加入模型
    NPC_ESP.DescConn = Workspace.DescendantAdded:Connect(function(obj)
        if not obj then return end
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            -- 模型加入时已含Humanoid
            OnModelAdded(obj)
        elseif obj:IsA("Humanoid") then
            -- Humanoid后加入模型, 向上找Character模型
            local model = obj.Parent
            if model and model:IsA("Model") then
                OnModelAdded(model)
            end
        end
    end)
end

local function StopCacheListeners()
    if NPCChildAddedConn then NPCChildAddedConn:Disconnect() NPCChildAddedConn = nil end
    if NPCChildRemovedConn then NPCChildRemovedConn:Disconnect() NPCChildRemovedConn = nil end
    if NPC_ESP.DescConn then NPC_ESP.DescConn:Disconnect() NPC_ESP.DescConn = nil end
end

local function ClearAllNPCESP()
    for model, _ in pairs(NPC_ESP.Highlights) do RemoveNPCESP(model) end
    -- 兜底: 清理所有死亡监听
    for model, conn in pairs(NPC_ESP.DiedConns) do
        if conn then conn:Disconnect() end
        NPC_ESP.DiedConns[model] = nil
    end
    NPC_ESP.Highlights = {}; NPC_ESP.Billboards = {}; NPC_ESP.ActiveModels = {}
    NPC_ESP.ProcessQueue = {}; NPC_ESP.LastScan = 0; NPC_ESP.LastDistUpdate = 0
    NPC_ESP.LastCacheRebuild = 0; NPC_ESP.ScanIndex = 0; NPC_ESP.LastCleanup = 0
    CachedModels = {}; ModelList = {}; ModelCount = 0; CacheDirty = false
    StopCacheListeners()
end

local function UpdateNPCDistancesAsync()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local myPos = hrp.Position
    local list = {}
    for model, _ in pairs(NPC_ESP.Billboards) do
        if model and model.Parent then table.insert(list, model) end
    end
    for i, model in ipairs(list) do
        if not Config.NPCESP then return end
        local bb = NPC_ESP.Billboards[model]
        if bb and bb.Parent then
            local npcPart = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
            if not npcPart then
                for _, child in ipairs(model:GetDescendants()) do
                    if child:IsA("BasePart") then npcPart = child; break end
                end
            end
            if npcPart then
                local dist = (myPos - npcPart.Position).Magnitude
                local distLbl = bb:FindFirstChild("DistLabel")
                if distLbl then distLbl.Text = string.format("%.1fm", dist) end
            end
        end
        if i % 8 == 0 then task.wait() end
    end
end

local function UpdateNPCESPColor(newColor)
    local list = {}
    for model, _ in pairs(NPC_ESP.Highlights) do table.insert(list, model) end
    for i, model in ipairs(list) do
        local hl = NPC_ESP.Highlights[model]
        if hl and hl.Parent then hl.FillColor = newColor end
        local bb = NPC_ESP.Billboards[model]
        if bb and bb.Parent then
            local nl = bb:FindFirstChild("NameLabel")
            if nl then nl.TextColor3 = newColor end
        end
        if i % 3 == 0 then task.wait() end
    end
end

-- 慢速扫描: 逐个处理, 极低频率
local function SlowScanNPCs()
    if not Config.NPCESP then return end
    local now = tick()
    local color = NPC_COLORS[Config.NPCESPColor] or NPC_COLORS.Red

    StartCacheListeners()

    -- 缓存为空时立即扫描 (分批, 防卡顿)
    if ModelCount == 0 then
        local scanned = 0
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Model") and IsNPCModel(obj) then
                if not CachedModels[obj] then
                    CachedModels[obj] = true
                    table.insert(ModelList, obj)
                    ModelCount += 1
                    table.insert(NPC_ESP.ProcessQueue, obj)
                end
            end
            for _, sub in ipairs(obj:GetChildren()) do
                if sub:IsA("Model") and IsNPCModel(sub) then
                    if not CachedModels[sub] then
                        CachedModels[sub] = true
                        table.insert(ModelList, sub)
                        ModelCount += 1
                        table.insert(NPC_ESP.ProcessQueue, sub)
                    end
                end
            end
            scanned += 1
            if scanned >= 50 then break end
        end
        NPC_ESP.LastCacheRebuild = now
    end

    -- 每30秒异步重建缓存
    if now - NPC_ESP.LastCacheRebuild > 30 then
        NPC_ESP.LastCacheRebuild = now
        task.defer(function()
            local newCache = {}; local newList = {}; local count = 0
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("Model") and IsNPCModel(obj) then
                    newCache[obj] = true; table.insert(newList, obj); count += 1
                end
                for _, sub in ipairs(obj:GetChildren()) do
                    if sub:IsA("Model") and IsNPCModel(sub) then
                        newCache[sub] = true; table.insert(newList, sub); count += 1
                    end
                end
                if count % 20 == 0 then task.wait() end
            end
            CachedModels = newCache; ModelList = newList; ModelCount = count
            CacheDirty = false
        end)
    end

    -- 处理队列: 每0.1秒最多处理3个 (新NPC快速透视)
    -- 数量上限检查: 达到MAX_NPC_ESP就不再新增, 防止Highlight累积卡退
    if #NPC_ESP.ProcessQueue > 0 and GetActiveESPCount() < MAX_NPC_ESP then
        if not NPC_ESP._lastProcess or now - NPC_ESP._lastProcess >= 0.1 then
            NPC_ESP._lastProcess = now
            local processed = 0
            while processed < 3 and #NPC_ESP.ProcessQueue > 0 and GetActiveESPCount() < MAX_NPC_ESP do
                local model = table.remove(NPC_ESP.ProcessQueue, 1)
                processed += 1
                if model and model.Parent and not NPC_ESP.Highlights[model] then
                    local displayName = TranslateNPCName(model.Name)
                    local hl = CreateNPCHL(model, color)
                    local bb, distLbl = CreateNPCBB(model, color, displayName)
                    if hl then
                        NPC_ESP.Highlights[model] = hl
                        NPC_ESP.ActiveModels[model] = true
                        if bb then
                            local nl = bb:FindFirstChild("NameLabel")
                            local hlb = bb:FindFirstChild("HealthLabel")
                            local dl = bb:FindFirstChild("DistLabel")
                            if nl then nl.Visible = Config.NPCShowName end
                            if hlb then hlb.Visible = Config.NPCShowHealth end
                            if dl then dl.Visible = Config.NPCShowDist end
                        end
                    end
                    if bb then NPC_ESP.Billboards[model] = bb end
                end
            end
        end
    end

    -- 兜底扫描: 每0.5秒扫描1个已缓存但未处理的模型
    if now - NPC_ESP.LastScan > 0.5 and #NPC_ESP.ProcessQueue == 0 and not CacheDirty
       and GetActiveESPCount() < MAX_NPC_ESP then
        NPC_ESP.LastScan = now
        NPC_ESP.ScanIndex += 1
        if NPC_ESP.ScanIndex > ModelCount then NPC_ESP.ScanIndex = 1 end
        local model = ModelList[NPC_ESP.ScanIndex]
        if model and model.Parent and not NPC_ESP.Highlights[model] then
            local displayName = TranslateNPCName(model.Name)
            local hl = CreateNPCHL(model, color)
            local bb = CreateNPCBB(model, color, displayName)
            if hl then
                NPC_ESP.Highlights[model] = hl
                NPC_ESP.ActiveModels[model] = true
                if bb then
                    local nl = bb:FindFirstChild("NameLabel")
                    local hlb = bb:FindFirstChild("HealthLabel")
                    local dl = bb:FindFirstChild("DistLabel")
                    if nl then nl.Visible = Config.NPCShowName end
                    if hlb then hlb.Visible = Config.NPCShowHealth end
                    if dl then dl.Visible = Config.NPCShowDist end
                end
            end
            if bb then NPC_ESP.Billboards[model] = bb end
        elseif model and not model.Parent then
            CachedModels[model] = nil; CacheDirty = true
        end
    end

    -- 定期清理: 每5秒清理无效ESP (只清理model已消失的, 避免误删活着的NPC)
    -- Health判断交给Died事件处理, 这里只做model存在性兜底
    if now - NPC_ESP.LastCleanup > 5 then
        NPC_ESP.LastCleanup = now
        task.defer(function()
            local toRemove = {}
            for model, _ in pairs(NPC_ESP.Highlights) do
                if not model or not model.Parent then
                    table.insert(toRemove, model)
                end
            end
            for _, model in ipairs(toRemove) do
                RemoveNPCESP(model)
            end
        end)
    end

    -- 距离更新: 每2秒异步执行一次 (降低频率 + 距离剔除)
    if now - NPC_ESP.LastDistUpdate > 2 then
        NPC_ESP.LastDistUpdate = now
        task.defer(UpdateNPCDistancesAsync)
    end
end

-- ============== NPC 击杀 ==============
local NPCKillData = {LastKill=0, KillIndex=0}

local function ProcessNPCKill()
    if not Config.NPCKill then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local myPos = hrp.Position
    local range = Config.NPCKillRange
    local now = tick()
    if now - NPCKillData.LastKill < 0.15 then return end
    -- 独立扫描: NPCKill不依赖NPCESP缓存, 自己扫描一遍NPC
    if ModelCount == 0 then
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Model") and IsNPCModel(obj) and not CachedModels[obj] then
                CachedModels[obj] = true
                table.insert(ModelList, obj)
                ModelCount += 1
            end
            for _, sub in ipairs(obj:GetChildren()) do
                if sub:IsA("Model") and IsNPCModel(sub) and not CachedModels[sub] then
                    CachedModels[sub] = true
                    table.insert(ModelList, sub)
                    ModelCount += 1
                end
            end
        end
        if ModelCount == 0 then return end
    end
    NPCKillData.KillIndex += 1
    if NPCKillData.KillIndex > ModelCount then NPCKillData.KillIndex = 1 end
    local model = ModelList[NPCKillData.KillIndex]
    if model and model.Parent then
        local npcPart = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
        if not npcPart then
            for _, child in ipairs(model:GetDescendants()) do
                if child:IsA("BasePart") then npcPart = child; break end
            end
        end
        if npcPart then
            local dist = (myPos - npcPart.Position).Magnitude
            if dist <= range then
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    NPCKillData.LastKill = now
                    pcall(function() hum.Health = 0 end)
                end
            end
        end
    end
end

task.wait()

-- ============== 无限跳跃 ==============
local InfiniteJumpConns = {}  -- 集中管理所有连接, 便于关闭时统一清理
local function ApplyInfiniteJump()
    -- 统一断开所有连接
    for _, conn in ipairs(InfiniteJumpConns) do
        if conn then conn:Disconnect() end
    end
    InfiniteJumpConns = {}
    Saved.JumpConn = nil
    if Config.InfiniteJump then
        ShowNotification("无限跳跃", "已开启 (长按空格持续跳跃)", Color3.fromRGB(100, 220, 180))
        local spaceHeld = false
        local lastJump = 0
        local jumpInterval = 0.12
        local inputBeganConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Enum.KeyCode.Space then spaceHeld = true end
        end)
        local inputEndedConn = UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Space then spaceHeld = false end
        end)
        table.insert(InfiniteJumpConns, inputBeganConn)
        table.insert(InfiniteJumpConns, inputEndedConn)
        local hbConn = RunService.Heartbeat:Connect(function()
            if not Config.InfiniteJump then return end
            if not spaceHeld then return end
            local now = tick()
            if now - lastJump < jumpInterval then return end
            lastJump = now
            local hrp = GetHRP()
            local hum = GetHum()
            if not hrp or not hum then return end
            if hum.Health <= 0 then return end
            -- 跳跃力度联动 Config.JumpValue, 默认50
            local jumpPower = Config.JumpValue > 0 and Config.JumpValue or 50
            local currentVel = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(currentVel.X, jumpPower, currentVel.Z)
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
        end)
        table.insert(InfiniteJumpConns, hbConn)
        Saved.JumpConn = hbConn  -- 兼容外部引用
    else
        ShowNotification("无限跳跃", "已关闭", Color3.fromRGB(180, 180, 180))
    end
end

-- ============== 悬浮模式 ==============
local function ApplyFloat()
    if Saved.FloatConn then Saved.FloatConn:Disconnect() Saved.FloatConn = nil end
    if Config.FloatMode then
        ShowNotification("悬浮模式", "已开启 (Q下降 E上升, WASD移动)", Color3.fromRGB(100, 180, 220))
        local hum = GetHum()
        local hrp = GetHRP()
        if hum then
            SavedFloatState = hum:GetState()
            hum.PlatformStand = true  -- 关闭人形自平衡, 让我们直接控制速度
            hum.AutoRotate = false
        end
        if hrp then
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
        Saved.FloatConn = RunService.Heartbeat:Connect(function()
            if not Config.FloatMode then return end
            local hrp = GetHRP()
            local hum = GetHum()
            if not hrp or not hum then return end
            -- 持续清零角速度, 防止翻转失控 (不再用 CFrame 强制锁定, 避免与物理引擎打架导致卡顿/不动)
            local av = hrp.AssemblyAngularVelocity
            if av.Magnitude > 0.05 then
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
            -- 相机方向移动
            local cam = Camera.CFrame
            local fwd = Vector3.new(cam.LookVector.X, 0, cam.LookVector.Z)
            local right = Vector3.new(cam.RightVector.X, 0, cam.RightVector.Z)
            if fwd.Magnitude > 0 then fwd = fwd.Unit end
            if right.Magnitude > 0 then right = right.Unit end
            local moveDir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += fwd end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= fwd end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= right end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += right end
            local yVel = 0
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then yVel = Config.FloatSpeed
            elseif UserInputService:IsKeyDown(Enum.KeyCode.Q) then yVel = -Config.FloatSpeed end
            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit
                hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X * Config.FloatSpeed, yVel, moveDir.Z * Config.FloatSpeed)
            else
                local cv = hrp.AssemblyLinearVelocity
                if yVel == 0 then
                    -- 悬停: Y速度归零, 水平阻尼, 不下落
                    hrp.AssemblyLinearVelocity = Vector3.new(cv.X * 0.82, 0, cv.Z * 0.82)
                else
                    hrp.AssemblyLinearVelocity = Vector3.new(cv.X * 0.9, yVel, cv.Z * 0.9)
                end
            end
        end)
    else
        local hrp = GetHRP()
        if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
        local hum = GetHum()
        if hum then
            hum.PlatformStand = false  -- 恢复正常站立控制
            hum.AutoRotate = true
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            task.delay(0.1, function()
                if hum and hum.Parent then hum:ChangeState(Enum.HumanoidStateType.Running) end
            end)
        end
        SavedFloatState = nil
        ShowNotification("悬浮模式", "已关闭", Color3.fromRGB(180, 180, 180))
    end
end

-- ============== 幽灵模式 ==============
local function ApplyGhostMode()
    if Ghost.Conn then Ghost.Conn:Disconnect() Ghost.Conn=nil end
    if Ghost.CamConn then Ghost.CamConn:Disconnect() Ghost.CamConn=nil end
    if Ghost.FreezeConn then Ghost.FreezeConn:Disconnect() Ghost.FreezeConn=nil end

    if Config.GhostMode then
        ShowNotification("幽灵模式", "已开启 (WASD移动相机, 穿墙透视, 人物冻结)", Color3.fromRGB(180, 80, 255))
        Ghost.OriginalCamType = Camera.CameraType
        Ghost.OriginalSubject = Camera.CameraSubject
        local hum = GetHum()
        local hrp = GetHRP()
        if hum then
            Ghost.OriginalWalkSpeed = hum.WalkSpeed
            Ghost.OriginalJumpPower = hum.JumpPower
            Ghost.OriginalAutoRotate = hum.AutoRotate
            hum.WalkSpeed = 0; hum.JumpPower = 0; hum.AutoRotate = false
        end
        if hrp then
            Ghost.OriginalCFrame = hrp.CFrame
            Ghost.OriginalAnchored = hrp.Anchored
        end
        Camera.CameraType = Enum.CameraType.Scriptable
        Camera.CameraSubject = nil

        Ghost.FreezeConn = RunService.Heartbeat:Connect(function()
            if not Config.GhostMode then return end
            if Camera.CameraType ~= Enum.CameraType.Scriptable then
                Camera.CameraType = Enum.CameraType.Scriptable
            end
            Camera.CameraSubject = nil
            local hrp = GetHRP()
            local hum = GetHum()
            if hrp and Ghost.OriginalCFrame then
                hrp.CFrame = Ghost.OriginalCFrame
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
            if hum then
                hum.WalkSpeed = 0; hum.JumpPower = 0; hum.AutoRotate = false
                hum:ChangeState(Enum.HumanoidStateType.Physics)
            end
        end)

        local camPos = Camera.CFrame.Position
        local camRot = Camera.CFrame.Rotation
        Ghost.OriginalMouseBehavior = UserInputService.MouseBehavior
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

        Ghost.CamConn = RunService.RenderStepped:Connect(function(dt)
            if not Config.GhostMode then return end
            local speed = Config.GhostSpeed * dt
            local moveDir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camRot.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camRot.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camRot.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camRot.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0, 1, 0) end
            if moveDir.Magnitude > 0 then camPos += moveDir.Unit * speed end
            local delta = UserInputService:GetMouseDelta()
            camRot = camRot * CFrame.Angles(0, -delta.X * 0.002, 0) * CFrame.Angles(-delta.Y * 0.002, 0, 0)
            Camera.CFrame = CFrame.new(camPos) * camRot
        end)
        UpdateGhostStatusBar()
    else
        if Ghost.FreezeConn then Ghost.FreezeConn:Disconnect() Ghost.FreezeConn=nil end
        if Ghost.OriginalMouseBehavior then
            UserInputService.MouseBehavior = Ghost.OriginalMouseBehavior
            Ghost.OriginalMouseBehavior = nil
        end
        if Ghost.OriginalCamType then Camera.CameraType = Ghost.OriginalCamType end
        if Ghost.OriginalSubject then Camera.CameraSubject = Ghost.OriginalSubject end
        Ghost.OriginalCamType = nil; Ghost.OriginalSubject = nil
        local hum = GetHum()
        local hrp = GetHRP()
        if hum then
            hum.WalkSpeed = Ghost.OriginalWalkSpeed or 16
            hum.JumpPower = Ghost.OriginalJumpPower or 50
            hum.AutoRotate = Ghost.OriginalAutoRotate ~= false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            task.delay(0.1, function()
                if hum and hum.Parent then hum:ChangeState(Enum.HumanoidStateType.Running) end
            end)
        end
        if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
        Ghost.OriginalWalkSpeed = nil; Ghost.OriginalJumpPower = nil
        Ghost.OriginalAutoRotate = nil; Ghost.OriginalCFrame = nil
        ShowNotification("幽灵模式", "已关闭", Color3.fromRGB(180, 180, 180))
        UpdateGhostStatusBar()
    end
end

local function SetupGhostShortcut()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not Config.GhostShortcutEnabled then return end
        local keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
        if keyName == Config.GhostShortcutKey then
            Config.GhostMode = not Config.GhostMode
            ApplyGhostMode()
            UpdateGhostToggleUI()
        end
    end)
end

function UpdateGhostToggleUI()
end

task.wait()

-- ============== Xray ==============
local Xray = {Parts={}, Triggers={}, Damages={}, Conn=nil, RefreshConn=nil, Running=false}
local function IsTrigger(p) local n=tostring(p.Name):lower()
    return n:find("trigger") or n:find("zone") or n:find("area") or n:find("detector") or n:find("sensor") or n:find("region") or n:find("teleport") or p:FindFirstChildOfClass("ClickDetector")~=nil end
local function IsDamage(p) local n=tostring(p.Name):lower()
    return n:find("damage") or n:find("kill") or n:find("lava") or n:find("hazard") or n:find("trap") or n:find("deadly") or n:find("danger") or n:find("fire") end
local function IsCharPart(p)
    local m = p:FindFirstAncestorOfClass("Model")
    if not m then return false end
    return m:FindFirstChildOfClass("Humanoid")~=nil or Players:GetPlayerFromCharacter(m)~=nil
end

local function SavePart(p)
    if not Saved.PartData[p] then
        Saved.PartData[p] = {Transparency=p.Transparency, Color=p.Color, Material=p.Material}
    end
end
local function ApplyXrayPart(p, mode)
    SavePart(p)
    if mode=="wall" then p.Transparency=Config.WallTrans; p.Color=Color3.fromRGB(255,255,255); Xray.Parts[p]=true
    elseif mode=="trigger" then p.Transparency=Config.TriggerTrans; p.Color=Color3.fromRGB(255,230,30); p.Material=Enum.Material.Neon; Xray.Triggers[p]=true
    elseif mode=="damage" then p.Transparency=Config.DamageTrans; p.Color=Color3.fromRGB(255,30,30); p.Material=Enum.Material.Neon; Xray.Damages[p]=true end
end

local function ApplyWallXrayFast()
    local hrp = GetHRP()
    local pos = hrp and hrp.Position or Vector3.zero
    local r = Config.WallRange; local cnt = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsA("Terrain") and not IsCharPart(obj) then
            if (obj.Position-pos).Magnitude <= r then
                ApplyXrayPart(obj, "wall")
                if Config.WallDetail then
                    if IsDamage(obj) then ApplyXrayPart(obj, "damage")
                    elseif IsTrigger(obj) then ApplyXrayPart(obj, "trigger") end
                end
            end
        end
        cnt += 1
        if cnt % 50 == 0 then task.wait() end
    end
end

local function ApplyWallXraySlow()
    local hrp = GetHRP()
    local pos = hrp and hrp.Position or Vector3.zero
    local r = Config.WallRange; local cnt = 0
    Xray.Running = true
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not Config.WallXray or not Xray.Running then break end
        if obj:IsA("BasePart") and not obj:IsA("Terrain") and not IsCharPart(obj) then
            if (obj.Position-pos).Magnitude <= r then
                ApplyXrayPart(obj, "wall")
                if Config.WallDetail then
                    if IsDamage(obj) then ApplyXrayPart(obj, "damage")
                    elseif IsTrigger(obj) then ApplyXrayPart(obj, "trigger") end
                end
                cnt += 1; if cnt%20==0 then task.wait(0.01) end
            end
        end
    end
    Xray.Running = false
end

local function ApplyWallXray()
    if not Config.WallXray then return end
    if Config.WallSpeedMode=="fast" then ApplyWallXrayFast() else task.spawn(ApplyWallXraySlow) end
end

local function RestoreWallXray()
    Xray.Running = false
    if Xray.Conn then Xray.Conn:Disconnect() Xray.Conn=nil end
    for p, d in pairs(Saved.PartData) do
        pcall(function() p.Transparency=d.Transparency; p.Color=d.Color; p.Material=d.Material end)
    end
    Saved.PartData={}; Xray.Parts={}; Xray.Triggers={}; Xray.Damages={}
end

local function SetupWallAutoRefresh()
    if Xray.RefreshConn then return end
    if not (Config.WallAutoRefresh and Config.WallXray) then return end
    Xray.RefreshConn = true  -- 标记已启动 (true 表示刷新循环运行中, nil 表示停止)
    task.spawn(function()
        while Xray.RefreshConn do
            task.wait(Config.WallRefreshInterval)
            if not Xray.RefreshConn then break end
            if not Config.WallAutoRefresh or not Config.WallXray then
                Xray.RefreshConn = nil
                break
            end
            -- 保存原始数据后恢复, 再重新应用 (不删除Saved.PartData)
            local oldData = {}
            for p, d in pairs(Saved.PartData) do oldData[p] = d end
            pcall(function()
                RestoreWallXray()
                -- 恢复 Saved.PartData 供下次使用
                Saved.PartData = oldData
                task.wait(0.1)
                ApplyWallXray()
                ShowNotification("墙体透视","定时刷新完成",Color3.fromRGB(255,200,80))
            end)
        end
    end)
end

local function SetupXrayDynamic()
    if Xray.Conn then Xray.Conn:Disconnect() Xray.Conn=nil end
    if not Config.WallXray then return end
    Xray.Conn = Workspace.DescendantAdded:Connect(function(obj)
        if not Config.WallXray then return end
        if obj:IsA("BasePart") and not obj:IsA("Terrain") and not IsCharPart(obj) then
            local hrp = GetHRP(); local pos = hrp and hrp.Position or Vector3.zero
            if (obj.Position-pos).Magnitude <= Config.WallRange then
                ApplyXrayPart(obj, "wall")
                if Config.WallDetail then
                    if IsDamage(obj) then ApplyXrayPart(obj, "damage")
                    elseif IsTrigger(obj) then ApplyXrayPart(obj, "trigger") end
                end
            end
        end
    end)
end

task.wait()

-- ============== 移动辅助 ==============
local Move = {SpeedConn=nil, JumpConn=nil, FlyConn=nil, TeleConn=nil}
local SavedFlyState = nil

local function ApplySpeed()
    if Move.SpeedConn then Move.SpeedConn=nil end
    if Config.SpeedEnabled then
        local hum = GetHum()
        if hum then if not Saved.WalkSpeed then Saved.WalkSpeed=hum.WalkSpeed end; hum.WalkSpeed=Config.SpeedValue end
        Move.SpeedConn = true
        task.spawn(function()
            while Move.SpeedConn do
                local h = GetHum(); if h and Config.SpeedEnabled then h.WalkSpeed=Config.SpeedValue end
                task.wait(0.5)
            end
        end)
    else
        local hum = GetHum()
        if hum and Saved.WalkSpeed then hum.WalkSpeed=Saved.WalkSpeed; Saved.WalkSpeed=nil end
    end
end

local function ApplyJump()
    if Move.JumpConn then Move.JumpConn=nil end
    if Config.JumpEnabled then
        local hum = GetHum()
        if hum then
            if not Saved.JumpPower then
                -- 兼容 JumpPower 和 JumpHeight 两种模式
                Saved.JumpPower = hum.JumpPower
                Saved.JumpHeight = hum.JumpHeight
                Saved.UseJumpPower = hum.UseJumpPower
            end
            -- 优先用 JumpPower, 对不支持的游戏回退 JumpHeight
            pcall(function()
                hum.UseJumpPower = true
                hum.JumpPower = Config.JumpValue
            end)
        end
        Move.JumpConn = true
        task.spawn(function()
            while Move.JumpConn do
                local h = GetHum()
                if h and Config.JumpEnabled then
                    pcall(function()
                        h.UseJumpPower = true
                        h.JumpPower = Config.JumpValue
                    end)
                end
                task.wait(0.5)
            end
        end)
    else
        local hum = GetHum()
        if hum and Saved.JumpPower then
            pcall(function()
                hum.JumpPower = Saved.JumpPower
                if Saved.JumpHeight then hum.JumpHeight = Saved.JumpHeight end
                if Saved.UseJumpPower ~= nil then hum.UseJumpPower = Saved.UseJumpPower end
            end)
            Saved.JumpPower = nil; Saved.JumpHeight = nil; Saved.UseJumpPower = nil
        end
    end
end

local function ApplyFly()
    if Move.FlyConn then Move.FlyConn:Disconnect() Move.FlyConn=nil end
    if Config.FlyEnabled then
        ShowNotification("飞行",string.format("已开启: %.1f (锁定面朝前方, 视角上下控制升降)",Config.FlySpeed),Color3.fromRGB(100,180,220))
        local hum = GetHum()
        local hrp = GetHRP()
        if hum then
            SavedFlyState = hum:GetState()
            hum.PlatformStand = true  -- 保持站立姿态, 不被重力拉倒 (避免Physics导致的躺地)
            hum.AutoRotate = false
            -- 锁定关节角速度, 防止翻转失控
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
        Move.FlyConn = RunService.Heartbeat:Connect(function()
            local h = GetHRP()
            if not h or not Config.FlyEnabled then return end
            -- 强制锁定旋转, 防止翻转失控 (只保留Y轴朝向, 永远面朝前方)
            local angVel = h.AssemblyAngularVelocity
            if angVel.Magnitude > 0.1 then
                h.AssemblyAngularVelocity = Vector3.zero
            end
            -- 锁定俯仰/翻滚角度, 只保留Y轴旋转
            local rot = h.Rotation
            local lookX, lookZ = rot.LookVector.X, rot.LookVector.Z
            local yRot = math.atan2(-lookX, -lookZ)
            h.CFrame = CFrame.new(h.Position) * CFrame.Angles(0, yRot, 0)
            -- 使用相机水平方向移动 (锁定面朝前方)
            local cam = Camera.CFrame
            local camLook = cam.LookVector
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Vector3.new(camLook.X, 0, camLook.Z).Unit end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= Vector3.new(camLook.X, 0, camLook.Z).Unit end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= Vector3.new(cam.RightVector.X, 0, cam.RightVector.Z).Unit end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Vector3.new(cam.RightVector.X, 0, cam.RightVector.Z).Unit end
            -- 上下飞行: 通过视角向上/向下时按W/S自然实现; 空格/Ctrl保留为纯垂直辅助
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
            if dir.Magnitude > 0 then
                dir = dir.Unit
                h.AssemblyLinearVelocity = dir * Config.FlySpeed
            else
                -- 悬停时Y速度归零, 防止下落
                h.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end)
    else
        local h = GetHRP()
        if h then h.AssemblyLinearVelocity = Vector3.zero end
        local hum = GetHum()
        if hum then
            hum.PlatformStand = false  -- 恢复正常站立控制
            hum.AutoRotate = true
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            task.delay(0.1, function()
                if hum and hum.Parent then hum:ChangeState(Enum.HumanoidStateType.Running) end
            end)
        end
        SavedFlyState = nil
        ShowNotification("飞行","已关闭",Color3.fromRGB(180,180,180))
    end
end

-- ============== 娱乐功能 (直升机旋转 / 360旋转 / 假布娃娃) ==============
local Fun = {
    HeliConn=nil, HeliAngle=0,    -- 直升机
    Spin360Conn=nil, Spin360Angle=0,  -- 360旋转
    RagdollConn=nil,              -- 假布娃娃
    -- 保存原始 Motor6D (用于手臂/身体恢复)
    SavedMotors={}, SavedRagdollState=nil,
}
-- 找角色手臂关节 (兼容 R6/R15)
local function FindArmMotors(char)
    -- R6: Left Shoulder / Right Shoulder (在 HumanoidRootPart? 实际在 Torso)
    -- R15: LeftShoulder / RightShoulder (在 UpperTorso)
    local result = {}
    pcall(function()
        local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
        if torso then
            for _, child in ipairs(torso:GetChildren()) do
                if child:IsA("Motor6D") then
                    local n = child.Name:lower()
                    if n:find("shoulder") or n:find("arm") then
                        table.insert(result, child)
                    end
                end
            end
        end
    end)
    return result
end

-- 直升机旋转: 展开双臂 + 快速旋转 + 飞行 (WASD移动, Q下降 E上升, 朝镜头方向飞)
local function ApplyHelicopterSpin()
    if Fun.HeliConn then Fun.HeliConn:Disconnect() Fun.HeliConn=nil end
    if Config.HelicopterSpin then
        ShowNotification("直升机旋转", "已开启 (自动开启飞行, WASD移动, Q下降E上升)", Color3.fromRGB(255, 200, 80))
        -- 自动开启飞行 (但不调用 ApplyFly 避免它锁定面朝方向, 这里自管)
        local hum = GetHum(); local hrp = GetHRP()
        if hum then
            if not Fun.SavedRagdollState then Fun.SavedRagdollState = hum:GetState() end
            hum.PlatformStand = true
            hum.AutoRotate = false
        end
        if hrp then hrp.AssemblyAngularVelocity = Vector3.zero end
        -- 强制双臂展开 (旋转 Motor6D C0, 让手臂水平伸出)
        local armsMotors = FindArmMotors(LocalPlayer.Character or {})
        for _, m in ipairs(armsMotors) do
            if not Fun.SavedMotors[m] then
                Fun.SavedMotors[m] = {C0 = m.C0, C1 = m.C1}
            end
            -- 把肩膀关节旋转 90度, 让手臂水平展开
            local isLeft = m.Name:lower():find("left") ~= nil
            -- R6 Left Shoulder C0 默认 (-1, 0.5, 0.5) * R; 右肩 (1, 0.5, 0.5) * R
            -- 这里直接旋转 C0 让手臂张开
            pcall(function()
                m.C0 = m.C0 * CFrame.Angles(0, 0, isLeft and math.rad(90) or math.rad(-90))
            end)
        end
        Fun.HeliAngle = 0
        Fun.HeliConn = RunService.Heartbeat:Connect(function(dt)
            if not Config.HelicopterSpin then return end
            local h = GetHRP(); local hum = GetHum()
            if not h or not hum then return end
            -- 旋转角度累加 (Y轴)
            Fun.HeliAngle = Fun.HeliAngle + (Config.HelicopterSpinSpeed or 18) * dt
            -- 相机方向 (不锁定面朝方向, 朝镜头飞)
            local cam = Camera.CFrame
            local fwd = Vector3.new(cam.LookVector.X, 0, cam.LookVector.Z)
            local right = Vector3.new(cam.RightVector.X, 0, cam.RightVector.Z)
            if fwd.Magnitude > 0.01 then fwd = fwd.Unit end
            if right.Magnitude > 0.01 then right = right.Unit end
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += fwd end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= fwd end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= right end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += right end
            local yVel = 0
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then yVel = Config.FlySpeed or 50
            elseif UserInputService:IsKeyDown(Enum.KeyCode.Q) then yVel = -(Config.FlySpeed or 50) end
            -- 保持高度 + 移动 (用相机水平方向), 同时Y轴自转
            local pos = h.Position
            -- 用相机朝向作为基础朝向 + Y轴自转 (直升机效果)
            local camYaw = math.atan2(-cam.LookVector.X, -cam.LookVector.Z)
            h.CFrame = CFrame.new(pos) * CFrame.Angles(0, camYaw + Fun.HeliAngle, 0)
            -- 速度
            if move.Magnitude > 0 then
                move = move.Unit
                h.AssemblyLinearVelocity = Vector3.new(move.X * (Config.FlySpeed or 50), yVel, move.Z * (Config.FlySpeed or 50))
            else
                local cv = h.AssemblyLinearVelocity
                h.AssemblyLinearVelocity = Vector3.new(cv.X * 0.85, yVel, cv.Z * 0.85)
            end
        end)
    else
        -- 关闭: 恢复手臂 + 飞行状态
        local char = LocalPlayer.Character
        if char then
            for m, data in pairs(Fun.SavedMotors) do
                pcall(function() if m and m.Parent then m.C0 = data.C0; m.C1 = data.C1 end end)
            end
        end
        Fun.SavedMotors = {}
        local hum = GetHum()
        if hum then
            hum.PlatformStand = false
            hum.AutoRotate = true
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            task.delay(0.1, function()
                if hum and hum.Parent then hum:ChangeState(Enum.HumanoidStateType.Running) end
            end)
        end
        ShowNotification("直升机旋转", "已关闭", Color3.fromRGB(180, 180, 180))
    end
end

-- 360度无死角旋转 (三轴任意方向旋转, 碰撞体积不变, 只旋转视觉)
local function ApplySpin360()
    if Fun.Spin360Conn then Fun.Spin360Conn:Disconnect() Fun.Spin360Conn=nil end
    if Config.Spin360 then
        ShowNotification("360旋转", "已开启 (三轴任意方向旋转, 碰撞体积不变)", Color3.fromRGB(255, 200, 80))
        Fun.Spin360Angle = 0
        -- 用于三轴不同速度的相位偏移, 让旋转方向不固定
        Fun.Spin360Conn = RunService.Heartbeat:Connect(function(dt)
            if not Config.Spin360 then return end
            local h = GetHRP(); if not h then return end
            Fun.Spin360Angle = Fun.Spin360Angle + (Config.Spin360Speed or 10) * dt
            -- 三轴旋转: X/Y/Z 各以不同倍率旋转, 实现任意方向无死角翻滚
            -- 通过旋转 RootJoint 的 C0 (HRP朝向不变=碰撞不变, 身体视觉翻滚)
            local char = LocalPlayer.Character
            if not char then return end
            local rootJoint = char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart:FindFirstChild("RootJoint") or
                              (char:FindFirstChild("LowerTorso") and char.LowerTorso:FindFirstChild("Root")) or
                              (char:FindFirstChild("Torso") and char.Torso:FindFirstChild("RootJoint"))
            if rootJoint then
                if not Fun.SavedMotors[rootJoint] then
                    Fun.SavedMotors[rootJoint] = {C0 = rootJoint.C0, C1 = rootJoint.C1}
                end
                pcall(function()
                    -- X/Y/Z 三轴叠加, 倍率不同让旋转方向不重复 (无死角)
                    local ang = Fun.Spin360Angle
                    rootJoint.C0 = Fun.SavedMotors[rootJoint].C0
                        * CFrame.Angles(ang,        ang * 0.7,  ang * 1.3)
                end)
            else
                -- 兜底: 直接旋转 HRP (会改变碰撞朝向, 仅在找不到 RootJoint 时)
                local pos = h.Position
                local ang = Fun.Spin360Angle
                h.CFrame = CFrame.new(pos) * CFrame.Angles(ang, ang * 0.7, ang * 1.3)
            end
        end)
    else
        -- 恢复 RootJoint
        local char = LocalPlayer.Character
        if char then
            local rootJoint = char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart:FindFirstChild("RootJoint") or
                              (char:FindFirstChild("LowerTorso") and char.LowerTorso:FindFirstChild("Root")) or
                              (char:FindFirstChild("Torso") and char.Torso:FindFirstChild("RootJoint"))
            if rootJoint and Fun.SavedMotors[rootJoint] then
                pcall(function() rootJoint.C0 = Fun.SavedMotors[rootJoint].C0; rootJoint.C1 = Fun.SavedMotors[rootJoint].C1 end)
                Fun.SavedMotors[rootJoint] = nil
            end
        end
        ShowNotification("360旋转", "已关闭", Color3.fromRGB(180, 180, 180))
    end
end

-- 假布娃娃: 自然倒地 + 四肢身体瘫软 + 名字跟随 + 搞笑爬行移动
-- 实现: 用 BallSocketConstraint 替换所有 Motor6D, 让四肢和身体各部分自由摆动瘫软
local function FindCharMotors(char)
    local list = {}
    pcall(function()
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("Motor6D") then
                local n = d.Name:lower()
                -- 排除 Root 关节 (保持 HRP 与身体的连接, 否则身体会脱离)
                if n ~= "rootjoint" and n ~= "root" then
                    table.insert(list, d)
                end
            end
        end
    end)
    return list
end
local function ApplyFakeRagdoll()
    if Fun.RagdollConn then Fun.RagdollConn:Disconnect() Fun.RagdollConn=nil end
    if Config.FakeRagdoll then
        ShowNotification("假布娃娃", "已开启 (四肢身体瘫软, 可爬行移动)", Color3.fromRGB(255, 200, 80))
        local char = LocalPlayer.Character
        local hum = GetHum(); local hrp = GetHRP()
        if hum and char then
            if not Fun.SavedRagdollState then Fun.SavedRagdollState = hum:GetState() end
            -- PlatformStand + 物理倒地 (碰撞体积改变, 名字Billboard跟随身体)
            hum.PlatformStand = true
            hum.AutoRotate = false
            hum:ChangeState(Enum.HumanoidStateType.Physics)
            -- 关键: 把所有 Motor6D (除RootJoint外) 用 BallSocketConstraint 替换, 让四肢身体瘫软
            Fun.SavedMotors = {}
            local motors = FindCharMotors(char)
            for _, m in ipairs(motors) do
                pcall(function()
                    if not Fun.SavedMotors[m] then
                        Fun.SavedMotors[m] = {C0 = m.C0, C1 = m.C1, Enabled = m.Enabled, Parent = m.Parent}
                    end
                    local part0 = m.Part0; local part1 = m.Part1
                    if part0 and part1 then
                        -- 禁用 Motor6D (保留实例用于恢复)
                        m.Enabled = false
                        -- 创建球窝关节 (BallSocketConstraint), 让连接处可自由旋转
                        local att0 = Instance.new("Attachment")
                        att0.Name = "RagdollAtt0"
                        -- C0 是相对 Part0 的偏移
                        att0.CFrame = m.C0
                        att0.Parent = part0
                        local att1 = Instance.new("Attachment")
                        att1.Name = "RagdollAtt1"
                        att1.CFrame = m.C1
                        att1.Parent = part1
                        local ball = Instance.new("BallSocketConstraint")
                        ball.Name = "RagdollBall"
                        ball.Attachment0 = att0
                        ball.Attachment1 = att1
                        -- 限制角度避免过度扭曲, 但足够瘫软
                        ball.LimitsEnabled = true
                        ball.TwistLimitsEnabled = true
                        ball.UpperAngle = 80
                        ball.TwistUpperAngle = 80
                        -- 加点阻尼让瘫软更自然
                        ball.Visible = false
                        ball.Parent = part0
                    end
                end)
            end
        end
        if hrp then
            pcall(function()
                -- 给一个初始倾倒力让自然倒地
                hrp.AssemblyAngularVelocity = Vector3.new(5, 0, 0)
            end)
        end
        -- 搞笑爬行移动: WASD时给一个低矮的水平速度 + 小幅抖动 (像在地上拱)
        Fun.RagdollConn = RunService.Heartbeat:Connect(function(dt)
            if not Config.FakeRagdoll then return end
            local h = GetHRP(); local hum = GetHum()
            if not h or not hum then return end
            -- 持续保持趴下状态
            if hum.PlatformStand == false then hum.PlatformStand = true end
            local cam = Camera.CFrame
            local fwd = Vector3.new(cam.LookVector.X, 0, cam.LookVector.Z)
            local right = Vector3.new(cam.RightVector.X, 0, cam.RightVector.Z)
            if fwd.Magnitude > 0.01 then fwd = fwd.Unit end
            if right.Magnitude > 0.01 then right = right.Unit end
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += fwd end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= fwd end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= right end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += right end
            if move.Magnitude > 0 then
                move = move.Unit
                local crawlSpeed = (Config.SpeedValue or 16) * 0.5  -- 爬行较慢
                -- 搞笑抖动: Y轴小幅上下 + 随机左右扭动 (像在拱)
                local wobble = math.sin(tick() * 10) * 2
                local wobbleY = math.abs(math.sin(tick() * 8)) * 1.5
                h.AssemblyLinearVelocity = Vector3.new(
                    move.X * crawlSpeed + wobble * 0.3,
                    wobbleY,
                    move.Z * crawlSpeed + math.cos(tick() * 10) * 0.3
                )
                -- 身体小幅扭动 (带动四肢摆动)
                h.AssemblyAngularVelocity = Vector3.new(0, wobble * 0.5, 0)
            else
                -- 静止时趴着不动 (阻尼)
                local cv = h.AssemblyLinearVelocity
                h.AssemblyLinearVelocity = Vector3.new(cv.X * 0.7, cv.Y, cv.Z * 0.7)
            end
        end)
    else
        -- 关闭: 恢复所有 Motor6D + 删除球窝关节 + 附件
        local char = LocalPlayer.Character
        if char then
            pcall(function()
                -- 删除我们创建的球窝关节和附件
                for _, d in ipairs(char:GetDescendants()) do
                    if (d:IsA("BallSocketConstraint") and d.Name == "RagdollBall")
                       or (d:IsA("Attachment") and (d.Name == "RagdollAtt0" or d.Name == "RagdollAtt1")) then
                        d:Destroy()
                    end
                end
            end)
            -- 恢复 Motor6D
            for m, data in pairs(Fun.SavedMotors) do
                pcall(function()
                    if m and m.Parent then
                        m.Enabled = data.Enabled
                        m.C0 = data.C0
                        m.C1 = data.C1
                    end
                end)
            end
            Fun.SavedMotors = {}
        end
        local hum = GetHum()
        if hum then
            hum.PlatformStand = false
            hum.AutoRotate = true
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            task.delay(0.15, function()
                if hum and hum.Parent then hum:ChangeState(Enum.HumanoidStateType.Running) end
            end)
        end
        ShowNotification("假布娃娃", "已关闭", Color3.fromRGB(180, 180, 180))
    end
end

local function ApplyTeleWalk()
    if Move.TeleConn then Move.TeleConn:Disconnect() Move.TeleConn=nil end
    if Config.TeleWalk then
        ShowNotification("瞬移行走",string.format("已开启: %.1f",Config.TeleWalkValue),Color3.fromRGB(100,180,220))
        Move.TeleConn = RunService.Heartbeat:Connect(function(dt)
            if not Config.TeleWalk then return end
            local hrp = GetHRP(); if not hrp then return end
            local hum = GetHum(); if not hum or hum.Health <= 0 then return end
            if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.A)
               or UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.D) then
                local fwd = Camera.CFrame.LookVector; fwd = Vector3.new(fwd.X,0,fwd.Z).Unit
                local right = Camera.CFrame.RightVector; right = Vector3.new(right.X,0,right.Z).Unit
                local move = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += fwd end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= fwd end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= right end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += right end
                if move.Magnitude > 0 then move = move.Unit; hrp.CFrame = hrp.CFrame + move * (Config.TeleWalkValue * dt) end
            end
        end)
    else
        ShowNotification("瞬移行走","已关闭",Color3.fromRGB(180,180,180))
    end
end

-- ============== 穿墙 ==============
local NoclipConn = nil
local NoclipCleanupConn = nil
local NoclipChildAddedConn = nil     -- 角色子级新增监听 (增量更新缓存)
local NoclipParts = {}               -- 缓存当前角色的 BasePart 列表, 避免每帧 GetDescendants
local NoclipCharRef = nil            -- 缓存对应的角色引用, 用于检测重生/换角色

local function IsLegOrFoot(partName)
    local n = tostring(partName):lower()
    return n:find("foot") or n:find("leg") or n:find("shin") or n:find("calf")
        or n:find("sole") or n:find("shoe") or n:find("lowerleg") or n:find("upperleg")
end

-- 为指定角色构建/重建 Noclip 部件缓存, 并挂载 ChildAdded 监听以增量更新
local function NoclipAttachChar(char)
    NoclipParts = {}
    if NoclipChildAddedConn then NoclipChildAddedConn:Disconnect() NoclipChildAddedConn=nil end
    NoclipCharRef = char
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if Saved.PartCollide[part] == nil then Saved.PartCollide[part] = part.CanCollide end
            if Config.Noclip then part.CanCollide = false end
            NoclipParts[#NoclipParts+1] = part
        end
    end
    NoclipChildAddedConn = char.ChildAdded:Connect(function(obj)
        local function addPart(p)
            if Saved.PartCollide[p] == nil then Saved.PartCollide[p] = p.CanCollide end
            if Config.Noclip then p.CanCollide = false end
            NoclipParts[#NoclipParts+1] = p
        end
        if obj:IsA("BasePart") then
            addPart(obj)
        else
            -- 容器类 (如 Accessory): 收集其内含的 BasePart
            for _, sub in ipairs(obj:GetDescendants()) do
                if sub:IsA("BasePart") then addPart(sub) end
            end
        end
    end)
end

local function ApplyNoclip()
    if NoclipConn then NoclipConn:Disconnect() NoclipConn=nil end
    if NoclipCleanupConn then NoclipCleanupConn:Disconnect() NoclipCleanupConn=nil end
    if NoclipChildAddedConn then NoclipChildAddedConn:Disconnect() NoclipChildAddedConn=nil end
    if Config.Noclip then
        ShowNotification("穿墙","已开启",Color3.fromRGB(100,180,220))
        NoclipAttachChar(LocalPlayer.Character)
        NoclipConn = RunService.Stepped:Connect(function()
            if not Config.Noclip then return end
            local c = LocalPlayer.Character
            if not c then return end
            -- 角色变更 (重生): 重建缓存并重连监听
            if c ~= NoclipCharRef then
                NoclipAttachChar(c)
            end
            -- 遍历缓存 (避免每帧 GetDescendants)
            for _, part in ipairs(NoclipParts) do
                if part.Parent then
                    part.CanCollide = false
                end
            end
        end)
    else
        -- 关闭: 从缓存恢复原始 CanCollide
        for _, part in ipairs(NoclipParts) do
            if part.Parent and Saved.PartCollide[part] ~= nil then
                if IsLegOrFoot(part.Name) then
                    part.CanCollide = false
                else
                    part.CanCollide = Saved.PartCollide[part]
                end
            end
        end
        Saved.PartCollide = {}
        NoclipParts = {}
        NoclipCharRef = nil
        NoclipCleanupConn = RunService.Stepped:Connect(function()
            local c = LocalPlayer.Character
            if not c then return end
            for _, part in ipairs(c:GetChildren()) do
                if part:IsA("BasePart") and IsLegOrFoot(part.Name) then
                    part.CanCollide = false
                end
            end
        end)
        task.delay(3, function()
            if NoclipCleanupConn then NoclipCleanupConn:Disconnect() NoclipCleanupConn=nil end
        end)
        ShowNotification("穿墙","已关闭",Color3.fromRGB(180,180,180))
    end
end

task.wait()

-- ============== 互动透视 ==============
local Interact = {
    Highlights = {}, Billboards = {}, PromptsCache = {}, PromptList = {},
    PendingQueue = {}, ProcessIndex = 0, NeedRebuild = false, LastFullScan = 0,
    ChildAddedConn = nil, ChildRemovedConn = nil, Running = false,
}

-- 更新已缓存Prompts的HoldDuration和MaxActivationDistance (轻量, 不做全树扫描)
-- 全树扫描交给 InteractESP 的 StartInteractListeners (DescendantAdded 增量注册) + FullScanInteractablesAsync
-- 互动代码类型检测: 自动识别ProximityPrompt/ClickDetector/BindableEvent等并返回中文描述
local InteractTypes = {}
local function DetectInteractType(obj)
    if obj:IsA("ProximityPrompt") then
        return "邻近提示(ProximityPrompt)", "HoldDuration/MaxActivationDistance"
    elseif obj:IsA("ClickDetector") then
        return "点击检测(ClickDetector)", "MaxActivationDistance"
    elseif obj:IsA("TouchTransmitter") or obj.Name:lower():find("touch") then
        return "触碰触发(Touch)", "Touched事件"
    elseif obj:IsA("RemoteEvent") then
        return "远程事件(RemoteEvent)", "FireServer"
    elseif obj:IsA("RemoteFunction") then
        return "远程函数(RemoteFunction)", "InvokeServer"
    elseif obj:IsA("BindableEvent") then
        return "绑定事件(BindableEvent)", "Fire"
    end
    return nil, nil
end

-- 判断远距离互动是否可修改 (仅ProximityPrompt/ClickDetector支持)
local function CanModifyRange(obj)
    return obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector")
end

-- 智能快速互动: 检测类型并应用对应修改 (新刷新的也会自动应用)
local function ApplySmartInteract(prompt)
    if not prompt or not prompt.Parent then return end
    local t, fields = DetectInteractType(prompt)
    if t == "邻近提示(ProximityPrompt)" then
        -- 保存原始值 (仅首次)
        if not Saved.Prompts[prompt] then
            Saved.Prompts[prompt] = {prompt.HoldDuration, prompt.MaxActivationDistance}
        end
        if Config.FastInteract then
            prompt.HoldDuration = 0
            -- 启用Enabled确保可触发
            prompt.Enabled = true
        end
        if Config.LongRangeInteract then
            prompt.MaxActivationDistance = Config.InteractDist
        end
    elseif t == "点击检测(ClickDetector)" then
        if not Saved.Prompts[prompt] then
            Saved.Prompts[prompt] = {0, prompt.MaxActivationDistance}
        end
        if Config.LongRangeInteract then
            prompt.MaxActivationDistance = Config.InteractDist
        end
    end
end

local function ApplyFastInteract()
    -- 对所有已缓存的prompt应用
    for prompt, data in pairs(Saved.Prompts) do
        if prompt and prompt.Parent then
            if data and type(data) == "table" then
                if Config.FastInteract then
                    prompt.HoldDuration = 0
                    prompt.Enabled = true
                else
                    prompt.HoldDuration = data[1]
                end
                if Config.LongRangeInteract then
                    prompt.MaxActivationDistance = Config.InteractDist
                else
                    prompt.MaxActivationDistance = data[2]
                end
            else
                if Config.FastInteract then prompt.HoldDuration = 0; prompt.Enabled = true end
                if Config.LongRangeInteract then prompt.MaxActivationDistance = Config.InteractDist end
            end
        end
    end
end

-- 智能互动监听: 新刷新的可互动对象自动应用快速互动 (不会因新刷新而失效)
local function StartSmartInteractListener()
    if Saved.SmartInteractConn then return end
    Saved.SmartInteractConn = Workspace.DescendantAdded:Connect(function(child)
        if child:IsA("ProximityPrompt") or child:IsA("ClickDetector") then
            -- 延迟一帧确保对象初始化完成
            task.defer(function()
                if Config.FastInteract or Config.LongRangeInteract then
                    ApplySmartInteract(child)
                end
                -- 同时注册到互动透视缓存
                if Config.InteractESP and child:IsA("ProximityPrompt") then
                    RegisterInteractPrompt(child)
                end
            end)
        end
    end)
end

-- 轻量更新距离: 只遍历缓存改MaxActivationDistance (滑块拖动时用, 避免每帧全树遍历)
local function UpdatePromptDistances()
    for prompt, data in pairs(Saved.Prompts) do
        if prompt and prompt.Parent and Config.LongRangeInteract then
            prompt.MaxActivationDistance = Config.InteractDist
        end
    end
end

-- 慢速扫描全树填充 Saved.Prompts 缓存 (开启远距离互动但未开快速互动/透视时用, 防止缓存为空导致远距离不生效)
local function ScanAndCachePromptsAsync()
    task.spawn(function()
        local scanned = 0
        local childrenIterated = 0
        local queue = { Workspace }
        while #queue > 0 and scanned < 800 do
            local container = table.remove(queue, 1)
            local valid = false
            pcall(function() valid = container ~= nil and container.Parent ~= nil end)
            if valid then
                local children
                pcall(function() children = container:GetChildren() end)
                if children then
                    for _, child in ipairs(children) do
                        childrenIterated = childrenIterated + 1
                        if childrenIterated >= 30 then
                            childrenIterated = 0
                            task.wait(0.1)
                        end
                        local cls
                        pcall(function() cls = child.ClassName end)
                        if cls == "ProximityPrompt" or cls == "ClickDetector" then
                            pcall(ApplySmartInteract, child)
                            scanned = scanned + 1
                        else
                            if cls and cls ~= "Camera" and cls ~= "Terrain" and cls ~= "Humanoid"
                               and cls ~= "Script" and cls ~= "LocalScript" and cls ~= "ModuleScript"
                               and cls ~= "Sound" and cls ~= "Weld" and cls ~= "WeldConstraint"
                               and cls ~= "Motor6D" and cls ~= "Bone" and cls ~= "Animation"
                               and #queue < 3000 then
                                table.insert(queue, child)
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function CreateInteractHighlight(part)
    if not part or not part.Parent then return nil end
    if part:FindFirstChild("InteractHighlight") then return part:FindFirstChild("InteractHighlight") end
    local h = Instance.new("Highlight")
    h.Name = "InteractHighlight"
    h.FillColor = Color3.fromRGB(0, 255, 200); h.FillTransparency = 0.6
    h.OutlineColor = Color3.fromRGB(0, 255, 200); h.OutlineTransparency = 0.2
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = part
    return h
end

local function CreateInteractBB(part, promptText)
    if not part or not part.Parent then return nil end
    local existing = part:FindFirstChild("InteractBillboard")
    if existing then return existing end
    local bb = Instance.new("BillboardGui")
    bb.Name = "InteractBillboard"
    bb.Size = UDim2.new(0, 150, 0, 50)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = true; bb.MaxDistance = 200
    bb.Parent = part
    local lbl = Instance.new("TextLabel")
    lbl.Name = "ActionLabel"
    lbl.Size = UDim2.new(1, 0, 0.5, 0); lbl.BackgroundTransparency = 1
    lbl.Text = promptText or "可互动"; lbl.TextColor3 = Color3.fromRGB(0, 255, 200)
    lbl.TextStrokeTransparency = 0.3; lbl.TextStrokeColor3 = Color3.new(0,0,0)
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 12
    lbl.Parent = bb
    local distLbl = Instance.new("TextLabel")
    distLbl.Name = "DistLabel"
    distLbl.Size = UDim2.new(1, 0, 0.5, 0); distLbl.Position = UDim2.new(0, 0, 0.5, 0)
    distLbl.BackgroundTransparency = 1; distLbl.Text = "0m"
    distLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLbl.TextStrokeTransparency = 0.3; distLbl.TextStrokeColor3 = Color3.new(0,0,0)
    distLbl.Font = Enum.Font.Gotham; distLbl.TextSize = 11
    distLbl.Parent = bb
    return bb
end

local function RemoveInteractESP(part)
    if not part then return end
    pcall(function()
        for _, child in ipairs(part:GetChildren()) do
            if child.Name == "InteractHighlight" or child.Name == "InteractBillboard" then
                child:Destroy()
            end
        end
    end)
end

local function ClearInteractESP()
    for part, _ in pairs(Interact.Highlights) do RemoveInteractESP(part) end
    Interact.Highlights = {}; Interact.Billboards = {}
    Interact.PromptsCache = {}; Interact.PromptList = {}; Interact.PendingQueue = {}
    Interact.ProcessIndex = 0; Interact.NeedRebuild = false
    if Interact.ChildAddedConn then Interact.ChildAddedConn:Disconnect() Interact.ChildAddedConn=nil end
    if Interact.ChildRemovedConn then Interact.ChildRemovedConn:Disconnect() Interact.ChildRemovedConn=nil end
end

local function RegisterInteractPrompt(prompt)
    if not Saved.Prompts[prompt] then Saved.Prompts[prompt]={prompt.HoldDuration,prompt.MaxActivationDistance} end
    if Interact.PromptsCache[prompt] then return end
    local parent = prompt.Parent
    if not parent or not parent:IsA("BasePart") then return end
    Interact.PromptsCache[prompt] = {Parent = parent, ActionText = prompt.ActionText or "", ObjectText = prompt.ObjectText or ""}
    table.insert(Interact.PromptList, prompt)
    table.insert(Interact.PendingQueue, prompt)
end

local function UnregisterInteractPrompt(prompt)
    if not Interact.PromptsCache[prompt] then return end
    local data = Interact.PromptsCache[prompt]
    if data and data.Parent then
        RemoveInteractESP(data.Parent)
        Interact.Highlights[data.Parent] = nil
        Interact.Billboards[data.Parent] = nil
    end
    Interact.PromptsCache[prompt] = nil
    Interact.NeedRebuild = true
end

local function StartInteractListeners()
    if Interact.ChildAddedConn then return end
    Interact.ChildAddedConn = Workspace.DescendantAdded:Connect(function(child)
        if child:IsA("ProximityPrompt") then RegisterInteractPrompt(child) end
    end)
    Interact.ChildRemovedConn = Workspace.DescendantRemoving:Connect(function(child)
        if child:IsA("ProximityPrompt") then UnregisterInteractPrompt(child) end
    end)
end

local function FullScanInteractablesAsync()
    if Interact.Running then return end
    Interact.Running = true
    task.defer(function()
        -- 慢速扫描: 每帧只处理少量对象, 防止一开启就卡顿
        local count = 0
        local batch = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then RegisterInteractPrompt(obj) end
            -- 智能快速互动: 检测到就应用
            if (obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector")) and (Config.FastInteract or Config.LongRangeInteract) then
                ApplySmartInteract(obj)
            end
            count += 1; batch += 1
            -- 每50个对象让出一帧, 平滑扫描不卡顿
            if batch >= 50 then batch = 0; task.wait() end
        end
        Interact.Running = false
        Interact.LastFullScan = tick()
    end)
end

local function ProcessInteractQueue()
    if not Config.InteractESP then return end
    local processed = 0
    while #Interact.PendingQueue > 0 and processed < 3 do
        local prompt = table.remove(Interact.PendingQueue, 1)
        if prompt and prompt.Parent then
            local data = Interact.PromptsCache[prompt]
            if data then
                local parent = data.Parent
                if parent and parent.Parent and not Interact.Highlights[parent] then
                    local hl = CreateInteractHighlight(parent)
                    local text = data.ActionText ~= "" and data.ActionText or (data.ObjectText ~= "" and data.ObjectText or "可互动")
                    local bb = CreateInteractBB(parent, text)
                    if hl then Interact.Highlights[parent] = hl end
                    if bb then Interact.Billboards[parent] = bb end
                end
            end
        end
        processed += 1
    end
end

local function UpdateInteractBillboards()
    if not Config.InteractESP then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local myPos = hrp.Position
    local list = Interact.PromptList
    local total = #list
    if total == 0 then return end
    local startIdx = (Interact.ProcessIndex % total) + 1
    local endIdx = math.min(startIdx + 4, total)
    for i = startIdx, endIdx do
        local prompt = list[i]
        if prompt and prompt.Parent then
            local data = Interact.PromptsCache[prompt]
            if data then
                local parent = data.Parent
                if parent and parent.Parent then
                    local bb = Interact.Billboards[parent]
                    if bb and bb.Parent then
                        local dist = (myPos - parent.Position).Magnitude
                        local distLbl = bb:FindFirstChild("DistLabel")
                        if distLbl then distLbl.Text = string.format("%.1fm", dist) end
                    end
                end
            end
        end
    end
    Interact.ProcessIndex = endIdx
    if Interact.ProcessIndex >= total then Interact.ProcessIndex = 0 end
end

local function CleanInteractCache()
    if not Interact.NeedRebuild then return end
    Interact.NeedRebuild = false
    local newList = {}
    for _, prompt in ipairs(Interact.PromptList) do
        if prompt and prompt.Parent and Interact.PromptsCache[prompt] then
            table.insert(newList, prompt)
        else
            local data = Interact.PromptsCache[prompt]
            if data and data.Parent then
                RemoveInteractESP(data.Parent)
                Interact.Highlights[data.Parent] = nil
                Interact.Billboards[data.Parent] = nil
            end
            Interact.PromptsCache[prompt] = nil
        end
    end
    Interact.PromptList = newList
end

local function ApplyInteractESP()
    ClearInteractESP()
    if not Config.InteractESP then return end
    StartInteractListeners()
    StartSmartInteractListener()
    FullScanInteractablesAsync()
end

-- ============== 自动互动系统 + 自动修改系统 ==============
-- do-end 块隔离 local 寄存器, 性能化设计: 慢速分批扫描, yield 防卡
local StartAutoInteract, StopAutoInteract, RefreshInteractNames, GetInteractNames
local StartAutoDetect, StopAutoDetect
local StartPureAutoInteract, StopPureAutoInteract
local StartAutoModify, StopAutoModify
do
    local AI = {
        Enabled = false,
        LoopToken = 0,     -- 触发循环的取消令牌
        ScanToken = 0,     -- 扫描任务的取消令牌 (与触发循环解耦, 可独立扫描)
        NamesCount = {},   -- name -> 出现次数 (用于"频繁出现"统计)
        NamesList = {},    -- 去重后的名称列表 (用于UI选择)
        PromptsList = {},  -- 扫描到的互动对象实例列表 (供触发循环使用)
        ScanQueue = {},
        LastScanTime = 0,
    }
    local AD = {
        Enabled = false,
        LoopToken = 0,
    }
    local PA = {
        Enabled = false,
        LoopToken = 0,
    }
    local AM = {
        Enabled = false,
        LoopToken = 0,
        ModifiedSet = {},  -- instance -> true (单次模式已修改记录)
        ScanQueue = {},
    }

    -- 安全读取
    local function safeGet(obj, prop)
        local ok, v = pcall(function() return obj[prop] end)
        if ok then return v end
        return nil
    end

    -- 获取互动对象的"中文名称" (按类型取最合适的文本)
    local function GetInteractName(prompt)
        local cls
        pcall(function() cls = prompt.ClassName end)
        if cls == "ProximityPrompt" then
            local actionText = safeGet(prompt, "ActionText")
            if type(actionText) == "string" and #actionText > 0 then return actionText end
            local objectText = safeGet(prompt, "ObjectText")
            if type(objectText) == "string" and #objectText > 0 then return objectText end
        elseif cls == "TextButton" or cls == "ImageButton" then
            local txt = safeGet(prompt, "Text")
            if type(txt) == "string" and #txt > 0 then return txt end
        end
        -- 通用: 优先用父对象名 (ProximityPrompt/ClickDetector 通常挂在道具上)
        local parent = safeGet(prompt, "Parent")
        if parent then
            local pn = safeGet(parent, "Name")
            if type(pn) == "string" and #pn > 0 then return pn end
        end
        local ownName = safeGet(prompt, "Name")
        if type(ownName) == "string" and #ownName > 0 then return ownName end
        return "未命名互动"
    end

    -- 判断是否为可触发互动对象 (扩展检测: 道具/座椅/世界UI按钮等, 防止漏检)
    local function IsInteractable(obj)
        local ok, cls = pcall(function() return obj.ClassName end)
        if not ok then return false end
        if cls == "ProximityPrompt" or cls == "ClickDetector" then return true end
        if cls == "Seat" or cls == "VehicleSeat" then return true end
        if cls == "Tool" then return true end
        -- 世界中的可点击UI按钮 (BillboardGui/SurfaceGui 内的 TextButton/ImageButton)
        if cls == "TextButton" or cls == "ImageButton" then
            local parent = safeGet(obj, "Parent")
            if parent then
                local pcls
                pcall(function() pcls = parent.ClassName end)
                if pcls == "BillboardGui" or pcls == "SurfaceGui" then return true end
            end
        end
        return false
    end

    -- 触发单个互动对象 (按类型分别处理; useKey 用于部分游戏的按键模拟)
    local function TriggerInteract(prompt, useKey)
        useKey = useKey or Config.AutoInteractKey or Enum.KeyCode.E
        local ok, cls = pcall(function() return prompt.ClassName end)
        if not ok then return false end
        if cls == "ProximityPrompt" then
            local triggered = false
            pcall(function()
                if fireproximityprompt then
                    fireproximityprompt(prompt, 0)
                    triggered = true
                end
            end)
            if not triggered then
                pcall(function()
                    prompt:InputHoldBegin()
                    task.wait(0.05)
                    prompt:InputHoldEnd()
                    triggered = true
                end)
            end
            return triggered
        elseif cls == "ClickDetector" then
            pcall(function()
                local parent = prompt.Parent
                if parent and LocalPlayer.Character then
                    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        for _, conn in ipairs(getconnections(prompt.MouseClick) or {}) do
                            pcall(function() conn:Fire(root) end)
                        end
                    end
                end
            end)
            return true
        elseif cls == "Seat" or cls == "VehicleSeat" then
            pcall(function()
                local hum = GetHum()
                if hum and prompt.Occupant == nil then
                    prompt:Sit(hum)
                end
            end)
            return true
        elseif cls == "Tool" then
            pcall(function()
                local char = LocalPlayer.Character
                local parent = prompt.Parent
                if char and parent and not parent:IsDescendantOf(char) then
                    prompt.Parent = char  -- 尝试装备 (部分游戏会过滤, 尽力而为)
                end
            end)
            return true
        elseif cls == "TextButton" or cls == "ImageButton" then
            pcall(function()
                for _, conn in ipairs(getconnections(prompt.MouseButton1Click) or {}) do
                    pcall(function() conn:Fire() end)
                end
                for _, conn in ipairs(getconnections(prompt.Activated) or {}) do
                    pcall(function() conn:Fire() end)
                end
            end)
            return true
        end
        -- 兜底: 模拟按键 (针对用自定义按键检测互动的游戏, 执行器无此函数则静默跳过)
        pcall(function()
            if keypress then
                keypress(useKey)
                task.wait(0.05)
                if keyrelease then keyrelease(useKey) end
            end
        end)
        return false
    end

    -- 扫描收集所有互动对象的名称 + 实例 (慢速, 分批 yield)
    -- 注意: 使用 AI.ScanToken (与触发循环解耦), 允许自动检测独立扫描
    local function ScanInteractNames(scanToken)
        AI.NamesCount = {}
        AI.NamesList = {}
        AI.PromptsList = {}
        AI.ScanQueue = { Workspace }
        local scanned = 0
        local childrenIterated = 0

        while #AI.ScanQueue > 0 do
            if AI.ScanToken ~= scanToken then return end
            local container = table.remove(AI.ScanQueue, 1)
            local valid = false
            pcall(function() valid = container ~= nil and container.Parent ~= nil end)
            if valid then
                local children
                pcall(function() children = container:GetChildren() end)
                if children then
                    for _, child in ipairs(children) do
                        if AI.ScanToken ~= scanToken then return end
                        childrenIterated = childrenIterated + 1
                        if childrenIterated >= 30 then
                            childrenIterated = 0
                            task.wait(0.15)
                        end
                        if IsInteractable(child) then
                            local name = GetInteractName(child)
                            if not AI.NamesCount[name] then
                                AI.NamesCount[name] = 1
                                table.insert(AI.NamesList, name)
                            else
                                AI.NamesCount[name] = AI.NamesCount[name] + 1
                            end
                            table.insert(AI.PromptsList, child)
                            scanned = scanned + 1
                            if scanned >= 600 then return end
                        else
                            -- 递归 (限制队列大小, 跳过无关类型)
                            local ccls
                            pcall(function() ccls = child.ClassName end)
                            if ccls and ccls ~= "Camera" and ccls ~= "Terrain" and ccls ~= "Humanoid"
                               and ccls ~= "Script" and ccls ~= "LocalScript" and ccls ~= "ModuleScript"
                               and ccls ~= "Sound" and ccls ~= "Weld" and ccls ~= "WeldConstraint"
                               and ccls ~= "Motor6D" and ccls ~= "Bone" and ccls ~= "Animation"
                               and #AI.ScanQueue < 3000 then
                                table.insert(AI.ScanQueue, child)
                            end
                        end
                    end
                end
            end
        end
    end

    -- 对外: 刷新名称列表 (慢速, 异步, 不影响触发循环)
    RefreshInteractNames = function()
        AI.ScanToken = AI.ScanToken + 1
        local scanToken = AI.ScanToken
        task.spawn(function()
            pcall(ScanInteractNames, scanToken)
        end)
    end

    -- 对外: 获取当前名称列表 (含次数, 已按次数降序排序)
    GetInteractNames = function()
        local result = {}
        for _, name in ipairs(AI.NamesList) do
            table.insert(result, {name = name, count = AI.NamesCount[name] or 1})
        end
        table.sort(result, function(a, b) return a.count > b.count end)
        return result
    end

    -- 自动互动主循环: 每隔 interval 遍历已扫描的互动对象, 匹配名称后触发
    local function AutoInteractLoop(myToken)
        while AI.Enabled and AI.LoopToken == myToken do
            local interval = Config.AutoInteractInterval
            if type(interval) ~= "number" or interval < 0.1 then interval = 0.5 end
            local range = Config.AutoInteractRange
            if type(range) ~= "number" or range < 1 then range = 30 end
            local target = Config.AutoInteractTarget or ""
            local singleMode = Config.AutoInteractSingleMode == true
            local autoDetect = Config.AutoDetectInteract == true
            local ignoreDist = Config.AutoInteractIgnoreDist == true
            local useKey = Config.AutoInteractKey or Enum.KeyCode.E

            -- 默认模式: 未开单选 + 未开自动检测 + 未选目标 -> 自动互动周围(强制受距离限制)
            local isDefaultMode = (target == "" and not singleMode and not autoDetect)
            local effectiveIgnoreDist = ignoreDist and not isDefaultMode

            -- 单选模式: 必须有目标名才触发; 默认模式/无目标时互动全部
            local requireTarget = singleMode
            if requireTarget and target == "" then
                task.wait(interval)
            else
                -- 玩家位置 (用于距离判断)
                local rootPos = nil
                pcall(function()
                    if LocalPlayer.Character then
                        local r = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if r then rootPos = r.Position end
                    end
                end)

                -- 遍历已扫描的实例列表 (由 ScanInteractNames 填充)
                local promptsToCheck = AI.PromptsList or {}
                for _, prompt in ipairs(promptsToCheck) do
                    if AI.LoopToken ~= myToken then return end
                    local alive = false
                    pcall(function() alive = prompt ~= nil and prompt.Parent ~= nil end)
                    if alive then
                        local name = GetInteractName(prompt)
                        local nameMatch = (target == "") or (name == target)
                        if nameMatch then
                            local inRange = true
                            if not effectiveIgnoreDist and rootPos then
                                local parent = safeGet(prompt, "Parent")
                                local partPos = nil
                                pcall(function()
                                    if parent then
                                        if parent:IsA("BasePart") then
                                            partPos = parent.Position
                                        elseif parent:IsA("Model") then
                                            local pfp = parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart")
                                            if pfp then partPos = pfp.Position end
                                        elseif parent:IsA("Tool") then
                                            local h = parent:FindFirstChildWhichIsA("BasePart")
                                            if h then partPos = h.Position end
                                        end
                                    end
                                end)
                                if partPos then
                                    inRange = (rootPos - partPos).Magnitude <= range
                                end
                            end
                            if inRange then
                                pcall(TriggerInteract, prompt, useKey)
                                task.wait(0.05)  -- 每次触发后小yield防卡
                            end
                        end
                    end
                end
                task.wait(interval)
            end
        end
    end

    StartAutoInteract = function()
        if AI.Enabled then return end
        AI.Enabled = true
        AI.LoopToken = AI.LoopToken + 1
        local myToken = AI.LoopToken
        -- 先慢速扫描一次填充名称/实例列表
        RefreshInteractNames()
        -- 启动触发循环
        task.spawn(function()
            pcall(AutoInteractLoop, myToken)
        end)
        -- 若自动检测已开启, 同步启动检测循环
        if Config.AutoDetectInteract and not AD.Enabled then
            StartAutoDetect()
        end
    end

    StopAutoInteract = function()
        AI.Enabled = false
        AI.LoopToken = AI.LoopToken + 1
    end

    -- ====== 自动检测 (持续慢速扫描填充列表, 无需手动点) ======
    StartAutoDetect = function()
        if AD.Enabled then return end
        AD.Enabled = true
        AD.LoopToken = AD.LoopToken + 1
        local myToken = AD.LoopToken
        task.spawn(function()
            -- 立即先扫一次
            pcall(RefreshInteractNames)
            while AD.Enabled and AD.LoopToken == myToken do
                -- 每 5 秒慢速重扫一次 (性能化, 防卡)
                local waited = 0
                while waited < 5 and AD.Enabled and AD.LoopToken == myToken do
                    task.wait(0.5)
                    waited = waited + 0.5
                end
                if AD.Enabled and AD.LoopToken == myToken and Config.AutoDetectInteract then
                    pcall(RefreshInteractNames)
                end
            end
        end)
    end

    StopAutoDetect = function()
        AD.Enabled = false
        AD.LoopToken = AD.LoopToken + 1
    end

    -- ====== 纯自动互动 (开启后连续点按设定按键, 不扫描不找对象, 纯按键模拟) ======
    StartPureAutoInteract = function()
        if PA.Enabled then return end
        PA.Enabled = true
        PA.LoopToken = PA.LoopToken + 1
        local myToken = PA.LoopToken
        task.spawn(function()
            while PA.Enabled and PA.LoopToken == myToken do
                if not Config.PureAutoInteract then return end
                local useKey = Config.AutoInteractKey or Enum.KeyCode.E
                -- 优先用执行器按键模拟函数 (覆盖面最广, 适配大多数游戏)
                local ok = false
                pcall(function()
                    if keypress and keyrelease then
                        keypress(useKey)
                        task.wait(0.05)
                        keyrelease(useKey)
                        ok = true
                    end
                end)
                -- 兜底: 模拟 ProximityPrompt 鼠标点击事件
                if not ok then
                    pcall(function()
                        local char = LocalPlayer.Character
                        if char then
                            local root = char:FindFirstChild("HumanoidRootPart")
                            if root then
                                for prompt, _ in pairs(Saved.Prompts) do
                                    pcall(function()
                                        if prompt.Parent then
                                            if prompt:IsA("ProximityPrompt") and fireproximityprompt then
                                                fireproximityprompt(prompt, 0)
                                            elseif prompt:IsA("ClickDetector") then
                                                for _, conn in ipairs(getconnections(prompt.MouseClick) or {}) do
                                                    pcall(function() conn:Fire(root) end)
                                                end
                                            end
                                        end
                                    end)
                                end
                            end
                        end
                    end)
                end
                local interval = Config.PureAutoInteractInterval
                if type(interval) ~= "number" or interval < 0.05 then interval = 0.3 end
                task.wait(interval)
            end
        end)
    end

    StopPureAutoInteract = function()
        PA.Enabled = false
        PA.LoopToken = PA.LoopToken + 1
    end

    -- ====== 自动修改系统 (刷新互动增强) ======
    -- 模式1: 全部重复修改 (每隔 interval 重新应用 ApplySmartInteract 防游戏回调)
    -- 模式2: 单次修改 (每个互动对象只修改一次, 用 ModifiedSet 记录)
    local function AutoModifyLoop(myToken)
        while AM.Enabled and AM.LoopToken == myToken do
            local interval = Config.AutoModifyInterval
            if type(interval) ~= "number" or interval < 0.5 then interval = 2 end
            local mode = Config.AutoModifyMode or 1

            -- 慢速扫描 + 修改
            local processed = 0
            local queue = { Workspace }
            local childrenIterated = 0

            while #queue > 0 and processed < 30 do
                if AM.LoopToken ~= myToken then return end
                local container = table.remove(queue, 1)
                local valid = false
                pcall(function() valid = container ~= nil and container.Parent ~= nil end)
                if valid then
                    local children
                    pcall(function() children = container:GetChildren() end)
                    if children then
                        for _, child in ipairs(children) do
                            if AM.LoopToken ~= myToken then return end
                            childrenIterated = childrenIterated + 1
                            if childrenIterated >= 25 then
                                childrenIterated = 0
                                task.wait(0.1)
                            end
                            local ok, cls = pcall(function() return child.ClassName end)
                            if not ok then
                                -- 跳过
                            elseif cls == "ProximityPrompt" or cls == "ClickDetector" then
                                if mode == 1 then
                                    -- 全部重复修改: 每次都应用
                                    pcall(ApplySmartInteract, child)
                                    processed = processed + 1
                                elseif mode == 2 then
                                    -- 单次修改: 只修改一次
                                    if not AM.ModifiedSet[child] then
                                        pcall(ApplySmartInteract, child)
                                        AM.ModifiedSet[child] = true
                                        processed = processed + 1
                                    end
                                end
                                -- 防止 ModifiedSet 无限增长
                                if mode == 2 and processed >= 500 then break end
                            else
                                -- 递归 (限制队列)
                                if cls ~= "Camera" and cls ~= "Terrain" and cls ~= "Humanoid"
                                   and cls ~= "Script" and cls ~= "LocalScript" and cls ~= "ModuleScript"
                                   and cls ~= "Sound" and cls ~= "Weld" and cls ~= "WeldConstraint"
                                   and cls ~= "Motor6D" and cls ~= "Bone" and cls ~= "Animation"
                                   and #queue < 3000 then
                                    table.insert(queue, child)
                                end
                            end
                        end
                    end
                end
            end

            -- 清理 ModifiedSet 中已失效的引用 (防止内存泄漏)
            if mode == 2 then
                local toRemove = {}
                local cleaned = 0
                for obj, _ in pairs(AM.ModifiedSet) do
                    cleaned = cleaned + 1
                    if cleaned >= 100 then break end
                    local alive = false
                    pcall(function() alive = obj ~= nil and obj.Parent ~= nil end)
                    if not alive then toRemove[obj] = true end
                end
                for obj, _ in pairs(toRemove) do
                    AM.ModifiedSet[obj] = nil
                end
            end

            -- 等待下一轮
            task.wait(interval)
        end
    end

    StartAutoModify = function()
        if AM.Enabled then return end
        AM.Enabled = true
        AM.LoopToken = AM.LoopToken + 1
        local myToken = AM.LoopToken
        -- 单次模式重置已修改记录
        if Config.AutoModifyMode == 2 then
            AM.ModifiedSet = {}
        end
        task.spawn(function()
            pcall(AutoModifyLoop, myToken)
        end)
    end

    StopAutoModify = function()
        AM.Enabled = false
        AM.LoopToken = AM.LoopToken + 1
        AM.ModifiedSet = {}
    end
end -- 自动互动/自动修改系统块结束

local function ApplyNightVision()
    if Config.NightVision then
        local intensity = Config.NightValue / 10
        Lighting.Brightness = math.min(10, Saved.Lighting.Brightness + intensity)
        Lighting.Ambient = Color3.fromRGB(math.min(255,50+Config.NightValue*4), math.min(255,50+Config.NightValue*4), math.min(255,50+Config.NightValue*3))
        Lighting.OutdoorAmbient = Color3.fromRGB(math.min(255,50+Config.NightValue*4), math.min(255,50+Config.NightValue*4), math.min(255,50+Config.NightValue*3))
        Lighting.ColorShift_Top = Color3.fromRGB(math.min(255,Config.NightValue*5), math.min(255,Config.NightValue*5), math.min(255,Config.NightValue*4))
        Lighting.ColorShift_Bottom = Color3.fromRGB(math.min(255,Config.NightValue*3), math.min(255,Config.NightValue*3), math.min(255,Config.NightValue*2))
        Lighting.GlobalShadows = false; Lighting.FogEnd = 1e6
        -- 兼容用 Atmosphere 控光的游戏: 降低 Decay 为0让远处也亮
        local atm = Lighting:FindFirstChildOfClass("Atmosphere")
        if atm then
            if not Saved.AtmosphereDecay then Saved.AtmosphereDecay = atm.Decay end
            atm.Decay = 0
        end
    else
        Lighting.Brightness=Saved.Lighting.Brightness; Lighting.Ambient=Saved.Lighting.Ambient
        Lighting.OutdoorAmbient=Saved.Lighting.OutdoorAmbient; Lighting.ColorShift_Top=Saved.Lighting.ColorShift_Top
        Lighting.ColorShift_Bottom=Saved.Lighting.ColorShift_Bottom; Lighting.GlobalShadows=Saved.Lighting.GlobalShadows
        Lighting.FogEnd=Saved.Lighting.FogEnd
        -- 还原 Atmosphere
        if Saved.AtmosphereDecay then
            local atm = Lighting:FindFirstChildOfClass("Atmosphere")
            if atm then atm.Decay = Saved.AtmosphereDecay end
            Saved.AtmosphereDecay = nil
        end
    end
end

task.wait()

-- ============== UI 创建 ==============
pcall(function()
    local old = CoreGui:FindFirstChild("UniversalHelperV34")
    if old then old:Destroy() end
    local old2 = CoreGui:FindFirstChild("UH_FloatBallV34")
    if old2 then old2:Destroy() end
end)

local BASE_W, BASE_H = 680, 520
local TITLE_H = 40

local Gui = Instance.new("ScreenGui")
Gui.Name = "UniversalHelperV34"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = CoreGui

local UIScale = Instance.new("UIScale")
UIScale.Scale = Config.UIScale
UIScale.Parent = Gui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, BASE_W, 0, BASE_H)
Main.Position = LoadUIPos()
Main.BackgroundColor3 = Color3.fromRGB(10, 14, 10)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = Gui

do -- 限制以下局部变量作用域 (减少寄存器占用, 避免200局部变量上限)
-- 黑客二进制主题: 1和0可动背景 (有规律列分布, 边缘渐隐, 从上向下流动)
local BinaryBg = Instance.new("TextLabel")
BinaryBg.Name = "BinaryBackground"
BinaryBg.Size = UDim2.new(1, 0, 1, 0)
BinaryBg.Position = UDim2.new(0, 0, 0, 0)
BinaryBg.BackgroundTransparency = 0.88
BinaryBg.BackgroundColor3 = Color3.fromRGB(0, 18, 0)
BinaryBg.TextColor3 = Color3.fromRGB(0, 200, 0)
BinaryBg.Font = Enum.Font.Code
BinaryBg.TextSize = 11
BinaryBg.TextXAlignment = Enum.TextXAlignment.Left
BinaryBg.TextYAlignment = Enum.TextYAlignment.Top
BinaryBg.TextWrapped = true
BinaryBg.Parent = Main
-- 边缘渐隐: 用UIGradient让左右上下边缘透明度渐变 (中间清晰, 边缘消失)
local BinGrad = Instance.new("UIGradient", BinaryBg)
BinGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),       -- 左边缘完全透明
    NumberSequenceKeypoint.new(0.12, 0.3),  -- 渐入
    NumberSequenceKeypoint.new(0.5, 0),     -- 中间清晰
    NumberSequenceKeypoint.new(0.88, 0.3),  -- 渐出
    NumberSequenceKeypoint.new(1, 1),       -- 右边缘完全透明
})
-- 从上向下流动的二进制雨 (有规律的列, 每列独立速度)
task.spawn(function()
    -- 用固定列数生成有规律的二进制 (列对齐, 不是随机全屏)
    local COLS = 40
    local ROWS = 32
    -- 每列有一个"种子"和"偏移", 让1和0有规律地流动
    local colSeeds = {}
    for c = 1, COLS do colSeeds[c] = math.random(0, 9999) end
    local frame = 0
    -- 预分配行表 (避免每帧重新分配)
    local lines = {}
    -- 预构建字符表 (避免每帧字符串拼接产生大量GC垃圾)
    local charBuf = {}
    for r = 1, ROWS do lines[r] = nil end
    while BinaryBg and BinaryBg.Parent do
        frame = frame + 1
        for r = 1, ROWS do
            for c = 1, COLS do
                local bit = ((colSeeds[c] + r + frame) % 7) % 2
                charBuf[c] = bit == 1 and "1 " or "0 "
            end
            lines[r] = table.concat(charBuf)
        end
        BinaryBg.Text = table.concat(lines, "\n")
        task.wait(0.15)  -- 降频: 0.15秒更新一次 (减少GC压力, 视觉无明显差异)
    end
end)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Thickness = 3
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local StrokeGradient = Instance.new("UIGradient", MainStroke)
StrokeGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,    Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(0, 180, 0)),
    ColorSequenceKeypoint.new(1,    Color3.fromRGB(0, 255, 0)),
})
task.spawn(function()
    local off = 0
    while Main and Main.Parent do
        off = off + 0.01
        if off > 1 then off = off - 1 end
        StrokeGradient.Offset = Vector2.new(off, 0)
        task.wait(0.05)
    end
end)
end -- 二进制背景/描边块结束 (BinaryBg/BinGrad/MainStroke/StrokeGradient 局部变量释放)
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, TITLE_H)
TitleBar.BackgroundColor3 = Color3.fromRGB(8, 18, 8)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -220, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "通用辅助 v3.8 [黑客模式]"
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.Font = Enum.Font.Code
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local LogBtn = Instance.new("TextButton")
LogBtn.Size = UDim2.new(0, 70, 0, 28)
LogBtn.Position = UDim2.new(1, -170, 0.5, -14)
LogBtn.BackgroundColor3 = Color3.fromRGB(60, 90, 160)
LogBtn.Text = "更新日志"
LogBtn.TextColor3 = Color3.fromRGB(255,255,255)
LogBtn.Font = Enum.Font.GothamBold
LogBtn.TextSize = 11
LogBtn.Parent = TitleBar
Instance.new("UICorner", LogBtn).CornerRadius = UDim.new(0, 6)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 32, 0, 28)
MinBtn.Position = UDim2.new(1, -90, 0.5, -14)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 62, 72)
MinBtn.Text = "_"
MinBtn.TextColor3 = Color3.fromRGB(255,255,255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 28)
CloseBtn.Position = UDim2.new(1, -50, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 150, 1, -TITLE_H - 8)
SideBar.Position = UDim2.new(0, 6, 0, TITLE_H + 4)
SideBar.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
SideBar.BorderSizePixel = 0
SideBar.Parent = Main
Instance.new("UICorner", SideBar).CornerRadius = UDim.new(0, 10)

local NavList = Instance.new("ScrollingFrame")
NavList.Size = UDim2.new(1, -12, 1, -12)
NavList.Position = UDim2.new(0, 6, 0, 6)
NavList.BackgroundTransparency = 1
NavList.ScrollBarThickness = 3
NavList.CanvasSize = UDim2.new(0,0,0,0)
NavList.AutomaticCanvasSize = Enum.AutomaticSize.Y
NavList.Parent = SideBar
do local NavLayout = Instance.new("UIListLayout", NavList)
NavLayout.Padding = UDim.new(0, 5)
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
end

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -168, 1, -TITLE_H - 12)
Content.Position = UDim2.new(0, 162, 0, TITLE_H + 6)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 5
Content.CanvasSize = UDim2.new(0,0,0,0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.Parent = Main
do local ContentLayout = Instance.new("UIListLayout", Content)
ContentLayout.Padding = UDim.new(0, 6)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
end

local Pages = {}
local NavButtons = {}

local function AddNav(name, pageName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(40, 42, 52)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(210,210,210)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = NavList
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = Content
    local pl = Instance.new("UIListLayout", page)
    pl.Padding = UDim.new(0, 6)
    pl.SortOrder = Enum.SortOrder.LayoutOrder
    Pages[pageName] = page

    btn.MouseButton1Click:Connect(function()
        for n, p in pairs(Pages) do p.Visible = (n == pageName) end
        for _, b in ipairs(NavButtons) do b.BackgroundColor3 = Color3.fromRGB(40, 42, 52) end
        btn.BackgroundColor3 = Color3.fromRGB(70, 110, 180)
    end)
    table.insert(NavButtons, btn)
    return page
end

task.wait()

local function MakeToggle(page, text, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 38)
    row.BackgroundColor3 = Color3.fromRGB(34, 36, 46)
    row.Parent = page
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(230,230,230)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 52, 0, 26)
    track.Position = UDim2.new(1, -62, 0.5, -13)
    track.BackgroundColor3 = default and Color3.fromRGB(60, 180, 100) or Color3.fromRGB(70, 70, 80)
    track.BorderSizePixel = 0
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 22, 0, 22)
    thumb.Position = default and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
    thumb.BackgroundColor3 = Color3.fromRGB(255,255,255)
    thumb.BorderSizePixel = 0
    thumb.Parent = track
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

    local state = default
    row.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            state = not state
            track.BackgroundColor3 = state and Color3.fromRGB(60, 180, 100) or Color3.fromRGB(70, 70, 80)
            TweenService:Create(thumb, TweenInfo.new(0.2), {
                Position = state and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
            }):Play()
            callback(state)
        end
    end)
    return row
end

local function MakeSlider(page, text, minv, maxv, default, step, callback, liveApplyFunc)
    step = step or 0.1
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 56)
    row.BackgroundColor3 = Color3.fromRGB(34, 36, 46)
    row.Parent = page
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 22)
    lbl.Position = UDim2.new(0, 12, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. string.format("%.1f", default)
    lbl.TextColor3 = Color3.fromRGB(230,230,230)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(1, -24, 0, 18)
    slider.Position = UDim2.new(0, 12, 0, 32)
    slider.BackgroundColor3 = Color3.fromRGB(50, 52, 62)
    slider.Text = ""
    slider.AutoButtonColor = false
    slider.Parent = row
    Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 4)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - minv) / (maxv - minv), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(80, 170, 230)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

    local dragging = false
    local function update(x)
        local rel = math.clamp((x - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        local val = minv + (maxv - minv) * rel
        val = math.floor(val / step + 0.5) * step
        val = math.clamp(val, minv, maxv)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        lbl.Text = text .. ": " .. string.format("%.1f", val)
        callback(val)
        if liveApplyFunc then liveApplyFunc() end
    end
    slider.MouseButton1Down:Connect(function() dragging = true end)
    slider.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then dragging = true; update(i.Position.X) end
    end)
    -- 连接绑定到slider销毁时自动清理 (避免每个slider泄漏2个永久连接)
    local inputEndedConn, inputChangedConn
    inputEndedConn = UserInputService.InputEnded:Connect(function(i)
        if not slider.Parent then inputEndedConn:Disconnect(); if inputChangedConn then inputChangedConn:Disconnect() end return end
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    inputChangedConn = UserInputService.InputChanged:Connect(function(i)
        if not slider.Parent then inputChangedConn:Disconnect(); if inputEndedConn then inputEndedConn:Disconnect() end return end
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position.X)
        end
    end)
    return row
end

local function MakeButton(page, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(60, 90, 160)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = page
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function MakeLabel(page, text, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(180, 180, 210)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = page
    return lbl
end

task.wait()

-- ============== 视觉页 ==============
local GhostToggle  -- 前向声明 (UpdateGhostToggleUI 后面需要引用)
do
local VisPage = AddNav("视觉", "visual")
MakeLabel(VisPage, "== 玩家透视 ==")
MakeToggle(VisPage, "透视玩家 (ESP)", false, function(v)
    Config.PlayerESP = v
    if v then
        SetupPlayerJoinListeners()  -- 启动新玩家监听, 实时透视后加入的玩家
        RefreshESP()
    else
        ClearAllPlayerESP()
    end
    ShowNotification("玩家透视", v and "已开启" or "已关闭", v and Color3.fromRGB(100,180,100) or Color3.fromRGB(180,180,180))
end)
MakeToggle(VisPage, "团队检测 (队友不透视)", false, function(v)
    Config.TeamCheck = v; ClearAllPlayerESP(); if Config.PlayerESP then RefreshESP() end
    ShowNotification("团队检测", v and "已开启" or "已关闭", v and Color3.fromRGB(100,180,100) or Color3.fromRGB(180,180,180))
end)
MakeToggle(VisPage, "显示玩家名称", true, function(v)
    Config.PlayerShowName = v
    UpdatePlayerLabelVisibility()
    ShowNotification("玩家名称", v and "已显示" or "已隐藏", Color3.fromRGB(100,180,100))
end)
MakeToggle(VisPage, "显示玩家血量", true, function(v)
    Config.PlayerShowHealth = v
    UpdatePlayerLabelVisibility()
    ShowNotification("玩家血量", v and "已显示" or "已隐藏", Color3.fromRGB(100,180,100))
end)
MakeToggle(VisPage, "显示玩家距离", true, function(v)
    Config.PlayerShowDist = v
    UpdatePlayerLabelVisibility()
    ShowNotification("玩家距离", v and "已显示" or "已隐藏", Color3.fromRGB(100,180,100))
end)

MakeLabel(VisPage, "== 墙体透视 (Xray) ==")
MakeToggle(VisPage, "墙体透视", false, function(v)
    Config.WallXray = v
    if v then
        ApplyWallXray(); SetupXrayDynamic()
    else
        RestoreWallXray()
        if Xray.Conn then Xray.Conn:Disconnect() Xray.Conn=nil end
        Xray.RefreshConn = nil
        Config.WallAutoRefresh = false
    end
    ShowNotification("墙体透视", v and "已开启" or "已关闭", v and Color3.fromRGB(255,200,80) or Color3.fromRGB(180,180,180))
end)
MakeToggle(VisPage, "详细模式 (触发器+伤害区)", false, function(v)
    Config.WallDetail = v
    if Config.WallXray then RestoreWallXray(); ApplyWallXray() end
    ShowNotification("详细模式", v and "已开启" or "已关闭", v and Color3.fromRGB(255,200,80) or Color3.fromRGB(180,180,180))
end)

MakeLabel(VisPage, "== 墙体透视模式 ==")
do
local SpeedModeRow = Instance.new("Frame")
SpeedModeRow.Size = UDim2.new(1, 0, 0, 38)
SpeedModeRow.BackgroundColor3 = Color3.fromRGB(34, 36, 46)
SpeedModeRow.Parent = VisPage
Instance.new("UICorner", SpeedModeRow).CornerRadius = UDim.new(0, 8)
local smLbl = Instance.new("TextLabel")
smLbl.Size = UDim2.new(0.5, 0, 1, 0); smLbl.Position = UDim2.new(0, 12, 0, 0)
smLbl.BackgroundTransparency = 1; smLbl.Text = "透视速度: 快速"
smLbl.TextColor3 = Color3.fromRGB(230,230,230); smLbl.Font = Enum.Font.Gotham; smLbl.TextSize = 13
smLbl.TextXAlignment = Enum.TextXAlignment.Left; smLbl.Parent = SpeedModeRow
local smBtn = Instance.new("TextButton")
smBtn.Size = UDim2.new(0, 80, 0, 26); smBtn.Position = UDim2.new(1, -92, 0.5, -13)
smBtn.BackgroundColor3 = Color3.fromRGB(70, 110, 180); smBtn.Text = "切换"
smBtn.TextColor3 = Color3.fromRGB(255,255,255); smBtn.Font = Enum.Font.GothamBold; smBtn.TextSize = 12
smBtn.Parent = SpeedModeRow; Instance.new("UICorner", smBtn).CornerRadius = UDim.new(0, 6)
smBtn.MouseButton1Click:Connect(function()
    Config.WallSpeedMode = (Config.WallSpeedMode == "fast") and "slow" or "fast"
    smLbl.Text = "透视速度: " .. (Config.WallSpeedMode == "fast" and "快速" or "慢速")
    ShowNotification("墙体透视", "已切换为" .. (Config.WallSpeedMode == "fast" and "快速" or "慢速") .. "模式", Color3.fromRGB(255, 200, 80))
end)
end -- SpeedModeRow/smLbl/smBtn 释放

MakeSlider(VisPage, "墙体透视范围", 10, 1000, 200, 1, function(v) Config.WallRange = v end)
MakeSlider(VisPage, "墙体透明度", 0, 1, 0.7, 0.1, function(v) Config.WallTrans = v end, function() if Config.WallXray then RestoreWallXray(); ApplyWallXray() end end)
MakeSlider(VisPage, "触发器透明度(黄)", 0, 1, 0.4, 0.1, function(v) Config.TriggerTrans = v end, function() if Config.WallXray then RestoreWallXray(); ApplyWallXray() end end)
MakeSlider(VisPage, "伤害区透明度(红)", 0, 1, 0.4, 0.1, function(v) Config.DamageTrans = v end, function() if Config.WallXray then RestoreWallXray(); ApplyWallXray() end end)

MakeLabel(VisPage, "== 墙体透视定时刷新 ==")
MakeToggle(VisPage, "定时刷新 (按快/慢模式刷新)", false, function(v)
    Config.WallAutoRefresh = v
    if v and Config.WallXray then
        SetupWallAutoRefresh()
    else
        Xray.RefreshConn = nil
        Config.WallAutoRefresh = false
    end
    ShowNotification("定时刷新", v and "已开启" or "已关闭", v and Color3.fromRGB(255,200,80) or Color3.fromRGB(180,180,180))
end)
MakeSlider(VisPage, "刷新间隔(0~20秒)", 0, 20, 10, 0.1, function(v) Config.WallRefreshInterval = v end)

MakeLabel(VisPage, "== 夜视 ==")
MakeToggle(VisPage, "夜视 (增强环境亮度)", false, function(v)
    Config.NightVision = v; ApplyNightVision()
    ShowNotification("夜视", v and "已开启" or "已关闭", v and Color3.fromRGB(200,200,100) or Color3.fromRGB(180,180,180))
end)
MakeSlider(VisPage, "夜视强度 (1~50)", 1, 50, 20, 0.1, function(v) Config.NightValue = v end, function() if Config.NightVision then ApplyNightVision() end end)
MakeButton(VisPage, "一键白天", function()
    Lighting.Brightness = 2; Lighting.Ambient = Color3.fromRGB(128,128,128)
    Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128); Lighting.ColorShift_Top = Color3.fromRGB(255,255,255)
    Lighting.ColorShift_Bottom = Color3.fromRGB(128,128,128); Lighting.GlobalShadows = true
    ShowNotification("天气", "已恢复白天", Color3.fromRGB(255, 220, 100))
end)

MakeLabel(VisPage, "== 幽灵模式 ==")
GhostToggle = MakeToggle(VisPage, "幽灵模式 (相机自由飞行, 人物冻结)", false, function(v)
    Config.GhostMode = v; ApplyGhostMode()
end)
MakeSlider(VisPage, "幽灵飞行速度 (10~200)", 10, 200, 50, 0.1, function(v) Config.GhostSpeed = v end)

MakeLabel(VisPage, "== 幽灵快捷键 ==")
MakeToggle(VisPage, "启用幽灵快捷键", false, function(v)
    Config.GhostShortcutEnabled = v
    ShowNotification("幽灵快捷键", v and "已启用 (按 " .. Config.GhostShortcutKey .. " 切换)" or "已禁用", Color3.fromRGB(180, 80, 255))
end)

do
local ShortcutRow = Instance.new("Frame")
ShortcutRow.Size = UDim2.new(1, 0, 0, 38)
ShortcutRow.BackgroundColor3 = Color3.fromRGB(34, 36, 46)
ShortcutRow.Parent = VisPage
Instance.new("UICorner", ShortcutRow).CornerRadius = UDim.new(0, 8)
local scLbl = Instance.new("TextLabel")
scLbl.Size = UDim2.new(0.5, 0, 1, 0); scLbl.Position = UDim2.new(0, 12, 0, 0)
scLbl.BackgroundTransparency = 1; scLbl.Text = "快捷键: " .. Config.GhostShortcutKey
scLbl.TextColor3 = Color3.fromRGB(230,230,230); scLbl.Font = Enum.Font.Gotham; scLbl.TextSize = 13
scLbl.TextXAlignment = Enum.TextXAlignment.Left; scLbl.Parent = ShortcutRow
local scBtn = Instance.new("TextButton")
scBtn.Size = UDim2.new(0, 80, 0, 26); scBtn.Position = UDim2.new(1, -92, 0.5, -13)
scBtn.BackgroundColor3 = Color3.fromRGB(70, 110, 180); scBtn.Text = "设置"
scBtn.TextColor3 = Color3.fromRGB(255,255,255); scBtn.Font = Enum.Font.GothamBold; scBtn.TextSize = 12
scBtn.Parent = ShortcutRow; Instance.new("UICorner", scBtn).CornerRadius = UDim.new(0, 6)

scBtn.MouseButton1Click:Connect(function()
    ShowNotification("快捷键设置", "请按下想要的按键...", Color3.fromRGB(180, 80, 255))
    local conn; conn = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            Config.GhostShortcutKey = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
            scLbl.Text = "快捷键: " .. Config.GhostShortcutKey
            ShowNotification("快捷键", "已设置为: " .. Config.GhostShortcutKey, Color3.fromRGB(180, 80, 255))
            conn:Disconnect()
        end
    end)
    task.delay(5, function()
        if conn and conn.Connected then
            conn:Disconnect()
            ShowNotification("快捷键", "设置超时", Color3.fromRGB(255, 80, 80))
        end
    end)
end)
end -- ShortcutRow/scLbl/scBtn 释放

MakeToggle(VisPage, "幽灵状态栏 (右上角)", true, function(v)
    Config.GhostStatusBar = v
    if v then CreateGhostStatusBar()
    else
        if Ghost.StatusGui then Ghost.StatusGui:Destroy() Ghost.StatusGui=nil end
    end
end)

MakeLabel(VisPage, "== 透视刷新 ==")
MakeToggle(VisPage, "自动刷新", false, function(v)
    Config.AutoRefresh = v
    if v then
        SetupPlayerAutoRefresh()
        ShowNotification("自动刷新", "已开启 - 每" .. Config.RefreshInterval .. "秒刷新一次", Color3.fromRGB(100,180,100))
    else
        ShowNotification("自动刷新", "已关闭", Color3.fromRGB(180,180,180))
    end
end)
MakeSlider(VisPage, "刷新间隔(秒)", 1, 60, 5, 0.1, function(v) Config.RefreshInterval = v end)
MakeButton(VisPage, "立即刷新一次", function()
    ClearAllPlayerESP(); task.wait(0.1); RefreshESP()
    ShowNotification("刷新", "已手动刷新透视对象", Color3.fromRGB(100, 180, 220))
end)
end -- VisPage 释放

-- ============== NPC功能页 ==============
do
local NPCPage = AddNav("NPC功能", "npc")

MakeLabel(NPCPage, "== NPC 透视 ==")
MakeToggle(NPCPage, "NPC透视 (慢速逐个透视所有NPC)", false, function(v)
    Config.NPCESP = v
    if v then
        task.spawn(function()
            CachedModels = {}; ModelList = {}; ModelCount = 0
            StartCacheListeners()
            local color = NPC_COLORS[Config.NPCESPColor] or NPC_COLORS.Red
            -- 使用 GetChildren + 一层子级扫描, 避免昂贵的 GetDescendants 全树遍历
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("Model") and IsNPCModel(obj) and not CachedModels[obj] then
                    CachedModels[obj] = true
                    table.insert(ModelList, obj)
                    ModelCount += 1
                    table.insert(NPC_ESP.ProcessQueue, obj)
                end
                for _, sub in ipairs(obj:GetChildren()) do
                    if sub:IsA("Model") and IsNPCModel(sub) and not CachedModels[sub] then
                        CachedModels[sub] = true
                        table.insert(ModelList, sub)
                        ModelCount += 1
                        table.insert(NPC_ESP.ProcessQueue, sub)
                    end
                end
                task.wait()
            end
            NPC_ESP.LastCacheRebuild = tick()
            ShowNotification("NPC透视", "已开启 - 发现 " .. ModelCount .. " 个NPC, 慢速透视中", Color3.fromRGB(100,180,100))
        end)
    else
        ClearAllNPCESP()
        ShowNotification("NPC透视", "已关闭", Color3.fromRGB(180,180,180))
    end
end)

-- NPC颜色选择
do
local NPCColorRow = Instance.new("Frame")
NPCColorRow.Size = UDim2.new(1, 0, 0, 38)
NPCColorRow.BackgroundColor3 = Color3.fromRGB(34, 36, 46)
NPCColorRow.Parent = NPCPage
Instance.new("UICorner", NPCColorRow).CornerRadius = UDim.new(0, 8)
local ncLbl = Instance.new("TextLabel")
ncLbl.Size = UDim2.new(0.3, 0, 1, 0); ncLbl.Position = UDim2.new(0, 12, 0, 0)
ncLbl.BackgroundTransparency = 1; ncLbl.Text = "NPC颜色:"
ncLbl.TextColor3 = Color3.fromRGB(230,230,230); ncLbl.Font = Enum.Font.Gotham; ncLbl.TextSize = 13
ncLbl.TextXAlignment = Enum.TextXAlignment.Left; ncLbl.Parent = NPCColorRow
do local colorValues = {
    Red = Color3.fromRGB(255,0,0), Blue = Color3.fromRGB(0,100,255),
    Yellow = Color3.fromRGB(255,215,0), Green = Color3.fromRGB(0,255,100),
}
local colorNames = {{"Red","红"}, {"Blue","蓝"}, {"Yellow","黄"}, {"Green","绿"}}
for i, cn in ipairs(colorNames) do
    local cbtn = Instance.new("TextButton")
    cbtn.Size = UDim2.new(0, 40, 0, 26)
    cbtn.Position = UDim2.new(0, 80 + (i-1)*50, 0.5, -13)
    cbtn.BackgroundColor3 = colorValues[cn[1]]
    cbtn.Text = cn[2]; cbtn.TextColor3 = Color3.new(1,1,1)
    cbtn.Font = Enum.Font.GothamBold; cbtn.TextSize = 11
    cbtn.Parent = NPCColorRow
    Instance.new("UICorner", cbtn).CornerRadius = UDim.new(0, 4)
    cbtn.MouseButton1Click:Connect(function()
        Config.NPCESPColor = cn[1]
        UpdateNPCESPColor(colorValues[cn[1]])
        ShowNotification("NPC颜色", "已切换为 " .. cn[2] .. "色", colorValues[cn[1]])
    end)
end end
end -- NPCColorRow/ncLbl 释放

MakeLabel(NPCPage, "== NPC 显示选项 ==")
MakeToggle(NPCPage, "显示NPC名称 (中文翻译)", true, function(v)
    Config.NPCShowName = v
    UpdateNPCLabelVisibility()
    ShowNotification("NPC名称", v and "已显示" or "已隐藏", Color3.fromRGB(100,180,100))
end)
MakeToggle(NPCPage, "显示NPC血量", true, function(v)
    Config.NPCShowHealth = v
    UpdateNPCLabelVisibility()
    ShowNotification("NPC血量", v and "已显示" or "已隐藏", Color3.fromRGB(100,180,100))
end)
MakeToggle(NPCPage, "显示NPC距离", true, function(v)
    Config.NPCShowDist = v
    UpdateNPCLabelVisibility()
    ShowNotification("NPC距离", v and "已显示" or "已隐藏", Color3.fromRGB(100,180,100))
end)

MakeLabel(NPCPage, "== NPC 击杀 ==")
MakeToggle(NPCPage, "NPC击杀 (范围内自动击杀)", false, function(v)
    Config.NPCKill = v
    ShowNotification("NPC击杀", v and "已开启 - 范围内NPC自动击杀" or "已关闭", v and Color3.fromRGB(255,80,80) or Color3.fromRGB(180,180,180))
end)
MakeSlider(NPCPage, "击杀范围 (1~200)", 1, 200, 50, 1, function(v) Config.NPCKillRange = v end)
end -- NPCPage 释放

-- ============== 移动页 ==============
do
local MovePage = AddNav("移动", "move")
MakeLabel(MovePage, "== 移动速度 ==")
MakeToggle(MovePage, "修改移动速度", false, function(v) Config.SpeedEnabled = v; ApplySpeed(); ShowNotification("移动速度", v and "已开启" or "已关闭", v and Color3.fromRGB(100,180,220) or Color3.fromRGB(180,180,180)) end)
MakeSlider(MovePage, "速度 (1~200)", 1, 200, 16, 0.1, function(v) Config.SpeedValue = v end, function() if Config.SpeedEnabled then ApplySpeed() end end)

MakeLabel(MovePage, "== 跳跃力 ==")
MakeToggle(MovePage, "修改跳跃力", false, function(v) Config.JumpEnabled = v; ApplyJump(); ShowNotification("跳跃力", v and "已开启" or "已关闭", v and Color3.fromRGB(100,180,220) or Color3.fromRGB(180,180,180)) end)
MakeSlider(MovePage, "跳跃力 (1~200)", 1, 200, 50, 0.1, function(v) Config.JumpValue = v end, function() if Config.JumpEnabled then ApplyJump() end end)

MakeLabel(MovePage, "== 飞行 ==")
MakeToggle(MovePage, "飞行 (WASD+Space/Ctrl)", false, function(v) Config.FlyEnabled = v; ApplyFly() end)
MakeSlider(MovePage, "飞行速度 (0~500)", 0, 500, 50, 0.1, function(v) Config.FlySpeed = v end, function() if Config.FlyEnabled then ApplyFly() end end)

MakeLabel(MovePage, "== 瞬移行走 ==")
MakeToggle(MovePage, "瞬移行走 (循环修改)", false, function(v) Config.TeleWalk = v; ApplyTeleWalk() end)
MakeSlider(MovePage, "瞬移强度 (0~100)", 0, 100, 10, 0.1, function(v) Config.TeleWalkValue = v end, function() if Config.TeleWalk then ApplyTeleWalk() end end)

MakeLabel(MovePage, "== 穿墙 ==")
MakeToggle(MovePage, "穿墙 (可穿过任何物体)", false, function(v) Config.Noclip = v; ApplyNoclip() end)

MakeLabel(MovePage, "== 无限跳跃 ==")
MakeToggle(MovePage, "无限跳跃 (空格无限跳)", false, function(v)
    Config.InfiniteJump = v; ApplyInfiniteJump()
end)

MakeLabel(MovePage, "== 悬浮模式 (WASD移动 + Q下降E上升) ==")
MakeToggle(MovePage, "悬浮模式 (WASD移动 Q下降E上升)", false, function(v)
    Config.FloatMode = v; ApplyFloat()
end)
MakeSlider(MovePage, "悬浮速度 (1~100)", 1, 100, 30, 0.1, function(v) Config.FloatSpeed = v end)
end -- MovePage 释放

-- ============== 互动页 ==============
do
local InterPage = AddNav("互动", "interact")
MakeLabel(InterPage, "== 智能快速互动 ==")
MakeToggle(InterPage, "快速互动 (自动检测类型并加速)", false, function(v)
    Config.FastInteract = v
    ApplyFastInteract()
    StartSmartInteractListener()
    ShowNotification("快速互动", v and "已开启 (新刷新也会生效)" or "已关闭", v and Color3.fromRGB(255,200,80) or Color3.fromRGB(180,180,180))
end)

MakeLabel(InterPage, "== 远距离互动 ==")
MakeToggle(InterPage, "远距离互动 (扩大互动范围)", false, function(v)
    Config.LongRangeInteract = v
    ApplyFastInteract()
    StartSmartInteractListener()
    if v then
        -- 独立扫描全树填充缓存 (防止未开快速互动/透视时缓存为空导致远距离不生效)
        ScanAndCachePromptsAsync()
    end
    ShowNotification("远距离互动", v and "已开启 (慢速扫描填充中)" or "已关闭", v and Color3.fromRGB(255,200,80) or Color3.fromRGB(180,180,180))
end)

MakeLabel(InterPage, "== 互动透视 (慢速扫描防卡) ==")
MakeToggle(InterPage, "高亮透视可互动物体", false, function(v)
    Config.InteractESP = v
    if v then ApplyInteractESP(); ShowNotification("互动透视", "慢速扫描已开启", Color3.fromRGB(100,220,180))
    else ClearInteractESP(); ShowNotification("互动透视", "已关闭", Color3.fromRGB(180,180,180)) end
end)

MakeLabel(InterPage, "== 互动距离 ==")
MakeSlider(InterPage, "互动距离 (1~100)", 1, 100, 10, 0.1, function(v) Config.InteractDist = v end, function() UpdatePromptDistances() end)
MakeButton(InterPage, "检测当前互动代码类型", function()
    local found = {}
    local count = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if count >= 20 then break end
        local t, fields = DetectInteractType(obj)
        if t then
            local canRange = CanModifyRange(obj) and "可改距离" or "不可改距离"
            table.insert(found, t .. " [" .. canRange .. "]")
            count += 1
        end
    end
    if #found == 0 then
        ShowNotification("互动检测", "未检测到可互动对象", Color3.fromRGB(255,150,80))
    else
        ShowNotification("互动检测", "检测到 " .. #found .. " 种类型 (详见控制台)", Color3.fromRGB(100,220,180))
        print("[互动检测] 检测到的互动代码类型:")
        for _, t in ipairs(found) do print("  - " .. t) end
    end
end)
MakeButton(InterPage, "手动刷新互动对象 (一次性)", function()
    ApplyFastInteract(); ClearInteractESP(); ApplyInteractESP()
    ShowNotification("互动", "已刷新互动对象", Color3.fromRGB(100, 220, 180))
end)

-- ====== 自动互动 (性能化设计, 不卡顿) ======
MakeLabel(InterPage, "== 自动互动 (自动检测 + 自动触发) ==")
MakeLabel(InterPage, "说明: 默认自动互动周围; 开自动检测持续扫描; 单选模式仅互动选中目标")
MakeToggle(InterPage, "自动互动 (总开关)", false, function(v)
    Config.AutoInteract = v
    if v then
        StartAutoInteract()
        ShowNotification("自动互动", "已开启 (默认互动周围)", Color3.fromRGB(255, 200, 80))
    else
        StopAutoInteract()
        ShowNotification("自动互动", "已关闭", Color3.fromRGB(180, 180, 180))
    end
end)
MakeToggle(InterPage, "自动检测可互动对象 (持续扫描)", true, function(v)
    Config.AutoDetectInteract = v
    if v then
        StartAutoDetect()
        ShowNotification("自动检测", "已开启 (慢速扫描填充列表)", Color3.fromRGB(255, 200, 80))
    else
        StopAutoDetect()
        ShowNotification("自动检测", "已关闭", Color3.fromRGB(180, 180, 180))
    end
end)
MakeToggle(InterPage, "单选模式 (仅互动选中目标)", false, function(v)
    Config.AutoInteractSingleMode = v
    ShowNotification("单选模式", v and "已开启 (请在下方列表选目标)" or "已关闭 (互动全部匹配)", Color3.fromRGB(255, 200, 80))
end)

-- ====== 纯自动互动模式 (开启后连续点按设定按键, 不扫描不找对象) ======
MakeToggle(InterPage, "纯自动互动模式 (开启后连续点按按键)", false, function(v)
    Config.PureAutoInteract = v
    if v then
        StartPureAutoInteract()
        ShowNotification("纯自动互动", "已开启 (连续点按设定按键)", Color3.fromRGB(255, 80, 80))
    else
        StopPureAutoInteract()
        ShowNotification("纯自动互动", "已关闭", Color3.fromRGB(180, 180, 180))
    end
end)
MakeSlider(InterPage, "纯自动点按间隔 (秒, 越小越快)", 0.05, 2, 0.3, 0.05, function(v)
    Config.PureAutoInteractInterval = v
end)

-- 自动互动按键 (默认E, 可自定义)
do
local KeyRow = Instance.new("Frame")
KeyRow.Size = UDim2.new(1, 0, 0, 38)
KeyRow.BackgroundColor3 = Color3.fromRGB(34, 36, 46)
KeyRow.Parent = InterPage
Instance.new("UICorner", KeyRow).CornerRadius = UDim.new(0, 8)
local keyLbl = Instance.new("TextLabel")
keyLbl.Size = UDim2.new(0.5, 0, 1, 0); keyLbl.Position = UDim2.new(0, 12, 0, 0)
keyLbl.BackgroundTransparency = 1
local function keyShortName(k)
    local s = tostring(k):gsub("Enum.KeyCode.", "")
    return s
end
keyLbl.Text = "自动互动按键: " .. keyShortName(Config.AutoInteractKey or Enum.KeyCode.E)
keyLbl.TextColor3 = Color3.fromRGB(230,230,230); keyLbl.Font = Enum.Font.Gotham; keyLbl.TextSize = 13
keyLbl.TextXAlignment = Enum.TextXAlignment.Left; keyLbl.Parent = KeyRow
local keyBtn = Instance.new("TextButton")
keyBtn.Size = UDim2.new(0, 80, 0, 26); keyBtn.Position = UDim2.new(1, -92, 0.5, -13)
keyBtn.BackgroundColor3 = Color3.fromRGB(70, 110, 180); keyBtn.Text = "设置"
keyBtn.TextColor3 = Color3.fromRGB(255,255,255); keyBtn.Font = Enum.Font.GothamBold; keyBtn.TextSize = 12
keyBtn.Parent = KeyRow; Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 6)
keyBtn.MouseButton1Click:Connect(function()
    ShowNotification("按键设置", "请按下想要的互动按键...", Color3.fromRGB(255, 200, 80))
    local conn; conn = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            Config.AutoInteractKey = input.KeyCode
            keyLbl.Text = "自动互动按键: " .. keyShortName(input.KeyCode)
            ShowNotification("自动互动按键", "已设置为: " .. keyShortName(input.KeyCode), Color3.fromRGB(255, 200, 80))
            conn:Disconnect()
        end
    end)
    task.delay(5, function()
        if conn and conn.Connected then
            conn:Disconnect()
            ShowNotification("按键设置", "超时", Color3.fromRGB(255, 80, 80))
        end
    end)
end)
end -- KeyRow 释放

-- 当前目标显示
local targetLabel
do
local TRow = Instance.new("Frame")
TRow.Size = UDim2.new(1, 0, 0, 30)
TRow.BackgroundColor3 = Color3.fromRGB(40, 42, 52)
TRow.Parent = InterPage
Instance.new("UICorner", TRow).CornerRadius = UDim.new(0, 8)
targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.new(1, -16, 1, 0); targetLabel.Position = UDim2.new(0, 12, 0, 0)
targetLabel.BackgroundTransparency = 1
targetLabel.Text = "当前目标: 全部 (默认互动周围)"
targetLabel.TextColor3 = Color3.fromRGB(255, 200, 80); targetLabel.Font = Enum.Font.GothamBold; targetLabel.TextSize = 13
targetLabel.TextXAlignment = Enum.TextXAlignment.Left; targetLabel.Parent = TRow
end

-- 可互动物品列表 (滚动, 点击选择)
MakeLabel(InterPage, "已检测到的可互动物品 (点击选择):")
local listFrame = Instance.new("ScrollingFrame")
listFrame.Size = UDim2.new(1, 0, 0, 160)
listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
listFrame.ScrollBarThickness = 6
listFrame.BackgroundColor3 = Color3.fromRGB(28, 30, 40)
listFrame.BorderSizePixel = 0
listFrame.Parent = InterPage
Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 8)
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 2)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = listFrame
local listPad = Instance.new("UIPadding")
listPad.PaddingTop = UDim.new(0, 4); listPad.PaddingBottom = UDim.new(0, 4)
listPad.PaddingLeft = UDim.new(0, 4); listPad.PaddingRight = UDim.new(0, 4)
listPad.Parent = listFrame

local function RefreshInteractListUI()
    if not listFrame.Parent then return end
    -- 清空旧条目
    for _, child in ipairs(listFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local names = GetInteractNames()
    local curTarget = Config.AutoInteractTarget or ""
    -- "全部" 选项
    local allBtn = Instance.new("TextButton")
    allBtn.Size = UDim2.new(1, 0, 0, 26)
    allBtn.BackgroundColor3 = (curTarget == "") and Color3.fromRGB(60, 140, 100) or Color3.fromRGB(50, 52, 62)
    allBtn.Text = "  全部  (默认互动周围, 不限名称)"
    allBtn.TextColor3 = Color3.fromRGB(255,255,255)
    allBtn.Font = Enum.Font.Gotham; allBtn.TextSize = 12
    allBtn.TextXAlignment = Enum.TextXAlignment.Left
    allBtn.Parent = listFrame
    Instance.new("UICorner", allBtn).CornerRadius = UDim.new(0, 5)
    allBtn.MouseButton1Click:Connect(function()
        Config.AutoInteractTarget = ""
        if targetLabel then targetLabel.Text = "当前目标: 全部 (默认互动周围)" end
        ShowNotification("自动互动", "已选择: 全部", Color3.fromRGB(255, 200, 80))
        RefreshInteractListUI()
    end)
    -- 各名称条目
    for i, item in ipairs(names) do
        if i > 50 then break end
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 26)
        btn.BackgroundColor3 = (curTarget == item.name) and Color3.fromRGB(60, 140, 100) or Color3.fromRGB(50, 52, 62)
        local dispName = item.name
        if #dispName > 28 then dispName = dispName:sub(1, 28) .. "…" end
        btn.Text = "  " .. dispName .. "  (" .. item.count .. "次)"
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.Gotham; btn.TextSize = 12
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = listFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
        local selName = item.name
        btn.MouseButton1Click:Connect(function()
            Config.AutoInteractTarget = selName
            if targetLabel then targetLabel.Text = "当前目标: " .. selName end
            ShowNotification("自动互动", "已选择: " .. selName, Color3.fromRGB(255, 200, 80))
            RefreshInteractListUI()
        end)
    end
end

-- 手动刷新按钮 (备用, 自动检测开启时无需手动点)
MakeButton(InterPage, "手动刷新列表 (自动检测开启时无需点)", function()
    RefreshInteractNames()
    ShowNotification("自动检测", "正在扫描, 1-2秒后列表更新", Color3.fromRGB(255, 200, 80))
    task.delay(2, function() RefreshInteractListUI() end)
end)

-- 列表自动刷新协程 (自动检测开启时定期更新列表UI)
task.spawn(function()
    while listFrame.Parent do
        if Config.AutoDetectInteract then
            RefreshInteractListUI()
        end
        task.wait(3)
    end
end)

-- 初次填充 (异步等待首次扫描完成)
task.delay(2, function() RefreshInteractListUI() end)

-- 启动时若自动检测已开启, 立即开始后台扫描 (无需手动点击)
if Config.AutoDetectInteract then
    task.spawn(function() pcall(StartAutoDetect) end)
end

MakeSlider(InterPage, "自动互动范围 (stud, 限距离时有效)", 5, 500, 30, 1, function(v)
    Config.AutoInteractRange = v
end)
MakeSlider(InterPage, "自动互动间隔 (秒, 越大越不卡)", 0.1, 5, 0.5, 0.1, function(v)
    Config.AutoInteractInterval = v
end)
MakeToggle(InterPage, "不受距离限制 (全图触发, 关=只互动周围)", false, function(v)
    Config.AutoInteractIgnoreDist = v
    ShowNotification("自动互动", v and "已开启全图触发" or "已切换为只互动周围", Color3.fromRGB(255, 200, 80))
end)

-- ====== 自动修改 (刷新互动增强, 开关模式) ======
MakeLabel(InterPage, "== 自动修改 (持续修改防游戏回调) ==")
MakeLabel(InterPage, "说明: 开启后慢速扫描检测, 防止游戏内回调重置互动参数")
MakeToggle(InterPage, "自动修改 (总开关)", false, function(v)
    Config.AutoModify = v
    if v then
        StartAutoModify()
        local modeName = (Config.AutoModifyMode == 1) and "全部重复修改" or "单次修改"
        ShowNotification("自动修改", "已开启 (" .. modeName .. ")", Color3.fromRGB(255, 200, 80))
    else
        StopAutoModify()
        ShowNotification("自动修改", "已关闭", Color3.fromRGB(180, 180, 180))
    end
end)
do
local ModeRow = Instance.new("Frame")
ModeRow.Size = UDim2.new(1, 0, 0, 38)
ModeRow.BackgroundColor3 = Color3.fromRGB(34, 36, 46)
ModeRow.Parent = InterPage
Instance.new("UICorner", ModeRow).CornerRadius = UDim.new(0, 8)
local modeLbl = Instance.new("TextLabel")
modeLbl.Size = UDim2.new(0.5, 0, 1, 0); modeLbl.Position = UDim2.new(0, 12, 0, 0)
modeLbl.BackgroundTransparency = 1
modeLbl.Text = "模式: 全部重复修改"
modeLbl.TextColor3 = Color3.fromRGB(230,230,230); modeLbl.Font = Enum.Font.Gotham; modeLbl.TextSize = 13
modeLbl.TextXAlignment = Enum.TextXAlignment.Left; modeLbl.Parent = ModeRow
local modeBtn = Instance.new("TextButton")
modeBtn.Size = UDim2.new(0, 80, 0, 26); modeBtn.Position = UDim2.new(1, -92, 0.5, -13)
modeBtn.BackgroundColor3 = Color3.fromRGB(70, 110, 180); modeBtn.Text = "切换"
modeBtn.TextColor3 = Color3.fromRGB(255,255,255); modeBtn.Font = Enum.Font.GothamBold; modeBtn.TextSize = 12
modeBtn.Parent = ModeRow; Instance.new("UICorner", modeBtn).CornerRadius = UDim.new(0, 6)
modeBtn.MouseButton1Click:Connect(function()
    Config.AutoModifyMode = ((Config.AutoModifyMode or 1) % 2) + 1
    local modeNames = {[1]="全部重复修改", [2]="单次修改"}
    modeLbl.Text = "模式: " .. modeNames[Config.AutoModifyMode]
    -- 切换单次模式时清空已修改记录
    if Config.AutoModifyMode == 2 and Config.AutoModify then
        StopAutoModify(); task.wait(0.2); StartAutoModify()
    end
    ShowNotification("自动修改", "已切换为: " .. modeNames[Config.AutoModifyMode], Color3.fromRGB(255, 200, 80))
end)
end -- ModeRow/modeLbl/modeBtn 释放
MakeSlider(InterPage, "全部重复模式间隔 (秒, 越小越防回调但越卡)", 0.5, 10, 2, 0.1, function(v)
    Config.AutoModifyInterval = v
end)
end -- InterPage 释放

-- ============== 枪械检测/修改窗口 + 颜色选择器 + 外出UI ==============
-- 前向声明 Weapon 和 DetectWeapon (实际定义在后面, 但这些函数需要引用同一个upvalue)
local Weapon
local DetectWeapon
-- 冻结数值表: key=属性对象, value=冻结的目标值 (循环强制写入防止重复修改)
-- (Weapon.Frozen 在 Weapon 表定义处初始化, 此处仅定义辅助函数)
local function FreezeWeaponValue(obj, val)
    if not obj then return end
    if Weapon and Weapon.Frozen then Weapon.Frozen[obj] = val end
end
local function UnfreezeWeaponValue(obj)
    if obj and Weapon and Weapon.Frozen then Weapon.Frozen[obj] = nil end
end

-- 冻结循环 (每0.2秒强制写入冻结值, 防止游戏重置)
task.spawn(function()
    while true do
        if Weapon and Weapon.Frozen then
            for obj, val in pairs(Weapon.Frozen) do
                if obj and obj.Parent then
                    pcall(function()
                        if obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("BoolValue") then
                            obj.Value = val
                        end
                    end)
                else
                    Weapon.Frozen[obj] = nil
                end
            end
        end
        task.wait(0.2)
    end
end)

-- 打开枪械检测/修改窗口 (黑客主题, 可最小化/关闭, 检测持有+背包所有枪械)
function OpenWeaponWindow()
    -- 清理旧窗口
    pcall(function() if Weapon and Weapon.Gui then Weapon.Gui:Destroy() end end)
    DetectWeapon()
    local sg = Instance.new("ScreenGui")
    sg.Name = "WeaponWindow"
    sg.ResetOnSpawn = false; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = CoreGui
    Weapon.Gui = sg
    local win = Instance.new("Frame")
    win.Size = UDim2.new(0, 420, 0, 460)
    win.Position = UDim2.new(0.5, -210, 0.5, -230)
    win.BackgroundColor3 = Color3.fromRGB(10, 14, 10)
    win.BorderSizePixel = 0; win.ClipsDescendants = true
    win.Parent = sg
    Instance.new("UICorner", win).CornerRadius = UDim.new(0, 10)
    -- 黑客主题绿色边框
    local ws = Instance.new("UIStroke", win)
    ws.Thickness = 2; ws.Color = Color3.fromRGB(0, 255, 0)
    -- 二进制背景 (枪械窗口也有, 与主UI风格一致)
    local binBg = Instance.new("TextLabel")
    binBg.Size = UDim2.new(1, 0, 1, 0); binBg.BackgroundTransparency = 0.9
    binBg.BackgroundColor3 = Color3.fromRGB(0, 20, 0)
    binBg.TextColor3 = Color3.fromRGB(0, 150, 0); binBg.Font = Enum.Font.Code; binBg.TextSize = 10
    binBg.TextXAlignment = Enum.TextXAlignment.Left; binBg.TextYAlignment = Enum.TextYAlignment.Top
    binBg.TextWrapped = true; binBg.Parent = win
    task.spawn(function()
        -- 用table.concat避免60次字符串拼接产生GC垃圾
        local function gl()
            local buf = {}
            for i = 1, 60 do buf[i] = math.random() > 0.5 and "1 " or "0 " end
            return table.concat(buf)
        end
        local lines={}
        for i=1,30 do lines[i]=gl() end
        while binBg and binBg.Parent do
            binBg.Text = table.concat(lines, "\n")
            table.remove(lines,1); table.insert(lines, gl())
            task.wait(0.2)
        end
    end)
    -- 标题栏
    local tbar = Instance.new("Frame")
    tbar.Size = UDim2.new(1, 0, 0, 34); tbar.BackgroundColor3 = Color3.fromRGB(8, 18, 8)
    tbar.BorderSizePixel = 0; tbar.ZIndex = 5; tbar.Parent = win
    Instance.new("UICorner", tbar).CornerRadius = UDim.new(0, 10)
    local ttl = Instance.new("TextLabel")
    ttl.Size = UDim2.new(1, -120, 1, 0); ttl.Position = UDim2.new(0, 10, 0, 0)
    ttl.BackgroundTransparency = 1; ttl.Text = "枪械检测/修改 [黑客模式]"
    ttl.TextColor3 = Color3.fromRGB(0, 255, 0); ttl.Font = Enum.Font.Code; ttl.TextSize = 14
    ttl.TextXAlignment = Enum.TextXAlignment.Left; ttl.ZIndex = 6; ttl.Parent = tbar
    -- 最小化按钮
    local minB = Instance.new("TextButton")
    minB.Size = UDim2.new(0, 30, 0, 26); minB.Position = UDim2.new(1, -70, 0.5, -13)
    minB.BackgroundColor3 = Color3.fromRGB(40, 50, 40); minB.Text = "_"
    minB.TextColor3 = Color3.fromRGB(0, 255, 0); minB.Font = Enum.Font.Code; minB.TextSize = 13
    minB.ZIndex = 6; minB.Parent = tbar; Instance.new("UICorner", minB).CornerRadius = UDim.new(0, 6)
    -- 关闭按钮
    local closeB = Instance.new("TextButton")
    closeB.Size = UDim2.new(0, 30, 0, 26); closeB.Position = UDim2.new(1, -36, 0.5, -13)
    closeB.BackgroundColor3 = Color3.fromRGB(120, 30, 30); closeB.Text = "X"
    closeB.TextColor3 = Color3.fromRGB(255,255,255); closeB.Font = Enum.Font.Code; closeB.TextSize = 13
    closeB.ZIndex = 6; closeB.Parent = tbar; Instance.new("UICorner", closeB).CornerRadius = UDim.new(0, 6)
    -- 内容滚动区
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -16, 1, -46); content.Position = UDim2.new(0, 8, 0, 40)
    content.BackgroundTransparency = 1; content.ScrollBarThickness = 4
    content.CanvasSize = UDim2.new(0,0,0,0); content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.ZIndex = 7; content.Parent = win
    local cl = Instance.new("UIListLayout", content)
    cl.Padding = UDim.new(0, 6); cl.SortOrder = Enum.SortOrder.LayoutOrder
    -- 检测按钮 (重新检测)
    local detBtn = Instance.new("TextButton")
    detBtn.Size = UDim2.new(1, 0, 0, 32); detBtn.BackgroundColor3 = Color3.fromRGB(20, 80, 30)
    detBtn.Text = ">> 重新检测武器 <<"; detBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
    detBtn.Font = Enum.Font.Code; detBtn.TextSize = 13; detBtn.ZIndex = 7; detBtn.Parent = content
    Instance.new("UICorner", detBtn).CornerRadius = UDim.new(0, 6)
    -- 当前装备状态标签
    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size = UDim2.new(1, 0, 0, 24); statusLbl.BackgroundColor3 = Color3.fromRGB(15, 25, 15)
    statusLbl.Text = "状态: 检测中..."; statusLbl.TextColor3 = Color3.fromRGB(0, 255, 0)
    statusLbl.Font = Enum.Font.Code; statusLbl.TextSize = 12
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left; statusLbl.ZIndex = 7; statusLbl.Parent = content
    Instance.new("UICorner", statusLbl).CornerRadius = UDim.new(0, 6)
    -- 信息标签 (当前装备武器详情)
    local infoLbl = Instance.new("TextLabel")
    infoLbl.Size = UDim2.new(1, 0, 0, 80); infoLbl.BackgroundColor3 = Color3.fromRGB(15, 25, 15)
    infoLbl.Text = "未检测"; infoLbl.TextColor3 = Color3.fromRGB(180, 255, 180)
    infoLbl.Font = Enum.Font.Code; infoLbl.TextSize = 11
    infoLbl.TextXAlignment = Enum.TextXAlignment.Left; infoLbl.TextYAlignment = Enum.TextYAlignment.Top
    infoLbl.ZIndex = 7; infoLbl.Parent = content; Instance.new("UICorner", infoLbl).CornerRadius = UDim.new(0, 6)
    -- 背包武器列表标签
    local bpLbl = Instance.new("TextLabel")
    bpLbl.Size = UDim2.new(1, 0, 0, 20); bpLbl.BackgroundTransparency = 1
    bpLbl.Text = "== 背包内所有枪械 (点击切换) =="; bpLbl.TextColor3 = Color3.fromRGB(0, 220, 0)
    bpLbl.Font = Enum.Font.Code; bpLbl.TextSize = 11
    bpLbl.TextXAlignment = Enum.TextXAlignment.Left; bpLbl.ZIndex = 7; bpLbl.Parent = content
    -- 背包列表容器
    local bpHolder = Instance.new("Frame")
    bpHolder.Size = UDim2.new(1, 0, 0, 0); bpHolder.BackgroundTransparency = 1
    bpHolder.AutomaticSize = Enum.AutomaticSize.Y; bpHolder.ZIndex = 7; bpHolder.Parent = content
    local bpl = Instance.new("UIListLayout", bpHolder)
    bpl.Padding = UDim.new(0, 3); bpl.SortOrder = Enum.SortOrder.LayoutOrder
    -- 数值调节滑块容器 (动态生成)
    local sliderHolder = Instance.new("Frame")
    sliderHolder.Size = UDim2.new(1, 0, 0, 0); sliderHolder.BackgroundTransparency = 1
    sliderHolder.AutomaticSize = Enum.AutomaticSize.Y; sliderHolder.ZIndex = 7; sliderHolder.Parent = content
    local sl = Instance.new("UIListLayout", sliderHolder)
    sl.Padding = UDim.new(0, 6); sl.SortOrder = Enum.SortOrder.LayoutOrder
    -- 当前选中武器
    local selectedTool = nil
    local RefreshInfo  -- 前向声明 (ScanAllWeapons和RefreshInfo互相调用)

    -- 创建带冻结功能的滑块 (中文标签)
    -- obj: ValueBase实例(可能为nil)  field: 字段名(用于attr/prop回退写入)
    local function MakeWSlider(labelText, obj, field, minv, maxv, default, isBool)
        if default == nil then return end
        -- 统一写入函数: 优先Value对象, 回退到attr/prop
        local function writeVal(v)
            pcall(function()
                if obj and typeof(obj) == "Instance" and (obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("BoolValue")) then
                    obj.Value = v
                else
                    local key = Weapon[field.."Key"]; local kind = Weapon[field.."Kind"]
                    if key and kind == "attr" then Weapon.Tool:SetAttribute(key, v)
                    elseif key and kind == "prop" then Weapon.Tool[key] = v end
                end
            end)
        end
        -- 是否可冻结 (仅Value对象可冻结, attr/prop无对象引用无法循环强制写入)
        local canFreeze = obj and typeof(obj) == "Instance" and (obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("BoolValue"))
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 56); row.BackgroundColor3 = Color3.fromRGB(15, 25, 15)
        row.ZIndex = 7; row.Parent = sliderHolder; Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -70, 0, 20); lbl.Position = UDim2.new(0, 6, 0, 4)
        lbl.BackgroundTransparency = 1; lbl.Text = labelText .. ": " .. tostring(default)
        lbl.TextColor3 = Color3.fromRGB(180, 255, 180); lbl.Font = Enum.Font.Code; lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 8; lbl.Parent = row
        -- 冻结按钮 (仅Value对象可冻结)
        local freezeBtn
        local frozen = false
        local curVal = default
        if canFreeze then
            freezeBtn = Instance.new("TextButton")
            freezeBtn.Size = UDim2.new(0, 56, 0, 20); freezeBtn.Position = UDim2.new(1, -62, 0, 4)
            freezeBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 20); freezeBtn.Text = "冻结"
            freezeBtn.TextColor3 = Color3.fromRGB(255, 200, 80); freezeBtn.Font = Enum.Font.Code; freezeBtn.TextSize = 10
            freezeBtn.ZIndex = 8; freezeBtn.Parent = row; Instance.new("UICorner", freezeBtn).CornerRadius = UDim.new(0, 4)
            freezeBtn.MouseButton1Click:Connect(function()
                frozen = not frozen
                if frozen then
                    FreezeWeaponValue(obj, curVal)
                    freezeBtn.Text = "已冻结"
                    freezeBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
                    freezeBtn.TextColor3 = Color3.fromRGB(255,255,255)
                else
                    UnfreezeWeaponValue(obj)
                    freezeBtn.Text = "冻结"
                    freezeBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 20)
                    freezeBtn.TextColor3 = Color3.fromRGB(255, 200, 80)
                end
            end)
        end
        if isBool then
            -- 布尔值用切换按钮
            local togBtn = Instance.new("TextButton")
            togBtn.Size = UDim2.new(1, -12, 0, 24); togBtn.Position = UDim2.new(0, 6, 0, 28)
            togBtn.BackgroundColor3 = default and Color3.fromRGB(40, 100, 40) or Color3.fromRGB(80, 30, 30)
            togBtn.Text = default and "开启 (点击关闭)" or "关闭 (点击开启)"
            togBtn.TextColor3 = Color3.fromRGB(0, 255, 0); togBtn.Font = Enum.Font.Code; togBtn.TextSize = 11
            togBtn.ZIndex = 8; togBtn.Parent = row; Instance.new("UICorner", togBtn).CornerRadius = UDim.new(0, 4)
            togBtn.MouseButton1Click:Connect(function()
                curVal = not curVal
                writeVal(curVal)
                togBtn.BackgroundColor3 = curVal and Color3.fromRGB(40, 100, 40) or Color3.fromRGB(80, 30, 30)
                togBtn.Text = curVal and "开启 (点击关闭)" or "关闭 (点击开启)"
                lbl.Text = labelText .. ": " .. tostring(curVal)
                if frozen and canFreeze then FreezeWeaponValue(obj, curVal) end
            end)
        else
            -- 数值滑块
            local slider = Instance.new("TextButton")
            slider.Size = UDim2.new(1, -12, 0, 20); slider.Position = UDim2.new(0, 6, 0, 30)
            slider.BackgroundColor3 = Color3.fromRGB(25, 35, 25); slider.Text = ""; slider.AutoButtonColor = false
            slider.ZIndex = 8; slider.Parent = row; Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 4)
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((default-minv)/(maxv-minv), 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(0, 220, 0); fill.BorderSizePixel = 0; fill.ZIndex = 9; fill.Parent = slider
            Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)
            local dragging = false
            local function upd(x)
                local r = math.clamp((x - slider.AbsolutePosition.X)/slider.AbsoluteSize.X, 0, 1)
                curVal = minv + (maxv-minv)*r
                fill.Size = UDim2.new(r, 0, 1, 0)
                lbl.Text = labelText .. ": " .. string.format("%.2f", curVal)
                writeVal(curVal)
                if frozen and canFreeze then FreezeWeaponValue(obj, curVal) end
            end
            slider.MouseButton1Down:Connect(function() dragging = true; upd(UserInputService:GetMouseLocation().X) end)
            slider.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.Touch then dragging = true; upd(i.Position.X) end
            end)
            local ec, cc
            ec = UserInputService.InputEnded:Connect(function(i)
                if not slider.Parent then ec:Disconnect(); if cc then cc:Disconnect() end return end
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
            end)
            cc = UserInputService.InputChanged:Connect(function(i)
                if not slider.Parent then cc:Disconnect(); if ec then ec:Disconnect() end return end
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i.Position.X) end
            end)
        end
    end

    -- 应用数值到武器
    local function ApplyWeaponValue(obj, val)
        if not obj then return end
        pcall(function()
            if typeof(obj) == "Instance" then
                if obj:IsA("IntValue") or obj:IsA("NumberValue") then obj.Value = val end
            end
        end)
    end

    -- 扫描背包所有枪械工具
    local function ScanAllWeapons()
        for _, c in ipairs(bpHolder:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        local char = LocalPlayer.Character
        local tools = {}
        -- 背包工具
        for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if t:IsA("Tool") then table.insert(tools, t) end
        end
        -- 手持工具
        if char then
            for _, t in ipairs(char:GetChildren()) do
                if t:IsA("Tool") then table.insert(tools, t) end
            end
        end
        for _, t in ipairs(tools) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 24); btn.BackgroundColor3 = Color3.fromRGB(15, 25, 15)
            btn.Text = "  " .. t.Name .. (t.Parent == char and " [已装备]" or "")
            btn.TextColor3 = Color3.fromRGB(0, 220, 0); btn.Font = Enum.Font.Code; btn.TextSize = 11
            btn.TextXAlignment = Enum.TextXAlignment.Left; btn.ZIndex = 8; btn.Parent = bpHolder
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            btn.MouseButton1Click:Connect(function()
                selectedTool = t
                -- 直接检测该武器属性 (无需装备也能读取, 解决"背包武器检测不到"问题)
                DetectWeapon(t)
                -- 同时尝试装备 (部分游戏需要装备后修改才生效)
                pcall(function() if char then t.Parent = char end end)
                RefreshInfo()
            end)
        end
        if #tools == 0 then
            local empty = Instance.new("TextLabel")
            empty.Size = UDim2.new(1, 0, 0, 20); empty.BackgroundTransparency = 1
            empty.Text = "  (背包为空, 无枪械)"; empty.TextColor3 = Color3.fromRGB(150, 150, 150)
            empty.Font = Enum.Font.Code; empty.TextSize = 11
            empty.TextXAlignment = Enum.TextXAlignment.Left; empty.ZIndex = 8; empty.Parent = bpHolder
        end
    end

    -- 检测并刷新UI (中文标签 + 冻结功能)
    RefreshInfo = function()
        DetectWeapon()
        ScanAllWeapons()
        if not Weapon.Detected then
            statusLbl.Text = "状态: 未装备武器"
            infoLbl.Text = "请先装备武器, 或点击上方背包列表中的枪械"
            for _, c in ipairs(sliderHolder:GetChildren()) do
                if c:IsA("Frame") then c:Destroy() end
            end
            return
        end
        statusLbl.Text = "状态: 已检测 -> " .. Weapon.Name
        local info = "武器名称: " .. Weapon.Name
        if Weapon.Values.Ammo then info = info .. "\n子弹数量: " .. Weapon.Values.Ammo end
        if Weapon.Values.MaxAmmo then info = info .. "\n子弹上限: " .. Weapon.Values.MaxAmmo end
        if Weapon.Values.Reserve then info = info .. "\n备弹数量: " .. Weapon.Values.Reserve end
        if Weapon.Values.FireRate then info = info .. "\n射击间隔: " .. Weapon.Values.FireRate end
        if Weapon.Values.ReloadTime then info = info .. "\n换弹时间: " .. Weapon.Values.ReloadTime end
        if Weapon.Values.Auto ~= nil then info = info .. "\n全自动模式: " .. tostring(Weapon.Values.Auto) end
        infoLbl.Text = info
        -- 清空并重建滑块 (中文标签) — 改为检查Values, 支持attr/prop类型
        for _, c in ipairs(sliderHolder:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        if Weapon.Values.Ammo ~= nil then
            MakeWSlider("子弹数量", Weapon.Ammo, "Ammo", 0, math.max(Weapon.Values.MaxAmmo or 30, Weapon.Values.Ammo or 30)*2, Weapon.Values.Ammo, false)
        end
        if Weapon.Values.MaxAmmo ~= nil then
            MakeWSlider("子弹上限", Weapon.MaxAmmo, "MaxAmmo", 0, math.max(Weapon.Values.MaxAmmo*2, 100), Weapon.Values.MaxAmmo, false)
        end
        if Weapon.Values.Reserve ~= nil then
            MakeWSlider("备弹数量", Weapon.Reserve, "Reserve", 0, math.max((Weapon.Values.Reserve or 0)*2, 100), Weapon.Values.Reserve, false)
        end
        if Weapon.Values.FireRate ~= nil then
            MakeWSlider("射击间隔", Weapon.FireRate, "FireRate", 0, math.max(Weapon.Values.FireRate*2, 1), Weapon.Values.FireRate, false)
        end
        if Weapon.Values.ReloadTime ~= nil then
            MakeWSlider("换弹时间", Weapon.ReloadTime, "ReloadTime", 0, math.max(Weapon.Values.ReloadTime*2, 5), Weapon.Values.ReloadTime, false)
        end
        if Weapon.Values.Auto ~= nil then
            MakeWSlider("全自动开火", Weapon.Auto, "Auto", nil, nil, Weapon.Values.Auto, true)
        end
    end
    detBtn.MouseButton1Click:Connect(RefreshInfo)
    -- 拖拽
    local dragging, dragStart, startPos = false, nil, nil
    tbar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = win.Position
        end
    end)
    tbar.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    -- 最小化
    local minimized = false
    minB.MouseButton1Click:Connect(function()
        minimized = not minimized
        content.Visible = not minimized
        binBg.Visible = not minimized
        if minimized then win.Size = UDim2.new(0, 420, 0, 40)
        else win.Size = UDim2.new(0, 420, 0, 460) end
    end)
    closeB.MouseButton1Click:Connect(function()
        -- 清理冻结 (关闭窗口时不影响游戏, 冻结循环自动清理失效对象)
        sg:Destroy()
    end)
    RefreshInfo()
end

-- 前向声明 (这些函数/表在后面定义, 但按钮回调和颜色选择器需要引用)
local Combat
local UpdateLockColor
local GetAllTargets

-- 颜色选择器 (HSV色板+亮度条+颜色代码)
function OpenColorPicker()
    pcall(function() if _G.UH_ColorPicker then _G.UH_ColorPicker:Destroy() end end)
    local sg = Instance.new("ScreenGui")
    sg.Name = "ColorPicker"
    sg.ResetOnSpawn = false; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset = true
    sg.Parent = CoreGui
    _G.UH_ColorPicker = sg
    local win = Instance.new("Frame")
    win.Size = UDim2.new(0, 380, 0, 360)
    win.Position = UDim2.new(0.5, -190, 0.5, -180)
    win.BackgroundColor3 = Color3.fromRGB(28,30,38); win.BorderSizePixel = 0
    win.ZIndex = 5
    win.Parent = sg; Instance.new("UICorner", win).CornerRadius = UDim.new(0, 10)
    local ws = Instance.new("UIStroke", win)
    ws.Thickness = 2; ws.Color = Color3.fromRGB(180,80,255)
    -- 标题栏 (可拖拽)
    local tbar = Instance.new("Frame")
    tbar.Size = UDim2.new(1, 0, 0, 32); tbar.BackgroundColor3 = Color3.fromRGB(38,40,50)
    tbar.BorderSizePixel = 0; tbar.ZIndex = 6; tbar.Parent = win
    Instance.new("UICorner", tbar).CornerRadius = UDim.new(0, 10)
    local ttl = Instance.new("TextLabel")
    ttl.Size = UDim2.new(1, -50, 1, 0); ttl.Position = UDim2.new(0, 10, 0, 0)
    ttl.BackgroundTransparency = 1; ttl.Text = "锁定方框颜色调节"
    ttl.TextColor3 = Color3.fromRGB(255,255,255); ttl.Font = Enum.Font.GothamBold; ttl.TextSize = 14
    ttl.TextXAlignment = Enum.TextXAlignment.Left; ttl.ZIndex = 7; ttl.Parent = tbar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 24); closeBtn.Position = UDim2.new(1, -34, 0.5, -12)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200,60,60); closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255,255,255); closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 12
    closeBtn.ZIndex = 7; closeBtn.Parent = tbar; Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

    local SV_SIZE = 220
    -- 左侧颜色选择方框: H(水平) × S(垂直)
    -- 实现: 底层=当前Hue纯色, 上层白色渐变(顶=白,底=透明) -> 顶部白底部纯色
    local svBox = Instance.new("TextButton")
    svBox.Size = UDim2.new(0, SV_SIZE, 0, SV_SIZE)
    svBox.Position = UDim2.new(0, 12, 0, 42)
    svBox.BackgroundColor3 = Color3.fromRGB(255,0,0)
    svBox.BorderSizePixel = 0; svBox.Text = ""; svBox.AutoButtonColor = false
    svBox.ZIndex = 5; svBox.Parent = win
    Instance.new("UICorner", svBox).CornerRadius = UDim.new(0, 6)
    -- Hue 水平渐变 (显示所有颜色光谱)
    local hueGrad = Instance.new("UIGradient", svBox)
    hueGrad.Rotation = 0
    hueGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Color3.fromHSV(0, 1, 1)),
        ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
        ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
        ColorSequenceKeypoint.new(0.5,  Color3.fromHSV(0.5, 1, 1)),
        ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
        ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
        ColorSequenceKeypoint.new(1,    Color3.fromHSV(1, 1, 1)),
    })
    -- Saturation 覆盖: 白→透明 (顶白, 底显示纯色) + 透明→黑 (顶透明, 底黑)
    -- 用两个 Frame 叠加实现完整 SV 选择
    local satOverlay = Instance.new("Frame")
    satOverlay.Size = UDim2.new(1, 0, 1, 0)
    satOverlay.BackgroundColor3 = Color3.fromRGB(255,255,255); satOverlay.BorderSizePixel = 0
    satOverlay.ZIndex = 6; satOverlay.Parent = svBox
    Instance.new("UICorner", satOverlay).CornerRadius = UDim.new(0, 6)
    local satGrad = Instance.new("UIGradient", satOverlay)
    satGrad.Rotation = 90  -- 从上到下
    satGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
    })
    satGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),    -- 顶部白色不透明 (S=0)
        NumberSequenceKeypoint.new(1, 1),    -- 底部透明 (S=1, 显示纯色)
    })
    -- Value 覆盖: 黑色渐变 (顶透明, 底不透明黑)
    local valOverlay = Instance.new("Frame")
    valOverlay.Size = UDim2.new(1, 0, 1, 0)
    valOverlay.BackgroundColor3 = Color3.fromRGB(0,0,0); valOverlay.BorderSizePixel = 0
    valOverlay.ZIndex = 7; valOverlay.Parent = svBox
    Instance.new("UICorner", valOverlay).CornerRadius = UDim.new(0, 6)
    local valGrad = Instance.new("UIGradient", valOverlay)
    valGrad.Rotation = 90
    valGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
    })
    valGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),    -- 顶部透明 (V=1)
        NumberSequenceKeypoint.new(1, 0),    -- 底部黑色不透明 (V=0)
    })
    -- 颜色选择圆圈 (ZIndex最高, 显示在最上层)
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.BackgroundColor3 = Color3.fromRGB(255,255,255); dot.BorderSizePixel = 0
    dot.ZIndex = 20; dot.Parent = svBox
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local dotStroke = Instance.new("UIStroke", dot)
    dotStroke.Thickness = 2; dotStroke.Color = Color3.fromRGB(0,0,0)

    -- 右侧 Hue 色相条 (垂直彩虹)
    local hueBar = Instance.new("TextButton")
    hueBar.Size = UDim2.new(0, 28, 0, SV_SIZE)
    hueBar.Position = UDim2.new(0, 244, 0, 42)
    hueBar.BackgroundColor3 = Color3.fromRGB(255,255,255); hueBar.BorderSizePixel = 0
    hueBar.Text = ""; hueBar.AutoButtonColor = false; hueBar.ZIndex = 5; hueBar.Parent = win
    Instance.new("UICorner", hueBar).CornerRadius = UDim.new(0, 4)
    local hueBarGrad = Instance.new("UIGradient", hueBar)
    hueBarGrad.Rotation = 90
    hueBarGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Color3.fromHSV(0, 1, 1)),
        ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
        ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
        ColorSequenceKeypoint.new(0.5,  Color3.fromHSV(0.5, 1, 1)),
        ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
        ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
        ColorSequenceKeypoint.new(1,    Color3.fromHSV(1, 1, 1)),
    })
    local hdot = Instance.new("Frame")
    hdot.Size = UDim2.new(1, 4, 0, 12)
    hdot.BackgroundColor3 = Color3.fromRGB(255,255,255); hdot.BorderSizePixel = 0
    hdot.ZIndex = 20; hdot.Parent = hueBar
    Instance.new("UICorner", hdot).CornerRadius = UDim.new(1, 0)
    local hdotStroke = Instance.new("UIStroke", hdot)
    hdotStroke.Thickness = 2; hdotStroke.Color = Color3.fromRGB(0,0,0)

    -- 颜色预览块
    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 80, 0, 40); preview.Position = UDim2.new(0, 282, 0, 42)
    preview.BackgroundColor3 = Color3.fromRGB(255,255,255); preview.BorderSizePixel = 0
    preview.ZIndex = 5; preview.Parent = win; Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 6)
    local previewLbl = Instance.new("TextLabel")
    previewLbl.Size = UDim2.new(1, 0, 0, 16); previewLbl.Position = UDim2.new(0, 0, 1, -16)
    previewLbl.BackgroundTransparency = 0.3; previewLbl.Text = "预览"
    previewLbl.TextColor3 = Color3.fromRGB(255,255,255); previewLbl.Font = Enum.Font.Gotham; previewLbl.TextSize = 10
    previewLbl.ZIndex = 6; previewLbl.Parent = preview

    -- RGB显示 + Hex输入
    local codeLbl = Instance.new("TextLabel")
    codeLbl.Size = UDim2.new(0, 200, 0, 20); codeLbl.Position = UDim2.new(0, 12, 0, 280)
    codeLbl.BackgroundTransparency = 1; codeLbl.Text = "RGB: 255,255,255"
    codeLbl.TextColor3 = Color3.fromRGB(230,230,230); codeLbl.Font = Enum.Font.Gotham; codeLbl.TextSize = 12
    codeLbl.TextXAlignment = Enum.TextXAlignment.Left; codeLbl.ZIndex = 6; codeLbl.Parent = win
    local codeBox = Instance.new("TextBox")
    codeBox.Size = UDim2.new(0, 100, 0, 26); codeBox.Position = UDim2.new(0, 12, 0, 306)
    codeBox.BackgroundColor3 = Color3.fromRGB(40,42,50); codeBox.Text = "FFFFFF"
    codeBox.TextColor3 = Color3.fromRGB(255,255,255); codeBox.Font = Enum.Font.Gotham; codeBox.TextSize = 12
    codeBox.ClearTextOnFocus = false; codeBox.ZIndex = 6; codeBox.Parent = win
    Instance.new("UICorner", codeBox).CornerRadius = UDim.new(0, 4)

    -- 确定按钮 (ZIndex提高, 确保可点击)
    local okBtn = Instance.new("TextButton")
    okBtn.Size = UDim2.new(0, 80, 0, 32); okBtn.Position = UDim2.new(1, -92, 1, -42)
    okBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 100); okBtn.Text = "确定"
    okBtn.TextColor3 = Color3.fromRGB(255,255,255); okBtn.Font = Enum.Font.GothamBold; okBtn.TextSize = 14
    okBtn.ZIndex = 15; okBtn.Parent = win; Instance.new("UICorner", okBtn).CornerRadius = UDim.new(0, 6)

    -- 取消按钮
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0, 80, 0, 32); cancelBtn.Position = UDim2.new(1, -178, 1, -42)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 60); cancelBtn.Text = "取消"
    cancelBtn.TextColor3 = Color3.fromRGB(255,255,255); cancelBtn.Font = Enum.Font.GothamBold; cancelBtn.TextSize = 14
    cancelBtn.ZIndex = 15; cancelBtn.Parent = win; Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 6)
    cancelBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

    -- 当前HSV值
    local curH, curS, curV = 0, 1, 1

    local function UpdateUI()
        local c = Color3.fromHSV(curH, curS, curV)
        -- SV方框底层颜色 = 当前Hue纯色
        svBox.BackgroundColor3 = Color3.fromHSV(curH, 1, 1)
        preview.BackgroundColor3 = c
        local r, g, b = math.floor(c.R*255+0.5), math.floor(c.G*255+0.5), math.floor(c.B*255+0.5)
        codeLbl.Text = string.format("RGB: %d,%d,%d", r, g, b)
        codeBox.Text = string.format("%02X%02X%02X", r, g, b)
        -- SV圆圈: X=H, Y=(1-S)
        dot.Position = UDim2.new(0, curH * SV_SIZE - 7, 0, (1 - curS) * SV_SIZE - 7)
        -- Hue圆圈: Y=H
        hdot.Position = UDim2.new(0, -2, 0, curH * SV_SIZE - 6)
    end

    -- SV方框拖拽
    local svDrag = false
    local function updateSVFromMouse(pos)
        local relX = pos.X - svBox.AbsolutePosition.X
        local relY = pos.Y - svBox.AbsolutePosition.Y
        curH = math.clamp(relX / SV_SIZE, 0, 1)
        curS = math.clamp(1 - relY / SV_SIZE, 0, 1)
        UpdateUI()
    end
    svBox.MouseButton1Down:Connect(function()
        svDrag = true
        local mp = UserInputService:GetMouseLocation()
        updateSVFromMouse(mp)
    end)
    svBox.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then svDrag = true; updateSVFromMouse(i.Position) end
    end)
    -- Hue色相条拖拽
    local hDrag = false
    local function updateHueFromMouse(pos)
        local relY = pos.Y - hueBar.AbsolutePosition.Y
        curH = math.clamp(relY / SV_SIZE, 0, 1)
        UpdateUI()
    end
    hueBar.MouseButton1Down:Connect(function()
        hDrag = true
        local mp = UserInputService:GetMouseLocation()
        updateHueFromMouse(mp)
    end)
    hueBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then hDrag = true; updateHueFromMouse(i.Position) end
    end)
    -- 统一InputChanged处理
    local inputConn
    inputConn = UserInputService.InputChanged:Connect(function(i)
        if not win.Parent then inputConn:Disconnect() return end
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            if svDrag then updateSVFromMouse(i.Position) end
            if hDrag then updateHueFromMouse(i.Position) end
        end
    end)
    local endConn
    endConn = UserInputService.InputEnded:Connect(function(i)
        if not win.Parent then endConn:Disconnect() return end
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            svDrag = false; hDrag = false
        end
    end)
    -- 颜色代码输入
    codeBox.FocusLost:Connect(function()
        local hex = codeBox.Text:gsub("#",""):upper()
        if #hex == 6 then
            local r = tonumber(hex:sub(1,2), 16) or 255
            local g = tonumber(hex:sub(3,4), 16) or 255
            local b = tonumber(hex:sub(5,6), 16) or 255
            local c = Color3.fromRGB(r, g, b)
            curH, curS, curV = Color3.toHSV(c)
            UpdateUI()
        end
    end)
    -- 确定按钮
    okBtn.MouseButton1Click:Connect(function()
        local c = Color3.fromHSV(curH, curS, curV)
        Config.CombatLockColorR = math.floor(c.R*255+0.5)
        Config.CombatLockColorG = math.floor(c.G*255+0.5)
        Config.CombatLockColorB = math.floor(c.B*255+0.5)
        UpdateLockColor()
        ShowNotification("颜色", string.format("已设为 %d,%d,%d", Config.CombatLockColorR, Config.CombatLockColorG, Config.CombatLockColorB), c)
        sg:Destroy()
    end)
    -- 拖拽窗口
    local dragging, dragStart, startPos = false, nil, nil
    tbar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = win.Position
        end
    end)
    tbar.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UpdateUI()
end

-- 外出UI (小型同步UI)
local CombatMiniUI = nil
function OpenCombatMiniUI()
    CloseCombatMiniUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "CombatMiniUI"
    sg.ResetOnSpawn = false; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = CoreGui
    local win = Instance.new("Frame")
    win.Size = UDim2.new(0, 220, 0, 240)
    win.Position = UDim2.new(1, -240, 0, 80)
    win.BackgroundColor3 = Color3.fromRGB(28,30,38); win.BorderSizePixel = 0
    win.Parent = sg; Instance.new("UICorner", win).CornerRadius = UDim.new(0, 8)
    local ws = Instance.new("UIStroke", win)
    ws.Thickness = 2; ws.Color = Color3.fromRGB(180,80,255)
    -- 标题栏
    local tbar = Instance.new("Frame")
    tbar.Size = UDim2.new(1, 0, 0, 28); tbar.BackgroundColor3 = Color3.fromRGB(38,40,50)
    tbar.BorderSizePixel = 0; tbar.Parent = win
    Instance.new("UICorner", tbar).CornerRadius = UDim.new(0, 8)
    local ttl = Instance.new("TextLabel")
    ttl.Size = UDim2.new(1, -60, 1, 0); ttl.Position = UDim2.new(0, 8, 0, 0)
    ttl.BackgroundTransparency = 1; ttl.Text = "格斗外出UI"
    ttl.TextColor3 = Color3.fromRGB(255,255,255); ttl.Font = Enum.Font.GothamBold; ttl.TextSize = 12
    ttl.TextXAlignment = Enum.TextXAlignment.Left; ttl.Parent = tbar
    local minB = Instance.new("TextButton")
    minB.Size = UDim2.new(0, 24, 0, 22); minB.Position = UDim2.new(1, -56, 0.5, -11)
    minB.BackgroundColor3 = Color3.fromRGB(60,62,72); minB.Text = "_"
    minB.TextColor3 = Color3.fromRGB(255,255,255); minB.Font = Enum.Font.GothamBold; minB.TextSize = 11
    minB.Parent = tbar; Instance.new("UICorner", minB).CornerRadius = UDim.new(0, 4)
    local closeB = Instance.new("TextButton")
    closeB.Size = UDim2.new(0, 24, 0, 22); closeB.Position = UDim2.new(1, -28, 0.5, -11)
    closeB.BackgroundColor3 = Color3.fromRGB(200,60,60); closeB.Text = "X"
    closeB.TextColor3 = Color3.fromRGB(255,255,255); closeB.Font = Enum.Font.GothamBold; closeB.TextSize = 11
    closeB.Parent = tbar; Instance.new("UICorner", closeB).CornerRadius = UDim.new(0, 4)
    -- 内容 (滚动)
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -12, 1, -36); content.Position = UDim2.new(0, 6, 0, 32)
    content.BackgroundTransparency = 1; content.ScrollBarThickness = 3
    content.CanvasSize = UDim2.new(0,0,0,0); content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.Parent = win
    local cl = Instance.new("UIListLayout", content)
    cl.Padding = UDim.new(0, 4); cl.SortOrder = Enum.SortOrder.LayoutOrder
    -- 同步开关 (绑定Config, 实时同步主UI)
    local function MakeMiniToggle(text, getConfig, setConfig)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 32); row.BackgroundColor3 = Color3.fromRGB(34,36,46)
        row.Parent = content; Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -50, 1, 0); lbl.Position = UDim2.new(0, 8, 0, 0)
        lbl.BackgroundTransparency = 1; lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(230,230,230); lbl.Font = Enum.Font.Gotham; lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row
        local track = Instance.new("Frame")
        track.Size = UDim2.new(0, 40, 0, 20); track.Position = UDim2.new(1, -46, 0.5, -10)
        track.BackgroundColor3 = getConfig() and Color3.fromRGB(120,80,255) or Color3.fromRGB(70,70,80)
        track.BorderSizePixel = 0; track.Parent = row
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
        local thumb = Instance.new("Frame")
        thumb.Size = UDim2.new(0, 16, 0, 16)
        thumb.Position = getConfig() and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        thumb.BackgroundColor3 = Color3.fromRGB(255,255,255); thumb.BorderSizePixel = 0; thumb.Parent = track
        Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
        -- 实时同步: 检查Config变化
        task.spawn(function()
            while row.Parent do
                local cur = getConfig()
                track.BackgroundColor3 = cur and Color3.fromRGB(120,80,255) or Color3.fromRGB(70,70,80)
                thumb.Position = cur and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                task.wait(0.3)
            end
        end)
        row.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                setConfig(not getConfig())
            end
        end)
    end
    MakeMiniToggle("总开关", function() return Config.CombatEnabled end, function(v)
        Config.CombatEnabled = v
        if not v then Combat.Target = nil end
    end)
    MakeMiniToggle("自动面朝", function() return Config.CombatFaceTarget end, function(v)
        Config.CombatFaceTarget = v
        if not v then Combat.Target = nil end
    end)
    MakeMiniToggle("强制面朝", function() return Config.CombatForceFace end, function(v) Config.CombatForceFace = v end)
    MakeMiniToggle("视角锁定", function() return Config.CombatLockView end, function(v) Config.CombatLockView = v end)
    MakeMiniToggle("预判", function() return Config.CombatPredict end, function(v) Config.CombatPredict = v end)
    -- 最小化
    local minimized = false
    minB.MouseButton1Click:Connect(function()
        minimized = not minimized
        content.Visible = not minimized
        if minimized then win.Size = UDim2.new(0, 220, 0, 32)
        else win.Size = UDim2.new(0, 220, 0, 240) end
    end)
    closeB.MouseButton1Click:Connect(function()
        Config.CombatMiniUI = false
        sg:Destroy()
    end)
    -- 拖拽
    local dragging, dragStart, startPos = false, nil, nil
    tbar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = win.Position
        end
    end)
    tbar.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    CombatMiniUI = sg
end
function CloseCombatMiniUI()
    if CombatMiniUI then pcall(function() CombatMiniUI:Destroy() end); CombatMiniUI = nil end
end

-- ============== 检测/修改页 ==============
do local WpnPage = AddNav("检测/修改", "weapon")
MakeLabel(WpnPage, "== 枪械检测/修改 ==")
MakeButton(WpnPage, "枪械检测/修改 (点击启动专属界面)", function()
    OpenWeaponWindow()
end)
end

-- ============== 格斗适用页 ==============
do
local CmbPage = AddNav("格斗适用", "combat")
MakeLabel(CmbPage, "== 格斗总开关 ==")
MakeToggle(CmbPage, "格斗功能总开关", false, function(v)
    Config.CombatEnabled = v
    if not v then
        Config.CombatFaceTarget = false; Config.CombatLockView = false
        Combat.Target = nil
        if Combat.LockBox then Combat.LockBox.Visible = false end
        if Combat.Arrow then Combat.Arrow.Visible = false end
    end
    ShowNotification("格斗", v and "总开关已开启" or "总开关已关闭", v and Color3.fromRGB(180,80,255) or Color3.fromRGB(180,180,180))
end)
MakeLabel(CmbPage, "== 自动面朝 ==")
MakeToggle(CmbPage, "自动面朝最近玩家/NPC", false, function(v)
    Config.CombatFaceTarget = v
    if not v then Combat.Target = nil end
    ShowNotification("自动面朝", v and "已开启" or "已关闭", v and Color3.fromRGB(180,80,255) or Color3.fromRGB(180,180,180))
end)
MakeButton(CmbPage, "设置面朝快捷键 (默认F1)", function()
    ShowNotification("提示", "请在3秒内按下任意键设置快捷键", Color3.fromRGB(255,200,80))
    task.delay(3, function()
        local setting = true
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp or not setting then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                Config.CombatFaceKey = keyName
                setting = false
                conn:Disconnect()
                ShowNotification("快捷键", "面朝快捷键已设为 " .. keyName, Color3.fromRGB(100,220,180))
            end
        end)
    end)
end)
MakeSlider(CmbPage, "面朝平滑度 (1~100, 越高越灵敏)", 1, 100, 50, 1, function(v) Config.CombatFaceSmooth = v end)
MakeToggle(CmbPage, "强制面朝 (不受测闪/技能影响)", false, function(v)
    Config.CombatForceFace = v
    ShowNotification("强制面朝", v and "已开启" or "已关闭", v and Color3.fromRGB(180,80,255) or Color3.fromRGB(180,180,180))
end)
MakeLabel(CmbPage, "== 视角锁定 ==")
MakeToggle(CmbPage, "视角锁定 (锁定到目标)", false, function(v)
    Config.CombatLockView = v
    ShowNotification("视角锁定", v and "已开启" or "已关闭", v and Color3.fromRGB(180,80,255) or Color3.fromRGB(180,180,180))
end)
MakeSlider(CmbPage, "视角锁定平滑度 (1~100)", 1, 100, 50, 1, function(v) Config.CombatLockSmooth = v end)
MakeLabel(CmbPage, "== 预判功能 ==")
MakeToggle(CmbPage, "预判打击 (需开启视角锁定)", false, function(v)
    Config.CombatPredict = v
    ShowNotification("预判", v and "已开启" or "已关闭", v and Color3.fromRGB(180,80,255) or Color3.fromRGB(180,180,180))
end)
MakeSlider(CmbPage, "预判百分比 (0~100, 100=完美)", 0, 100, 80, 1, function(v) Config.CombatPredictPercent = v end)
MakeSlider(CmbPage, "子弹速度 (50~2000, 远程武器预判用)", 50, 2000, 500, 10, function(v) Config.CombatBulletSpeed = v end)
MakeLabel(CmbPage, "== 锁定目标 ==")
-- 锁定模式切换按钮 (前向声明+单独Connect, 避免自引用问题)
do
local lockModeBtn = Instance.new("TextButton")
lockModeBtn.Size = UDim2.new(1, 0, 0, 36)
lockModeBtn.BackgroundColor3 = Color3.fromRGB(60, 90, 160)
lockModeBtn.Text = "锁定模式: 全部 (点击切换)"
lockModeBtn.TextColor3 = Color3.fromRGB(255,255,255)
lockModeBtn.Font = Enum.Font.GothamBold
lockModeBtn.TextSize = 13
lockModeBtn.Parent = CmbPage
Instance.new("UICorner", lockModeBtn).CornerRadius = UDim.new(0, 8)
lockModeBtn.MouseButton1Click:Connect(function()
    pcall(function()
        Config.CombatLockMode = ((Config.CombatLockMode or 1) % 3) + 1
        local modeNames = {[1]="全部", [2]="仅玩家", [3]="仅NPC"}
        if Combat then Combat.Target = nil end
        local newName = modeNames[Config.CombatLockMode] or "未知"
        lockModeBtn.Text = "锁定模式: " .. newName .. " (点击切换)"
        ShowNotification("锁定模式", "已切换为: " .. newName, Color3.fromRGB(100,220,180))
    end)
end)
-- 锁定部位切换按钮 (前向声明+单独Connect, 避免自引用问题)
local lockPartBtn = Instance.new("TextButton")
lockPartBtn.Size = UDim2.new(1, 0, 0, 36)
lockPartBtn.BackgroundColor3 = Color3.fromRGB(60, 90, 160)
lockPartBtn.Text = "锁定部位: 身体 (点击切换)"
lockPartBtn.TextColor3 = Color3.fromRGB(255,255,255)
lockPartBtn.Font = Enum.Font.GothamBold
lockPartBtn.TextSize = 13
lockPartBtn.Parent = CmbPage
Instance.new("UICorner", lockPartBtn).CornerRadius = UDim.new(0, 8)
lockPartBtn.MouseButton1Click:Connect(function()
    pcall(function()
        Config.CombatLockPart = ((Config.CombatLockPart or 1) % 2) + 1
        local partNames = {[1]="身体", [2]="头部"}
        local newName = partNames[Config.CombatLockPart] or "未知"
        lockPartBtn.Text = "锁定部位: " .. newName .. " (点击切换)"
        ShowNotification("锁定部位", "已切换为: " .. newName, Color3.fromRGB(100,220,180))
    end)
end)
end -- lockModeBtn/lockPartBtn 释放
MakeLabel(CmbPage, "== 锁定显示 ==")
MakeButton(CmbPage, "调节锁定方框颜色", function()
    OpenColorPicker()
end)
MakeLabel(CmbPage, "== 外出UI模式 ==")
MakeToggle(CmbPage, "开启外出UI (小型同步UI)", false, function(v)
    Config.CombatMiniUI = v
    if v then OpenCombatMiniUI() else CloseCombatMiniUI() end
    ShowNotification("外出UI", v and "已开启" or "已关闭", v and Color3.fromRGB(180,80,255) or Color3.fromRGB(180,180,180))
end)
end -- CmbPage 释放

-- ============== 娱乐页 ==============
do
local FunPage = AddNav("娱乐", "fun")
MakeLabel(FunPage, "== 直升机旋转 ==")
MakeLabel(FunPage, "开启后展开双臂快速旋转 + 自动飞行, WASD移动, Q下降E上升")
MakeToggle(FunPage, "直升机旋转", false, function(v)
    Config.HelicopterSpin = v
    ApplyHelicopterSpin()
end)
MakeSlider(FunPage, "旋转速度 (越大转越快)", 1, 50, 18, 1, function(v)
    Config.HelicopterSpinSpeed = v
end)
MakeSlider(FunPage, "飞行速度 (直升机模式)", 0, 500, 50, 0.1, function(v)
    Config.FlySpeed = v
end)

MakeLabel(FunPage, "== 360度无死角旋转 ==")
MakeLabel(FunPage, "人物身体360度旋转, 碰撞体积不变")
MakeToggle(FunPage, "360旋转", false, function(v)
    Config.Spin360 = v
    ApplySpin360()
end)
MakeSlider(FunPage, "360旋转速度", 1, 50, 10, 1, function(v)
    Config.Spin360Speed = v
end)

MakeLabel(FunPage, "== 假布娃娃 ==")
MakeLabel(FunPage, "自然倒地 + 名字跟随 + 可爬行移动 (搞笑拱地)")
MakeToggle(FunPage, "假布娃娃", false, function(v)
    Config.FakeRagdoll = v
    ApplyFakeRagdoll()
end)
end -- FunPage 释放

-- ============== 优化页 (服务器特效简化) ==============
do
local OptPage = AddNav("优化", "optimize")
MakeLabel(OptPage, "== 服务器特效简化 ==")
MakeLabel(OptPage, "说明: 保留特效但大幅降低渲染负担, 慢速分批处理防闪退")
MakeToggle(OptPage, "启用特效简化 (总开关)", false, function(v)
    Config.FXSimplify = v
    if v then
        StartFXSimplify()
        ShowNotification("特效简化", "已开启 (慢速扫描中, 几秒后生效)", Color3.fromRGB(100,220,180))
    else
        local n = StopFXSimplify()
        ShowNotification("特效简化", "已关闭, 还原 " .. n .. " 项", Color3.fromRGB(180,180,180))
    end
end)
MakeToggle(OptPage, "简化粒子发射器", true, function(v)
    Config.FXSimplifyParticles = v
    if not Config.FXSimplify then return end
    FXRestart()
end)
MakeToggle(OptPage, "简化光束 (Beam)", true, function(v)
    Config.FXSimplifyBeams = v
    if not Config.FXSimplify then return end
    FXRestart()
end)
MakeToggle(OptPage, "简化拖尾 (Trail)", true, function(v)
    Config.FXSimplifyTrails = v
    if not Config.FXSimplify then return end
    FXRestart()
end)
MakeToggle(OptPage, "简化贴花 (Decal)", true, function(v)
    Config.FXSimplifyDecals = v
    if not Config.FXSimplify then return end
    FXRestart()
end)
MakeToggle(OptPage, "简化烟雾/火焰", true, function(v)
    Config.FXSimplifySmoke = v
    if not Config.FXSimplify then return end
    FXRestart()
end)
MakeLabel(OptPage, "== 强度调节 ==")
MakeSlider(OptPage, "粒子保留比例 (越小越简化)", 0.01, 1.0, 0.15, 0.01, function(v)
    Config.FXParticleRate = v
end)
MakeSlider(OptPage, "光束透明度 (越大越淡)", 0.0, 0.95, 0.7, 0.05, function(v)
    Config.FXBeamTransparency = v
end)
MakeSlider(OptPage, "拖尾透明度 (越大越淡)", 0.0, 0.95, 0.7, 0.05, function(v)
    Config.FXTrailTransparency = v
end)
MakeSlider(OptPage, "贴花透明度 (越大越淡)", 0.0, 0.95, 0.6, 0.05, function(v)
    Config.FXDecalTransparency = v
end)
MakeLabel(OptPage, "== 处理速度 (越慢越稳) ==")
MakeSlider(OptPage, "每帧处理数量 (1-5, 越小越不易卡)", 1, 5, 2, 1, function(v)
    Config.FXBatchSize = math.floor(v)
end)
MakeSlider(OptPage, "每帧间隔 (秒, 越大越慢)", 0.05, 0.5, 0.1, 0.05, function(v)
    Config.FXBatchInterval = v
end)

-- ====== 超级简化 (彻底优化, 适合低端电脑/重特效游戏) ======
MakeLabel(OptPage, "== 超级简化 (彻底优化, 适合低端电脑) ==")
MakeLabel(OptPage, "说明: 关闭阴影/光照/贴图, 激进简化所有特效, 大幅提升帧率")
MakeButton(OptPage, "一键极致优化 (推荐低端电脑)", function()
    -- 启用全部超级简化选项
    Config.SSRemoveShadows = true
    Config.SSRemoveLighting = true
    Config.SSRemoveTextures = true
    Config.SSReduceMaterials = true
    Config.SSLowerRenderDistance = true
    Config.SSDisablePostEffects = true
    Config.SSAggressiveParticles = true
    Config.SSCullParts = true
    Config.SSRemoveMeshes = false  -- 不开, 防看不到模型
    Config.SuperSimplify = true
    StartSuperSimplify()
    ShowNotification("超级简化", "已开启极致优化 (适合低端电脑)", Color3.fromRGB(255, 100, 100))
end)
MakeButton(OptPage, "一键平衡优化 (保留模型可见)", function()
    -- 平衡: 保留贴图但关阴影/后处理/激进粒子
    Config.SSRemoveShadows = true
    Config.SSRemoveLighting = true
    Config.SSRemoveTextures = false  -- 保留贴图
    Config.SSReduceMaterials = true
    Config.SSLowerRenderDistance = true
    Config.SSDisablePostEffects = true
    Config.SSAggressiveParticles = true
    Config.SSCullParts = true
    Config.SSRemoveMeshes = false
    Config.SuperSimplify = true
    StartSuperSimplify()
    ShowNotification("超级简化", "已开启平衡优化 (保留模型可见)", Color3.fromRGB(255, 200, 80))
end)
MakeToggle(OptPage, "超级简化 (总开关)", false, function(v)
    Config.SuperSimplify = v
    if v then
        StartSuperSimplify()
        ShowNotification("超级简化", "已开启 (慢速扫描中, 几秒后生效)", Color3.fromRGB(255, 100, 100))
    else
        local n = StopSuperSimplify()
        ShowNotification("超级简化", "已关闭, 还原 " .. n .. " 项", Color3.fromRGB(180, 180, 180))
    end
end)
MakeToggle(OptPage, "关闭所有阴影 (CastShadow=false)", true, function(v)
    Config.SSRemoveShadows = v
end)
MakeToggle(OptPage, "简化光照 (关雾/关ColorShift)", true, function(v)
    Config.SSRemoveLighting = v
    if Config.SuperSimplify then
        StopSuperSimplify()
        task.wait(0.3)
        StartSuperSimplify()
    end
end)
MakeToggle(OptPage, "移除贴图 (Texture/Decal透明)", true, function(v)
    Config.SSRemoveTextures = v
end)
MakeToggle(OptPage, "简化材质 (改SmoothPlastic)", true, function(v)
    Config.SSReduceMaterials = v
end)
MakeToggle(OptPage, "降低画质等级 (Level01)", true, function(v)
    Config.SSLowerRenderDistance = v
    if Config.SuperSimplify then
        StopSuperSimplify()
        task.wait(0.3)
        StartSuperSimplify()
    end
end)
MakeToggle(OptPage, "关闭后处理 (Bloom/景深等)", true, function(v)
    Config.SSDisablePostEffects = v
    if Config.SuperSimplify then
        StopSuperSimplify()
        task.wait(0.3)
        StartSuperSimplify()
    end
end)
MakeToggle(OptPage, "激进简化粒子 (Rate=0)", true, function(v)
    Config.SSAggressiveParticles = v
end)
MakeToggle(OptPage, "简化远距离部件", true, function(v)
    Config.SSCullParts = v
end)
MakeToggle(OptPage, "移除SpecialMesh (谨慎, 可能看不见模型)", false, function(v)
    Config.SSRemoveMeshes = v
end)
end -- OptPage 释放

-- ============== 设置页 ==============
do
local SetPage = AddNav("设置", "settings")
MakeLabel(SetPage, "== 通知系统 ==")
MakeToggle(SetPage, "全部通知 (总开关)", true, function(v)
    Config.NotifyEnabled = v
    ShowNotification("通知", v and "通知已开启" or "通知已关闭", Color3.fromRGB(200, 200, 200))
end)

MakeLabel(SetPage, "== 通知模式 ==")
do
local NotifyModeRow = Instance.new("Frame")
NotifyModeRow.Size = UDim2.new(1, 0, 0, 38)
NotifyModeRow.BackgroundColor3 = Color3.fromRGB(34, 36, 46)
NotifyModeRow.Parent = SetPage
Instance.new("UICorner", NotifyModeRow).CornerRadius = UDim.new(0, 8)
local nmLbl = Instance.new("TextLabel")
nmLbl.Size = UDim2.new(0.5, 0, 1, 0); nmLbl.Position = UDim2.new(0, 12, 0, 0)
nmLbl.BackgroundTransparency = 1; nmLbl.Text = "通知模式: 正常"
nmLbl.TextColor3 = Color3.fromRGB(230,230,230); nmLbl.Font = Enum.Font.Gotham; nmLbl.TextSize = 13
nmLbl.TextXAlignment = Enum.TextXAlignment.Left; nmLbl.Parent = NotifyModeRow
local nmBtn = Instance.new("TextButton")
nmBtn.Size = UDim2.new(0, 80, 0, 26); nmBtn.Position = UDim2.new(1, -92, 0.5, -13)
nmBtn.BackgroundColor3 = Color3.fromRGB(70, 110, 180); nmBtn.Text = "切换"
nmBtn.TextColor3 = Color3.fromRGB(255,255,255); nmBtn.Font = Enum.Font.GothamBold; nmBtn.TextSize = 12
nmBtn.Parent = NotifyModeRow; Instance.new("UICorner", nmBtn).CornerRadius = UDim.new(0, 6)
local nmOptions = {{"low","少量"},{"normal","正常"},{"high","大量"}}
local nmIdx = 2
nmBtn.MouseButton1Click:Connect(function()
    nmIdx = (nmIdx % 3) + 1
    Config.NotifyMode = nmOptions[nmIdx][1]
    NotifyCount = 0; NotifyCooldownEnd = 0
    nmLbl.Text = "通知模式: " .. nmOptions[nmIdx][2]
    ShowNotification("通知", "已切换为" .. nmOptions[nmIdx][2] .. "模式", Color3.fromRGB(200, 200, 200))
end)
end -- NotifyModeRow/nmLbl/nmBtn/nmOptions/nmIdx 释放

MakeLabel(SetPage, "== UI 大小 ==")
MakeButton(SetPage, "调节 UI 大小 (点击打开)", function()
    local ScaleGui = Instance.new("ScreenGui")
    ScaleGui.Name = "UH_ScalePopup"
    ScaleGui.ResetOnSpawn = false; ScaleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScaleGui.Parent = CoreGui
    local Backdrop = Instance.new("Frame")
    Backdrop.Size = UDim2.new(1, 0, 1, 0)
    Backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0); Backdrop.BackgroundTransparency = 0.4
    Backdrop.Parent = ScaleGui
    local Popup = Instance.new("Frame")
    Popup.Size = UDim2.new(0, 400, 0, 140)
    Popup.Position = UDim2.new(0.5, -200, 0.5, -70)
    Popup.BackgroundColor3 = Color3.fromRGB(32, 34, 42); Popup.BorderSizePixel = 0
    Popup.Parent = ScaleGui
    Instance.new("UICorner", Popup).CornerRadius = UDim.new(0, 12)
    local pStroke = Instance.new("UIStroke", Popup)
    pStroke.Thickness = 2; pStroke.Color = Color3.fromRGB(80, 170, 230)
    local pTitle = Instance.new("TextLabel")
    pTitle.Size = UDim2.new(1, -20, 0, 30); pTitle.Position = UDim2.new(0, 10, 0, 8)
    pTitle.BackgroundTransparency = 1; pTitle.Text = "UI 缩放调节"
    pTitle.TextColor3 = Color3.fromRGB(255, 255, 255); pTitle.Font = Enum.Font.GothamBold; pTitle.TextSize = 15
    pTitle.TextXAlignment = Enum.TextXAlignment.Left; pTitle.Parent = Popup
    local pLbl = Instance.new("TextLabel")
    pLbl.Size = UDim2.new(1, -20, 0, 20); pLbl.Position = UDim2.new(0, 10, 0, 42)
    pLbl.BackgroundTransparency = 1; pLbl.Text = "缩放: " .. string.format("%.1f", Config.UIScale)
    pLbl.TextColor3 = Color3.fromRGB(230, 230, 230); pLbl.Font = Enum.Font.Gotham; pLbl.TextSize = 13
    pLbl.TextXAlignment = Enum.TextXAlignment.Left; pLbl.Parent = Popup
    local pSlider = Instance.new("TextButton")
    pSlider.Size = UDim2.new(1, -20, 0, 18); pSlider.Position = UDim2.new(0, 10, 0, 68)
    pSlider.BackgroundColor3 = Color3.fromRGB(50, 52, 62); pSlider.Text = ""; pSlider.AutoButtonColor = false
    pSlider.Parent = Popup
    Instance.new("UICorner", pSlider).CornerRadius = UDim.new(0, 4)
    local pFill = Instance.new("Frame")
    pFill.Size = UDim2.new((Config.UIScale - 0.5) / 1.5, 0, 1, 0)
    pFill.BackgroundColor3 = Color3.fromRGB(80, 170, 230); pFill.BorderSizePixel = 0
    pFill.Parent = pSlider
    Instance.new("UICorner", pFill).CornerRadius = UDim.new(0, 4)
    local pClose = Instance.new("TextButton")
    pClose.Size = UDim2.new(0, 80, 0, 28); pClose.Position = UDim2.new(1, -90, 1, -38)
    pClose.BackgroundColor3 = Color3.fromRGB(200, 60, 60); pClose.Text = "关闭"
    pClose.TextColor3 = Color3.fromRGB(255, 255, 255); pClose.Font = Enum.Font.GothamBold; pClose.TextSize = 13
    pClose.Parent = Popup
    Instance.new("UICorner", pClose).CornerRadius = UDim.new(0, 6)
    local pDragging = false
    local function pUpdate(x)
        local rel = math.clamp((x - pSlider.AbsolutePosition.X) / pSlider.AbsoluteSize.X, 0, 1)
        local val = 0.5 + 1.5 * rel
        val = math.floor(val * 10 + 0.5) / 10
        val = math.clamp(val, 0.5, 2.0)
        pFill.Size = UDim2.new(rel, 0, 1, 0)
        pLbl.Text = "缩放: " .. string.format("%.1f", val)
        Config.UIScale = val; UIScale.Scale = val
    end
    pSlider.MouseButton1Down:Connect(function() pDragging = true end)
    pSlider.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then pDragging = true; pUpdate(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then pDragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if pDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then pUpdate(i.Position.X) end
    end)
    pClose.MouseButton1Click:Connect(function() ScaleGui:Destroy() end)
    Backdrop.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then ScaleGui:Destroy() end
    end)
end)

MakeLabel(SetPage, "== 其他 ==")
MakeButton(SetPage, "关闭所有功能", function()
    Config.PlayerESP=false; Config.WallXray=false; Config.WallDetail=false; Config.NightVision=false
    Config.NPCESP=false; Config.SpeedEnabled=false; Config.JumpEnabled=false; Config.FlyEnabled=false
    Config.TeleWalk=false; Config.Noclip=false; Config.FastInteract=false; Config.InteractESP=false; Config.AutoRefresh=false
    Config.AutoInteract=false; Config.PureAutoInteract=false; Config.AutoModify=false; Config.AutoModifyMode=1
    Config.HelicopterSpin=false; Config.Spin360=false; Config.FakeRagdoll=false
    Config.WallAutoRefresh=false; Config.InfiniteJump=false; Config.FloatMode=false; Config.GhostMode=false; Config.NPCKill=false
    ClearAllPlayerESP(); ClearAllNPCESP(); ClearInteractESP(); RestoreWallXray()
    if Xray.Conn then Xray.Conn:Disconnect(); Xray.Conn=nil end
    Xray.RefreshConn = nil
    pcall(StopAutoInteract); pcall(StopAutoDetect); pcall(StopPureAutoInteract); pcall(StopAutoModify)
    Config.HelicopterSpin=false; Config.Spin360=false; Config.FakeRagdoll=false
    pcall(ApplyHelicopterSpin); pcall(ApplySpin360); pcall(ApplyFakeRagdoll)
    ApplyNightVision(); ApplySpeed(); ApplyJump(); ApplyFly(); ApplyTeleWalk(); ApplyNoclip(); ApplyFastInteract()
    ApplyInfiniteJump(); ApplyFloat(); ApplyGhostMode()
    ShowNotification("设置", "已关闭所有功能", Color3.fromRGB(255, 100, 100))
end)

MakeButton(SetPage, "销毁 UI (彻底关闭)", function()
    local ConfirmGui = Instance.new("ScreenGui")
    ConfirmGui.Name = "UH_ConfirmDialog"
    ConfirmGui.ResetOnSpawn = false; ConfirmGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ConfirmGui.Parent = CoreGui
    local Backdrop = Instance.new("Frame")
    Backdrop.Size = UDim2.new(1, 0, 1, 0)
    Backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0); Backdrop.BackgroundTransparency = 0.5
    Backdrop.Parent = ConfirmGui
    local Dialog = Instance.new("Frame")
    Dialog.Size = UDim2.new(0, 360, 0, 180)
    Dialog.Position = UDim2.new(0.5, -180, 0.5, -90)
    Dialog.BackgroundColor3 = Color3.fromRGB(32, 34, 42); Dialog.BorderSizePixel = 0
    Dialog.Parent = ConfirmGui
    Instance.new("UICorner", Dialog).CornerRadius = UDim.new(0, 12)
    local dStroke = Instance.new("UIStroke", Dialog)
    dStroke.Thickness = 2; dStroke.Color = Color3.fromRGB(200, 60, 60)
    local dTitle = Instance.new("TextLabel")
    dTitle.Size = UDim2.new(1, -20, 0, 30); dTitle.Position = UDim2.new(0, 10, 0, 10)
    dTitle.BackgroundTransparency = 1; dTitle.Text = "警告"
    dTitle.TextColor3 = Color3.fromRGB(255, 80, 80); dTitle.Font = Enum.Font.GothamBold; dTitle.TextSize = 18
    dTitle.Parent = Dialog
    local dMsg = Instance.new("TextLabel")
    dMsg.Size = UDim2.new(1, -20, 0, 60); dMsg.Position = UDim2.new(0, 10, 0, 45)
    dMsg.BackgroundTransparency = 1
    dMsg.Text = "确定要销毁 UI 吗?\n所有功能将关闭并恢复到原始状态,\nUI 将被彻底删除。"
    dMsg.TextColor3 = Color3.fromRGB(220, 220, 220); dMsg.Font = Enum.Font.Gotham; dMsg.TextSize = 13
    dMsg.TextWrapped = true; dMsg.Parent = Dialog
    local dYes = Instance.new("TextButton")
    dYes.Size = UDim2.new(0, 100, 0, 32); dYes.Position = UDim2.new(0.25, -50, 1, -50)
    dYes.BackgroundColor3 = Color3.fromRGB(200, 60, 60); dYes.Text = "确定销毁"
    dYes.TextColor3 = Color3.fromRGB(255, 255, 255); dYes.Font = Enum.Font.GothamBold; dYes.TextSize = 13
    dYes.Parent = Dialog; Instance.new("UICorner", dYes).CornerRadius = UDim.new(0, 6)
    local dNo = Instance.new("TextButton")
    dNo.Size = UDim2.new(0, 100, 0, 32); dNo.Position = UDim2.new(0.75, -50, 1, -50)
    dNo.BackgroundColor3 = Color3.fromRGB(60, 60, 70); dNo.Text = "取消"
    dNo.TextColor3 = Color3.fromRGB(255, 255, 255); dNo.Font = Enum.Font.GothamBold; dNo.TextSize = 13
    dNo.Parent = Dialog; Instance.new("UICorner", dNo).CornerRadius = UDim.new(0, 6)
    dNo.MouseButton1Click:Connect(function() ConfirmGui:Destroy() end)
    dYes.MouseButton1Click:Connect(function()
        ConfirmGui:Destroy()
        Config.PlayerESP=false; Config.WallXray=false; Config.WallDetail=false; Config.NightVision=false
        Config.NPCESP=false; Config.SpeedEnabled=false; Config.JumpEnabled=false; Config.FlyEnabled=false
        Config.TeleWalk=false; Config.Noclip=false; Config.FastInteract=false; Config.InteractESP=false
        Config.AutoRefresh=false; Config.WallAutoRefresh=false; Config.InfiniteJump=false
        Config.FloatMode=false; Config.GhostMode=false; Config.NPCKill=false
        if Move.SpeedConn then Move.SpeedConn=nil end
        if Move.JumpConn then Move.JumpConn=nil end
        if Move.FlyConn then Move.FlyConn:Disconnect(); Move.FlyConn=nil end
        if Move.TeleConn then Move.TeleConn:Disconnect(); Move.TeleConn=nil end
        if Saved.FloatConn then Saved.FloatConn:Disconnect(); Saved.FloatConn=nil end
        if NoclipConn then NoclipConn:Disconnect(); NoclipConn=nil end
        if NoclipCleanupConn then NoclipCleanupConn:Disconnect(); NoclipCleanupConn=nil end
        if NoclipChildAddedConn then NoclipChildAddedConn:Disconnect(); NoclipChildAddedConn=nil end
        if Saved.JumpConn then Saved.JumpConn:Disconnect(); Saved.JumpConn=nil end
        if Ghost.Conn then Ghost.Conn:Disconnect(); Ghost.Conn=nil end
        if Ghost.CamConn then Ghost.CamConn:Disconnect(); Ghost.CamConn=nil end
        if Ghost.FreezeConn then Ghost.FreezeConn:Disconnect(); Ghost.FreezeConn=nil end
        if Ghost.OriginalMouseBehavior then
            UserInputService.MouseBehavior = Ghost.OriginalMouseBehavior
            Ghost.OriginalMouseBehavior = nil
        end
        StopCacheListeners()
        if Interact.ChildAddedConn then Interact.ChildAddedConn:Disconnect(); Interact.ChildAddedConn=nil end
        if Interact.ChildRemovedConn then Interact.ChildRemovedConn:Disconnect(); Interact.ChildRemovedConn=nil end
        if Xray.Conn then Xray.Conn:Disconnect(); Xray.Conn=nil end
        Xray.RefreshConn = nil
        ClearAllPlayerESP(); ClearAllNPCESP(); ClearInteractESP(); RestoreWallXray()
        -- 关闭特效简化/超级简化 (还原所有修改)
        pcall(StopFXSimplify)
        pcall(StopSuperSimplify)
        -- 关闭自动互动/自动检测/纯自动互动/自动修改
        pcall(StopAutoInteract)
        pcall(StopAutoDetect)
        pcall(StopPureAutoInteract)
        pcall(StopAutoModify)
        -- 关闭娱乐功能
        Config.HelicopterSpin=false; Config.Spin360=false; Config.FakeRagdoll=false
        pcall(ApplyHelicopterSpin); pcall(ApplySpin360); pcall(ApplyFakeRagdoll)
        ApplyNightVision()
        local hum = GetHum()
        if hum then
            if Saved.WalkSpeed then hum.WalkSpeed = Saved.WalkSpeed end
            if Saved.JumpPower then hum.JumpPower = Saved.JumpPower end
        end
        pcall(function() Gui:Destroy() end)
        pcall(function() FloatGui:Destroy() end)
        pcall(function() NotifyGui:Destroy() end)
        pcall(function() if Ghost.StatusGui then Ghost.StatusGui:Destroy() end end)
    end)
end)
end -- SetPage 释放

-- 更新日志页
do
local LogPage = Instance.new("Frame")
LogPage.Size = UDim2.new(1, 0, 0, 0)
LogPage.BackgroundTransparency = 1
LogPage.AutomaticSize = Enum.AutomaticSize.Y
LogPage.Visible = false
LogPage.Parent = Content
local logPL = Instance.new("UIListLayout", LogPage)
logPL.Padding = UDim.new(0, 6); logPL.SortOrder = Enum.SortOrder.LayoutOrder
Pages["log"] = LogPage

local LogText = Instance.new("TextLabel")
LogText.Size = UDim2.new(1, 0, 0, 0)
LogText.AutomaticSize = Enum.AutomaticSize.Y
LogText.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
LogText.TextColor3 = Color3.fromRGB(200, 210, 220)
LogText.Font = Enum.Font.Code; LogText.TextSize = 12
LogText.TextXAlignment = Enum.TextXAlignment.Left; LogText.TextYAlignment = Enum.TextYAlignment.Top
LogText.Text = [[
====== 更新日志 ======

[v3.4]
- 修复: end)ShowNotification 语法错误导致脚本无法加载
- 修复: 通知系统 ttl.Size 赋值错误 (应为 msg.Size)
- 修复: 通知堆叠失效 (改用绝对Y定位 + RepositionNotifs)
- NPC透视: 慢速逐个处理 (每0.1秒处理1个, 不卡顿)
- NPC透视: 新增中文翻译表 (100+ NPC名称翻译为简体中文)
- NPC透视: 新增"显示名称"和"显示距离"开关按钮
- NPC透视: 距离更新频率降低至1.5秒 (减少卡顿)
- 玩家ESP: 从Heartbeat改为0.3秒定时更新 (大幅减少卡顿)
- 墙体透视定时刷新: 修复刷新后颜色丢失问题
- 优化: 全局 _G 键名改为 UH_V34 避免冲突
- 优化: 清理所有重复/冗余代码

[v3.3]
- 新增NPC功能独立导航页
- NPC击杀: 范围内自动击杀NPC
- 互动透视: 缓存机制, 事件驱动
- 无限跳跃, 悬浮模式, 幽灵模式

[v3.1]
- 墙体透视定时刷新, 通知X条后冷却
- 飞行防坠落, 穿墙脚底碰撞修复
]]
LogText.Parent = LogPage
local lc = Instance.new("UIPadding", LogText)
lc.PaddingLeft = UDim.new(0, 10); lc.PaddingTop = UDim.new(0, 8)
end -- LogPage/logPL/LogText/lc 局部变量释放

task.wait()

NavButtons[1].BackgroundColor3 = Color3.fromRGB(70, 110, 180)

function UpdateGhostToggleUI()
    if GhostToggle then
        local track = GhostToggle:FindFirstChildOfClass("Frame")
        local thumb = track and track:FindFirstChildOfClass("Frame")
        if track and thumb then
            if Config.GhostMode then
                track.BackgroundColor3 = Color3.fromRGB(60, 180, 100)
                thumb.Position = UDim2.new(1, -24, 0.5, -11)
            else
                track.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
                thumb.Position = UDim2.new(0, 2, 0.5, -11)
            end
        end
    end
end

LogBtn.MouseButton1Click:Connect(function()
    for n, p in pairs(Pages) do p.Visible = (n == "log") end
    for _, b in ipairs(NavButtons) do b.BackgroundColor3 = Color3.fromRGB(40, 42, 52) end
end)

-- 悬浮窗
local FloatGui = Instance.new("ScreenGui")
FloatGui.Name = "UH_FloatBallV34"
FloatGui.ResetOnSpawn = false; FloatGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
FloatGui.Parent = CoreGui

local FB_SIZE = 64
local FloatBall = Instance.new("TextButton")
FloatBall.Size = UDim2.new(0, FB_SIZE, 0, FB_SIZE)
FloatBall.Position = LoadFloatPos()
FloatBall.BackgroundColor3 = Color3.fromRGB(70, 110, 180)
FloatBall.Text = "辅"; FloatBall.TextColor3 = Color3.fromRGB(255,255,255)
FloatBall.Font = Enum.Font.GothamBold; FloatBall.TextSize = 24
FloatBall.Visible = false; FloatBall.Active = true
FloatBall.Parent = FloatGui
Instance.new("UICorner", FloatBall).CornerRadius = UDim.new(1, 0)

do local fStroke = Instance.new("UIStroke", FloatBall)
fStroke.Thickness = 3
local fGrad = Instance.new("UIGradient", fStroke)
fGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,    Color3.fromRGB(255, 80, 80)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(80, 255, 120)),
    ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(80, 150, 255)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 80, 180)),
    ColorSequenceKeypoint.new(1,    Color3.fromRGB(255, 80, 80)),
})
task.spawn(function()
    local off = 0
    while FloatBall and FloatBall.Parent do
        off = off + 0.01
        if off > 1 then off = off - 1 end
        fGrad.Offset = Vector2.new(off, 0)
        -- 降频: 0.05秒更新一次, 视觉无差异但减少CPU占用
        task.wait(0.05)
    end
end)
end -- fStroke/fGrad 局部变量释放

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(Main, TweenInfo.new(0.25), {Size = UDim2.new(0, BASE_W, 0, TITLE_H)}):Play()
    else
        TweenService:Create(Main, TweenInfo.new(0.25), {Size = UDim2.new(0, BASE_W, 0, BASE_H)}):Play()
    end
end)

local UISavedPos = nil

local function CloseToFloat()
    UISavedPos = Main.Position
    local centerX = Camera.ViewportSize.X / 2 - (BASE_W * Config.UIScale) / 2
    local centerY = Camera.ViewportSize.Y / 2 - (BASE_H * Config.UIScale) / 2
    local tw1 = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(0, centerX, 0, centerY),
        Size = UDim2.new(0, 0, 0, 0)
    })
    tw1:Play()
    tw1.Completed:Connect(function()
        Main.Visible = false
        FloatBall.Visible = true
        FloatBall.Size = UDim2.new(0, 0, 0, 0)
        local savedFloat = LoadFloatPos()
        FloatBall.Position = UDim2.new(0, savedFloat.X.Offset, 0, savedFloat.Y.Offset)
        TweenService:Create(FloatBall, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, FB_SIZE, 0, FB_SIZE)
        }):Play()
    end)
end

local function OpenFromFloat()
    local centerX = Camera.ViewportSize.X / 2 - (BASE_W * Config.UIScale) / 2
    local centerY = Camera.ViewportSize.Y / 2 - (BASE_H * Config.UIScale) / 2
    SaveFloatPos(FloatBall.Position)
    FloatBall.Visible = false
    Main.Visible = true
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main.Position = UDim2.new(0, centerX + (BASE_W*Config.UIScale)/2, 0, centerY + (BASE_H*Config.UIScale)/2)
    local targetPos = UISavedPos or LoadUIPos()
    local tw = TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, BASE_W, 0, BASE_H),
        Position = targetPos
    })
    tw:Play()
    UISavedPos = nil
end

CloseBtn.MouseButton1Click:Connect(CloseToFloat)

local fbDrag, fbMoved, fbStart, fbPos = false, false, nil, nil
FloatBall.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        fbDrag = true; fbMoved = false; fbStart = i.Position; fbPos = FloatBall.Position
    end
end)
FloatBall.InputChanged:Connect(function(i)
    if fbDrag and fbStart and fbPos and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - fbStart
        if delta.Magnitude > 5 then fbMoved = true end
        -- 检查 FloatBall 仍有效
        local alive = false
        pcall(function() alive = FloatBall ~= nil and FloatBall.Parent ~= nil end)
        if alive then
            FloatBall.Position = UDim2.new(0, fbPos.X.Offset + delta.X, 0, fbPos.Y.Offset + delta.Y)
        end
    end
end)
FloatBall.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        fbDrag = false; fbStart = nil
        -- 检查 FloatBall 仍有效
        local alive = false
        pcall(function() alive = FloatBall ~= nil and FloatBall.Parent ~= nil end)
        if alive then
            if fbMoved then SaveFloatPos(FloatBall.Position) else OpenFromFloat() end
        end
    end
end)

local dragging, dragStart, startPos = false, nil, nil
TitleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = i.Position; startPos = Main.Position
    end
end)
TitleBar.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = false; dragStart = nil
        if Main and Main.Parent then SaveUIPos(Main.Position) end
    end
end)
UserInputService.InputChanged:Connect(function(i)
    -- 检查 dragging/dragStart/startPos 都有效, 防止 nil 算术报错
    if dragging and dragStart and startPos
       and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        -- 检查 Main 仍有效 (防止 GUI 销毁后访问抛错)
        local mainAlive = false
        pcall(function() mainAlive = Main ~= nil and Main.Parent ~= nil end)
        if mainAlive then
            local delta = i.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                        startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    -- 每个调用用 pcall 隔离, 防止某一个报错中断后续恢复
    if Config.SpeedEnabled then pcall(ApplySpeed) end
    if Config.JumpEnabled then pcall(ApplyJump) end
    if Config.FlyEnabled then pcall(ApplyFly) end
    if Config.TeleWalk then pcall(ApplyTeleWalk) end
    if Config.Noclip then pcall(ApplyNoclip) end
    if Config.InfiniteJump then pcall(ApplyInfiniteJump) end
    if Config.FloatMode then pcall(ApplyFloat) end
    if Config.GhostMode then pcall(ApplyGhostMode) end
    if Config.HelicopterSpin then pcall(ApplyHelicopterSpin) end
    if Config.Spin360 then pcall(ApplySpin360) end
    if Config.FakeRagdoll then pcall(ApplyFakeRagdoll) end
end)

-- ============== 枪械检测/修改系统 ==============
Weapon = {  -- 赋值给前面前向声明的 local Weapon
    Detected = false, Tool = nil, Name = "",
    Ammo = nil, MaxAmmo = nil, Reserve = nil, MaxReserve = nil,
    FireRate = nil, ReloadTime = nil, Auto = nil,
    Values = {},  -- 原始值缓存
    Gui = nil, LastCheck = 0,
    Frozen = {},  -- 冻结数值表 (key=属性对象, value=冻结目标值)
}

-- 检测武器 (可传tool参数直接检测指定武器, 不传则检测手持武器)
-- 递归搜索Value对象 + Attributes + 属性, 兼容各种枪械系统
DetectWeapon = function(toolOverride)  -- 赋值给前向声明的 local DetectWeapon
    Weapon.Detected = false; Weapon.Tool = nil; Weapon.Name = ""
    Weapon.Ammo = nil; Weapon.MaxAmmo = nil; Weapon.Reserve = nil; Weapon.MaxReserve = nil
    Weapon.FireRate = nil; Weapon.ReloadTime = nil; Weapon.Auto = nil
    Weapon.Values = {}
    local tool = toolOverride
    if not tool then
        local char = LocalPlayer.Character
        if not char then return end
        tool = char:FindFirstChildOfClass("Tool")
    end
    if not tool or not tool:IsA("Tool") then return end
    Weapon.Tool = tool
    Weapon.Name = tool.Name
    Weapon.Detected = true

    -- 属性同义词表 (大幅扩充, 覆盖主流FPS框架: ACS, FE Gun Kit, CAS, ACS2, Custom等)
    local ammoNames = {"Ammo","ammo","CurrentAmmo","Magazine","Clip","Mag","AmmoInMag","BulletCount","MagAmmo","LoadedAmmo","Rounds","Chambered"}
    local maxAmmoNames = {"MaxAmmo","maxAmmo","MagSize","MagazineSize","MaxMag","MaxClip","MagCapacity","ClipSize","MaxMagazine","MagMax","Capacity"}
    local reserveNames = {"Reserve","reserve","BackupAmmo","StoredAmmo","TotalAmmo","AmmoReserve","ReserveAmmo","SpareAmmo","ExtraAmmo","Backup"}
    local maxReserveNames = {"MaxReserve","maxReserve","MaxBackup","MaxStored","MaxTotal","MaxReserveAmmo","MaxSpare"}
    local fireRateNames = {"FireRate","FireDelay","fireRate","Cooldown","ShootCooldown","AttackSpeed","FireCooldown","Delay","ShotDelay","FireInterval","RateOfFire"}
    local reloadNames = {"ReloadTime","reloadTime","ReloadDuration","Reload","ReloadSpeed","ReloadLength"}
    local autoNames = {"Automatic","Auto","IsAutomatic","FullAuto","automatic","AutoFire","IsAuto","FullAutoMode"}

    -- 检测 Roblox Instance Attributes (很多新游戏用SetAttribute)
    local attrCache = nil
    local function getAttr(name)
        if attrCache == nil then
            local ok, t = pcall(function() return tool:GetAttributes() end)
            attrCache = ok and t or {}
        end
        return attrCache[name]
    end
    -- 统一查找: Value对象 > Attributes > Tool属性
    -- 返回: obj(ValueBase或nil), val(当前值或nil), kind("value"/"attr"/"prop"/nil), key(属性名或nil)
    local function findVal(names, isBool)
        -- 1. ValueBase对象 (递归搜索子文件夹)
        for _, n in ipairs(names) do
            local child = tool:FindFirstChild(n, true)
            if child then
                if isBool and child:IsA("BoolValue") then return child, child.Value, "value", n end
                if not isBool and (child:IsA("IntValue") or child:IsA("NumberValue")) then return child, child.Value, "value", n end
            end
        end
        -- 2. Attributes
        for _, n in ipairs(names) do
            local v = getAttr(n)
            if v ~= nil then
                if isBool and type(v) == "boolean" then return nil, v, "attr", n end
                if not isBool and type(v) == "number" then return nil, v, "attr", n end
            end
        end
        -- 3. Tool属性
        for _, n in ipairs(names) do
            local ok, v = pcall(function() return tool[n] end)
            if ok and v ~= nil then
                if isBool and type(v) == "boolean" then return nil, v, "prop", n end
                if not isBool and type(v) == "number" then return nil, v, "prop", n end
            end
        end
        return nil, nil, nil, nil
    end

    local aObj, aVal, aKind, aKey = findVal(ammoNames, false)
    Weapon.Ammo = aObj; Weapon.Values.Ammo = aVal; Weapon.AmmoKind = aKind; Weapon.AmmoKey = aKey
    local maObj, maVal, maKind, maKey = findVal(maxAmmoNames, false)
    Weapon.MaxAmmo = maObj; Weapon.Values.MaxAmmo = maVal; Weapon.MaxAmmoKind = maKind; Weapon.MaxAmmoKey = maKey
    local rObj, rVal, rKind, rKey = findVal(reserveNames, false)
    Weapon.Reserve = rObj; Weapon.Values.Reserve = rVal; Weapon.ReserveKind = rKind; Weapon.ReserveKey = rKey
    local mrObj, mrVal, mrKind, mrKey = findVal(maxReserveNames, false)
    Weapon.MaxReserve = mrObj; Weapon.Values.MaxReserve = mrVal; Weapon.MaxReserveKind = mrKind; Weapon.MaxReserveKey = mrKey
    local fObj, fVal, fKind, fKey = findVal(fireRateNames, false)
    Weapon.FireRate = fObj; Weapon.Values.FireRate = fVal; Weapon.FireRateKind = fKind; Weapon.FireRateKey = fKey
    local relObj, relVal, relKind, relKey = findVal(reloadNames, false)
    Weapon.ReloadTime = relObj; Weapon.Values.ReloadTime = relVal; Weapon.ReloadTimeKind = relKind; Weapon.ReloadTimeKey = relKey
    local autoObj, autoVal, autoKind, autoKey = findVal(autoNames, true)
    Weapon.Auto = autoObj; Weapon.Values.Auto = autoVal; Weapon.AutoKind = autoKind; Weapon.AutoKey = autoKey
end

-- 读取武器属性当前值 (支持Value对象/Attribute/Property三种类型)
-- field: "Ammo"/"MaxAmmo"/"Reserve"/"MaxReserve"/"FireRate"/"ReloadTime"/"Auto"
local function ReadWeaponField(field)
    local obj = Weapon[field]
    if obj and typeof(obj) == "Instance" then
        if obj:IsA("IntValue") or obj:IsA("NumberValue") then return obj.Value end
        if obj:IsA("BoolValue") then return obj.Value end
    end
    -- attr / prop 路径: 用缓存的Values
    return Weapon.Values and Weapon.Values[field]
end
-- 写入武器属性 (支持Value对象/Attribute/Property三种类型)
local function WriteWeaponField(field, val)
    local obj = Weapon[field]
    if obj and typeof(obj) == "Instance" then
        if obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("BoolValue") then
            obj.Value = val; return true
        end
    end
    local key = Weapon[field.."Key"]
    local kind = Weapon[field.."Kind"]
    if not key or not kind then return false end
    if kind == "attr" then
        pcall(function() Weapon.Tool:SetAttribute(key, val) end)
        return true
    elseif kind == "prop" then
        pcall(function() Weapon.Tool[key] = val end)
        return true
    end
    return false
end

-- 无限子弹: 低于阈值时自动补满
function WeaponInfAmmoTick()
    if not Weapon.Detected then return end
    if not Weapon.Values.Ammo or not Weapon.Values.MaxAmmo then return end
    local maxAmmo = Weapon.Values.MaxAmmo or 0
    if maxAmmo <= 0 then return end
    local curAmmo = ReadWeaponField("Ammo") or 0
    if curAmmo < Config.WeaponInfAmmoThreshold then
        WriteWeaponField("Ammo", maxAmmo)
    end
end

-- 半自动转全自动
local function ApplyAutoFire()
    if not Weapon.Detected then return end
    if Weapon.Values.Auto == nil then return end
    WriteWeaponField("Auto", Config.WeaponAutoFire)
end

-- ============== 格斗系统 (自动面朝+视角锁定+预判) ==============
Combat = {
    Target = nil,  -- 锁定的目标 (Character或Model)
    LockGui = nil, -- 旋转方框GUI
    ArrowGui = nil, -- 屏幕外箭头GUI
    LastTargetPos = nil, -- 上一帧目标位置 (用于速度计算)
    LastTargetTime = 0,
}

-- 获取所有可能的目标 (按锁定模式过滤: 1=全部 2=仅玩家 3=仅NPC)
GetAllTargets = function()
    local list = {}
    local mode = Config.CombatLockMode or 1
    -- 玩家
    if mode == 1 or mode == 2 then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    table.insert(list, {model=p.Character, hrp=hrp, hum=hum, type="Player"})
                end
            end
        end
    end
    -- NPC
    if mode == 1 or mode == 3 then
        for model, _ in pairs(NPC_ESP.ActiveModels or {}) do
            if model and model.Parent then
                local hrp = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    table.insert(list, {model=model, hrp=hrp, hum=hum, type="NPC"})
                end
            end
        end
    end
    return list
end

-- 获取锁定部位 (1=身体 2=头部)
local function GetTargetLockPart(target)
    if not target or not target.model then return target and target.hrp end
    if Config.CombatLockPart == 2 then
        local head = target.model:FindFirstChild("Head")
        if head and head:IsA("BasePart") then return head end
    end
    return target.hrp
end

-- 找最近的目标
local function FindNearestTarget()
    local myHrp = GetHRP()
    if not myHrp then return nil end
    local nearest, nearestDist = nil, math.huge
    for _, t in ipairs(GetAllTargets()) do
        local dist = (myHrp.Position - t.hrp.Position).Magnitude
        if dist < nearestDist then nearestDist = dist; nearest = t end
    end
    return nearest
end

-- 创建旋转方框 + 箭头提示GUI
local function CreateCombatLockUI()
    if Combat.LockGui then return end
    local sg = Instance.new("ScreenGui")
    sg.Name = "CombatLockUI"
    sg.ResetOnSpawn = false; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = CoreGui
    -- 旋转方框 (4条边用Frame模拟, 旋转用Rotation)
    local box = Instance.new("Frame")
    box.Name = "LockBox"
    box.Size = UDim2.new(0, 80, 0, 80)
    box.BackgroundTransparency = 1
    box.Visible = false
    box.Parent = sg
    -- 4条边
    local function makeEdge(size, pos, rot)
        local e = Instance.new("Frame")
        e.Size = size; e.Position = pos; e.Rotation = rot
        e.BackgroundColor3 = Color3.fromRGB(255,255,255)
        e.BorderSizePixel = 0
        e.Parent = box
        return e
    end
    makeEdge(UDim2.new(1,0,0,3), UDim2.new(0,0,0,0), 0)
    makeEdge(UDim2.new(1,0,0,3), UDim2.new(0,0,1,-3), 0)
    makeEdge(UDim2.new(0,3,1,0), UDim2.new(0,0,0,0), 0)
    makeEdge(UDim2.new(0,3,1,0), UDim2.new(1,-3,0,0), 0)
    -- 中心小圆点 (瞄准点)
    local dot = Instance.new("Frame")
    dot.Name = "CenterDot"
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.Position = UDim2.new(0.5, -3, 0.5, -3)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot
    dot.Parent = box
    Combat.LockDot = dot
    Combat.LockBox = box
    -- 屏幕外箭头
    local arrow = Instance.new("Frame")
    arrow.Name = "Arrow"
    arrow.Size = UDim2.new(0, 40, 0, 40)
    arrow.BackgroundTransparency = 1
    arrow.Visible = false
    arrow.Parent = sg
    local arrowLbl = Instance.new("TextLabel")
    arrowLbl.Size = UDim2.new(1,0,1,0); arrowLbl.BackgroundTransparency = 1
    arrowLbl.Text = "▶"; arrowLbl.TextColor3 = Color3.fromRGB(255,255,255)
    arrowLbl.TextSize = 30; arrowLbl.Font = Enum.Font.GothamBold
    arrowLbl.Parent = arrow
    Combat.Arrow = arrow
    Combat.ArrowLabel = arrowLbl
    Combat.LockGui = sg
    -- 旋转动画线程
    task.spawn(function()
        while Combat.LockGui and Combat.LockGui.Parent do
            if Combat.LockBox and Combat.LockBox.Visible then
                Combat.LockBox.Rotation = (Combat.LockBox.Rotation + 2) % 360
            end
            task.wait(0.03)
        end
    end)
end

-- 更新锁定方框颜色
UpdateLockColor = function()
    if Combat.LockBox then
        local c = Color3.fromRGB(Config.CombatLockColorR, Config.CombatLockColorG, Config.CombatLockColorB)
        for _, edge in ipairs(Combat.LockBox:GetChildren()) do
            if edge:IsA("Frame") then edge.BackgroundColor3 = c end
        end
    end
    if Combat.ArrowLabel then
        Combat.ArrowLabel.TextColor3 = Color3.fromRGB(Config.CombatLockColorR, Config.CombatLockColorG, Config.CombatLockColorB)
    end
end

-- 平滑插值 (用于视角锁定平滑度)
local function LerpAngle(a, b, t)
    local diff = (b - a + math.pi) % (math.pi*2) - math.pi
    return a + diff * t
end

-- 格斗主帧函数 (每帧调用)
function CombatFrame()
    if not Config.CombatEnabled then return end
    local myHrp = GetHRP()
    local myHum = GetHum()
    if not myHrp or not myHum then return end
    -- 计算预判位置 (统一函数: 用目标实际速度+距离+子弹速度)
    local function ComputePredictPos(basePos, target)
        if not Config.CombatPredict then return basePos end
        -- 用 AssemblyLinearVelocity 获取目标真实移动速度 (含方向和大小, 比位置差分准确)
        local vel = target.hrp.AssemblyLinearVelocity
        -- 只取水平分量 (Y分量多为跳跃/重力, 不影响水平预判)
        vel = Vector3.new(vel.X, 0, vel.Z)
        if vel.Magnitude < 0.5 then return basePos end  -- 目标几乎静止, 无需预判
        local dist = (myHrp.Position - basePos).Magnitude
        -- 子弹速度: 用配置值 (默认500 stud/s)
        local bulletSpeed = Config.CombatBulletSpeed or 500
        if bulletSpeed < 1 then bulletSpeed = 500 end
        local travelTime = dist / bulletSpeed
        local predictPct = (Config.CombatPredictPercent or 80) / 100
        return basePos + vel * travelTime * predictPct
    end
    -- 自动面朝: 找最近目标并转向
    if Config.CombatFaceTarget or Config.CombatForceFace then
        local target = Combat.Target
        if Config.CombatFaceTarget and not target then
            target = FindNearestTarget()
            if target then Combat.Target = target end
        elseif Config.CombatFaceTarget and target then
            -- 目标失效则重新找
            if not target.model or not target.model.Parent or target.hum.Health <= 0 then
                target = FindNearestTarget()
                Combat.Target = target
            end
        end
        if target and target.hrp and target.hrp.Parent then
            local lockPart = GetTargetLockPart(target)
            local smooth = math.clamp(Config.CombatFaceSmooth, 1, 100) / 100
            local targetPos = ComputePredictPos(lockPart.Position, target)
            local dir = (targetPos - myHrp.Position)
            dir = Vector3.new(dir.X, 0, dir.Z)
            if dir.Magnitude > 0.1 then
                local targetAngle = math.atan2(-dir.X, -dir.Z)
                if Config.CombatForceFace then
                    -- 强制面朝: 直接设置 (不受测闪/技能影响)
                    myHrp.CFrame = CFrame.new(myHrp.Position) * CFrame.Angles(0, targetAngle, 0)
                else
                    -- 平滑面朝
                    local currentAngle = math.atan2(-myHrp.CFrame.LookVector.X, -myHrp.CFrame.LookVector.Z)
                    local newAngle = LerpAngle(currentAngle, targetAngle, smooth)
                    myHrp.CFrame = CFrame.new(myHrp.Position) * CFrame.Angles(0, newAngle, 0)
                end
            end
        end
    end
    -- 视角锁定: 相机锁定到目标方向
    if Config.CombatLockView and Combat.Target and Combat.Target.hrp then
        local target = Combat.Target
        if target.model and target.model.Parent and target.hum.Health > 0 then
            local lockPart = GetTargetLockPart(target)
            local smooth = math.clamp(Config.CombatLockSmooth, 1, 100) / 100
            local camPos = Camera.CFrame.Position
            local targetPos = ComputePredictPos(lockPart.Position, target)
            local dir = (targetPos - camPos)
            if dir.Magnitude > 0.1 then
                local targetCFrame = CFrame.lookAt(camPos, targetPos)
                local currentCFrame = Camera.CFrame
                -- 平滑插值
                local newCFrame = currentCFrame:Lerp(targetCFrame, smooth)
                Camera.CFrame = newCFrame
            end
        end
    end
    -- 锁定方框+箭头显示 (按目标大小自适应方框尺寸, 方框套在敌人身上)
    if Combat.Target and Combat.Target.hrp and Combat.Target.model and Combat.Target.model.Parent
       and Combat.Target.hum.Health > 0 then
        local target = Combat.Target
        local lockPart = GetTargetLockPart(target)
        local screenPos, onScreen = Camera:WorldToViewportPoint(lockPart.Position)
        if Combat.LockBox then
            if onScreen then
                Combat.LockBox.Visible = true
                -- 方框大小+中心点: 按锁定部位分别计算, 让方框准确套在对应部位上
                local headPart = target.model:FindFirstChild("Head")
                local boxSize, centerX, centerY = 80, screenPos.X, screenPos.Y
                if headPart and headPart:IsA("BasePart") then
                    local headSP = Camera:WorldToViewportPoint(headPart.Position)
                    local hrpSP = Camera:WorldToViewportPoint(target.hrp.Position)
                    local span = math.abs(headSP.Y - hrpSP.Y)
                    if Config.CombatLockPart == 2 then
                        -- 头部锁定: 方框较小, 中心在 Head
                        if span > 10 then boxSize = math.clamp(span * 0.6, 30, 100) end
                        centerX, centerY = headSP.X, headSP.Y
                    else
                        -- 身体锁定: 方框套全身, 中心在 Head 和 HRP 中点
                        if span > 20 then boxSize = math.clamp(span * 1.3, 45, 240) end
                        centerX = (headSP.X + hrpSP.X) / 2
                        centerY = (headSP.Y + hrpSP.Y) / 2
                    end
                end
                Combat.LockBox.Size = UDim2.new(0, boxSize, 0, boxSize)
                Combat.LockBox.Position = UDim2.new(0, centerX - boxSize/2, 0, centerY - boxSize/2)
                Combat.Arrow.Visible = false
            else
                -- 目标离开屏幕: 方框隐藏, 显示箭头提示
                Combat.LockBox.Visible = false
                Combat.Arrow.Visible = true
                -- 计算箭头位置 (屏幕边缘)
                local vp = Camera.ViewportSize
                local cx, cy = vp.X/2, vp.Y/2
                local dx, dy = screenPos.X - cx, screenPos.Y - cy
                local angle = math.atan2(dy, dx)
                local margin = 60
                local ax = cx + math.cos(angle) * (cx - margin)
                local ay = cy + math.sin(angle) * (cy - margin)
                Combat.Arrow.Position = UDim2.new(0, ax - 20, 0, ay - 20)
                Combat.ArrowLabel.Rotation = math.deg(angle)
            end
        end
    else
        if Combat.LockBox then Combat.LockBox.Visible = false end
        if Combat.Arrow then Combat.Arrow.Visible = false end
    end
end

-- 格斗快捷键监听
local function SetupCombatHotkey()
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        local keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
        if keyName == Config.CombatFaceKey then
            -- 必须开启格斗总开关才可用快捷键
            if Config.CombatEnabled then
                Config.CombatFaceTarget = not Config.CombatFaceTarget
                if not Config.CombatFaceTarget then
                    Combat.Target = nil
                end
                ShowNotification("格斗", "自动面朝已" .. (Config.CombatFaceTarget and "开启" or "关闭"), Color3.fromRGB(180,80,255))
            end
        end
    end)
end

task.wait()

SetupGhostShortcut()
SetupCombatHotkey()
CreateCombatLockUI()
UpdateLockColor()

if Config.GhostStatusBar then CreateGhostStatusBar() end

-- 主循环: NPC慢速扫描 + NPC击杀 + 互动透视 + NPC血量更新 + 格斗系统
-- NPC扫描限频: 每0.15秒才执行一次, 避免每帧调用导致卡顿
local NPC_LastSlowScan = 0
local NPC_LastHealthUpdate = 0
local Combat_LastFrame = 0
RunService.Heartbeat:Connect(function()
    local now = tick()
    if Config.NPCESP and now - NPC_LastSlowScan >= 0.15 then
        NPC_LastSlowScan = now
        SlowScanNPCs()
    end
    -- NPC血量文字更新 (每0.5秒, 避免每帧遍历)
    if Config.NPCESP and Config.NPCShowHealth and now - NPC_LastHealthUpdate >= 0.5 then
        NPC_LastHealthUpdate = now
        UpdateNPCHealthLabels()
    end
    if Config.NPCKill then ProcessNPCKill() end
    if Config.InteractESP then
        ProcessInteractQueue()
        UpdateInteractBillboards()
        CleanInteractCache()
    end
    -- 格斗系统 (每帧, 帧限频0.02秒)
    if Config.CombatEnabled and now - Combat_LastFrame >= 0.02 then
        Combat_LastFrame = now
        CombatFrame()
    end
    -- 无限子弹 (每0.1秒检查)
    if Config.WeaponInfAmmo and now - (Weapon_LastCheck or 0) >= 0.1 then
        Weapon_LastCheck = now
        WeaponInfAmmoTick()
    end
end)

ShowNotification("通用辅助", "v3.8 加载完成", Color3.fromRGB(80, 180, 120))
print("[通用辅助] v3.8 加载完成")

end)  -- task.spawn end