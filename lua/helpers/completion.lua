-- Heavily adapted from https://github.com/xzbdmw/nvimconfig
local M = {}

---@param detail string?
M.trim_detail = function(detail)
    --
    if detail then
        detail = vim.trim(detail)

        if vim.startswith(detail, "(use") then
            detail = "(" .. string.sub(detail, 6, #detail)
        end
    end

    return detail
end

---@param description string
M.match_fn = function(description)
    return string.match(description, "^pub fn")
        or string.match(description, "^fn")
        or string.match(description, "^unsafe fn")
        or string.match(description, "^pub unsafe fn")
        or string.match(description, "^pub async fn")
        or string.match(description, "^async fn")
        or string.match(description, "^pub const unsafe fn")
        or string.match(description, "^const fn")
        or string.match(description, "^pub const fn")
end

--- @param ctx blink.cmp.DrawItemContext
--- @return string
M.rust_format = function(ctx)
    --
    local kind = ctx.item.kind
    local types = require("blink.cmp.types").CompletionItemKind
    local label = ctx.label .. ctx.label_detail

    -- local is_async = false

    if kind == types.Method or kind == types.Function then
        --
        --[[ labelDetails.
        function#function#if detail: {
          description = "pub fn shl(self, rhs: Rhs) -> Self::Output",
          detail = " (use std::ops::Shl)"
        } ]]
        if ctx.label_detail then
            local detail = M.trim_detail(ctx.label)
            local description = ctx.label_description

            if description then
                -- is_async = string.find(description, "async", nil, true) ~= nil

                if string.sub(description, #description, #description) == "," then
                    description = description:sub(1, #description - 1)
                end
            end

            if (detail and vim.startswith(detail, "macro")) or (description and vim.startswith(description, "macro")) then
                goto OUT
            end

            if detail and description then
                --
                if M.match_fn(description) then
                    local start_index, _ = string.find(description, "(", nil, true)

                    if start_index then
                        description = description:sub(start_index, #description)
                    end
                end

                local index = string.find(ctx.label, "(", nil, true)

                -- description: "macro simd_swizzle"
                -- detail: " (use std::simd::simd_swizzle)"
                if index then
                    local prefix = string.sub(ctx.label, 1, index - 1)
                    label = prefix .. " " .. description
                end
            elseif detail then
                --
                label = ctx.label .. " " .. detail
            elseif description then
                --
                if M.match_fn(description) then
                    local start_index, _ = string.find(description, "%(")

                    if start_index then
                        description = description:sub(start_index, #description)
                    end
                end

                local index = string.find(ctx.label, "(", nil, true)

                if index then
                    local prefix = string.sub(ctx.label, 1, index - 1)
                    label = prefix .. description .. " "
                else
                    label = ctx.label .. " " .. description
                end
            end
        end
    elseif kind == types.Snippet then
        --
        label = ctx.label
    elseif kind == types.Field then
        --
        local detail = M.trim_detail(ctx.label_detail)

        if detail then
            label = ctx.label .. ": " .. detail
        end
    elseif kind == types.Variable or kind == types.Constant then
        --
        if ctx.label_detail then
            --
            local detail = ctx.label_description

            if detail then
                -- label = "let " .. ctx.label .. ": " .. detail
                label = ctx.label .. ": " .. detail
            end
        end
    elseif kind == types.Module then
        --
        local detail = M.trim_detail(ctx.label_detail)

        if detail then
            label = ctx.label .. " " .. detail
        end
    elseif kind == types.Interface then
        local detail = M.trim_detail(ctx.label_detail)

        if detail then
            label = ctx.label .. " " .. detail
            -- else
            --     label = "trait " .. ctx.label .. "{}"
        end
    elseif kind == types.Struct then
        local detail = M.trim_detail(ctx.label_detail)

        if detail then
            label = ctx.label .. " " .. detail
        end
    end

    ::OUT::

    return label
end

return M
