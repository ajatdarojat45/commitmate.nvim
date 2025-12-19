local M = {}

local config = {
  open_lazygit = false,
  ping_message = "CommitMate.nvim is ready 🤝",
  chat_float = true,
  float_opts = {
    width = 0.60,
    height = 0.60,
    border = "rounded",
  },
}

function M.setup(opts) 
  config = vim.tbl_deep_extend("force", config, opts or {})
end

function M.say_hello()
  vim.notify(config.ping_message, vim.log.levels.INFO)
end

-- Open CopilotChat buffer in a floating window
local function open_copilotchat_float()
  vim.defer_fn(function()
    local bufnr = vim.fn.bufnr("copilot-chat")
    if bufnr == -1 then return end

    -- Close any existing windows showing this buffer
    for _, w in ipairs(vim.api.nvim_list_wins()) do
      local wb = vim.api.nvim_win_get_buf(w)
      if wb == bufnr then
        pcall(vim.api.nvim_win_close, w, true)
      end
    end

    local cols = vim.o.columns
    local lines = vim.o.lines
    local width = math.max(20, math.floor(cols * (config.float_opts and config.float_opts.width or 0.85)))
    local height = math.max(10, math.floor(lines * (config.float_opts and config.float_opts.height or 0.85)))
    local row = math.max(1, math.floor((lines - height) / 2 - 1))
    local col = math.max(1, math.floor((cols - width) / 2))

    vim.api.nvim_open_win(bufnr, true, {
      relative = "editor",
      row = row,
      col = col,
      width = width,
      height = height,
      style = "minimal",
      border = (config.float_opts and config.float_opts.border) or "rounded",
    })
  end, 200)
end

-- Extract commit message from CopilotChat buffer
local function extract_commit_message()
  local bufnr = vim.fn.bufnr("copilot-chat")
  if bufnr == -1 then
    vim.notify("Failed to get commit message", vim.log.levels.ERROR)
    return nil
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local response_lines = {}
  local in_copilot = false

  for _, line in ipairs(lines) do
    if line:match("^# Copilot") then
      in_copilot = true
    elseif line:match("^# User") then
      in_copilot = false
    elseif in_copilot and not line:match("^#") and line ~= "" then
      table.insert(response_lines, line)
    end
  end

  local commit_msg = table.concat(response_lines, "\n")
    :gsub("```gitcommit\n", "")
    :gsub("```", "")
    :gsub("^%s+", "")
    :gsub("%s+$", "")

  if commit_msg == "" then
    vim.notify("No commit message generated", vim.log.levels.WARN)
    return nil
  end

  return commit_msg
end

-- Save commit message to clipboard and file
local function save_commit_message(commit_msg, git_root)
  -- Copy to clipboard
  vim.fn.setreg("+", commit_msg)

  -- Write COMMIT_EDITMSG
  local path = git_root .. "/.git/COMMIT_EDITMSG"
  os.remove(path)
  local f = io.open(path, "w")
  if f then
    f:write(commit_msg)
    f:close()
  end
end

-- Automate lazygit commit form with paste
local function automate_lazygit_paste(commit_msg)
  vim.defer_fn(function()
    local term_bufnr = vim.fn.bufnr("%")
    local job_id = vim.b[term_bufnr].terminal_job_id
    if not job_id then return end

    -- Navigate to commit screen
    vim.api.nvim_chan_send(job_id, "c")
    
    -- Clear and paste commit message
    vim.defer_fn(function()
      -- Clear summary field
      vim.api.nvim_chan_send(job_id, "\x15")
      
      -- Navigate to description and clear it thoroughly
      vim.api.nvim_chan_send(job_id, "\t")
      for _ = 1, 10 do
        vim.api.nvim_chan_send(job_id, "\x15")
      end
      
      -- Return to summary field
      vim.api.nvim_chan_send(job_id, "\t")
      
      -- Paste commit message
      vim.defer_fn(function()
        vim.api.nvim_chan_send(job_id, "\x1b[200~" .. commit_msg .. "\x1b[201~")
      end, 100)
    end, 500)
  end, 800)
end

-- Open lazygit in terminal and setup automation
local function open_lazygit_with_message(commit_msg)
  vim.cmd("terminal lazygit")
  vim.cmd("autocmd TermClose <buffer> bdelete!")
  vim.cmd("startinsert")
  
  automate_lazygit_paste(commit_msg)
  
  vim.notify(
    "Commit message ready — review in lazygit and press Enter",
    vim.log.levels.INFO
  )
end

-- Get git repository root directory
local function get_git_root()
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    vim.notify("Not in a git repository", vim.log.levels.ERROR)
    return nil
  end
  return git_root
end

-- Get staged changes diff
local function get_staged_diff(git_root)
  local staged_diff = vim.fn.system("cd " .. git_root .. " && git diff --cached")
  if staged_diff == "" or staged_diff:match("^fatal:") then
    vim.notify("No staged changes found. Use 'git add' first.", vim.log.levels.WARN)
    return nil
  end
  return staged_diff
end

-- Handle the generated commit message
local function handle_commit_message(commit_msg, git_root)
  save_commit_message(commit_msg, git_root)
  vim.cmd("close")

  if config.open_lazygit then
    open_lazygit_with_message(commit_msg)
  else
    vim.notify(
      "Commit message generated! Saved to .git/COMMIT_EDITMSG and copied to clipboard",
      vim.log.levels.INFO
    )
  end
end

function M.generate()
  local git_root = get_git_root()
  if not git_root then return end

  local staged_diff = get_staged_diff(git_root)
  if not staged_diff then return end

  local chat = require("CopilotChat")
  chat.reset()

  local prompt = "Write a commit message following commitizen convention for these changes:\n\n"
    .. staged_diff
    .. "\n\nKeep title under 50 characters, wrap body at 72 characters. Output ONLY the commit message."

  chat.ask(prompt, {
    callback = function()
      vim.defer_fn(function()
        local commit_msg = extract_commit_message()
        if commit_msg then
          handle_commit_message(commit_msg, git_root)
        end
      end, 1500)
    end,
  })

  if config.chat_float then
    open_copilotchat_float()
  end
end

return M
