-- Generate buildServer.json for xcodeproj-based projects so sourcekit-lsp can
-- resolve compiler arguments via the Build Server Protocol.
--
-- Automatic: when a Swift/ObjC buffer opens in a project that has a .xcodeproj
--   but no buildServer.json, the config is generated once (cheap, no build).
--
-- Manual: :XcodeBuildServer (re)generates the config, prompts for a build
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

-- The .compile file is already in JSON Compilation Database format, but its
-- `command` strings carry build-orchestration flags that make clangd's embedded
-- clang fail or write stray artifacts when it replays the compile to index a
-- file. Strip those flags and write a clangd-named compile_commands.json.
--
-- Two subtleties:
--   * -fbuild-session-file= points at a transient marker that only exists
--     during the xcodebuild run, so clangd would error with drv_no_such_file.
--     We cannot simply drop it: its companion -fmodules-validate-once-per-
--     build-session then errors that it requires a session file/timestamp.
--     Instead we REWRITE the flag to a stable file we touch at generation time
--     (clang reads the file's mtime as the session stamp -> modules revalidate
--     once per build, matching Xcode's intent).
--   * The @<resp> response file is kept: it carries the -I/header-map include
--     paths clangd needs, and clangd reads response files natively.

-- Stable session file, touched on every generation so its mtime advances once
-- per build. Lives at the project root next to .compile/compile_commands.json.
local SESSION_FILE = ".clangd-build-session"

-- Flags whose value is the FOLLOWING token; both are dropped.
---@type table<string, boolean>
local drop_with_arg = {
    ["-index-store-path"] = true,
    ["-index-unit-output-path"] = true,
    ["-MT"] = true,
    ["-MF"] = true,
    ["--serialize-diagnostics"] = true,
    ["-c"] = true,
    ["-o"] = true,
}

-- Single, self-contained flags that are dropped outright.
---@type table<string, boolean>
local drop_flag = {
    ["-MMD"] = true,
}

---Strip build-only flags from a shell-escaped clang command string and repoint
---the build-session file at a stable path. Token escaping is preserved by only
---removing or replacing whole whitespace-delimited tokens.
---@param command string
---@param session_path string absolute path to the stable session file
---@return string
local function strip_build_flags(command, session_path)
    local kept = {} ---@type string[]
    local skip_next = false

    for token in command:gmatch("%S+") do
        if skip_next then
            skip_next = false
        elseif drop_with_arg[token] then
            skip_next = true
        elseif drop_flag[token] then
            -- drop
        elseif token:match("^%-fbuild%-session%-file\\?=") then
            -- Repoint at the stable file, mirroring the original "\=" escaping so
            -- the token tokenizes identically.
            kept[#kept + 1] = "-fbuild-session-file\\=" .. session_path
        else
            kept[#kept + 1] = token
        end
    end

    return table.concat(kept, " ")
end

-- Stop attached clangd clients so a freshly written compile_commands.json is
-- read on reattach. Best-effort: pcall guards a stopped/invalid client.
local function restart_clangd()
    for _, client in ipairs(vim.lsp.get_clients({ name = "clangd" })) do
        pcall(function()
            client:stop(true)
        end)
    end
end

-- Read the .compile JSON database, strip build-only flags from each entry's
-- command, and write the result as compile_commands.json for clangd.
---@param root string project root directory
local function write_compile_commands(root)
    local compile = vim.fs.joinpath(root, ".compile")
    local target = vim.fs.joinpath(root, "compile_commands.json")
    local session = vim.fs.joinpath(root, SESSION_FILE)

    local fd = io.open(compile, "r")

    if not fd then
        return
    end

    local raw = fd:read("*a")
    fd:close()

    local ok, db = pcall(vim.json.decode, raw)

    if not ok or type(db) ~= "table" then
        vim.notify("xcode: could not parse .compile as JSON", vim.log.levels.WARN)
        return
    end

    -- Touch the stable session file so its mtime is "now": clang reads that
    -- mtime as the build-session stamp for -fmodules-validate-once-per-build-
    -- session, so modules revalidate once after each rebuild.
    local touch = io.open(session, "w")

    if touch then
        touch:close()
    else
        vim.notify("xcode: could not create " .. SESSION_FILE, vim.log.levels.WARN)
        return
    end

    for _, entry in ipairs(db) do
        if type(entry.command) == "string" then
            entry.command = strip_build_flags(entry.command, session)
        end
    end

    local out = io.open(target, "w")

    if not out then
        vim.notify("xcode: could not write compile_commands.json", vim.log.levels.WARN)
        return
    end

    out:write(vim.json.encode(db))
    out:close()

    restart_clangd()
end

-- Detect whether a JSON compilation database references an @response file that
-- no longer exists on disk. Every entry in our generated db references an
-- @response under transient DerivedData/Intermediates.noindex that carries the
-- real -I include paths; a clean build elsewhere can delete those files, leaving
-- a compile_commands.json that looks fresh by mtime but has lost its includes.
-- Used for both compile_commands.json and the source .compile (to decide whether
-- regenerating would actually help -- see the autocmd below).
---@param path string absolute path to a JSON compilation database
---@return boolean
local function has_dangling_response(path)
    local fd = io.open(path, "r")

    if not fd then
        return false
    end

    local raw = fd:read("*a")
    fd:close()

    local ok, db = pcall(vim.json.decode, raw)

    if not ok or type(db) ~= "table" then
        return false
    end

    local checked = {} ---@type table<string, boolean>

    for _, entry in ipairs(db) do
        if type(entry.command) == "string" then
            for token in entry.command:gmatch("%S+") do
                if token:sub(1, 1) == "@" then
                    -- Unescape shell escaping ("\=" -> "=", "\ " -> " ") before stat.
                    local resp = token:sub(2):gsub("\\(.)", "%1")

                    if not checked[resp] then
                        checked[resp] = true

                        if not vim.uv.fs_stat(resp) then
                            return true
                        end
                    end
                end
            end
        end
    end

    return false
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
    vim.notify(("xcode: clean-building all (%s) and parsing args..."):format(destination))

    local cmd = ("xcodebuild -project %s -scheme all -destination %s clean build 2>&1 | xcode-build-server parse -o .compile"):format(
        vim.fn.shellescape(project),
        vim.fn.shellescape(destination)
    )

    vim.system(
        { "sh", "-c", cmd },
        { cwd = root, text = true },
        vim.schedule_wrap(function(result)
            if result.code ~= 0 then
                vim.notify("xcode: build/parse failed\n" .. (result.stderr or result.stdout or ""), vim.log.levels.ERROR)
                return
            end

            write_compile_commands(root)

            vim.notify("xcode: .compile + compile_commands.json written, clangd restarted")
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
    vim.notify(("xcode: generating buildServer.json (scheme: %s)"):format(scheme))

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
            vim.notify("xcode: no schemes found in " .. project, vim.log.levels.ERROR)
            return
        end

        vim.ui.select(schemes, { prompt = "Select scheme for " .. vim.fs.basename(project) }, function(scheme)
            if scheme then
                generate(root, project, scheme, on_success, function()
                    vim.notify("xcode: xcode-build-server config failed for scheme " .. scheme, vim.log.levels.ERROR)
                end)
            end
        end)
    end)
end

nvim.command("XcodeBuildServer", function()
    if vim.fn.executable("xcode-build-server") == 0 then
        vim.notify("xcode: xcode-build-server not found (brew install xcode-build-server)", vim.log.levels.ERROR)
        return
    end

    local root = nvim.root()
    local project = find_xcodeproj(root)

    if not project then
        vim.notify("xcode: no .xcodeproj found under " .. root, vim.log.levels.ERROR)
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
end, { desc = "Regenerate Xcode buildServer.json and build" })

-- Regenerate clangd's compile_commands.json from an existing .compile, with no
-- rebuild. The derivation is a pure function of .compile, so it need not be
-- gated behind a full clean build.
nvim.command("ClangdCompileCommands", function()
    local root = nvim.root()

    if not vim.uv.fs_stat(vim.fs.joinpath(root, ".compile")) then
        vim.notify("xcode: no .compile found (run :XcodeBuildServer first)", vim.log.levels.WARN)
        return
    end

    write_compile_commands(root)
    vim.notify("xcode: compile_commands.json regenerated, clangd restarted")
end, { desc = "Regenerate clangd compile_commands.json from .compile" })

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
        vim.notify("xcode: buildServer.json written, restart LSP (run :XcodeBuildServer to build)")
    end)
end, {
    pattern = { "swift", "objc", "objcpp" },
})

-- Keep clangd's compile_commands.json in sync with .compile. On opening a
-- C-family buffer, regenerate when the JSON is missing, when .compile is newer
-- (mtime is self-limiting: after regen the JSON is newer, so this won't re-fire
-- until the next build rewrites .compile), OR when the JSON looks fresh but
-- references an @response file that a clean build elsewhere has deleted.
--
-- The dangling-@response case has a loop hazard: write_compile_commands copies
-- the @response path verbatim from .compile, so regenerating only helps if
-- .compile's own @response files still exist. If .compile is itself dangling,
-- regeneration cannot fix it, so we warn once per root and leave the db alone
-- (the user must rebuild via :XcodeBuildServer).
local warned_dangling = {} ---@type table<string, boolean>

ev.on(ev.FileType, function()
    local root = nvim.root()
    local compile_path = vim.fs.joinpath(root, ".compile")
    local compile = vim.uv.fs_stat(compile_path)

    if not compile then
        return
    end

    local target = vim.uv.fs_stat(vim.fs.joinpath(root, "compile_commands.json"))

    if not target or compile.mtime.sec > target.mtime.sec then
        write_compile_commands(root)
        warned_dangling[root] = nil
        vim.notify("xcode: compile_commands.json refreshed from newer .compile")
    elseif has_dangling_response(vim.fs.joinpath(root, "compile_commands.json")) then
        if has_dangling_response(compile_path) then
            -- Regenerating would reproduce the same dead @response: warn once.
            if not warned_dangling[root] then
                warned_dangling[root] = true
                vim.notify("xcode: compile_commands.json references a deleted @response file; run :XcodeBuildServer to rebuild", vim.log.levels.WARN)
            end
        else
            write_compile_commands(root)
            warned_dangling[root] = nil
            vim.notify("xcode: compile_commands.json had a missing @response file, regenerated")
        end
    end
end, {
    pattern = { "c", "cpp", "objc", "objcpp" },
})
