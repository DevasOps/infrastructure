-- ╭─────────────────────────────────────────────────────────╮
-- │ Settings                                                │
-- ╰─────────────────────────────────────────────────────────╯

---@type core.settings
local M = {}

--------------------------------------------------------------------------------
--  Options
--------------------------------------------------------------------------------
M.options = {
  formatoptions = "jqlnt", -- Formatting options
  helplang = "de", -- Set the language for the help messages
  swapfile = false, -- Disable swap file
  mousemodel = "extend", -- 右键不再弹出上下文菜单（改为选区扩展）

  -- Indentation
  softtabstop = 2, -- Number of spaces that a <Tab> counts for while performing editing operations, like inserting a <Tab> or using <BS>

  -- Spelling
  spelllang = { "en_us", "de_de" },

  -- Wrap
  breakindent = true, -- Indent wrapped lines visually
  showbreak = core.icons.ui.Tab .. " ", -- Character displayed for the break
  wrap = true, -- Wrap lines
}

--------------------------------------------------------------------------------
--  Globals
--------------------------------------------------------------------------------
M.globals = {
  lazyvim_check_order = false,
}

--------------------------------------------------------------------------------
--  Disabled providers
--------------------------------------------------------------------------------
M.disabled_providers = { "perl", "ruby", "node", "python3" }

--------------------------------------------------------------------------------
--  Additional settings
--------------------------------------------------------------------------------
function M.run()
  -- Go to previous/next line with h/l/left arrow/right arrow when cursor reaches end/beginning of line
  vim.opt.whichwrap:append("<>[]hl")

  -- For Tailwind CSS wraps
  vim.opt.breakat:remove({ ":", "/", "-" })

  -- Modify shortmess
  vim.opt.shortmess:append({
    a = true, -- append `l`, `m`, `r`, `w` abbreviations
    A = true, -- don't give the "ATTENTION" message when an existing swap file is found
  })

  if utils.shell.is_nushell() then
    utils.shell.setup_nushell()
  end

  -- Setup WSL clipboard
  if utils.is_wsl() then
    -- Sync WSL clipboard with Windows clipboard via win32yank.
    -- win32yank handles UTF-8 correctly in both directions (unlike clip.exe,
    -- which decodes stdin as the console codepage and mangles CJK text).
    -- Use an absolute path so we don't depend on Windows PATH injection,
    -- which is disabled here to keep Nushell startup fast.
    vim.g.clipboard = {
      name = "win32yank",
      copy = {
        ["+"] = "/mnt/c/Windows/win32yank.exe -i --crlf",
        ["*"] = "/mnt/c/Windows/win32yank.exe -i --crlf",
      },
      paste = {
        ["+"] = "/mnt/c/Windows/win32yank.exe -o --lf",
        ["*"] = "/mnt/c/Windows/win32yank.exe -o --lf",
      },
      cache_enabled = 0,
    }
    -- Make yy/dd/p use system clipboard by default
    vim.opt.clipboard = "unnamedplus"
  end

  -- Setup SSH clipboard
  if vim.env.SSH_TTY then
    vim.g.clipboard = "osc52"
  end
end

return M
