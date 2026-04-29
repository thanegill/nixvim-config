{ ... }: {
  imports = [
    ./plugins/gitsigns.nix
  ];

  plugins = {
    fugitive.enable = true;
  };

  # autoCmdGroup.gitcommit.autoCmds = [{
  #   event = [ "FileType" ];
  #   pattern = "gitcommit";
  #   command = ":DiffGitCached | wincmd p | resize 20";
  #   desc = "Auto show git diff --cached in horizontal split";
  #   callback.__raw = ''
  #     function()
  #       vim.opt.winfixheight = 20;
  #     end
  #   '';
  # }];

}
