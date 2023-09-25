if package.loaded["mini.pairs"] then
    --
    -- Don't match on the 3rd quote for docstrings.
    require("mini.pairs").map_buf(0, "i", '"', { action = "closeopen", pair = '""', neigh_pattern = '[^\\"][]%s)}\'"]', register = { cr = false } })
end
