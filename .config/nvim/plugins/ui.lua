-- Fixed UTC+8 clock, independent of the machine's timezone
local function utc8_hour()
  return os.date("!*t", os.time() + 8 * 3600).hour
end

-- stylua: ignore
local greeting_pools = {
  late_night = { -- 0-4
    "It's the middle of the night. Even Neovim is idle.",
    "Real lazy devs let the LSP do the night shift.",
    "Still up? Your bed called. It misses you.",
    "The quickest fix is sleep. Debug tomorrow.",
  },
  morning = { -- 5-10
    "Morning. Let's coast through it, lazy style.",
    "Good morning. Do less, but better.",
    "Slow start is still a start. Hi.",
    "Lazy morning, efficient afternoon. Maybe.",
    "Coffee's brewing, plugins are lazy-loading.",
  },
  noon = { -- 11-13
    "Lazy lunch first. The code can wait.",
    "Nap now, merge later. It's noon.",
    "Good noon. Delegate the boring parts.",
    "Half-day of rest, half-day of genius.",
  },
  afternoon = { -- 14-17
    "Good afternoon. Autocompletion exists for a reason.",
    "Work smart, nap hard. Afternoon vibes.",
    "Slow is smooth. Smooth is lazy.",
    "Hydrate, delegate, autocomplete.",
  },
  evening = { -- 18-21
    "Good evening. Let tomorrow's you handle it.",
    "Wind down. Even lazy people ship things.",
    "Evening: the golden hour of doing nothing.",
    "Good evening. Save, commit, rest.",
  },
  night = { -- 22-23
    "Almost midnight. Take it easy on yourself.",
    "Bed > buffers. You know it's true.",
    "Lazy rule #1: never debug past midnight.",
    "One more line, then actually sleep. Promise.",
  },
}

local function greeting(h)
  math.randomseed() -- OS entropy; snacks re-seeds with os.time() on dashboard load
  local pool = h < 5 and greeting_pools.late_night
    or h < 11 and greeting_pools.morning
    or h < 14 and greeting_pools.noon
    or h < 18 and greeting_pools.afternoon
    or h < 22 and greeting_pools.evening
    or greeting_pools.night
  return "[ " .. pool[math.random(#pool)] .. " ]"
end

local header_logo = (function()
  local logo = [[
       ██╗      █████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗          Z
       ██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██║   ██║██║████╗ ████║      Z
       ██║     ███████║  ███╔╝  ╚████╔╝ ██║   ██║██║██╔████╔██║   z
       ██║     ██╔══██║ ███╔╝    ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ z
       ███████╗██║  ██║███████╗   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║
       ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝
]]
  local lines = vim.split(logo:gsub("^%s+", ""):gsub("\n%s+", "\n"):gsub("%s+$", ""), "\n", { plain = true })
  local width = math.max(unpack(vim.tbl_map(vim.api.nvim_strwidth, lines)))
  for i, line in ipairs(lines) do
    lines[i] = line .. (" "):rep(width - vim.api.nvim_strwidth(line))
  end
  return table.concat(lines, "\n")
end)()

return {
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
      { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
      { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
      { "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
    },
    opts = {
      options = {
      -- stylua: ignore
      close_command = function(n) Snacks.bufdelete(n) end,
      -- stylua: ignore
      right_mouse_command = function(n) Snacks.bufdelete(n) end,
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        diagnostics_indicator = function(_, _, diag)
          local icons = LazyVim.config.icons.diagnostics
          local ret = (diag.error and icons.Error .. diag.error .. " " or "")
            .. (diag.warning and icons.Warn .. diag.warning or "")
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "Neo-tree",
            highlight = "Directory",
            text_align = "left",
          },
          {
            filetype = "snacks_layout_box",
          },
        },
        ---@param opts bufferline.IconFetcherOpts
        get_element_icon = function(opts)
          return LazyVim.config.icons.ft[opts.filetype]
        end,
      },
    },
    config = function(_, opts)
      require("bufferline").setup(opts)
      -- Fix bufferline when restoring a session
      vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
        callback = function()
          vim.schedule(function()
            pcall(nvim_bufferline)
          end)
        end,
      })
    end,
  },
  {
    "nvim-mini/mini.icons",
    lazy = true,
    opts = {
      file = {
        [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
        ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
      },
      filetype = {
        dotenv = { glyph = "", hl = "MiniIconsYellow" },
      },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
  {
    "snacks.nvim",
    init = function()
      local set_greeting_hl = function()
        vim.api.nvim_set_hl(0, "SnacksDashboardGreeting", { link = "String", default = true })
      end
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("dashboard_greeting_hl", { clear = true }),
        callback = set_greeting_hl,
      })
      set_greeting_hl()
    end,
    opts = {
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = false }, -- we set this in options.lua
      toggle = { map = LazyVim.safe_keymap_set },
      words = { enabled = true },
      picker = {
        sources = {
          explorer = {
            layout = { layout = { width = 32, min_width = 32 } },
          },
        },
      },
      dashboard = {
        preset = {
          pick = function(cmd, opts)
            return LazyVim.pick(cmd, opts)()
          end,
          header = header_logo,
       -- stylua: ignore
       ---@type snacks.dashboard.Item[]
       keys = {
         { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
         { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
         { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
         { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
         { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
         { icon = " ", key = "s", desc = "Restore Session", section = "session" },
         { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
         { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
         { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
         },
        sections = {
          { header = header_logo, padding = 1 }, -- padding 1 (default header section uses 2)
          function()
            return {
              { text = { greeting(utc8_hour()), hl = "SnacksDashboardGreeting" }, align = "center", padding = 1 },
            }
          end,
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
      },
    },
  -- stylua: ignore
  keys = {
    { "<leader>n", function()
      if Snacks.config.picker and Snacks.config.picker.enabled then
        Snacks.picker.notifications()
      else
        Snacks.notifier.show_history()
      end
    end, desc = "Notification History" },
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
  },
  },
}
