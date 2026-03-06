{ lib, config, ... }: {

  imports = [
    ./plugins/whitespace.nix
    ./plugins/conform.nix
    ./plugins/suda.nix
    ./plugins/treejs.nix
  ];

  config = lib.mkMerge [ {
    plugins = {
      # Work with several variants of a word at once
      # crc camelCase
      # crp PascalCase
      # crm MixedCase (aka PascalCase)
      # cr_ snake_case
      # crs snake_case
      # cru SNAKE_UPPERCASE
      # crU SNAKE_UPPERCASE
      # crk kebab-case (not usually reversible; see |abolish-coercion-reversible|)
      # cr- dash-case (aka kebab-case)
      # cr. dot.case (not usually reversible; see |abolish-coercion-reversible|)
      #
      # https://nix-community.github.io/nixvim/plugins/abolish/index.html
      # https://github.com/tpope/vim-abolish/
      abolish.enable = true;

      # Inserts matching pairs of parens, brackets, etc.
      # https://nix-community.github.io/nixvim/plugins/nvim-autopairs/index.html
      # https://github.com/windwp/nvim-autopairs/
      nvim-autopairs = {
        enable = true;
        settings = {
          check_ts = config.plugins.treesitter.enable;
          disable_in_visualblock = true;
        };
      };

      # Comments. Supports treesitter, dot repeat, left-right/up-down motions,
      # hooks, and more.
      # https://nix-community.github.io/nixvim/plugins/comment/index.html
      # https://github.com/numtostr/comment.nvim/
      comment.enable = true;

      # Enable repeating supported plugin maps with the '.' command.
      # https://nix-community.github.io/nixvim/plugins/repeat/index.html
      repeat.enable = true;

      # Better Around/Inside textobjects
      #
      # Examples:
      #  - va)  - [V]isually select [A]round [)]paren
      #  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      #  - ci'  - [C]hange [I]nside [']quote
      #
      # https://nix-community.github.io/nixvim/plugins/mini-ai/index.html
      # https://github.com/nvim-mini/mini.ai/
      mini-ai = {
        enable = true;
        settings.n_line = 500;
      };

      # Add/delete/replace surroundings (brackets, quotes, etc.)
      #
      # Examples:
      #  - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      #  - sd'   - [S]urround [D]elete [']quotes
      #  - sr)'  - [S]urround [R]eplace [)] [']
      vim-surround.enable = true;

      # Preview CSS colors in Vim.
      # https://nix-community.github.io/nixvim/plugins/vim-css-color/index.html
      # vim-css-color.enable = true;

      # Adds indentation guides
      # https://nix-community.github.io/nixvim/plugins/indent-blankline/index.html
      indent-blankline = {
        enable = true;
        settings.scope = {
          show_end = false;
          show_start = false;
        };
      };

      # Automatically opens files at your last edit position
      # https://nix-community.github.io/nixvim/plugins/lastplace/settings.html?highlight=lastpl#pluginslastplacesettings
      lastplace.enable = true;

      # https://nix-community.github.io/nixvim/plugins/hardtime/index.html
      # https://github.com/m4xshen/hardtime.nvim/
      hardtime = {
        enable = true;
        settings = {
          restriction_mode = "hint";
          disable_mouse = false;
        };
      };

    };

    opts = {
      # Enable break indent
      breakindent = true;

      # Show matching brackets when text indicator is over them
      showmatch = true;

      # Don't wrap lines
      wrap = false;

      # Use spaces instead of tabs
      expandtab = true;
      tabstop = 4;
      softtabstop = 4;
      shiftwidth = 4;
      smartindent = true;

      # Default textwidth
      textwidth = 80;

      # Preview substitutions live, as you type!
      inccommand = "split";

      # Don't fold by default
      foldenable = false;

      formatoptions = "tcroqnjp";

    };

    keymaps = [
      # Disable arrow keys in normal mode
      { mode = "n"; key = "<up>"; action = "<cmd>echo 'Use k to move!'<CR>"; }
      { mode = "n"; key = "<down>"; action = "<cmd>echo 'Use j to move!'<CR>"; }
      { mode = "n"; key = "<left>"; action = "<cmd>echo 'Use h to move!'<CR>"; }
      { mode = "n"; key = "<right>"; action = "<cmd>echo 'Use l to move!'<CR>"; }

      # Reselect on indent/unindented in visual mode.
      { mode = "v"; key = ">"; action = ">gv"; }
      { mode = "v"; key = "<"; action = "<gv"; }

      # Search and replace word under cursor
      { mode = "n"; key = "\#"; action = '':%s/\<<C-r><C-w>\>//g<Left><Left>''; }
      # And for visual: https://stackoverflow.com/questions/676600/vim-search-and-replace-selected-text
      { mode = "v"; key = "\#"; action = ''""y:%s/<C-r>=escape(@", '/\')<CR>//g<Left><Left>''; }
    ];

    # Tread hyphenated words as words.
    extraConfigLua = ''
      vim.opt.iskeyword:append("-")
    '';
  }

  # Clipboard
  {
    keymaps = [{ key = "<leader>pp"; action = ":setlocal paste!"; }];

    # Disable paste mode when leaving insert mode
    autoCmdGroup.paste.autoCmds = [{
      desc = "Disable paste mode when leaving insert mode";
      event = [ "InsertLeave" ];
      callback.__raw = ''
        function()
          vim.opt.paste = false
        end
      '';
    }];

    # https://nix-community.github.io/nixvim/NeovimOptions/autoCmd/index.html
    autoCmdGroup.highlight-yank.autoCmds = [{
      # Highlight when yanking (copying) text. See `:help vim.hl.on_yank()`.
      desc = "Highlight when yanking text";
      event = [ "TextYankPost" ];
      callback.__raw = ''
        function()
          vim.highlight.on_yank({ higroup = 'IncSearch' })
        end
      '';
    }];
  } ];
}
