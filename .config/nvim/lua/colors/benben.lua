-- OpenCode Theme - dark background with neon cyan / pink / lime accents
-- Retro terminal x neon cyberpunk, tuned for long reading sessions

local M = {}

-- Color palette
local colors = {
  -- Backgrounds (darkest to lightest), blue-violet tinted
  bg0 = "#080812", -- Main background
  bg1 = "#0e0e1a", -- Sidebar background
  bg2 = "#151524", -- Selection background
  bg3 = "#1d1d2e", -- Float background
  bg4 = "#262638", -- Active line background

  -- Accent hierarchy: neon (primary) > pink (interactive) > lime (status);
  -- violet/deep_blue/mint extend the markdown heading gradient
  neon = "#22cfcf", -- Primary accent (neon cyan)
  pink = "#efaaef", -- Interactive accent
  lime = "#b7dba0", -- Status/success accent
  violet = "#5B48F9", -- Vibrant blue-violet
  deep_blue = "#0d4f99", -- Deep blue (darkest accent)
  mint = "#77efcf", -- Light mint

  -- Text colors
  fg0 = "#f0f0ff", -- Main text
  fg1 = "#d0e0e0", -- Dimmed text
  fg2 = "#80bea0", -- Comments
  fg3 = "#8090a0", -- Inactive text
  fg4 = "#60a0a0", -- Inactive line

  -- Syntax colors (supporting cast, desaturated)
  red = "#f38ba8", -- Errors, keywords
  orange = "#e8a878", -- Numbers, constants
  yellow = "#e6d5a3", -- Warnings, types
  green = "#a6e3a1", -- Strings, success
  cyan = "#89dceb", -- Functions, methods
  lavender = "#bba8f9", -- Variables, identifiers
  peach = "#cfa890", -- Properties, fields

  -- UI colors
  border = "#3d3d50", -- Window borders
  cursor = "#efefef", -- Cursor
  highlight = "#4a6d8f", -- Selection highlight
  gray = "#6b6f95", -- Bright black (dim text in TUIs, muted violet-gray)
}

-- Terminal colors
local terminal = {
  colors.bg0, -- Black
  colors.red, -- Red
  colors.green, -- Green
  colors.yellow, -- Yellow
  colors.lavender, -- Blue slot (lavender)
  colors.pink, -- Magenta
  colors.cyan, -- Cyan
  colors.fg1, -- White
  colors.gray, -- Bright Black (muted violet-gray)
  colors.red, -- Bright Red
  colors.green, -- Bright Green
  colors.yellow, -- Bright Yellow
  colors.lavender, -- Bright Blue slot (lavender)
  colors.pink, -- Bright Magenta
  colors.cyan, -- Bright Cyan
  colors.fg0, -- Bright White
}

-- Highlight groups
local highlights = {
  -- Normal text
  Normal = { fg = colors.fg0, bg = colors.bg0 },
  NormalNC = { fg = colors.fg1, bg = colors.bg0 },
  NormalFloat = { fg = colors.fg0, bg = colors.bg3 },

  -- Cursor
  Cursor = { fg = colors.bg0, bg = colors.cursor },
  CursorLine = { bg = colors.bg4 },
  CursorLineNr = { fg = colors.neon, bg = colors.bg1 },
  CursorColumn = { bg = colors.bg2 },
  LineNr = { fg = colors.fg3, bg = colors.bg1 },

  -- Visual and selection
  Visual = { bg = colors.highlight },
  VisualNOS = { bg = colors.highlight },

  -- Search
  Search = { fg = colors.bg0, bg = colors.neon },
  IncSearch = { fg = colors.bg0, bg = colors.pink },
  Substitute = { fg = colors.bg0, bg = colors.orange },

  -- Popup menu
  Pmenu = { fg = colors.fg0, bg = colors.bg3 },
  PmenuSel = { fg = colors.bg0, bg = colors.lime },
  PmenuSbar = { bg = colors.bg2 },
  PmenuThumb = { bg = colors.violet },

  -- Statusline
  StatusLine = { fg = colors.fg0, bg = colors.bg3 },
  StatusLineNC = { fg = colors.fg3, bg = colors.bg1 },

  -- Tabline
  TabLine = { fg = colors.fg2, bg = colors.bg1 },
  TabLineFill = { bg = colors.bg0 },
  TabLineSel = { fg = colors.neon, bg = colors.bg2, bold = true },

  -- Window
  VertSplit = { fg = colors.border, bg = colors.bg0 },
  WinSeparator = { fg = colors.border, bg = colors.bg0 },

  -- Folds
  Folded = { fg = colors.fg2, bg = colors.bg2 },
  FoldColumn = { fg = colors.fg3, bg = colors.bg1 },
  SignColumn = { fg = colors.fg3, bg = colors.bg1 },

  -- Messages
  ModeMsg = { fg = colors.neon },
  MoreMsg = { fg = colors.neon },
  WarningMsg = { fg = colors.yellow },
  ErrorMsg = { fg = colors.red },

  -- Comments
  Comment = { fg = colors.fg2, italic = true },
  SpecialComment = { fg = colors.lime, italic = true },
  Todo = { fg = colors.yellow, bg = colors.bg2, bold = true },

  -- Constants
  Constant = { fg = colors.orange },
  String = { fg = colors.green },
  Character = { fg = colors.green },
  Number = { fg = colors.orange },
  Boolean = { fg = colors.orange },
  Float = { fg = colors.orange },

  -- Identifiers
  Identifier = { fg = colors.lavender },
  Function = { fg = colors.cyan },
  Method = { fg = colors.cyan },
  Property = { fg = colors.peach },
  Field = { fg = colors.peach },

  -- Statements
  Statement = { fg = colors.neon },
  Conditional = { fg = colors.neon },
  Repeat = { fg = colors.neon },
  Label = { fg = colors.lime },
  Operator = { fg = colors.fg0 },
  Keyword = { fg = colors.neon },
  Exception = { fg = colors.red },

  -- Preprocessor
  PreProc = { fg = colors.lime },
  Include = { fg = colors.lime },
  Define = { fg = colors.violet },
  Macro = { fg = colors.violet },
  PreCondit = { fg = colors.lime },

  -- Types
  Type = { fg = colors.yellow },
  StorageClass = { fg = colors.lime },
  Structure = { fg = colors.yellow },
  Typedef = { fg = colors.yellow },

  -- Special
  Special = { fg = colors.pink },
  SpecialChar = { fg = colors.orange },
  Tag = { fg = colors.cyan },
  Delimiter = { fg = colors.fg1 },
  SpecialKey = { fg = colors.fg3 },

  -- Text
  Title = { fg = colors.neon, bold = true },
  Underlined = { fg = colors.cyan, underline = true },
  Ignore = { fg = colors.fg3 },
  Error = { fg = colors.red, bg = colors.bg2 },
  NonText = { fg = colors.fg4 }, -- inactive file name
  Whitespace = { fg = colors.bg2 },

  -- Diff
  DiffAdd = { fg = colors.green, bg = colors.bg2 },
  DiffChange = { fg = colors.yellow, bg = colors.bg2 },
  DiffDelete = { fg = colors.red, bg = colors.bg2 },
  DiffText = { fg = colors.cyan, bg = colors.bg3 },

  -- Git
  gitcommitBranch = { fg = colors.fg3 },
  gitcommitComment = { fg = colors.fg2 },
  gitcommitDiscardedFile = { fg = colors.red },
  gitcommitFile = { fg = colors.fg0 },
  gitcommitHeader = { fg = colors.lime },
  gitcommitOnBranch = { fg = colors.fg1 },
  gitcommitSelectedFile = { fg = colors.green },
  gitcommitUnmergedFile = { fg = colors.yellow },
  gitcommitUntrackedFile = { fg = colors.cyan },

  -- Markdown
  markdownHeadingDelimiter = { fg = colors.neon, bold = true },
  markdownHeadingRule = { fg = colors.lime },
  markdownLinkText = { fg = colors.cyan },
  markdownUrl = { fg = colors.peach, underline = true },
  markdownCode = { fg = colors.green },
  markdownCodeBlock = { fg = colors.green },
  markdownBlockquote = { fg = colors.fg2 },
  markdownListMarker = { fg = colors.neon },

  -- Treesitter
  ["@variable"] = { fg = colors.lavender },
  ["@variable.builtin"] = { fg = colors.lime },
  ["@variable.parameter"] = { fg = colors.cyan },
  ["@variable.member"] = { fg = colors.peach },
  ["@constant"] = { fg = colors.orange },
  ["@constant.builtin"] = { fg = colors.orange },
  ["@constant.macro"] = { fg = colors.violet },
  ["@module"] = { fg = colors.yellow },
  ["@module.builtin"] = { fg = colors.yellow },
  ["@label"] = { fg = colors.lime },
  ["@string"] = { fg = colors.green },
  ["@string.documentation"] = { fg = colors.fg1 },
  ["@string.regexp"] = { fg = colors.peach },
  ["@string.escape"] = { fg = colors.orange },
  ["@string.special"] = { fg = colors.neon },
  ["@character"] = { fg = colors.green },
  ["@character.special"] = { fg = colors.neon },
  ["@boolean"] = { fg = colors.orange },
  ["@number"] = { fg = colors.orange },
  ["@number.float"] = { fg = colors.orange },
  ["@type"] = { fg = colors.yellow },
  ["@type.builtin"] = { fg = colors.yellow },
  ["@type.definition"] = { fg = colors.yellow },
  ["@type.qualifier"] = { fg = colors.lime },
  ["@attribute"] = { fg = colors.lime },
  ["@property"] = { fg = colors.peach },
  ["@function"] = { fg = colors.cyan },
  ["@function.builtin"] = { fg = colors.cyan },
  ["@function.call"] = { fg = colors.cyan },
  ["@function.macro"] = { fg = colors.violet },
  ["@function.method"] = { fg = colors.cyan },
  ["@function.method.call"] = { fg = colors.cyan },
  ["@constructor"] = { fg = colors.yellow },
  ["@operator"] = { fg = colors.fg0 },
  ["@keyword"] = { fg = colors.neon },
  ["@keyword.coroutine"] = { fg = colors.neon },
  ["@keyword.function"] = { fg = colors.neon },
  ["@keyword.operator"] = { fg = colors.lime },
  ["@keyword.import"] = { fg = colors.lime },
  ["@keyword.storage"] = { fg = colors.lime },
  ["@keyword.repeat"] = { fg = colors.neon },
  ["@keyword.return"] = { fg = colors.neon },
  ["@keyword.debug"] = { fg = colors.red },
  ["@keyword.exception"] = { fg = colors.red },
  ["@keyword.conditional"] = { fg = colors.neon },
  ["@keyword.conditional.ternary"] = { fg = colors.lime },
  ["@keyword.directive"] = { fg = colors.lime },
  ["@keyword.directive.define"] = { fg = colors.violet },
  ["@punctuation.delimiter"] = { fg = colors.fg1 },
  ["@punctuation.bracket"] = { fg = colors.fg1 },
  ["@punctuation.special"] = { fg = colors.neon },
  ["@comment"] = { fg = colors.fg2, italic = true },
  ["@comment.documentation"] = { fg = colors.fg1, italic = true },
  ["@comment.error"] = { fg = colors.red, italic = true },
  ["@comment.warning"] = { fg = colors.yellow, italic = true },
  ["@comment.todo"] = { fg = colors.yellow, bg = colors.bg2, bold = true },
  ["@comment.note"] = { fg = colors.cyan, italic = true },

  -- LSP
  LspReferenceText = { bg = colors.highlight },
  LspReferenceRead = { bg = colors.highlight },
  LspReferenceWrite = { bg = colors.highlight },
  LspCodeLens = { fg = colors.fg2 },
  LspCodeLensSeparator = { fg = colors.fg3 },
  LspSignatureActiveParameter = { fg = colors.neon, bold = true },

  -- Diagnostics
  DiagnosticError = { fg = colors.red },
  DiagnosticWarn = { fg = colors.yellow },
  DiagnosticInfo = { fg = colors.lavender },
  DiagnosticHint = { fg = colors.peach },
  DiagnosticVirtualTextError = { fg = colors.red, bg = colors.bg2 },
  DiagnosticVirtualTextWarn = { fg = colors.yellow, bg = colors.bg2 },
  DiagnosticVirtualTextInfo = { fg = colors.lavender, bg = colors.bg2 },
  DiagnosticVirtualTextHint = { fg = colors.peach, bg = colors.bg2 },
  DiagnosticUnderlineError = { underline = true, sp = colors.red },
  DiagnosticUnderlineWarn = { underline = true, sp = colors.yellow },
  DiagnosticUnderlineInfo = { underline = true, sp = colors.lavender },
  DiagnosticUnderlineHint = { underline = true, sp = colors.peach },

  -- LSP Saga
  LspFloatWinNormal = { bg = colors.bg3 },
  LspFloatWinBorder = { fg = colors.border },
  LspSagaHoverBorder = { fg = colors.lime },
  LspSagaSignatureHelpBorder = { fg = colors.lime },
  LspSagaCodeActionBorder = { fg = colors.lime },
  LspSagaDefPreviewBorder = { fg = colors.lime },
  LspSagaAutoPreview = { fg = colors.fg1 },
  LspSagaFinderSelection = { fg = colors.neon },
  ReferencesCount = { fg = colors.orange },
  DefinitionCount = { fg = colors.orange },
  DefinitionIcon = { fg = colors.lavender },
  TargetWord = { fg = colors.cyan },

  -- NvimTree
  NvimTreeNormal = { fg = colors.fg0, bg = colors.bg1 },
  NvimTreeNormalNC = { fg = colors.fg1, bg = colors.bg1 },
  NvimTreeRootFolder = { fg = colors.neon, bold = true },
  NvimTreeFolderIcon = { fg = colors.lime },
  NvimTreeFolderName = { fg = colors.lavender, bold = true },
  NvimTreeEmptyFolderName = { fg = colors.fg2 },
  NvimTreeOpenedFolderName = { fg = colors.neon, bold = true },
  NvimTreeGitDirty = { fg = colors.yellow },
  NvimTreeGitNew = { fg = colors.green },
  NvimTreeGitDeleted = { fg = colors.red },
  NvimTreeGitIgnored = { fg = colors.fg1 },
  NvimTreeSpecialFile = { fg = colors.cyan },
  NvimTreeImageFile = { fg = colors.orange },
  NvimTreeWindowPicker = { fg = colors.pink, bg = colors.bg3, bold = true },

  -- NeoTree
  NeoTreeNormal = { fg = colors.fg0, bg = colors.bg1 },
  NeoTreeNormalNC = { fg = colors.fg1, bg = colors.bg1 },
  NeoTreeRootName = { fg = colors.neon, bold = true },
  NeoTreeDirectoryName = { fg = colors.lavender, bold = true },
  NeoTreeDirectoryIcon = { fg = colors.lime },
  NeoTreeFileName = { fg = colors.fg0, bold = false },
  NeoTreeFileNameOpened = { fg = colors.neon, bold = true },
  NeoTreeGitModified = { fg = colors.yellow },
  NeoTreeGitAdded = { fg = colors.green },
  NeoTreeGitDeleted = { fg = colors.red },
  NeoTreeGitIgnored = { fg = colors.fg1 },
  NeoTreeDotfile = { fg = colors.fg1 },
  NeoTreeFileNameHidden = { fg = colors.fg0 },
  NeoTreeGitUntracked = { fg = colors.cyan },
  NeoTreeGitConflict = { fg = colors.red, bold = true },
  NeoTreeCursorLine = { bg = colors.bg2 },
  NeoTreeIndentMarker = { fg = colors.bg3 },
  NeoTreeExpander = { fg = colors.lime },
  NeoTreeSymbolicLinkTarget = { fg = colors.cyan },

  -- BufferLine
  BufferLineTabClose = { fg = colors.red },
  BufferLineBufferSelected = { fg = colors.neon, bg = colors.bg0, bold = true },
  BufferLineBufferVisible = { fg = colors.fg1, bg = colors.bg2 },
  BufferLineFill = { bg = colors.bg1 },
  BufferLineBackground = { fg = colors.fg2, bg = colors.bg1 },
  BufferLineSeparator = { fg = colors.border },
  BufferLineIndicatorSelected = { fg = colors.lime },
  BufferLineModified = { fg = colors.yellow },
  BufferLineModifiedSelected = { fg = colors.yellow },
  BufferLineModifiedVisible = { fg = colors.yellow },

  -- Telescope
  TelescopeNormal = { fg = colors.fg0, bg = colors.bg3 },
  TelescopeBorder = { fg = colors.border, bg = colors.bg3 },
  TelescopeTitle = { fg = colors.neon, bg = colors.bg2, bold = true },
  TelescopePromptNormal = { fg = colors.fg0, bg = colors.bg2 },
  TelescopePromptBorder = { fg = colors.lime, bg = colors.bg2 },
  TelescopePromptPrefix = { fg = colors.neon },
  TelescopePromptCounter = { fg = colors.fg2 },
  TelescopeMatching = { fg = colors.pink, bold = true },
  TelescopeSelection = { fg = colors.bg0, bg = colors.lime },
  TelescopeSelectionCaret = { fg = colors.neon, bg = colors.lime },
  TelescopeMultiSelection = { fg = colors.peach },
  TelescopePreviewNormal = { fg = colors.fg0, bg = colors.bg0 },
  TelescopePreviewLine = { bg = colors.highlight },
  TelescopePreviewMatch = { fg = colors.pink, bold = true },

  -- Cmp
  CmpItemAbbr = { fg = colors.fg0 },
  CmpItemAbbrDeprecated = { fg = colors.fg2, strikethrough = true },
  CmpItemAbbrMatch = { fg = colors.neon, bold = true },
  CmpItemAbbrMatchFuzzy = { fg = colors.lime, bold = true },
  CmpItemMenu = { fg = colors.fg2 },
  CmpItemKindText = { fg = colors.fg0 },
  CmpItemKindMethod = { fg = colors.cyan },
  CmpItemKindFunction = { fg = colors.cyan },
  CmpItemKindConstructor = { fg = colors.yellow },
  CmpItemKindField = { fg = colors.peach },
  CmpItemKindVariable = { fg = colors.lavender },
  CmpItemKindClass = { fg = colors.yellow },
  CmpItemKindInterface = { fg = colors.yellow },
  CmpItemKindModule = { fg = colors.lime },
  CmpItemKindProperty = { fg = colors.peach },
  CmpItemKindUnit = { fg = colors.orange },
  CmpItemKindValue = { fg = colors.orange },
  CmpItemKindEnum = { fg = colors.yellow },
  CmpItemKindKeyword = { fg = colors.neon },
  CmpItemKindSnippet = { fg = colors.green },
  CmpItemKindColor = { fg = colors.pink },
  CmpItemKindFile = { fg = colors.lavender },
  CmpItemKindReference = { fg = colors.cyan },
  CmpItemKindFolder = { fg = colors.lime },
  CmpItemKindEnumMember = { fg = colors.orange },
  CmpItemKindConstant = { fg = colors.orange },
  CmpItemKindStruct = { fg = colors.yellow },
  CmpItemKindEvent = { fg = colors.neon },
  CmpItemKindOperator = { fg = colors.fg0 },
  CmpItemKindTypeParameter = { fg = colors.yellow },

  -- WhichKey
  WhichKey = { fg = colors.neon },
  WhichKeyGroup = { fg = colors.lavender },
  WhichKeyDesc = { fg = colors.fg0 },
  WhichKeySeperator = { fg = colors.fg2 },
  WhichKeySeparator = { fg = colors.fg2 },
  WhichKeyFloat = { bg = colors.bg3 },
  WhichKeyValue = { fg = colors.fg2 },

  -- GitSigns
  GitSignsAdd = { fg = colors.green },
  GitSignsChange = { fg = colors.yellow },
  GitSignsDelete = { fg = colors.red },
  GitSignsAddLn = { fg = colors.bg0, bg = colors.green },
  GitSignsChangeLn = { fg = colors.bg0, bg = colors.yellow },
  GitSignsDeleteLn = { fg = colors.bg0, bg = colors.red },
  GitSignsCurrentLineBlame = { fg = colors.fg3 },

  -- Indent Blankline
  IndentBlanklineChar = { fg = colors.bg3 },
  IndentBlanklineContextChar = { fg = colors.lime },
  IndentBlanklineSpaceChar = { fg = colors.bg2 },
  IndentBlanklineSpaceCharBlankline = { fg = colors.bg2 },

  -- Mini
  MiniStatuslineModeNormal = { fg = colors.bg0, bg = colors.neon, bold = true },
  MiniStatuslineModeInsert = { fg = colors.bg0, bg = colors.green, bold = true },
  MiniStatuslineModeVisual = { fg = colors.bg0, bg = colors.yellow, bold = true },
  MiniStatuslineModeReplace = { fg = colors.bg0, bg = colors.red, bold = true },
  MiniStatuslineModeCommand = { fg = colors.bg0, bg = colors.lavender, bold = true },
  MiniStatuslineModeOther = { fg = colors.bg0, bg = colors.peach, bold = true },
  MiniStatuslineDevinfo = { fg = colors.fg0, bg = colors.bg3 },
  MiniStatuslineFilename = { fg = colors.fg1, bg = colors.bg2 },
  MiniStatuslineFileinfo = { fg = colors.fg0, bg = colors.bg3 },
  MiniStatuslineInactive = { fg = colors.fg3, bg = colors.bg1 },

  -- Dashboard (dashboard.nvim)
  DashboardHeader = { fg = colors.neon },
  DashboardCenter = { fg = colors.lime },
  DashboardShortcut = { fg = colors.cyan },
  DashboardFooter = { fg = colors.fg2 },

  -- Dashboard (snacks.dashboard - LazyVim default)
  SnacksDashboardHeader = { fg = colors.neon },
  SnacksDashboardDesc = { fg = colors.fg0 },
  SnacksDashboardKey = { fg = colors.neon, bold = true },
  SnacksDashboardIcon = { fg = colors.pink },
  SnacksDashboardSpecial = { fg = colors.lime },
  SnacksDashboardFooter = { fg = colors.fg2 },
  SnacksDashboardGreeting = { fg = colors.pink, italic = true },

  -- Lazy
  LazyH1 = { fg = colors.bg0, bg = colors.neon, bold = true },
  LazyH2 = { fg = colors.lime, bold = true },
  LazyButton = { fg = colors.fg0, bg = colors.bg3 },
  LazyButtonActive = { fg = colors.bg0, bg = colors.lime },
  LazyReasonPlugin = { fg = colors.lime },
  LazyReasonStart = { fg = colors.green },
  LazySpecial = { fg = colors.yellow },

  -- Notify
  NotifyERRORBorder = { fg = colors.red },
  NotifyWARNBorder = { fg = colors.yellow },
  NotifyINFOBorder = { fg = colors.lavender },
  NotifyDEBUGBorder = { fg = colors.fg3 },
  NotifyTRACEBorder = { fg = colors.lime },
  NotifyERRORIcon = { fg = colors.red },
  NotifyWARNIcon = { fg = colors.yellow },
  NotifyINFOIcon = { fg = colors.lavender },
  NotifyDEBUGIcon = { fg = colors.fg3 },
  NotifyTRACEIcon = { fg = colors.lime },
  NotifyERRORTitle = { fg = colors.red },
  NotifyWARNTitle = { fg = colors.yellow },
  NotifyINFOTitle = { fg = colors.lavender },
  NotifyDEBUGTitle = { fg = colors.fg3 },
  NotifyTRACETitle = { fg = colors.lime },

  -- Render Markdown
  RenderMarkdownH1 = { fg = colors.neon, bold = true },
  RenderMarkdownH2 = { fg = colors.lime, bold = true },
  RenderMarkdownH3 = { fg = colors.violet, bold = true },
  RenderMarkdownH4 = { fg = colors.deep_blue, bold = true },
  RenderMarkdownH5 = { fg = colors.pink, bold = true },
  RenderMarkdownH6 = { fg = colors.mint, bold = true },
  RenderMarkdownCode = { fg = colors.green, bg = colors.bg2 },
  RenderMarkdownBullet = { fg = colors.neon },
  RenderMarkdownQuote = { fg = colors.fg2, italic = true },
  RenderMarkdownLink = { fg = colors.cyan, underline = true },
  RenderMarkdownTableHead = { fg = colors.lime },
  RenderMarkdownTableRow = { fg = colors.fg1 },
}

-- Set terminal colors
function M.set_terminal_colors()
  for i, color in ipairs(terminal) do
    vim.g["terminal_color_" .. (i - 1)] = color
  end
end

-- Load theme
function M.load()
  -- Reset colors
  if vim.g.colors_name then
    vim.cmd("hi clear")
  end
  vim.g.colors_name = "opencode"
  vim.o.termguicolors = true

  -- Set terminal colors
  M.set_terminal_colors()

  -- Apply highlights
  for group, opts in pairs(highlights) do
    local hl_opts = {}
    if opts.fg then
      hl_opts.fg = opts.fg
    end
    if opts.bg then
      hl_opts.bg = opts.bg
    end
    if opts.sp then
      hl_opts.sp = opts.sp
    end
    if opts.bold then
      hl_opts.bold = opts.bold
    end
    if opts.italic then
      hl_opts.italic = opts.italic
    end
    if opts.underline then
      hl_opts.underline = opts.underline
    end
    if opts.strikethrough then
      hl_opts.strikethrough = opts.strikethrough
    end
    vim.api.nvim_set_hl(0, group, hl_opts)
  end
end

-- Setup function
function M.setup()
  vim.api.nvim_create_autocmd("ColorSchemePre", {
    pattern = "opencode",
    callback = function()
      M.load()
    end,
  })
end

-- Return theme
return M
