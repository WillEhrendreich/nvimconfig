-- Align LSP code lenses with the code they annotate.
--
-- Neovim 0.12 draws each code lens as a virtual line padded to the *start column
-- of the lens range* (`string.rep(' ', range.start_col)` in
-- runtime/lua/vim/lsp/codelens.lua). Roslyn anchors its lenses on the symbol
-- name rather than the statement, so "8 references" above
--
--     public sealed record AccessCredential(SignedJwt Token, ...)
--
-- lands 21 columns in, floating off to the right of the line it belongs to.
-- Rewriting each lens range to the code line's own indentation puts the lens
-- directly above its code, the way VS Code renders it.
--
-- There is no public seam for this. The padding happens inside a private
-- decoration provider, and that provider asks the client for lenses with an
-- explicit callback, so neither `vim.lsp.handlers` nor a server's `handlers`
-- table is ever consulted. The one stable place left is `Client.request` on the
-- client class itself, which instances inherit through `__index`, so wrapping it
-- once covers every client, whenever it starts. Everything below is guarded: if
-- a future Neovim reshapes these internals, this quietly becomes a no-op and
-- lenses simply go back to being indented the way Neovim indents them.

local M = {}

local CODE_LENS = "textDocument/codeLens"

--- Column (0-based) of the first non-blank character on `row` (0-based).
---@param bufnr integer
---@param row integer
---@return integer
local function indent_col(bufnr, row)
  local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
  if not line then
    return 0
  end
  return #line:match("^%s*")
end

---@param bufnr integer
---@param result lsp.CodeLens[]?
local function realign(bufnr, result)
  for _, lens in ipairs(result or {}) do
    local range = lens.range
    if range and range.start and range.start.line then
      -- Leading whitespace is ASCII, so a byte count is also a valid UTF-16
      -- character offset here, whatever the client's position encoding.
      range.start.character = indent_col(bufnr, range.start.line)
    end
  end
end

function M.setup()
  local ok, Client = pcall(require, "vim.lsp.client")
  if not ok or type(Client) ~= "table" or type(Client.request) ~= "function" then
    return
  end
  if Client.__codelens_align_wrapped then
    return
  end
  Client.__codelens_align_wrapped = true

  local request = Client.request
  Client.request = function(self, method, params, handler, bufnr)
    if method == CODE_LENS and type(handler) == "function" then
      local inner = handler
      handler = function(err, result, ctx)
        local target = ctx and ctx.bufnr or bufnr
        if not err and target and vim.api.nvim_buf_is_valid(target) then
          pcall(realign, target, result)
        end
        return inner(err, result, ctx)
      end
    end
    return request(self, method, params, handler, bufnr)
  end
end

return M
