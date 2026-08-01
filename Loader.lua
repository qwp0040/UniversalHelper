--========================================================================
-- UniversalHelper 远程加载器 v1.0
-- 用途: 从 GitHub 拉取主脚本并执行 (适配手机端 Roblox 执行器)
-- 来源: https://github.com/qwp0040/UniversalHelper
--========================================================================

local URL = "https://raw.githubusercontent.com/qwp0040/UniversalHelper/main/UniversalHelper.lua"

local function LoadScript(url)
    -- 显示加载状态
    pcall(function()
        if syn and syn.toast_notification then
            syn.toast_notification({
                Title = "UniversalHelper",
                Content = "正在从远程加载脚本...",
                Duration = 3
            })
        end
    end)

    local success, result = pcall(function()
        -- 优先尝试 HttpGet (主流执行器都支持)
        if httpget then
            return httpget(url)
        elseif syn and syn.request then
            return syn.request({Url = url, Method = "GET"}).Body
        elseif request then
            return request({Url = url, Method = "GET"}).Body
        elseif http_request then
            return http_request({Url = url, Method = "GET"}).Body
        else
            return game:HttpGet(url)
        end
    end)

    if not success or not result or result == "" then
        local errMsg = result and tostring(result) or "未知错误"
        error("[UniversalHelper] 加载失败: " .. errMsg)
        return
    end

    -- 执行脚本
    local fn, compileErr = loadstring(result)
    if not fn then
        error("[UniversalHelper] 编译失败: " .. tostring(compileErr))
        return
    end

    -- 设置环境变量 (跨执行器兼容)
    pcall(function()
        if setfenv then
            setfenv(fn, getfenv())
        end
    end)

    fn()
    print("[UniversalHelper] 远程加载完成")
end

-- 启动加载
LoadScript(URL)
