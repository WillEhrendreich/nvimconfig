return {
  compile_path = astronvim.default_compile_path,
  display = {
    open_fn = function() return require("packer.util").float { border = "rounded" } end,
  },
  profile = {
    enable = true,
    threshold = 0.0001,
  },
  git = {
    clone_timeout = 600,
    subcommands = {
      update = "pull --rebase",
    },
  },
  auto_clean = true,
  compile_on_sync = true,
  max_jobs = 20,
}
