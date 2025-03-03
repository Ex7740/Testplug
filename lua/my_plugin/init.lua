local M = {}

-- Default Arduino board and port
M.board = "arduino:avr:uno"  -- Change to match your board
M.port = "COM7"  -- Change to your Arduino's port

-- Function to detect available boards and update port
function M.detect_board()
    local cmd = "arduino-cli board list"
    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            if data then
                for _, line in ipairs(data) do
                    local port, board = line:match("^(%S+)%s+.*(%S+:%S+:%S+)")
                    if port and board then
                        M.port = port
                        M.board = board
                        print("Detected board: " .. board .. " on port: " .. port)
                        return
                    end
                end
            end
        end
    })
end

-- Function to create a floating window
local function create_floating_window()
    local buf = vim.api.nvim_create_buf(false, true)
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.6)
    local opts = {
        relative = "editor",
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        style = "minimal",
        border = "rounded"
    }
    local win = vim.api.nvim_open_win(buf, true, opts)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "Arduino CLI Commands:",
        "1. :ArduinoDetect - Detect Board",
        "2. :ArduinoCompile - Compile Sketch",
        "3. :ArduinoUpload - Upload Sketch",
        "------------------",
        "Output:"
    })
    return buf, win
end

-- Function to compile the Arduino sketch
function M.compile()
    M.detect_board()
    local buf, win = create_floating_window()
    local cmd = string.format("arduino-cli compile --fqbn %s", M.board)
    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            if data then
                vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
            end
        end,
        on_exit = function()
            vim.api.nvim_win_close(win, true)
        end
    })
end

-- Function to upload the compiled sketch to the Arduino
function M.upload()
    M.detect_board()
    local buf, win = create_floating_window()
    local cmd = string.format("arduino-cli upload -p %s --fqbn %s", M.port, M.board)
    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            if data then
                vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
            end
        end,
        on_exit = function()
            vim.api.nvim_win_close(win, true)
        end
    })
end

-- Function to set board
function M.set_board(board)
    M.board = board
    print("Arduino board set to: " .. board)
end

-- Function to set port
function M.set_port(port)
    M.port = port
    print("Arduino port set to: " .. port)
end

-- Set up Neovim commands
function M.setup()
    vim.api.nvim_create_user_command("ArduinoDetect", M.detect_board, {})
    vim.api.nvim_create_user_command("ArduinoCompile", M.compile, {})
    vim.api.nvim_create_user_command("ArduinoUpload", M.upload, {})
    vim.api.nvim_create_user_command("ArduinoSetBoard", function(opts)
        M.set_board(opts.args)
    end, { nargs = 1 })
    vim.api.nvim_create_user_command("ArduinoSetPort", function(opts)
        M.set_port(opts.args)
    end, { nargs = 1 })
end

return M
