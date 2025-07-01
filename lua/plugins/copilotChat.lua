local util = require("config.util")
local LazyVimUtil = require("lazyvim.util")
local hasCopilotChat = LazyVimUtil.has("CopilotChat.nvim")
local funcLeaning =
  "Always prefer Functional Programming paradigms, such as immutability, pure functions, and higher-order functions. Avoid side effects and mutable state where possible. Use recursion and higher-order functions to express complex logic in a clear and concise manner."
local noChatOpts = {
  debug = false, -- Enable debug logging
  proxy = nil, -- [protocol://]host[:port] Use this proxy
  allow_insecure = true, -- Allow insecure server connections

  model = "gpt-4.1", -- GPT model to use,
  temperature = 0.1, -- GPT temperature

  question_header = "", -- Header to use for user questions
  answer_header = "**Copilot** ", -- Header to use for AI answers
  error_header = "**Error** ", -- Header to use for errors
  separator = "---", -- Separator to use in chat

  show_folds = true, -- Shows folds for sections in chat
  show_help = true, -- Shows help message as virtual lines when waiting for user input
  auto_follow_cursor = true, -- Auto-follow cursor in chat
  auto_insert_mode = false, -- Automatically enter insert mode when opening window and if auto follow cursor is enabled on new prompt
  clear_chat_on_new_prompt = false, -- Clears chat on every new prompt

  context = "buffers", -- Default context to use, 'buffers', 'buffer' or none (can be specified manually in prompt via @).
  history_path = vim.fn.stdpath("data") .. "/copilotchat_history", -- Default path to stored history
  callback = nil, -- Callback to use when ask response is received

  -- default prompts
  prompts = {

    Explain = {
      prompt = funcLeaning
        .. "Write an explanation for the code above as paragraphs of text. Explain like I'm a ten year old, who knows basic programming concepts and loves functional programming, but needs clear imagery to build a mental model from. ",
    },
    Tests = {
      prompt = funcLeaning
        .. "Write a set of detailed unit test functions for the code.  If the current language is a dotnet language, prefer writing fsharp tests using the Expecto library, and in the Expecto.Flip style where the result can be piped into the expect assertion. ",
    },
    Fix = {
      prompt = funcLeaning .. "There is a problem in this code. Rewrite the code to show it with the bug fixed. ",
    },
    Optimize = {
      prompt = funcLeaning .. "Optimize the selected code to improve performance and readablilty.",
    },
    Docs = {
      prompt = funcLeaning
        .. "Write documentation for the selected code. The reply should be a codeblock containing the original code with the documentation added as comments. Use the most appropriate documentation style for the programming language used (e.g. JSDoc for JavaScript, docstrings for Python etc.",
    },
    Review = {
      prompt = funcLeaning .. "Please review the following code and provide suggestions for improvement.",
    },
    Refactor = {
      prompt = funcLeaning .. "Please refactor the following code to improve its clarity and readability.",
    },
    FixCode = {
      prompt = funcLeaning .. "Please fix the following code to make it work as intended.",
    },
    FixError = {
      prompt = funcLeaning .. "Please explain the error in the following text and provide a solution.",
    },
    BetterNamings = {
      prompt = funcLeaning .. "Please provide better names for the following variables and functions.",
    },
    Documentation = {
      prompt = funcLeaning .. "Please provide documentation for the following code.",
    },
    SwaggerApiDocs = {
      prompt = funcLeaning .. "Please provide documentation for the following API using Swagger.",
    },
    SwaggerJsDocs = {
      prompt = funcLeaning .. "Please write JSDoc for the following API using Swagger.",
    },
    -- Text related prompts
    Summarize = { prompt = "Please summarize the following text." },
    Spelling = { prompt = "Please correct any grammar and spelling errors in the following text." },
    Wording = { prompt = "Please improve the grammar and wording of the following text." },
    Concise = { prompt = "Please rewrite the following text to make it more concise." },
  },

  -- default window options
  window = {
    layout = "vertical", -- 'vertical', 'horizontal', 'float'
    -- Options below only apply to floating windows
    relative = "editor", -- 'editor', 'win', 'cursor', 'mouse'
    border = "single", -- 'none', single', 'double', 'rounded', 'solid', 'shadow'
    width = 0.6, -- fractional width of parent
    height = 0.6, -- fractional height of parent
    row = nil, -- row position of the window, default is centered
    col = nil, -- column position of the window, default is centered
    title = "Copilot Chat", -- title of chat window
    footer = nil, -- footer of chat window
    zindex = 1, -- determines if window is on top or below other floating windows
  },

  -- default mappings
  mappings = {
    complete = {
      detail = "Use @<Tab> or /<Tab> for options.",
      insert = "<Tab>",
    },
    close = {
      normal = "q",
      insert = "<C-c>",
    },
    reset = {
      normal = "<M-r>",
      insert = "<M-r>",
    },
    submit_prompt = {
      normal = "<CR>",
      insert = "<C-m>",
    },
    accept_diff = {
      normal = "<C-y>",
      insert = "<C-y>",
    },
    yank_diff = {
      normal = "gy",
    },
    show_diff = {
      normal = "gd",
    },
    show_system_prompt = {
      normal = "gp",
    },
    show_user_selection = {
      normal = "gs",
    },
  },
}
local getChatOpts = function()
  if not hasCopilotChat then
    return noChatOpts
  else
    local select = require("CopilotChat.select")
    return vim.tbl_extend("force", noChatOpts, {

      -- default selection (visual or line)
      selection = function(source)
        return require("CopilotChat.select").visual(source) or require("CopilotChat.select").line(source)
      end,

      -- default prompts
      prompts = {
        FixDiagnostic = {
          prompt = "Please assist with the following diagnostic issue in file:",
          selection = "context.diagnostics",
        },
        Commit = {
          prompt = "Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.",
          selection = "context.gitdiff",
        },
        CommitStaged = {
          prompt = "Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.",
          selection = "context.gitdiff",
        },
      },
    })
  end
end

return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    opts = getChatOpts(),
  },
}

--
--     :CopilotChat <input>? - Open chat window with optional input
--     :CopilotChatOpen - Open chat window
--     :CopilotChatClose - Close chat window
--     :CopilotChatToggle - Toggle chat window
--     :CopilotChatReset - Reset chat window
--     :CopilotChatSave <name>? - Save chat history to file
--     :CopilotChatLoad <name>? - Load chat history from file
--     :CopilotChatDebugInfo - Show debug information
--
-- Commands coming from default prompts
--
--     :CopilotChatExplain - Explain how it works
--     :CopilotChatTests - Briefly explain how selected code works then generate unit tests
--     :CopilotChatFix - There is a problem in this code. Rewrite the code to show it with the bug fixed.
--     :CopilotChatOptimize - Optimize the selected code to improve performance and readablilty.
--     :CopilotChatDocs - Write documentation for the selected code. The reply should be a codeblock containing the original code with the documentation added as comments. Use the most appropriate documentation style for the programming language used (e.g. JSDoc for JavaScript, docstrings for Python etc.
--     :CopilotChatFixDiagnostic - Please assist with the following diagnostic issue in file
--     :CopilotChatCommit - Write commit message for the change with commitizen convention
--     :CopilotChatCommitStaged - Write commit message for the change with commitizen convention
--
