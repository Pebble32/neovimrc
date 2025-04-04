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
        -- Set up completion capabilities
        local cmp = require("cmp")
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities()
        )

        -- Setup fidget to show LSP progress
        require("fidget").setup({})

        -- Set up Mason
        require("mason").setup()

        -- Define the on_attach function to map keybindings after the LSP attaches to a buffer
        local function on_attach(client, bufnr)
            local opts = { buffer = bufnr, silent = true, noremap = true }

            -- LSP Navigation
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)      -- Go to definition
            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)       -- Go to declaration
            vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)         -- Go to references
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)     -- Go to implementation
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)               -- Show documentation

            -- LSP Actions
            vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help, opts)  -- Signature help
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)            -- Rename symbol
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)       -- Code actions
        end

        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",        -- Lua
                "rust_analyzer", -- Rust
                "pyright",       -- Python
                "gopls",         -- Go
                "clangd",        -- C/C++
                -- "jdtls",      -- Java 
            },
            handlers = {
                -- Default handler for all servers
                function(server_name)
                    require("lspconfig")[server_name].setup({
                        capabilities = capabilities,
                        on_attach = on_attach,
                    })
                end,
                -- Custom handler for Pyright to add extra paths
                ["pyright"] = function()
                    require("lspconfig").pyright.setup({
                        capabilities = capabilities,
                        on_attach = on_attach,
                        settings = {
                            python = {
                                analysis = {
                                    extraPaths = {"../libdohop"}
                                }
                            }
                        }
                    })
                end,
                -- Custom handler for Lua LS with extra diagnostic globals
                ["lua_ls"] = function()
                    require("lspconfig").lua_ls.setup({
                        capabilities = capabilities,
                        on_attach = on_attach,
                        settings = {
                            Lua = {
                                diagnostics = {
                                    globals = { "vim", "it", "describe", "before_each", "after_each" },
                                }
                            }
                        }
                    })
                end,
            }
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
                ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
                ["<C-y>"] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
            }, {
                { name = "buffer" },
            }),
        })

        -- Configure diagnostics
        vim.diagnostic.config({
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
