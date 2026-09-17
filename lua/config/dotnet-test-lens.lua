-- Make roslyn_ls's "Run Test" / "Debug Test" code lenses actually run something.
--
-- roslyn_ls produces those lenses (that is why it, and not easy-dotnet's own
-- Roslyn client, is the C# server kept here -- see lua/plugins/easy-dotnet.lua),
-- but it registers no handler for the `dotnet.test.run` command they carry, so
-- invoking one just reported an unsupported command. easy-dotnet already
-- discovers the tests, tracks their results and owns the debugger wiring, so the
-- lens only needs to find the matching easy-dotnet node and hand it over.
--
-- The lens argument looks like:
--   { attachDebugger = boolean,
--     range = { start = { line, character }, ["end"] = { line, character } },
--     textDocument = { uri = "file://..." } }
-- with 0-based lines, matching easy-dotnet's own `signatureLine` / `endLine`.

local M = {}

local TEST_NODE_TYPES = {
  TestMethod = true,
  Subcase = true,
  TheoryGroup = true,
  TestClass = true,
  ProbableTest = true,
}

local function norm(path)
  return path and vim.fs.normalize(path) or nil
end

--- Every runnable easy-dotnet node declared in `filepath`, keyed by signature line.
--- A theory's group node stands in for its individual cases, the same way
--- easy-dotnet's own buffer mappings treat them.
local function groups_for_file(state, filepath)
  local npath = norm(filepath)
  local groups = {}

  state.traverse_all(function(node)
    if norm(node.filePath) ~= npath then
      return
    end
    local ntype = node.type and node.type.type
    if not (ntype and TEST_NODE_TYPES[ntype]) or node.signatureLine == nil then
      return
    end

    local sig = node.signatureLine
    local group = groups[sig]
    if not group then
      group = { nodes = {}, endLine = node.endLine or sig }
      groups[sig] = group
    end
    table.insert(group.nodes, node)
    if node.endLine and node.endLine > group.endLine then
      group.endLine = node.endLine
    end
  end)

  for _, group in pairs(groups) do
    for _, node in ipairs(group.nodes) do
      if node.type and node.type.type == "TheoryGroup" then
        group.nodes = { node }
        break
      end
    end
  end

  return groups
end

--- The innermost group whose span covers `line`, falling back to the enclosing
--- test class so that a class-level "Run All Tests" lens still resolves.
local function nodes_at_line(state, filepath, line)
  local best, best_span
  for sig, group in pairs(groups_for_file(state, filepath)) do
    local fin = group.endLine or sig
    if line >= sig and line <= fin then
      local span = fin - sig
      if not best_span or span < best_span then
        best, best_span = group.nodes, span
      end
    end
  end
  if best then
    return best
  end

  local npath = norm(filepath)
  local class
  state.traverse_all(function(node)
    if class or norm(node.filePath) ~= npath then
      return
    end
    if not (node.type and node.type.type == "TestClass") then
      return
    end
    local first, last = math.huge, -1
    for _, child in ipairs(state.children(node.id)) do
      if child.signatureLine then
        first = math.min(first, child.signatureLine)
      end
      if child.endLine then
        last = math.max(last, child.endLine)
      end
    end
    if line >= first and line <= last then
      class = node
    end
  end)

  return class and { class } or nil
end

---@param command table the resolved `dotnet.test.run` lens command
---@param ctx table LSP command context
function M.run(command, ctx)
  local arg = (command.arguments or {})[1]
  if type(arg) ~= "table" or not (arg.textDocument and arg.range) then
    vim.notify("dotnet.test.run: unrecognised lens arguments", vim.log.levels.ERROR)
    return
  end

  local ok_state, state = pcall(require, "easy-dotnet.test-runner.state")
  local ok_rpc, rpc = pcall(require, "easy-dotnet.rpc.rpc")
  if not (ok_state and ok_rpc) then
    vim.notify("dotnet.test.run: easy-dotnet is not available to run this test", vim.log.levels.ERROR)
    return
  end

  local filepath = vim.uri_to_fname(arg.textDocument.uri)
  local line = arg.range.start.line
  local nodes = nodes_at_line(state, filepath, line)
  if not nodes or #nodes == 0 then
    vim.notify(
      ("dotnet.test.run: easy-dotnet has not discovered a test at %s:%d yet"):format(vim.fn.fnamemodify(filepath, ":t"), line + 1),
      vim.log.levels.WARN
    )
    return
  end

  local runner = rpc.global_rpc_client.testrunner

  if arg.attachDebugger then
    local node = nodes[1]
    if node.type and node.type.type == "TestClass" then
      vim.notify("dotnet.test.run: easy-dotnet cannot debug a whole test class", vim.log.levels.WARN)
      return
    end
    runner:debug(node.id, function() end, "buffer")
    return
  end

  for _, node in ipairs(nodes) do
    runner:run(node.id, function(result)
      if not result or not result.success then
        vim.notify("dotnet.test.run: run failed", vim.log.levels.ERROR)
      end
    end, "buffer")
  end
end

return M
