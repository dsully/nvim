if vim.fn.has("mac") == 0 then
    return
end

local pattern = "applenotes://*"

ev.on(ev.BufReadCmd, function(args)
    require("lib.notes").read(args.buf)
end, { pattern = pattern })

ev.on(ev.BufWriteCmd, function(args)
    require("lib.notes").write(args.buf)
end, { pattern = pattern })
