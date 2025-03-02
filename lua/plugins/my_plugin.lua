return {
    {
        "Ex7740/my_plugin",  -- Replace with your actual GitHub username and repo
        lazy = false,  -- Set to true if you want to lazy-load it on a specific event
        config = function()
            -- Set a keybinding to open the floating window
            vim.api.nvim_set_keymap(
                "n", 
                "<leader>fw",  -- Keybinding
                ":lua require('my_plugin').open_floating_window()<CR>",  -- Command to open the window
                { noremap = true, silent = true }
            )
        end,
    },
}
