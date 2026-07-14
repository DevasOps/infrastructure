# ╭──────────────────────────────────────────────────────────╮
# │ AI                                                       │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  osConfig,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  # sops decrypted aix/p key file path (0400, owner only)
  aixKeyPath = osConfig.sops.secrets."aix/p".path;
in
{
  imports = [
    inputs.agent-skills.homeManagerModules.default

    self.homeModules.oh-my-pi
  ];
  programs = {
    agent-skills = {
      enable = true;
      sources.caveman = {
        path = inputs.caveman;
        subdir = "skills";
      };
      skills.enableAll = true;
      targets.claude.enable = true;
      targets.codex.enable = true;
      targets.agents.enable = true;
    };
    claude-code = {
      enable = true;
      settings = {
        includeCoAuthoredBy = false;
        permissions = {
          defaultMode = "bypassPermissions";
          skipDangerousModePermissionPrompt = true;
        };
        env = {
          CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS = "1";
          # iflytek Claude transfer station (Anthropic compatible endpoint)
          ANTHROPIC_BASE_URL = "https://one.iflytek.com/api/llm/console/chat";
        };
        # read auth token from sops decrypted file at runtime, key never in store/git
        apiKeyHelper = "cat ${aixKeyPath}";
        model = "claude-sonnet-5";
        statusLine = {
          type = "command";
          command = "bash \"${inputs.caveman}/src/hooks/caveman-statusline.sh\"";
        };
      };
      plugins = [
        inputs.superpowers
      ];
    };
  };
}