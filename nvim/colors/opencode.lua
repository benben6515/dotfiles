-- OpenCode Theme - A dark theme with purple gradient accents
-- Inspired by modern code editors with a focus on readability

local M = {}

-- Color palette
local colors = {
  -- Backgrounds (darkest to lightest)
  bg0 = "#0a0a0f", -- Main background
  bg1 = "#12121a", -- Darker background (sidebar, etc.)
  bg2 = "#1a1a25", -- Selection background
  bg3 = "#252533", -- Lighter background (floats)
  bg4 = "#2d2d3d", -- Active line background

  -- Blues/Cyans (accent colors)
  purple0 = "#0d4f99", -- Deep neon blue
  purple1 = "#5B48F9", -- Vibrant neon blue
  purple2 = "#E1FAA0", -- Bright cyan/neon blue
  purple3 = "#22cfcf", -- Neon cyan
  purple4 = "#efaaef", -- Electric teal
  purple5 = "#77efcf", -- Light electric teal

  -- Text colors
  fg0 = "#f0f0ff", -- Main text (brighter)
  fg1 = "#d0e0e0", -- Dimmed text (brighter)
  fg2 = "#80bea0", -- Comments (brighter for readability)
  fg3 = "#8090a0", -- Inactive text
  fg4 = "#60a0a0", -- Inactive line

  -- Syntax colors
  red = "#f38ba8", -- Errors, keywords
  orange = "#fab387", -- Numbers, constants
  yellow = "#f9e2af", -- Warnings, types
  green = "#a6e3a1", -- Strings, success
  cyan = "#89dceb", -- Functions, methods
  blue = "#bba8f9", -- Variables, identifiers (brighter blue)
  teal = "#dfaa8f", -- Properties, fields (brighter)

  -- UI colors
  border = "#3d3d50",
  cursor = "#efefef", -- Neon cyan cursor
  accent = "#00c4cc", -- Bright cyan accent
  highlight = "#4a6d8f", -- Neon blue selection
}

-- Terminal colors
local terminal = {
  colors.bg0, -- Black
  colors.red, -- Red
  colors.green, -- Green
  colors.yellow, -- Yellow
  colors.blue, -- Blue
  colors.purple2, -- Magenta
  colors.cyan, -- Cyan
  colors.fg1, -- White
  colors.bg3, -- Bright Black
  colors.red, -- Bright Red
  colors.green, -- Bright Green
  colors.yellow, -- Bright Yellow
  colors.blue, -- Bright Blue
  colors.purple3, -- Bright Magenta
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
  CursorLineNr = { fg = colors.purple3, bg = colors.bg1 },
  CursorColumn = { bg = colors.bg2 },
  LineNr = { fg = colors.fg3, bg = colors.bg1 },

  -- Visual and selection
  Visual = { bg = colors.highlight },
  VisualNOS = { bg = colors.highlight },

  -- Search
  Search = { fg = colors.bg0, bg = colors.purple3 },
  IncSearch = { fg = colors.bg0, bg = colors.purple4 },
  Substitute = { fg = colors.bg0, bg = colors.orange },

  -- Popup menu
  Pmenu = { fg = colors.fg0, bg = colors.bg3 },
  PmenuSel = { fg = colors.bg0, bg = colors.purple2 },
  PmenuSbar = { bg = colors.bg2 },
  PmenuThumb = { bg = colors.purple1 },

  -- Statusline
  StatusLine = { fg = colors.fg0, bg = colors.bg3 },
  StatusLineNC = { fg = colors.fg3, bg = colors.bg1 },

  -- Tabline
  TabLine = { fg = colors.fg2, bg = colors.bg1 },
  TabLineFill = { bg = colors.bg0 },
  TabLineSel = { fg = colors.purple3, bg = colors.bg2, bold = true },

  -- Window
  VertSplit = { fg = colors.border, bg = colors.bg0 },
  WinSeparator = { fg = colors.border, bg = colors.bg0 },

  -- Folds
  Folded = { fg = colors.fg2, bg = colors.bg2 },
  FoldColumn = { fg = colors.fg3, bg = colors.bg1 },
  SignColumn = { fg = colors.fg3, bg = colors.bg1 },

  -- Messages
  ModeMsg = { fg = colors.purple2 },
  MoreMsg = { fg = colors.purple2 },
  WarningMsg = { fg = colors.yellow },
  ErrorMsg = { fg = colors.red },

  -- Comments
  Comment = { fg = colors.fg2, italic = true },
  SpecialComment = { fg = colors.purple2, italic = true },
  Todo = { fg = colors.yellow, bg = colors.bg2, bold = true },

  -- Constants
  Constant = { fg = colors.orange },
  String = { fg = colors.green },
  Character = { fg = colors.green },
  Number = { fg = colors.orange },
  Boolean = { fg = colors.orange },
  Float = { fg = colors.orange },

  -- Identifiers
  Identifier = { fg = colors.blue },
  Function = { fg = colors.cyan },
  Method = { fg = colors.cyan },
  Property = { fg = colors.teal },
  Field = { fg = colors.teal },

  -- Statements
  Statement = { fg = colors.purple3 },
  Conditional = { fg = colors.purple3 },
  Repeat = { fg = colors.purple3 },
  Label = { fg = colors.purple2 },
  Operator = { fg = colors.fg0 },
  Keyword = { fg = colors.purple3 },
  Exception = { fg = colors.red },

  -- Preprocessor
  PreProc = { fg = colors.purple2 },
  Include = { fg = colors.purple2 },
  Define = { fg = colors.purple1 },
  Macro = { fg = colors.purple1 },
  PreCondit = { fg = colors.purple2 },

  -- Types
  Type = { fg = colors.yellow },
  StorageClass = { fg = colors.purple2 },
  Structure = { fg = colors.yellow },
  Typedef = { fg = colors.yellow },

  -- Special
  Special = { fg = colors.purple4 },
  SpecialChar = { fg = colors.orange },
  Tag = { fg = colors.cyan },
  Delimiter = { fg = colors.fg1 },
  SpecialKey = { fg = colors.fg3 },

  -- Text
  Title = { fg = colors.purple3, bold = true },
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
  gitcommitBranch = { fg = colors.purple3, bold = true },
  gitcommitComment = { fg = colors.fg2 },
  gitcommitDiscardedFile = { fg = colors.red },
  gitcommitFile = { fg = colors.fg0 },
  gitcommitHeader = { fg = colors.purple2 },
  gitcommitOnBranch = { fg = colors.fg1 },
  gitcommitSelectedFile = { fg = colors.green },
  gitcommitUnmergedFile = { fg = colors.yellow },
  gitcommitUntrackedFile = { fg = colors.cyan },

  -- Markdown
  markdownHeadingDelimiter = { fg = colors.purple3, bold = true },
  markdownHeadingRule = { fg = colors.purple2 },
  markdownLinkText = { fg = colors.cyan },
  markdownUrl = { fg = colors.teal, underline = true },
  markdownCode = { fg = colors.green },
  markdownCodeBlock = { fg = colors.green },
  markdownBlockquote = { fg = colors.fg2 },
  markdownListMarker = { fg = colors.purple3 },

  -- Treesitter
  ["@variable"] = { fg = colors.blue },
  ["@variable.builtin"] = { fg = colors.purple2 },
  ["@variable.parameter"] = { fg = colors.cyan },
  ["@variable.member"] = { fg = colors.teal },
  ["@constant"] = { fg = colors.orange },
  ["@constant.builtin"] = { fg = colors.orange },
  ["@constant.macro"] = { fg = colors.purple1 },
  ["@module"] = { fg = colors.yellow },
  ["@module.builtin"] = { fg = colors.yellow },
  ["@label"] = { fg = colors.purple2 },
  ["@string"] = { fg = colors.green },
  ["@string.documentation"] = { fg = colors.fg1 },
  ["@string.regexp"] = { fg = colors.teal },
  ["@string.escape"] = { fg = colors.orange },
  ["@string.special"] = { fg = colors.purple3 },
  ["@character"] = { fg = colors.green },
  ["@character.special"] = { fg = colors.purple3 },
  ["@boolean"] = { fg = colors.orange },
  ["@number"] = { fg = colors.orange },
  ["@number.float"] = { fg = colors.orange },
  ["@type"] = { fg = colors.yellow },
  ["@type.builtin"] = { fg = colors.yellow },
  ["@type.definition"] = { fg = colors.yellow },
  ["@type.qualifier"] = { fg = colors.purple2 },
  ["@attribute"] = { fg = colors.purple2 },
  ["@property"] = { fg = colors.teal },
  ["@function"] = { fg = colors.cyan },
  ["@function.builtin"] = { fg = colors.cyan },
  ["@function.call"] = { fg = colors.cyan },
  ["@function.macro"] = { fg = colors.purple1 },
  ["@function.method"] = { fg = colors.cyan },
  ["@function.method.call"] = { fg = colors.cyan },
  ["@constructor"] = { fg = colors.yellow },
  ["@operator"] = { fg = colors.fg0 },
  ["@keyword"] = { fg = colors.purple3 },
  ["@keyword.coroutine"] = { fg = colors.purple3 },
  ["@keyword.function"] = { fg = colors.purple3 },
  ["@keyword.operator"] = { fg = colors.purple2 },
  ["@keyword.import"] = { fg = colors.purple2 },
  ["@keyword.storage"] = { fg = colors.purple2 },
  ["@keyword.repeat"] = { fg = colors.purple3 },
  ["@keyword.return"] = { fg = colors.purple3 },
  ["@keyword.debug"] = { fg = colors.red },
  ["@keyword.exception"] = { fg = colors.red },
  ["@keyword.conditional"] = { fg = colors.purple3 },
  ["@keyword.conditional.ternary"] = { fg = colors.purple2 },
  ["@keyword.directive"] = { fg = colors.purple2 },
  ["@keyword.directive.define"] = { fg = colors.purple1 },
  ["@punctuation.delimiter"] = { fg = colors.fg1 },
  ["@punctuation.bracket"] = { fg = colors.fg1 },
  ["@punctuation.special"] = { fg = colors.purple3 },
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
  LspSignatureActiveParameter = { fg = colors.purple3, bold = true },

  -- Diagnostics
  DiagnosticError = { fg = colors.red },
  DiagnosticWarn = { fg = colors.yellow },
  DiagnosticInfo = { fg = colors.blue },
  DiagnosticHint = { fg = colors.teal },
  DiagnosticVirtualTextError = { fg = colors.red, bg = colors.bg2 },
  DiagnosticVirtualTextWarn = { fg = colors.yellow, bg = colors.bg2 },
  DiagnosticVirtualTextInfo = { fg = colors.blue, bg = colors.bg2 },
  DiagnosticVirtualTextHint = { fg = colors.teal, bg = colors.bg2 },
  DiagnosticUnderlineError = { underline = true, sp = colors.red },
  DiagnosticUnderlineWarn = { underline = true, sp = colors.yellow },
  DiagnosticUnderlineInfo = { underline = true, sp = colors.blue },
  DiagnosticUnderlineHint = { underline = true, sp = colors.teal },

  -- LSP Saga
  LspFloatWinNormal = { bg = colors.bg3 },
  LspFloatWinBorder = { fg = colors.border },
  LspSagaHoverBorder = { fg = colors.purple2 },
  LspSagaSignatureHelpBorder = { fg = colors.purple2 },
  LspSagaCodeActionBorder = { fg = colors.purple2 },
  LspSagaDefPreviewBorder = { fg = colors.purple2 },
  LspSagaAutoPreview = { fg = colors.fg1 },
  LspSagaFinderSelection = { fg = colors.purple3 },
  ReferencesCount = { fg = colors.orange },
  DefinitionCount = { fg = colors.orange },
  DefinitionIcon = { fg = colors.blue },
  TargetWord = { fg = colors.cyan },

  -- NvimTree
  NvimTreeNormal = { fg = colors.fg0, bg = colors.bg1 },
  NvimTreeNormalNC = { fg = colors.fg1, bg = colors.bg1 },
  NvimTreeRootFolder = { fg = colors.purple3, bold = true },
  NvimTreeFolderIcon = { fg = colors.purple2 },
  NvimTreeFolderName = { fg = colors.blue, bold = true },
  NvimTreeEmptyFolderName = { fg = colors.fg2 },
  NvimTreeOpenedFolderName = { fg = colors.purple3, bold = true },
  NvimTreeGitDirty = { fg = colors.yellow },
  NvimTreeGitNew = { fg = colors.green },
  NvimTreeGitDeleted = { fg = colors.red },
  NvimTreeGitIgnored = { fg = colors.fg1 },
  NvimTreeSpecialFile = { fg = colors.cyan },
  NvimTreeImageFile = { fg = colors.orange },
  NvimTreeWindowPicker = { fg = colors.purple4, bg = colors.bg3, bold = true },

  -- NeoTree
  NeoTreeNormal = { fg = colors.fg0, bg = colors.bg1 },
  NeoTreeNormalNC = { fg = colors.fg1, bg = colors.bg1 },
  NeoTreeRootName = { fg = colors.purple3, bold = true },
  NeoTreeDirectoryName = { fg = colors.blue, bold = true },
  NeoTreeDirectoryIcon = { fg = colors.purple2 },
  NeoTreeFileName = { fg = colors.fg0, bold = false },
  NeoTreeFileNameOpened = { fg = colors.purple3, bold = true },
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
  NeoTreeExpander = { fg = colors.purple2 },
  NeoTreeSymbolicLinkTarget = { fg = colors.cyan },

  -- BufferLine
  BufferLineTabClose = { fg = colors.red },
  BufferLineBufferSelected = { fg = colors.purple3, bg = colors.bg0, bold = true },
  BufferLineBufferVisible = { fg = colors.fg1, bg = colors.bg2 },
  BufferLineFill = { bg = colors.bg1 },
  BufferLineBackground = { fg = colors.fg2, bg = colors.bg1 },
  BufferLineSeparator = { fg = colors.border },
  BufferLineIndicatorSelected = { fg = colors.purple2 },
  BufferLineModified = { fg = colors.yellow },
  BufferLineModifiedSelected = { fg = colors.yellow },
  BufferLineModifiedVisible = { fg = colors.yellow },

  -- Telescope
  TelescopeNormal = { fg = colors.fg0, bg = colors.bg3 },
  TelescopeBorder = { fg = colors.border, bg = colors.bg3 },
  TelescopeTitle = { fg = colors.purple3, bg = colors.bg2, bold = true },
  TelescopePromptNormal = { fg = colors.fg0, bg = colors.bg2 },
  TelescopePromptBorder = { fg = colors.purple2, bg = colors.bg2 },
  TelescopePromptPrefix = { fg = colors.purple3 },
  TelescopePromptCounter = { fg = colors.fg2 },
  TelescopeMatching = { fg = colors.purple4, bold = true },
  TelescopeSelection = { fg = colors.bg0, bg = colors.purple2 },
  TelescopeSelectionCaret = { fg = colors.purple3, bg = colors.purple2 },
  TelescopeMultiSelection = { fg = colors.teal },
  TelescopePreviewNormal = { fg = colors.fg0, bg = colors.bg0 },
  TelescopePreviewLine = { bg = colors.highlight },
  TelescopePreviewMatch = { fg = colors.purple4, bold = true },

  -- Cmp
  CmpItemAbbr = { fg = colors.fg0 },
  CmpItemAbbrDeprecated = { fg = colors.fg2, strikethrough = true },
  CmpItemAbbrMatch = { fg = colors.purple3, bold = true },
  CmpItemAbbrMatchFuzzy = { fg = colors.purple2, bold = true },
  CmpItemMenu = { fg = colors.fg2 },
  CmpItemKindText = { fg = colors.fg0 },
  CmpItemKindMethod = { fg = colors.cyan },
  CmpItemKindFunction = { fg = colors.cyan },
  CmpItemKindConstructor = { fg = colors.yellow },
  CmpItemKindField = { fg = colors.teal },
  CmpItemKindVariable = { fg = colors.blue },
  CmpItemKindClass = { fg = colors.yellow },
  CmpItemKindInterface = { fg = colors.yellow },
  CmpItemKindModule = { fg = colors.purple2 },
  CmpItemKindProperty = { fg = colors.teal },
  CmpItemKindUnit = { fg = colors.orange },
  CmpItemKindValue = { fg = colors.orange },
  CmpItemKindEnum = { fg = colors.yellow },
  CmpItemKindKeyword = { fg = colors.purple3 },
  CmpItemKindSnippet = { fg = colors.green },
  CmpItemKindColor = { fg = colors.purple4 },
  CmpItemKindFile = { fg = colors.blue },
  CmpItemKindReference = { fg = colors.cyan },
  CmpItemKindFolder = { fg = colors.purple2 },
  CmpItemKindEnumMember = { fg = colors.orange },
  CmpItemKindConstant = { fg = colors.orange },
  CmpItemKindStruct = { fg = colors.yellow },
  CmpItemKindEvent = { fg = colors.purple3 },
  CmpItemKindOperator = { fg = colors.fg0 },
  CmpItemKindTypeParameter = { fg = colors.yellow },

  -- WhichKey
  WhichKey = { fg = colors.purple3 },
  WhichKeyGroup = { fg = colors.blue },
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
  IndentBlanklineContextChar = { fg = colors.purple2 },
  IndentBlanklineSpaceChar = { fg = colors.bg2 },
  IndentBlanklineSpaceCharBlankline = { fg = colors.bg2 },

  -- Mini
  MiniStatuslineModeNormal = { fg = colors.bg0, bg = colors.purple3, bold = true },
  MiniStatuslineModeInsert = { fg = colors.bg0, bg = colors.green, bold = true },
  MiniStatuslineModeVisual = { fg = colors.bg0, bg = colors.yellow, bold = true },
  MiniStatuslineModeReplace = { fg = colors.bg0, bg = colors.red, bold = true },
  MiniStatuslineModeCommand = { fg = colors.bg0, bg = colors.blue, bold = true },
  MiniStatuslineModeOther = { fg = colors.bg0, bg = colors.teal, bold = true },
  MiniStatuslineDevinfo = { fg = colors.fg0, bg = colors.bg3 },
  MiniStatuslineFilename = { fg = colors.fg1, bg = colors.bg2 },
  MiniStatuslineFileinfo = { fg = colors.fg0, bg = colors.bg3 },
  MiniStatuslineInactive = { fg = colors.fg3, bg = colors.bg1 },

  -- Dashboard
  DashboardHeader = { fg = colors.purple3 },
  DashboardCenter = { fg = colors.purple2 },
  DashboardShortcut = { fg = colors.cyan },
  DashboardFooter = { fg = colors.fg2 },

  -- Lazy
  LazyH1 = { fg = colors.bg0, bg = colors.purple3, bold = true },
  LazyH2 = { fg = colors.purple2, bold = true },
  LazyButton = { fg = colors.fg0, bg = colors.bg3 },
  LazyButtonActive = { fg = colors.bg0, bg = colors.purple2 },
  LazyReasonPlugin = { fg = colors.purple2 },
  LazyReasonStart = { fg = colors.green },
  LazySpecial = { fg = colors.yellow },

  -- Notify
  NotifyERRORBorder = { fg = colors.red },
  NotifyWARNBorder = { fg = colors.yellow },
  NotifyINFOBorder = { fg = colors.blue },
  NotifyDEBUGBorder = { fg = colors.fg3 },
  NotifyTRACEBorder = { fg = colors.purple2 },
  NotifyERRORIcon = { fg = colors.red },
  NotifyWARNIcon = { fg = colors.yellow },
  NotifyINFOIcon = { fg = colors.blue },
  NotifyDEBUGIcon = { fg = colors.fg3 },
  NotifyTRACEIcon = { fg = colors.purple2 },
  NotifyERRORTitle = { fg = colors.red },
  NotifyWARNTitle = { fg = colors.yellow },
  NotifyINFOTitle = { fg = colors.blue },
  NotifyDEBUGTitle = { fg = colors.fg3 },
  NotifyTRACETitle = { fg = colors.purple2 },

  -- Render Markdown
  RenderMarkdownH1 = { fg = colors.purple3, bold = true },
  RenderMarkdownH2 = { fg = colors.purple2, bold = true },
  RenderMarkdownH3 = { fg = colors.purple1, bold = true },
  RenderMarkdownH4 = { fg = colors.purple0, bold = true },
  RenderMarkdownH5 = { fg = colors.purple4, bold = true },
  RenderMarkdownH6 = { fg = colors.purple5, bold = true },
  RenderMarkdownCode = { fg = colors.green, bg = colors.bg2 },
  RenderMarkdownBullet = { fg = colors.purple3 },
  RenderMarkdownQuote = { fg = colors.fg2, italic = true },
  RenderMarkdownLink = { fg = colors.cyan, underline = true },
  RenderMarkdownTableHead = { fg = colors.purple2 },
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
