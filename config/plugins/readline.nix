{ pkgs, ... }: {

  extraPlugins = [
    pkgs.vimPlugins.readline-vim
  ];

  # extraConfigLua = ''
  #   require('readline.vim')
  # '';
}
