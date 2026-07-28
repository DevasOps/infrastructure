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
    -- Sync WSL clipboard with Windows clipboard
    vim.g.clipboard = {
      name = "WslClipboard",
      copy = {
        ["+"] = "/mnt/c/Windows/System32/clip.exe",
        ["*"] = "/mnt/c/Windows/System32/clip.exe",
      },
      paste = {
        ["+"] = [[/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoLogo -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))]],
        ["*"] = [[/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoLogo -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))]],
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
