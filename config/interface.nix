{ pkgs, lib, config, ... }: {

  extraPlugins = [
    pkgs.vimPlugins.readline-vim
  ];

  plugins = {

    which-key.enable = true;

    # Adds icons for plugins to utilize in ui
    web-devicons.enable = config.hasNerdFont;

    # https://nix-community.github.io/nixvim/plugins/lualine/index.html
    # https://github.com/nvim-lualine/lualine.nvim
    lualine = {
      enable = true;
      settings = {
        options = {
          icons_enabled = false;
          theme = "tokyonight";
          # Disable seperators
          section_separators = "";
          component_separators = "";
          always_show_tabline = true;
        };

        sections = {
          lualine_a = [ "mode" ];
          lualine_b = [ "branch" "diff" "diagnostics" ];
          lualine_c = [ "filename" "lsp_status" "searchcount" ];
          lualine_x = [ {
            __unkeyed-1.__raw = ''
              function()
                return require("auto-session.lib").current_session_name(true)
              end
            '';
          } ];
          lualine_y = [
            "filetype"
            {
              # Display the fileformat section as CRLF instead of icons or
              # unix/dos/mac
              __unkeyed-1 = "fileformat";
              icons_enabled = true;
              symbols = {
                unix = "LF";
                dos = "CRLF";
                mac = "CR";
              };
            }
            "fileformat"
            "encoding"
          ];
          lualine_z = [ "location" ];
        };
        inactive_sections = {
          lualine_a = [ ];
          lualine_b = [ ];
          lualine_c = [ "filename" ];
          lualine_x = [ "location" ];
          lualine_y = [ ];
          lualine_z = [ ];
        };
        extensions = let
          cfgp = config.plugins;
        in (
             lib.optional cfgp.fugitive.enable "fugitive"
          ++ lib.optional cfgp.oil.enable "oil"
          ++ lib.optional cfgp.neo-tree.enable "neotree"
        );
      };
    };
  };

  extraConfigLua = ''
    --  Don't give the intro message when starting.
    vim.opt.shortmess:append("I")
    vim.opt.fillchars:append("vert:\ ")
  '';

  opts = {
    # Display certain whitespace characters in the editor.
    list = true;
    listchars = {
      tab = "▸ ";
      trail = "·";
      eol = "¬";
      nbsp = "⎵";
      extends = "▸";
      precedes = "◂";
    };

    showbreak = "↪";

    # Show line numbers
    number = true;
    #relativenumber = true;

    # Splits to the right and below
    splitright = true;
    splitbelow = true;

    # Show which line your cursor is on.
    cursorline = true;

    # Don't show the mode in the comandline since it's already in the
    # statusline.
    showmode = false;

    # Highlight textwidth column plus one
    colorcolumn = "+1";

    # Keep signcolumn on by default
    signcolumn = "yes";

    # Always show tabs
    showtabline = 2;
  };

  keymaps = [
    # Use CTRL+<hjkl> to switch between windows
    # See `:help wincmd` for a list of all window commands
    { mode = "n"; key = "<C-h>"; action = "<C-w><C-h>"; options.desc = "Move focus to the left window"; }
    { mode = "n"; key = "<C-l>"; action = "<C-w><C-l>"; options.desc = "Move focus to the right window"; }
    { mode = "n"; key = "<C-j>"; action = "<C-w><C-j>"; options.desc = "Move focus to the lower window"; }
    { mode = "n"; key = "<C-k>"; action = "<C-w><C-k>"; options.desc = "Move focus to the upper window"; }
  ];

  autoCmdGroup.scrolloff.autoCmds = [{
    # Set scrolloff to 1/10 of the window height dynamically
    # https://stackoverflow.com/a/47154088/1202754
    event = [ "VimEnter" "WinEnter" "VimResized" ];
    desc = "Set scrolloff to a 10th of the window height dynamically";
    callback.__raw = ''
      function()
        vim.opt.scrolloff = math.min(math.floor(vim.fn.winheight(0) / 10), 15)
      end
    '';
  }];

  # To see what colorschemes are already installed run `:Telescope colorscheme`.
  # https://nix-community.github.io/nixvim/colorschemes/tokyonight/index.html
  colorschemes.tokyonight = {
    enable = true;
    settings = {
      style = "night";
      styles.comments.italic = false;
    };
  };

}
