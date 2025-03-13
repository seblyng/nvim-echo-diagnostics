local M = {}

local current_msg = nil

local opt = {
    show_diagnostic_number = true,
    show_diagnostic_source = false,
}

local function find_line_diagnostic(show_entire_diagnostic)
    local lnum, _ = unpack(vim.api.nvim_win_get_cursor(0))
    local diagnostics = vim.diagnostic.get(0, { lnum = lnum - 1 })
    if vim.tbl_isempty(diagnostics) then
        return nil
    end

    local full_msg = ''
    local trunc_msg = ''

    local winmargin = 20
    local used_height = 0

    for k, v in pairs(diagnostics) do
        if v.message then
            local msg = opt.show_diagnostic_number and string.format('%s: %s', k, v.message) or v.message
            if opt.show_diagnostic_source and v.source then
                msg = msg .. ' (' .. v.source .. ')'
            end

            if k < #diagnostics then
                full_msg = full_msg .. msg .. '\n'
            else
                full_msg = full_msg .. msg
            end

            -- Diagnostic sent from language server may contain newlines
            local lines = vim.split(msg, '\n')
            for i, line in ipairs(lines) do
                -- Check how many rows the diagnostics currently will fill
                local remaining_height = vim.o.cmdheight - used_height
                local msg_height = math.ceil(#line / vim.o.columns)
                local max_len = remaining_height * vim.o.columns - winmargin

                if used_height + msg_height < vim.o.cmdheight then
                    trunc_msg = trunc_msg .. line
                    -- Avoid edge case where the appended newline would create
                    -- a prompt of press enter to continue.
                    if #line ~= vim.o.columns then
                        trunc_msg = trunc_msg .. '\n'
                    end
                else
                    trunc_msg = trunc_msg .. string.sub(line, 1, max_len)
                    -- Append ... if more diagnostics exists or current msg is too long
                    if #diagnostics > k or #lines > i or #line > max_len then
                        trunc_msg = trunc_msg .. ' ...'
                    end
                    if not show_entire_diagnostic then
                        return trunc_msg
                    end
                end
                used_height = used_height + msg_height
            end
        end
    end

    -- Check if we should echo entire diagnostic
    if show_entire_diagnostic then
        local tbl = vim.split(full_msg, '\n')
        if #tbl <= vim.o.cmdheight then
            full_msg = full_msg .. string.rep('\n', (vim.o.cmdheight - #tbl) + 1)
        end
        return full_msg
    end

    return trunc_msg
end

local function echo_diagnostic(entire)
    local msg = find_line_diagnostic(entire)

    -- Echo an empty message to remove the diagnostic echo if we move
    -- away from a diagnostic
    if not msg and current_msg then
        vim.api.nvim_echo({ { '' } }, false, {})
    end

    current_msg = msg
    if not current_msg then
        return
    end
    vim.api.nvim_echo({ { current_msg } }, false, {})
end

M.echo_line_diagnostic = function()
    echo_diagnostic(false)
end

M.echo_entire_diagnostic = function()
    echo_diagnostic(true)
end

M.setup = function(user_options)
    user_options = user_options or {}
    opt = vim.tbl_extend('force', opt, user_options)
end

return M
