{ ... }: {

  plugins.vim-suda = {
    enable = true;
    settings.prompt = "Write with sudo. Password: ";
  };

  keymaps = [{
    mode = "c";
    key = "w!!";
    action = "<cmd>:SudaWrite<CR>";
    options.desc = "Forcedly save a current file with sudo";
  }];

}
