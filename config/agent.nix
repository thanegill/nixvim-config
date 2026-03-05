{ pkgs, ... }: {

  # https://nix-community.github.io/nixvim/plugins/codecompanion/settings.html
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
