{ lib, pkgs, ... }: lib.mkMerge [

{
  # https://nix-community.github.io/nixvim/plugins/avante/index.html
  # https://github.com/yetone/avante.nvim
  plugins.avante = {
    enable = true;
    settings = {
      provider = "lmstudio";
      auto_suggestions_provider = "lmstudio";
      providers = {
        # https://github.com/yetone/avante.nvim/issues/2488
        lmstudio = {
          __inherited_from = "openai";
          endpoint = "http://localhost:1234/v1";
          api_key_name = "";
            model = "qwen3.5-35b-a3b@q8_0";
        };
      };
    };
  };
}

{
  # https://nix-community.github.io/nixvim/plugins/codecompanion/index.html
  # https://github.com/olimorris/codecompanion.nvim/
  plugins.codecompanion = {
    enable = true;
    settings = {
      strategies = {
        agent.adapter = "ollama";
        chat.adapter = "ollama";
        cmd.adapter = "ollama";
        inline.adapter = "ollama";
      };
      adapters.http.ollama.__raw = ''
        function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            env = {
              url = "http://localhost:1234",
            },
          })
        end
        '';
      display.chat.show_settings = true;
      opts = {
        log_level = "TRACE";
        send_code = true;
        use_default_actions = true;
        use_default_prompts = true;
      };
    };
  };

  # https://github.com/franco-ruggeri/codecompanion-spinner.nvim
  extraPlugins = [ pkgs.vimPlugins.codecompanion-spinner-nvim ];
  plugins.codecompanion.settings.extensions.spinner = {};

  keymaps = [
    {
      mode = [ "n" "v" ];
      key = "<leader>cc";
      action = "<cmd>CodeCompanionChat<cr>";
      options.desc = "Chat";
    }
    {
      mode = [ "n" "v" ];
      key = "<leader>ct";
      action = "<cmd>CodeCompanionChat Toggle<cr>";
      options.desc = "Toggle";
    }
    {
      mode = [ "n" "v" ];
      key = "<leader>ce";
      action = "<cmd>CodeCompanionActions<cr>";
      options.desc = "Actions";
    }
    {
      mode = "v";
      key = "<leader>ca";
      action = "<cmd>CodeCompanionChat Add<cr>";
      options.desc = "Add to Chat";
    }
    {
      mode = [ "n" "v" ];
      key = "<leader>ci";
      action = "<cmd>CodeCompanion<cr>";
      options.desc = "Inline";
    }
  ];

}
