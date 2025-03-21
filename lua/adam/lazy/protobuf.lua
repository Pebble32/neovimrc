-- protobuf.lua

local configs = require('lspconfig.configs')
local util = require('lspconfig.util')

-- Only create the config if it hasn't been defined yet
if not configs.protobuf_language_server then
  configs.protobuf_language_server = {
    default_config = {
      cmd = { 'protobuf-language-server' },  -- Assumes the binary is in your PATH.
      filetypes = { 'proto', 'cpp' },          -- Adjust filetypes if needed.
      root_dir = util.root_pattern('.git'),    -- Customize root_dir as appropriate.
      single_file_support = true,
      settings = {
        ["additional-proto-dirs"] = {
          -- Insert additional directories if needed:
          -- "vendor",
          -- "third_party",
        },
      },
    },
  }
end

local lspconfig = require('lspconfig')

-- It's assumed that you have common on_attach and capabilities set up in your lsp.lua.
-- For example, you might have:
-- local on_attach = require('lsp').on_attach
-- local capabilities = require('lsp').capabilities
-- Otherwise, you can define them here.
local on_attach = vim.lsp.buf_attach_client or function() end
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

lspconfig.protobuf_language_server.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})
