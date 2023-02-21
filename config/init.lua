let mapleader = "\<space>"
tnoremap <Esc> <C-\><C-n>
command! -nargs=* T split | wincmd j | resize 20 | terminal <args>
autocmd TermOpen * startinsert
nmap <C-t> <cmd>T<Enter>

lua <<EOF

vim.opt.backup = false
vim.opt.number = true
vim.opt.list =  true
vim.opt.ruler = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.termguicolors = true
vim.api.nvim_command('set listchars=tab:>-,trail:-,nbsp:%,extends:>,precedes:<,eol:$')

vim.keymap.set('n', '<C-a>', '^', options)
vim.keymap.set('n', '<C-e>', '$', options)
vim.keymap.set('n', '<C-j>', '<C-w>', options)
vim.keymap.set('n', '<Esc><Esc>', '<cmd>:nohlsearch<Enter>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>ff', '<cmd>:Telescope find_files<Enter>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fg', '<cmd>:Telescope live_grep<Enter>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-b>', '<cmd>:NvimTreeToggle<Enter>', { noremap = true, silent = true })

vim.cmd'colorscheme tokyonight'

require("tokyonight").setup({
	style = "dark",
	terminal_colors = true,
	styles = {
		functions = {}
	},
})

---------------------------------------------------------------------
-- LSP config
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  -- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', '<leader>jd', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', '<leader>jd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', '<leader>ji', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<leader>jh', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<leader>jwa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>jwr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>jwl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<leader>jtd', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<leader>jrn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>jca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', '<leader>jr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<leader>jf', function() vim.lsp.buf.format { async = true } end, bufopts)
end
local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}

local lsp = require "lspconfig"
util = require "lspconfig/util"

lsp['gopls'].setup{
  cmd = {"gopls", "serve"},
  capabilities = capabilities,
  filetypes = {"go", "gomod", "gowork", "gotmpl"},
  root_dir = util.root_pattern("go.mod", ".git"),
  single_file_support = true,
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
    },
  },
  on_attach = on_attach,
  flags = lsp_flags,
}

function go_org_imports(wait_ms)
  local params = vim.lsp.util.make_range_params()
  params.context = {only = {"source.organizeImports"}}
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
  for cid, res in pairs(result or {}) do
    for _, r in pairs(res.result or {}) do
      if r.edit then
        local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
        vim.lsp.util.apply_workspace_edit(r.edit, enc)
      end
    end
  end
end

vim.api.nvim_command('autocmd BufWritePre *.go lua go_org_imports()')
vim.api.nvim_command('autocmd BufWritePre *.go lua vim.lsp.buf.format()')

capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
vim.opt.completeopt = "menu,menuone,noselect"

local cmp = require "cmp"
cmp.setup({
  window = {},
  mapping = cmp.mapping.preset.insert({
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<tab>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
  }, {
    { name = "buffer" },
  })
})

require("nvim-treesitter.configs").setup {
  ignore_install = { "javascript" },

  highlight = {
    enable = true,
    disable = {
      'vue',
    },
  },
}

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("nvim-tree").setup()

-- neogit configuration

local neogit = require("neogit")

neogit.setup {
  disable_signs = false,
  disable_hint = false,
  disable_context_highlighting = false,
  disable_commit_confirmation = false,
  -- Neogit refreshes its internal state after specific events, which can be expensive depending on the repository size.
  -- Disabling `auto_refresh` will make it so you have to manually refresh the status after you open it.
  auto_refresh = true,
  disable_builtin_notifications = false,
  use_magit_keybindings = false,
  -- Change the default way of opening neogit
  kind = "tab",
  -- The time after which an output console is shown for slow running commands
  console_timeout = 2000,
  -- Automatically show console if a command takes more than console_timeout milliseconds
  auto_show_console = true,
  -- Change the default way of opening the commit popup
  commit_popup = {
    kind = "split",
  },
  -- Change the default way of opening popups
  popup = {
    kind = "split",
  },
  -- customize displayed signs
  signs = {
    -- { CLOSED, OPENED }
    section = { ">", "v" },
    item = { ">", "v" },
    hunk = { "", "" },
  },
  integrations = {
    -- Neogit only provides inline diffs. If you want a more traditional way to look at diffs, you can use `sindrets/diffview.nvim`.
    -- The diffview integration enables the diff popup, which is a wrapper around `sindrets/diffview.nvim`.
    --
    -- Requires you to have `sindrets/diffview.nvim` installed.
    -- use {
    --   'TimUntersberger/neogit',
    --   requires = {
    --     'nvim-lua/plenary.nvim',
    --     'sindrets/diffview.nvim'
    --   }
    -- }
    --
    diffview = false
  },
  -- Setting any section to `false` will make the section not render at all
  sections = {
    untracked = {
      folded = false
    },
    unstaged = {
      folded = false
    },
    staged = {
      folded = false
    },
    stashes = {
      folded = true
    },
    unpulled = {
      folded = true
    },
    unmerged = {
      folded = false
    },
    recent = {
      folded = true
    },
  },
  -- override/add mappings
  mappings = {
    -- modify status buffer mappings
    status = {
      -- Adds a mapping with "B" as key that does the "BranchPopup" command
      ["B"] = "BranchPopup",
      -- Removes the default mapping of "s"
      -- ["s"] = "",
    }
  }
}
EOF

