{
  inputs,
  self,
  ...
}: {
  flake.modules.homeManager.llms = {
    pkgs,
    config,
    ...
  }: {
    home.packages = with pkgs; [
      claude-code
      claude-monitor
      inputs.lemonade-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
      # openrouter ori might be nice to have
    ];

    age.secrets."openrouter_api_key".file = "${self.inputs.secrets}/openrouter_api_key.age";

    home.sessionVariables = {
      ANTHROPIC_BASE_URL = "https://openrouter.ai/api";
      ANTHROPIC_API_KEY = "";
      CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY = 1;
    };

    # Read the decrypted secret at shell startup rather than baking it into the
    # Nix store. agenix decrypts to a tmpfs under $XDG_RUNTIME_DIR on activation.
    home.sessionVariablesExtra = ''
      if [ -r "${config.age.secrets."openrouter_api_key".path}" ]; then
        OPENROUTER_API_KEY="$(cat "${config.age.secrets."openrouter_api_key".path}")"
        ANTHROPIC_AUTH_TOKEN="$OPENROUTER_API_KEY"
        export OPENROUTER_API_KEY ANTHROPIC_AUTH_TOKEN
      fi
    '';
  };
}
