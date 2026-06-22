-- Generate buildServer.json for xcodeproj-based projects so sourcekit-lsp can
-- resolve compiler arguments via the Build Server Protocol.
--
-- Automatic: when a Swift/ObjC buffer opens in a project that has a .xcodeproj
--   but no buildServer.json, the config is generated once (cheap, no build).
--
-- Manual: :SourceKitBuildServer (re)generates the config, prompts for a build
--   destination, then clean-builds the "all" scheme and parses per-file
--   compiler args into .compile. The destination determines which platform
--   macros (TARGET_OS_IOS, TARGET_OS_XR, ...) are set, and therefore which
--   #if branches sourcekit-lsp treats as active.
if vim.fn.has("mac") == 0 then
    return
end

-- The build destination determines which compiler macros (TARGET_OS_IOS,
-- TARGET_OS_XR, etc.) are set, and therefore which #if branches sourcekit-lsp
-- treats as live. Only one destination's branches are visible at a time;
-- rebuild with a different destination to switch which branches are indexed.
---@type { label: string, destination: string }[]
local destinations = {
    { label = "macOS", destination = "generic/platform=macOS" },
    { label = "iOS", destination = "generic/platform=iOS" },
    { label = "iOS Simulator", destination = "generic/platform=iOS Simulator" },
    { label = "visionOS", destination = "generic/platform=visionOS" },
    { label = "visionOS Simulator", destination = "generic/platform=visionOS Simulator" },
    { label = "tvOS", destination = "generic/platform=tvOS" },
    { label = "watchOS", destination = "generic/platform=watchOS" },
    { label = "Mac Catalyst", destination = "generic/platform=macOS,variant=Mac Catalyst" },
}

---@param root string
---@return string? project absolute path to the .xcodeproj, if any
local function find_xcodeproj(root)
    local match = vim.fs.find(function(name)
        return name:match("%.xcodeproj$") ~= nil
    end, { path = root, type = "directory", limit = 1 })[1]

    return match
end

---@param project string absolute path to the .xcodeproj
---@return string[] schemes
local function list_schemes(project)
    local result = vim.system({ "xcodebuild", "-list", "-project", project }, { text = true }):wait()

    if result.code ~= 0 or not result.stdout then
        return {}
    end

    local schemes = {} ---@type string[]
    local in_section = false

    for line in vim.gsplit(result.stdout, "\n") do
        if line:match("^%s*Schemes:%s*$") then
            in_section = true
        elseif in_section then
            local scheme = vim.trim(line)

            -- Skip the aggregate "all" scheme and blank lines.
            if scheme == "" then
                break
            elseif scheme ~= "all" then
                schemes[#schemes + 1] = scheme
            end
        end
    end

    return schemes
end

---@param root string project root directory
---@param project string absolute path to the .xcodeproj
---@param destination string an xcodebuild -destination specifier
local function build(root, project, destination)
    -- Build the "all" scheme so every target's sources (framework, daemon,
    -- tools, tests) get compiler args -- files like daemon-only sources are
    -- otherwise never compiled and show #if branches as inactive.
    --
    -- A *clean* build is required: incremental builds skip unchanged files, so
    -- their CompileC lines never appear and their args go stale. The build
    -- output is piped through `xcode-build-server parse -o .compile`, which
    -- reads xcodebuild's stdout (not the .xcactivitylog) to write per-file
    -- compiler arguments that sourcekit-lsp reads.
    vim.notify(("sourcekit: clean-building all (%s) and parsing args..."):format(destination))

    local cmd = ("xcodebuild -project %s -scheme all -destination %s clean build 2>&1 | xcode-build-server parse -o .compile"):format(
        vim.fn.shellescape(project),
        vim.fn.shellescape(destination)
    )

    vim.system(
        { "sh", "-c", cmd },
        { cwd = root, text = true },
        vim.schedule_wrap(function(result)
            if result.code ~= 0 then
                vim.notify("sourcekit: build/parse failed\n" .. (result.stderr or result.stdout or ""), vim.log.levels.ERROR)
                return
            end

            vim.notify("sourcekit: .compile written, restart LSP to pick up new args")
        end)
    )
end

-- Write buildServer.json via the BSP build server for a specific scheme.
-- Calls `on_success(scheme)` if the config is written, or `on_failure()` if the
-- scheme was rejected so the caller can fall back to scheme discovery.
---@param root string project root directory
---@param project string absolute path to the .xcodeproj
---@param scheme string
---@param on_success fun(scheme: string)
---@param on_failure fun()
local function generate(root, project, scheme, on_success, on_failure)
    vim.notify(("sourcekit: generating buildServer.json (scheme: %s)"):format(scheme))

    vim.system(
        { "xcode-build-server", "config", "-project", project, "-scheme", scheme },
        { cwd = root, text = true },
        vim.schedule_wrap(function(result)
            if result.code ~= 0 then
                on_failure()
                return
            end

            on_success(scheme)
        end)
    )
end

-- Generate the config, calling `xcodebuild -list` ONLY if the basename scheme is
-- rejected. The happy path (scheme == project basename) never lists schemes.
---@param root string project root directory
---@param project string absolute path to the .xcodeproj
---@param on_success fun(scheme: string)
local function resolve_and_generate(root, project, on_success)
    -- Default scheme = project basename (e.g. SpaceAttributionFramework.xcodeproj
    -- -> SpaceAttributionFramework). Try it directly before paying for a list.
    local basename = vim.fs.basename(project)

    generate(root, project, basename, on_success, function()
        -- Basename was not a valid scheme: now (and only now) discover schemes.
        local schemes = list_schemes(project)

        if #schemes == 0 then
            vim.notify("sourcekit: no schemes found in " .. project, vim.log.levels.ERROR)
            return
        end

        vim.ui.select(schemes, { prompt = "Select scheme for " .. vim.fs.basename(project) }, function(scheme)
            if scheme then
                generate(root, project, scheme, on_success, function()
                    vim.notify("sourcekit: xcode-build-server config failed for scheme " .. scheme, vim.log.levels.ERROR)
                end)
            end
        end)
    end)
end

vim.api.nvim_create_user_command("SourceKitBuildServer", function()
    if vim.fn.executable("xcode-build-server") == 0 then
        vim.notify("sourcekit: xcode-build-server not found (brew install xcode-build-server)", vim.log.levels.ERROR)
        return
    end

    local root = nvim.root()
    local project = find_xcodeproj(root)

    if not project then
        vim.notify("sourcekit: no .xcodeproj found under " .. root, vim.log.levels.ERROR)
        return
    end

    resolve_and_generate(root, project, function(_)
        vim.ui.select(destinations, {
            prompt = "Build destination (sets which #if branches are visible)",
            format_item = function(item)
                return item.label
            end,
        }, function(choice)
            if choice then
                build(root, project, choice.destination)
            end
        end)
    end)
end, { desc = "Regenerate sourcekit buildServer.json and build" })

-- Auto-generate buildServer.json (config only, no build) the first time a
-- Swift/ObjC buffer opens in an xcodeproj project that lacks one. Guarded so it
-- runs at most once per root per session and never triggers an expensive build.
local attempted = {} ---@type table<string, boolean>

ev.on(ev.FileType, function()
    if vim.fn.executable("xcode-build-server") == 0 then
        return
    end

    local root = nvim.root()

    if attempted[root] then
        return
    end

    -- Cheap stat check: skip if config already exists.
    if vim.uv.fs_stat(vim.fs.joinpath(root, "buildServer.json")) then
        return
    end

    local project = find_xcodeproj(root)

    if not project then
        return
    end

    attempted[root] = true

    resolve_and_generate(root, project, function()
        vim.notify("sourcekit: buildServer.json written, restart LSP (run :SourceKitBuildServer to build)")
    end)
end, {
    pattern = { "swift", "objc", "objcpp" },
})
