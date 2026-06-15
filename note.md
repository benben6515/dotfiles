> term

- oh-my-zsh
- powerline
- starship
- nerd-front

> tools

```sh
# bat - hight version of cat
brew install bat

# mole - mac clean up
brew install mole

# eza - modern ls
brew install eza

# ripgrep - modern grep (rg)
brew install ripgrep

# fd - modern find
brew install fd

# zoxide - smarter cd
brew install zoxide

# fzf - fuzzy finder
brew install fzf
$(brew --prefix)/opt/fzf/install

# btop - beautiful system monitor
brew install btop

# gh - GitHub CLI
brew install gh

# tldr - simplified man pages
brew install tldr

# git-delta - better git diff
brew install git-delta

# lazygit - terminal UI for git
brew install lazygit
```

> CLI Tools — Dreams of Code (YouTube)
> Part 1: 10 CLI Tools That Changed My Workflow — https://youtube.com/watch?v=EJ6uvqhKR4M
> Part 2: 10 CLI Tools You've Never Heard Of — https://youtube.com/watch?v=VGtxARciwDM

## Part 1 — 主流必裝工具

| #   | 工具    | 介紹                                                                | Repo                                     | Stars |
| --- | ------- | ------------------------------------------------------------------- | ---------------------------------------- | ----: |
| 1   | zoxide  | 智慧版 cd，用模糊匹配記住你造訪過的目錄，打幾個字就能跳過去         | https://github.com/ajeetdsouza/zoxide    | 37.4k |
| 2   | ripgrep | 暴力快速的 grep 替代品，預設忽略 .gitignore、遞迴搜尋、彩色輸出     | https://github.com/BurntSushi/ripgrep    | 65.0k |
| 3   | fd      | 直覺版 find，語法更簡潔，預設忽略 .gitignore，支援 regex/glob       | https://github.com/sharkdp/fd            | 43.3k |
| 4   | tmux    | 終端機多工神器，多 pane/window/session 全鍵盤操作，SSH 斷線可重連   | https://github.com/tmux/tmux             | 46.5k |
| 5   | gh      | GitHub 官方 CLI，建 repo/查 issue/開 PR 都不用開瀏覽器              | https://github.com/cli/cli               | 44.8k |
| 6   | doppler | 雲端 Secrets 管理平台，用 CLI 注入環境變數，不用把 secret 寫進 .env | https://github.com/DopplerHQ/cli         |  0.4k |
| 7   | pass    | 自架密碼管理器，GPG 加密 + Git 版控，搭配 YubiKey 安全性極高        | https://github.com/zx2c4/password-store  |  0.7k |
| 8   | jq      | JSON 處理必備工具，格式化、過濾、轉換、聚合樣樣行                   | https://github.com/jqlang/jq             | 34.9k |
| 9   | stow    | Dotfiles 管理工具，用 symlink 把 repo 裡的設定檔放到對的位置        | https://github.com/aspiers/stow (mirror) |  1.0k |
| 10  | fzf     | 模糊搜尋神器，單獨用搜檔案，搭配其他命令做互動式補全/選單才是本體   | https://github.com/junegunn/fzf          | 80.9k |

## Part 2 — 冷門但有趣工具

| #   | 工具      | 介紹                                                              | Repo                                   | Stars |
| --- | --------- | ----------------------------------------------------------------- | -------------------------------------- | ----: |
| 11  | cbonsai   | ASCII 盆栽樹產生器，可以看它一秒一秒長大，純粹好玩                | https://gitlab.com/jallbrit/cbonsai    |  0.4k |
| 12  | asciinema | 終端機錄影工具，錄成文字格式，可嵌入網頁播放且觀眾能選取複製文字  | https://github.com/asciinema/asciinema | 17.4k |
| 13  | croc      | 簡易檔案傳輸，用 code phrase 配對，免 SSH/防火牆設定，端到端加密  | https://github.com/schollz/croc        | 35.3k |
| 14  | ttyd      | 把終端機開到瀏覽器上，搭配 VPS + Tailscale 可用手機遠端寫程式     | https://github.com/tsl0922/ttyd        | 11.9k |
| 15  | jrnl      | 終端機日記本，支援加密、標籤、時間查詢、多日記本管理              | https://github.com/jrnl-org/jrnl       |  7.3k |
| 16  | wttr.in   | curl 查天氣，`curl wttr.in/Taipei` 一行搞定，不是獨立工具是 API   | https://github.com/chubin/wttr.in      | 29.9k |
| 17  | newsboat  | 終端機 RSS 閱讀器，TUI 介面，在 CLI 裡訂閱和閱讀文章              | https://github.com/newsboat/newsboat   |  3.8k |
| 18  | lolcat    | 彩虹漸層版 cat，純粹讓輸出變漂亮，搭配 figlet 做 ASCII 歡迎訊息   | https://github.com/busyloop/lolcat     |  6.5k |
| 19  | faker     | 假資料產生器（姓名/email/地址/密碼），自動化測試和 mock data 神器 | https://github.com/joke2k/faker        | 19.3k |
| 20  | grex      | 自動產生正規表達式，丟幾個字串進去它幫你推導出 regex 規則         | https://github.com/pemistahl/grex      |  8.1k |

### 安裝狀態 (本機)

```
Part 1:  zoxide ✅  rg ✅  fd ✅  tmux ✅  gh ✅  doppler ❌  pass ❌  jq ✅  stow ❌  fzf ✅
Part 2:  cbonsai ❌  asciinema ❌  croc ✅  ttyd ❌  jrnl ❌  wttr.in ✅  newsboat ❌  lolcat ✅  faker ❌  grex ❌
```
