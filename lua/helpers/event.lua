local M = {
    --- after adding a buffer to the buffer list
    BufAdd = "BufAdd",
    --- deleting a buffer from the buffer list
    BufDelete = "BufDelete",
    --- after entering a buffer
    BufEnter = "BufEnter",
    --- after renaming a buffer
    BufFilePost = "BufFilePost",
    --- before renaming a buffer
    BufFilePre = "BufFilePre",
    --- just after buffer becomes hidden
    BufHidden = "BufHidden",
    --- before leaving a buffer
    BufLeave = "BufLeave",
    --- after the 'modified' state of a buffer changes
    BufModifiedSet = "BufModifiedSet",
    --- after creating any buffer
    BufNew = "BufNew",
    --- when creating a buffer for a new file
    BufNewFile = "BufNewFile",
    --- read buffer using command
    BufReadCmd = "BufReadCmd",
    --- after reading a buffer
    BufReadPost = "BufReadPost",
    --- before reading a buffer
    BufReadPre = "BufReadPre",
    --- just before unloading a buffer
    BufUnload = "BufUnload",
    --- after showing a buffer in a window
    BufWinEnter = "BufWinEnter",
    --- just after buffer removed from window
    BufWinLeave = "BufWinLeave",
    --- just before really deleting a buffer
    BufWipeout = "BufWipeout",
    --- write buffer using command
    BufWriteCmd = "BufWriteCmd",
    --- after writing a buffer
    BufWritePost = "BufWritePost",
    --- before writing a buffer
    BufWritePre = "BufWritePre",
    --- info was received about channel
    ChanInfo = "ChanInfo",
    --- channel was opened
    ChanOpen = "ChanOpen",
    --- command undefined
    CmdUndefined = "CmdUndefined",
    --- command line was modified
    CmdlineChanged = "CmdlineChanged",
    --- after entering cmdline mode
    CmdlineEnter = "CmdlineEnter",
    --- before leaving cmdline mode
    CmdlineLeave = "CmdlineLeave",
    --- after entering the cmdline window
    CmdWinEnter = "CmdwinEnter",
    --- before leaving the cmdline window
    CmdWinLeave = "CmdwinLeave",
    --- after loading a colorscheme
    ColorScheme = "ColorScheme",
    --- before loading a colorscheme
    ColorSchemePre = "ColorSchemePre",
    --- after popup menu changed
    CompleteChanged = "CompleteChanged",
    --- after finishing insert complete
    CompleteDone = "CompleteDone",
    --- idem, before clearing info
    CompleteDonePre = "CompleteDonePre",
    --- cursor in same position for a while
    CursorHold = "CursorHold",
    --- idem, in Insert mode
    CursorHoldI = "CursorHoldI",
    --- cursor was moved
    CursorMoved = "CursorMoved",
    --- cursor was moved in Insert mode
    CursorMovedI = "CursorMovedI",
    --- diffs have been updated
    DiffUpdated = "DiffUpdated",
    --- directory changed
    DirChanged = "DirChanged",
    --- after changing the 'encoding' option
    EncodingChanged = "EncodingChanged",
    --- before exiting
    ExitPre = "ExitPre",
    --- append to a file using command
    FileAppendCmd = "FileAppendCmd",
    --- after appending to a file
    FileAppendPost = "FileAppendPost",
    --- before appending to a file
    FileAppendPre = "FileAppendPre",
    --- before first change to read-only file
    FileChangedRO = "FileChangedRO",
    --- after shell command that changed file
    FileChangedShell = "FileChangedShell",
    --- after (not) reloading changed file
    FileChangedShellPost = "FileChangedShellPost",
    --- read from a file using command
    FileReadCmd = "FileReadCmd",
    --- after reading a file
    FileReadPost = "FileReadPost",
    --- before reading a file
    FileReadPre = "FileReadPre",
    --- new file type detected (user defined)
    FileType = "FileType",
    --- write to a file using command
    FileWriteCmd = "FileWriteCmd",
    --- after writing a file
    FileWritePost = "FileWritePost",
    --- before writing a file
    FileWritePre = "FileWritePre",
    --- after reading from a filter
    FilterReadPost = "FilterReadPost",
    --- before reading from a filter
    FilterReadPre = "FilterReadPre",
    --- after writing to a filter
    FilterWritePost = "FilterWritePost",
    --- before writing to a filter
    FilterWritePre = "FilterWritePre",
    --- got the focus
    FocusGained = "FocusGained",
    --- lost the focus to another app
    FocusLost = "FocusLost",
    --- if calling a function which doesn't exist
    FuncUndefined = "FuncUndefined",
    --- after starting the GUI
    GUIEnter = "GUIEnter",
    --- after starting the GUI failed
    GUIFailed = "GUIFailed",
    --- when changing Insert/Replace mode
    InsertChange = "InsertChange",
    --- before inserting a char
    InsertCharPre = "InsertCharPre",
    --- when entering Insert mode
    InsertEnter = "InsertEnter",
    --- just after leaving Insert mode
    InsertLeave = "InsertLeave",
    --- just before leaving Insert mode
    InsertLeavePre = "InsertLeavePre",
    -- after an LSP client attaches to a buffer
    LspAttach = "LspAttach",
    -- after an LSP client detaches from a buffer
    LspDetach = "LspDetach",
    -- after an LSP request is started, canceled, or completed
    LspRequest = "LspRequest",
    -- after an LSP notice has been sent to the server
    LspNotify = "LspNotify",
    -- after a visible LSP token is updated
    LspTokenUpdate = "LspTokenUpdate",
    -- after a LSP progress update
    LspProgress = "LspProgress",
    --- just before popup menu is displayed
    MenuPopup = "MenuPopup",
    --- after changing the mode
    ModeChanged = "ModeChanged",
    --- after setting any option
    OptionSet = "OptionSet",
    --- after :make, :grep etc.
    QuickFixCmdPost = "QuickFixCmdPost",
    --- before :make, :grep etc.
    QuickFixCmdPre = "QuickFixCmdPre",
    --- before :quit
    QuitPre = "QuitPre",
    --- upon string reception from a remote vim
    RemoteReply = "RemoteReply",
    --- when the search wraps around the document
    SearchWrapped = "SearchWrapped",
    --- after loading a session file
    SessionLoadPost = "SessionLoadPost",
    --- after ":!cmd"
    ShellCmdPost = "ShellCmdPost",
    --- after ":1,2!cmd", ":w !cmd", ":r !cmd".
    ShellFilterPost = "ShellFilterPost",
    --- after nvim process received a signal
    Signal = "Signal",
    --- sourcing a Vim script using command
    SourceCmd = "SourceCmd",
    --- after sourcing a Vim script
    SourcePost = "SourcePost",
    --- before sourcing a Vim script
    SourcePre = "SourcePre",
    --- spell file missing
    SpellFileMissing = "SpellFileMissing",
    --- after reading from stdin
    StdinReadPost = "StdinReadPost",
    --- before reading from stdin
    StdinReadPre = "StdinReadPre",
    --- found existing swap file
    SwapExists = "SwapExists",
    --- syntax selected
    Syntax = "Syntax",
    --- a tab has closed
    TabClosed = "TabClosed",
    --- after entering a tab page
    TabEnter = "TabEnter",
    --- before leaving a tab page
    TabLeave = "TabLeave",
    --- when creating a new tab
    TabNew = "TabNew",
    --- after entering a new tab
    TabNewEntered = "TabNewEntered",
    --- after changing 'term'
    TermChanged = "TermChanged",
    --- after the process exits
    TermClose = "TermClose",
    --- after entering Terminal mode
    TermEnter = "TermEnter",
    --- after leaving Terminal mode
    TermLeave = "TermLeave",
    --- after opening a terminal buffer
    TermOpen = "TermOpen",
    --- after setting "v:termresponse"
    TermResponse = "TermResponse",
    --- text was modified
    TextChanged = "TextChanged",
    --- text was modified in Insert mode(no popup)
    TextChangedI = "TextChangedI",
    --- text was modified in Insert mode(popup)
    TextChangedP = "TextChangedP",
    --- after a yank or delete was done (y, d, c)
    TextYankPost = "TextYankPost",
    --- after UI attaches
    UIEnter = "UIEnter",
    --- after UI detaches
    UILeave = "UILeave",
    --- user defined autocommand
    User = "User",
    --- when the user presses the same key 42 times
    UserGettingBored = "UserGettingBored",
    --- after starting Vim
    VimEnter = "VimEnter",
    --- before exiting Vim
    VimLeave = "VimLeave",
    --- before exiting Vim and writing ShaDa file
    VimLeavePre = "VimLeavePre",
    --- after Vim window was resized
    VimResized = "VimResized",
    --- after Nvim is resumed
    VimResume = "VimResume",
    --- before Nvim is suspended
    VimSuspend = "VimSuspend",
    --- after closing a window
    WinClosed = "WinClosed",
    --- after entering a window
    WinEnter = "WinEnter",
    --- before leaving a window
    WinLeave = "WinLeave",
    --- when entering a new window
    WinNew = "WinNew",
    --- after scrolling a window
    WinScrolled = "WinScrolled",

    --- When lazy has finished starting up and loaded your config
    LazyDone = "LazyDone",

    --- Startup event after a file is loaded
    LazyFile = "LazyFile",

    --- After loading a plugin. The `data` attribute will contain the plugin name.
    LazyLoad = "LazyLoad",

    --- Triggered after `UIEnter` when `require("lazy").stats().startuptime` has been calculated.
    LazyVimStarted = "LazyVimStarted",

    --- Triggered after `LazyDone` and processing `VimEnter` auto commands
    VeryLazy = "VeryLazy",

    -- For dynamic registration: User pattern
    LspDynamicCapability = "LspDynamicCapability",

    -- Switch on LSP method support: User pattern.
    LspSupportsMethod = "LspSupportsMethod",
}

---@alias EventOpts vim.api.keyset.create_autocmd
---@alias EventCallback string|(fun(args: vim.api.keyset.create_autocmd.callback_args): boolean?)
---@alias EmitOpts vim.api.keyset.exec_autocmds

---@param event string | string[]
---@param callback EventCallback
---@param opts EventOpts
---@return integer
M.on = function(event, callback, opts)
    opts = opts or {}

    if type(event) == "string" then
        event = { event }
    end

    if type(callback) == "table" then
        opts = callback
    else
        opts.callback = callback
    end

    return vim.api.nvim_create_autocmd(event, opts)
end

---@param event string
---@param opts EmitOpts
---@return nil
M.emit = function(event, opts)
    opts = opts or {}

    if M[event] then
        vim.api.nvim_exec_autocmds(event, opts)
    else
        notify.error("Unknown event: " .. event)
    end
end

--- Create an autocommand group.
--- @param name string The name of the group.
--- @param clear boolean? Whether to clear the group. Defaults to true.
--- @return integer
M.group = function(name, clear)
    if clear == nil then
        clear = true
    end

    return vim.api.nvim_create_augroup(vim.env.USER .. "/" .. name, { clear = clear })
end

M.is_loaded = function(name)
    local config = require("lazy.core.config")
    return config.plugins[name] and config.plugins[name]._.loaded
end

---@param name string
---@param fn fun(name:string)
M.on_load = function(name, fn)
    if M.is_loaded(name) then
        fn(name)
    else
        M.on(M.User, function(event)
            if event.data == name then
                fn(name)
            end
        end, { pattern = "LazyLoad" })
    end
end

return M
