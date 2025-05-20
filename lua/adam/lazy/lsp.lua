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

        -- Set global border style for hover, signature help, etc.
        vim.o.winborder = "rounded"

        -- Configure diagnostics - enable virtual text which is now disabled by default in 0.11
        vim.diagnostic.config({
            virtual_text = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })

        -- In Neovim 0.11, the best practice is to use LspAttach autocmd for keybindings
        -- This ensures custom mappings work correctly with the new default mappings
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
            callback = function(event)
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                local bufnr = event.buf
                
                -- Define buffer-local mappings
                local map_opts = { buffer = bufnr, noremap = true, silent = true }
                
                -- LSP Navigation - custom keybindings
                -- gd is already mapped by default to vim.lsp.buf.definition via tagfunc,
                -- but we set it explicitly for Icelandic keyboards where C-] is problematic
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, map_opts)
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, map_opts)
                
                -- LSP Actions - additional custom mappings alongside global defaults
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, map_opts)           -- Custom rename
                vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, map_opts)      -- Custom code action 
                vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help, map_opts)   -- Custom signature help
                
                -- Custom leader-based navigation that complements the global gr* mappings
                vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, map_opts)       -- Leader-based definition
                vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, map_opts)   -- Leader-based implementation
                vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, map_opts)       -- Leader-based references

                -- Reminder: Neovim 0.11 already has these GLOBAL mappings (no need to set them):
                -- "grn" in Normal mode for vim.lsp.buf.rename()
                -- "gra" in Normal and Visual mode for vim.lsp.buf.code_action()
                -- "grr" in Normal mode for vim.lsp.buf.references()
                -- "gri" in Normal mode for vim.lsp.buf.implementation()
                -- "gO" in Normal mode for vim.lsp.buf.document_symbol()
                -- CTRL-S in Insert mode for vim.lsp.buf.signature_help()
                -- K is already mapped to vim.lsp.buf.hover() unless keywordprg was customized
                
                -- Enable auto-completion if needed (optional, commented out by default)
                -- if client.supports_method('textDocument/completion') then
                --     vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
                -- end
                
                -- Enable inlay hints if supported (optional, commented out by default)
                -- if client.supports_method('textDocument/inlayHint') then
                --     vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                -- end
            end
        })

        -- Set up mason-lspconfig with the new position_encoding requirement
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
                        -- No need to specify on_attach since we're using the LspAttach autocmd
                        -- We now need to specify position_encoding with Neovim 0.11
                        position_encoding = "utf-16", -- Most common encoding used by LSP servers
                    })
                end,
                -- Custom handler for Pyright to add extra paths
                ["pyright"] = function()
                    require("lspconfig").pyright.setup({
                        capabilities = capabilities,
                        position_encoding = "utf-16",
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
                        position_encoding = "utf-16",
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
    end
}
