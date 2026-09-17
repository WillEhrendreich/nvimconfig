-- C# is handled by roslyn_ls, built into nvim-lspconfig (lsp/roslyn_ls.lua) and
-- enabled in nvim-lspconfig.lua's `servers` table. It talks to the mason "roslyn"
-- package (Crashdummyy registry) via the `roslyn-language-server` binary.
--
-- seblyng/roslyn.nvim (previously wired up here, see git history) added Razor
-- support and fancier solution-target picking, at the cost of a hand-patched
-- fsproj/vbproj regex, custom on_init plumbing, and a third-party dependency.
-- Not worth it: we don't touch Razor, and roslyn_ls's root_dir search (.sln/.slnx,
-- falling back to .csproj) is enough for pure C# projects.
return {}
