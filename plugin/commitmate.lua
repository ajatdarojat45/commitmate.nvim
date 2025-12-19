vim.api.nvim_create_user_command("CommitMate", function(opts)
  local commitmate = require("commitmate")

  if opts.args == "ping" then
    commitmate.say_hello()
  elseif opts.args == "" then
    commitmate.generate()
  else
    vim.notify(
      "Unknown subcommand: " .. opts.args .. "\nAvailable: ping",
      vim.log.levels.WARN
    )
  end
end, {
  nargs = "?",
  complete = function()
    return { "ping" }
  end,
  desc = "CommitMate: generate commit or ping",
})
