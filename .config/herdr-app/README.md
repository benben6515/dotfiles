# herdr-app

[Herdr](https://herdr.dev)(終端機 + coding agents 的桌面 app)的 **glass layout** 備份:半透明側欄配 ASCII 黑洞背景的玻璃風格,搭 pixel 系 mods。

## 內容

| 路徑 | 說明 |
|---|---|
| `layouts/glass.json` | 主 layout。已把兩項點擊設定烘焙進檔案:`theme`(亮 `gruvbox-glass` / 暗 `custom-atom-one-dark`)與側欄 `240px`,單一檔案即可重現外觀 |
| `themes/gruvbox-glass.json` | 亮色主題(chrome 半透明 `#1d2021d0`) |
| `themes/custom-atom-one-dark.json` | 暗色主題 |
| `backgrounds/ascii-black-hole.jpg` | 背景圖 |
| `mods/pixel-chrome/` | 側欄頂列:pixel 鈴鐺(等你的 agent 數)+ 搜尋鈕(開 `pixel-picker`)。**已改**:不上自家底色,讓 glass 的半透明側欄透出來 |
| `mods/pixel-spaces/` | Spaces 列表,pixel 精靈頭像。**已改**:同上 |
| `mods/pixel-picker/` | 指令/空間選擇器,由 pixel-chrome 的搜尋鈕開啟(`place: none`,不用放進 layout) |
| `mods/agents-glass/` | agents 面板(Done / Working / Idle 分組) |
| `mods/file-icons/` | 第三方 [Material Icon Theme](https://github.com/material-extensions/vscode-material-icon-theme)(MIT),取自 [cybertron288/herdr-mods](https://github.com/cybertron288/herdr-mods),授權檔在 mod 內 |

## 還原

```sh
mkdir -p ~/.config/herdr-app
cp -R <此目錄>/. ~/.config/herdr-app/
```

- Herdr 會自動生成 `AGENTS.md`、`gpui-kit.d.ts`、`jsconfig.json` 等,備份刻意不含這些
- Herdr 內建 mods(`workspace-chrome`、`tabs`、`pane`、`workspace-status`、`changes`)隨 app 附帶,不在備份內
- layout 與 mods 都是存檔即時熱載;驗證單一 mod:`herdr-app check ~/.config/herdr-app/mods/<name>`
- 改 layout 沒立即生效時,`ctrl-shift-l` 切換一輪會強制重讀
