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
            vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
            vim.keymap.set("n", "gD", function() vim.lsp.buf.declaration() end, opts)
            vim.keymap.set("n", "gr", function() vim.lsp.buf.references() end, opts)
            vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, opts)
            vim.keymap.set("n", "K", function() vim.lsp.buf.hover({
                border = "rounded",
            }) end, opts)

            -- LSP Actions
            vim.keymap.set("n", "<leader>sh", function() vim.lsp.buf.signature_help() end, opts)
            vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
            vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
        end

        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",        -- Lua
                "rust_analyzer", -- Rust
                "pyright",       -- Python
                "gopls",         -- Go
                "clangd",        -- C/C++
                "jdtls",         -- Java 
            },
            handlers = {
                -- Default handler for all servers
                function(server_name)
                    require("lspconfig")[server_name].setup({
                        capabilities = capabilities,
                        on_attach = on_attach,
                    })
                end,
                -- Custom handler for pyright to add extra paths
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

        vim.diagnostic.config({
            virtual_text     = true,     -- enable inline diagnostics (opt‑in in 0.11+) :contentReference[oaicite:22]{index=22}
            signs            = true,     -- show gutter icons :contentReference[oaicite:23]{index=23}
            underline        = true,     -- underline code with diagnostics :contentReference[oaicite:24]{index=24}
            update_in_insert = false,    -- do not update diagnostics while typing :contentReference[oaicite:25]{index=25}
            severity_sort    = true,     -- sort diagnostics by severity :contentReference[oaicite:26]{index=26}
            float = {
                focusable = false,
                style     = "minimal",
                border    = "rounded",
                source    = "always",  -- always show source (e.g., pyright) :contentReference[oaicite:27]{index=27}
                header    = "",
                prefix    = "",
            },
        })

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
