return {
  "neovim/nvim-lspconfig",
  tag = "v0.1.4",
  requires = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    local map = vim.keymap.set

    local default_capabilities = vim.lsp.protocol.make_client_capabilities()
    default_capabilities.textDocument.completion.completionItem.snippetSupport =
      true

    local lsp_flags = { debounce_text_changes = 150 }

    local on_attach = function(_, bufnr)
      local bufopts = { noremap = true, silent = true, buffer = bufnr }
      map("n", "<leader><leader>ca", vim.lsp.buf.code_action, bufopts)
      map("n", "<leader>gD", vim.lsp.buf.declaration, bufopts)
      map("n", "<leader>gd", vim.lsp.buf.definition, bufopts)
      map("n", "<leader>K", vim.lsp.buf.hover, bufopts)
      map("n", "<leader>gi", vim.lsp.buf.implementation, bufopts)
      map("n", "<leader>tD", vim.lsp.buf.type_definition, bufopts)
      map("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
      map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, bufopts)
      map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
      map(
        "n",
        "<leader>wl",
        function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
        bufopts
      )
      map("n", "<leader><C-k>", vim.lsp.buf.signature_help, bufopts)
      map(
        "n",
        "<leader>bf",
        function() vim.lsp.buf.format { async = true } end,
        bufopts
      )
    end

    -- local on_attach_with_format = function(client, bufnr)
    --   on_attach(client, bufnr)
    --   local format_ok, format = pcall(require, "lsp-format")
    --   if format_ok then format.on_attach(client) end
    -- end

    local opts = { noremap = true, silent = true }
    map("n", "<leader><leader>e", vim.diagnostic.open_float, opts)

    local lspconfig = require "lspconfig"
    local mason_lsp = require "mason-lspconfig"
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    mason_lsp.setup {
      ensure_installed = {
        "clangd",
        "cmake",
        "pylsp",
        "cssls",
        "html",
        "bashls",
        "sumneko_lua",
      },
    }

    mason_lsp.setup_handlers {
      function(server_name)
        lspconfig[server_name].setup {
          capabilities = capabilities,
          on_attach = on_attach,
        }
      end,
      sumneko_lua = function(server_name)
        lspconfig[server_name].setup {
          on_attach = on_attach,
          capabilities = capabilities,
          flags = lsp_flags,
          settings = {
            Lua = {
              runtime = {
                version = "LuaJIT",
              },
              diagnostics = {
                globals = { "vim", "use" },
              },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              telemetry = {
                enable = false,
              },
            },
          },
        }
      end,
      clangd = function(server_name)
        lspconfig[server_name].setup {
          cmd = { "clangd", "--completion-style=detailed" },
          on_attach = on_attach,
          capabilities = default_capabilities,
          flags = lsp_flags,
        }
      end,
      ["pylsp"] = function(server_name)
        lspconfig[server_name].setup {
          on_attach = on_attach,
          capabilities = default_capabilities,
          flags = lsp_flags,
          settings = {
            pylsp = {
              plugins = {
                pycodestyle = {
                  ignore = { "W391" },
                  maxLineLength = 100,
                },
              },
            },
          },
        }
      end,
    }
  end,
}
