return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    config = function()
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        require("fidget").setup({})
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls", -- Lua
                "rust_analyzer", -- Rust
                "pyright", -- Python
                "gopls", -- Go
                -- "clangd" -- C/C++
                -- "jdtls", -- Java
            },
            handlers = {
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities
                    }
                end,

                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                diagnostics = {
                                    globals = { "vim", "it", "describe", "before_each", "after_each" },
                                }
                            }
                        }
                    }
                end,
            }
        })

        local function on_attach(client, bufnr)
            local opts = { buffer = bufnr, silent = true, noremap = true }

            -- LSP Navigation
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts) -- Go to definition
            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- Go to declaration
            vim.keymap.set("n", "gr", vim.lsp.buf.references, opts) -- Go to references
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts) -- Go to implementation
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts) -- Show documentation

            -- LSP Actions
            vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help, opts) -- Show signature
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- Rename symbol eg. func
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts) -- Show actions
        end


        local lspconfig = require("lspconfig")
        for _, server in ipairs({ "pyright", "gopls", "lua_ls" }) do
            lspconfig[server].setup({
                capabilities = capabilities,
                on_attach = on_attach,
            })
        end

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
            }, {
                { name = 'buffer' },
            })
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
