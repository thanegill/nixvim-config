{ ... }: {

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
