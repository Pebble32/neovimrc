vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use {'wbthomason/packer.nvim', opt = true}

  -- deffview
  use { "sindrets/diffview.nvim" }
end)
