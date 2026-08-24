return {
  {
    dir = vim.fn.stdpath("config") .. "/lua/colors",
    name = "benben",
    lazy = false,
    priority = 1000,
    config = function()
      require("colors.benben").load()
      -- TODO: current theme
      vim.cmd.colorscheme("benben")
      -- vim.cmd.colorscheme("everforest")
      -- vim.cmd.colorscheme("dracula-soft")
      -- vim.cmd.colorscheme("catppuccin")

      -- Brighten dim UI lines: default WinSeparator (#11111b) / LineNr (#45475a)
      -- are near-invisible on the transparent near-black terminal bg
      local overrides = {
        WinSeparator = { fg = "#7f849c" }, -- overlay1
        VertSplit = { fg = "#7f849c" },
        LineNr = { fg = "#6c7086" }, -- overlay0
        FoldColumn = { fg = "#6c7086" },
        EndOfBuffer = { fg = "#45475a" },
      }
      for group, opts in pairs(overrides) do
        vim.api.nvim_set_hl(0, group, opts)
      end
      -- Re-apply after any :colorscheme switch back to catppuccin
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "catppuccin",
        callback = function()
          for group, opts in pairs(overrides) do
            vim.api.nvim_set_hl(0, group, opts)
          end
        end,
      })
    end,
  },
  {
    "xiyaowong/transparent.nvim",
    config = function()
      require("transparent").setup({ -- Optional, you don't have to run setup.
        groups = { -- table: default groups
          "Normal",
          "NormalNC",
          "Comment",
          "Constant",
          "Special",
          "Identifier",
          "Statement",
          "PreProc",
          "Type",
          "Underlined",
          "Todo",
          "String",
          "Function",
          "Conditional",
          "Repeat",
          "Operator",
          "Structure",
          "LineNr",
          "NonText",
          "SignColumn",
          "CursorLine",
          "CursorLineNr",
          "StatusLine",
          "StatusLineNC",
          "EndOfBuffer",
        },
        extra_groups = { -- table: additional groups that should be cleared
          "NormalFloat", -- plugins which have float panel such as Lazy, Mason, LspInfo
          "NvimTreeNormal", -- NvimTree
        },
        exclude_groups = {}, -- table: groups you don't want to clear
      })
      require("transparent").clear_prefix("BufferLine")
      require("transparent").clear_prefix("NeoTree")
      require("transparent").clear_prefix("RenderMarkdown")
      -- require("transparent").clear_prefix("lualine")
    end,
  },

  {
    "sainnhe/everforest",
    lazy = false,
    priority = 1000,
    config = function()
      -- Optionally configure and load the colorscheme
      -- directly inside the plugin declaration.
      vim.g.everforest_enable_italic = true
      -- vim.cmd.colorscheme("everforest")
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      -- vim.cmd.colorscheme("catppuccin")
    end,
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
      --  colorscheme tokyonight
      --
      -- " There are also colorschemes for the different styles.
      -- colorscheme tokyonight-night
      -- colorscheme tokyonight-storm
      -- colorscheme tokyonight-day
      -- colorscheme tokyonight-moon

      -- vim.cmd.colorscheme("tokyonight-moon")
    end,
  },
  {
    "sainnhe/sonokai",
    lazy = false,
    priority = 1000,
    config = function()
      -- Optionally configure and load the colorscheme
      -- directly inside the plugin declaration.
      vim.g.sonokai_enable_italic = true
      -- `'default'`, `'atlantis'`, `'andromeda'`, `'shusia'`, `'maia'`, `'espresso'`
      vim.g.sonokai_style = "atlantis"
      vim.g.sonokai_better_performance = 1
      -- vim.cmd.colorscheme("sonokai")
    end,
  },
  {
    "Mofiqul/dracula.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- vim.cmd.colorscheme("dracula")
      -- vim.cmd.colorscheme("dracula-soft")
    end,
  },
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
      -- vim.cmd.colorscheme("solarized-osaka")
    end,
  },
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
      -- nightfox, dayfox, dawnfox, duskfox, nordfox, terafox, carbonfox
      -- vim.cmd.colorscheme("nordfox")
    end,
  },
  {
    "2nthony/vitesse.nvim",
    dependencies = {
      "tjdevries/colorbuddy.nvim",
    },
    lazy = false,
    priority = 1000,
    config = function()
      -- vim.cmd.colorscheme("vitesse")
    end,
  },
}
