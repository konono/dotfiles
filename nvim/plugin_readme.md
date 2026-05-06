# Neovim プラグイン構成

## 概要

プラグイン管理には [lazy.nvim](https://github.com/folke/lazy.nvim) を使用。
各プラグインの設定ファイルは `lua/plugins/` ディレクトリに1ファイル1プラグインで配置し、lazy.nvim が自動で読み込む。

```
nvim/
├── init.lua                 # エントリポイント
├── lua/
│   ├── lazy_nvim.lua        # lazy.nvim ブートストラップ
│   ├── global.lua           # グローバル変数 (leader キー等)
│   ├── options.lua          # Neovim オプション
│   ├── keymaps.lua          # キーバインド
│   ├── colorscheme.lua      # カラースキーム / TrueColor 設定
│   ├── misc.lua             # IME / 全角スペース表示等
│   ├── utils.lua            # ユーティリティ関数
│   └── plugins/             # プラグイン設定
│       ├── lazy.lua
│       ├── coc-nvim.lua
│       ├── nvim-tree.lua
│       ├── nvim-treesitter.lua
│       ├── ansible-vim.lua
│       ├── multiple-cursors.lua
│       ├── others.lua       # nvim-autopairs
│       └── baleia.lua
└── lazy-lock.json           # バージョンロックファイル
```

---

## プラグイン一覧

### 1. lazy.nvim

| 項目 | 内容 |
|------|------|
| リポジトリ | [folke/lazy.nvim](https://github.com/folke/lazy.nvim) |
| 設定ファイル | `lua/plugins/lazy.lua`, `lua/lazy_nvim.lua` |
| 目的 | プラグインマネージャ |

**なぜ入れているか**: Neovim のプラグインを宣言的に管理し、遅延ロード・自動インストール・バージョンロックを提供する。

**主要設定** (`lua/lazy_nvim.lua`):
- プラグイン更新を自動チェック (通知なし)
- diff ツールに delta を使用
- 組み込みの netrw を無効化

---

### 2. coc.nvim

| 項目 | 内容 |
|------|------|
| リポジトリ | [neoclide/coc.nvim](https://github.com/neoclide/coc.nvim) |
| 設定ファイル | `lua/plugins/coc-nvim.lua` |
| 目的 | LSP クライアント / 補完 / 診断 / コードアクション |
| ロード条件 | `BufNewFile`, `BufRead` |

**なぜ入れているか**: 複数言語 (Go, Python, Rust, TypeScript, Lua 等) の LSP 補完・診断・リファクタリングを統一的に扱う。

**インストール済み拡張**:
`@yaegassy/coc-marksman`, `coc-biome`, `coc-css`, `coc-deno`, `coc-elixir`, `coc-go`, `coc-html`, `coc-highlight`, `coc-json`, `coc-prettier`, `coc-pyright`, `coc-rust-analyzer`, `coc-snippets`, `coc-tsserver`, `coc-yaml`, `coc-lua` (非 Windows のみ)

**キーバインド**:

| キー | モード | 動作 |
|------|--------|------|
| `<C-]>` | n | 定義に移動 |
| `<M-o>` | n | import 最適化 |
| `<M-s>` | n | ホバー (型・ドキュメント表示) |
| `<C-P>` | i | シグネチャヘルプ |
| `<M-k>` | n | 前の診断へ移動 |
| `<M-j>` | n | 次の診断へ移動 |
| `<CR>` | i | 補完候補を確定 |
| `<Tab>` | i | 次の補完候補 |
| `<S-Tab>` | i | 前の補完候補 |
| `<M-CR>` | n | コードアクション |
| `<S-M-r>` | n | リネーム |
| `<F5>` | i | 補完リフレッシュ |

**autocmd**:
- Go ファイル保存時に自動で import 整理
- カーソル停止時にシンボルハイライト (`CocHighlightText` / `CocHighlightRead` / `CocHighlightWrite`)

---

### 3. nvim-tree.lua

| 項目 | 内容 |
|------|------|
| リポジトリ | [nvim-tree/nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) |
| 設定ファイル | `lua/plugins/nvim-tree.lua` |
| 目的 | ファイルエクスプローラ |
| ロード条件 | `<C-n>` キー押下時 |

**なぜ入れているか**: サイドバー型のファイルツリーでプロジェクト内のファイルを視覚的にブラウズ・操作する。

**キーバインド**:

| キー | モード | 動作 |
|------|--------|------|
| `<C-n>` | n | ファイルツリーのトグル |

---

### 4. nvim-treesitter

| 項目 | 内容 |
|------|------|
| リポジトリ | [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) |
| 設定ファイル | `lua/plugins/nvim-treesitter.lua` |
| 目的 | 構文解析ベースのシンタックスハイライト |
| ロード条件 | 起動時 |

**なぜ入れているか**: 正規表現ベースの旧式ハイライトよりも正確で高品質な構文ハイライトを提供する。

**主要設定**:
- 自動インストール対象パーサー: `python`, `lua`, `rust`
- 同期インストール有効

---

### 5. ansible-vim

| 項目 | 内容 |
|------|------|
| リポジトリ | [pearofducks/ansible-vim](https://github.com/pearofducks/ansible-vim) |
| 設定ファイル | `lua/plugins/ansible-vim.lua` |
| 目的 | Ansible ファイルの filetype 検出とシンタックスハイライト |
| ロード条件 | 起動時 |

**なぜ入れているか**: Ansible playbook/role の YAML ファイルを正しく認識し、専用のハイライトを適用する。

**主要設定**: デフォルト設定のまま使用 (カスタム設定なし)。

---

### 6. vim-multiple-cursors

| 項目 | 内容 |
|------|------|
| リポジトリ | [terryma/vim-multiple-cursors](https://github.com/terryma/vim-multiple-cursors) |
| 設定ファイル | `lua/plugins/multiple-cursors.lua` |
| 目的 | マルチカーソル編集 |
| ロード条件 | 起動時 |

**なぜ入れているか**: 同じ単語を複数箇所同時に選択・編集する Sublime Text 風のマルチカーソル機能を提供する。

**主要設定**: デフォルト設定のまま使用 (カスタム設定なし)。

---

### 7. nvim-autopairs

| 項目 | 内容 |
|------|------|
| リポジトリ | [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs) |
| 設定ファイル | `lua/plugins/others.lua` |
| 目的 | 括弧・引用符の自動補完 |
| ロード条件 | 起動時 |

**なぜ入れているか**: `(`, `{`, `[`, `"`, `'` 等を入力した際に対応する閉じ記号を自動挿入する。

**主要設定**: デフォルト設定のまま使用 (`config = true`)。

---

### 8. baleia.nvim

| 項目 | 内容 |
|------|------|
| リポジトリ | [m00qek/baleia.nvim](https://github.com/m00qek/baleia.nvim) |
| 設定ファイル | `lua/plugins/baleia.lua` |
| 目的 | ANSI エスケープシーケンスのカラー表示 |
| ロード条件 | `BufReadPost` |

**なぜ入れているか**: Zellij の Edit Scrollback で開いたターミナル出力に含まれる ANSI カラーコードを Neovim のハイライトに変換して表示する。

**主要設定**:
- `strip_ansi_codes = true` — ANSI コードをバッファから除去して見やすくする
- `async = true` — 非同期処理で UI をブロックしない
- バッファの先頭50行に ANSI コード (`ESC[`) を検出したら自動でカラー化
- カラー化後に `modified` フラグをリセット (`:q` でそのまま閉じられるようにする)

**コマンド**:

| コマンド | 動作 |
|----------|------|
| `:BaleiaColorize` | 現在のバッファを手動でカラー化 |
