{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;
    userName = "YannickHerrero";
    userEmail = "yannick.herrero@proton.me";

    delta = {
      enable = true;
      options = {
        navigate = true;
        side-by-side = true;
      };
    };

    aliases = {
      st = "status";
      ck = "checkout";
      lo = "log";
    };

    extraConfig = {
      core = {
        editor = "nvim";
        autocrlf = "input";
      };
      credential.helper = "store";
      interactive.diffFilter = "delta --color-only";
      pull.rebase = false;
      merge = {
        tool = "nvimdiff";
        conflictstyle = "diff3";
      };
      diff = {
        colorMoved = "default";
        tool = "nvimdiff";
        guitool = "nvimdiff";
      };
      mergetool = {
        keepBackup = false;
        trustExitCode = false;
        prompt = true;
      };
      "mergetool \"nvimdiff\"".layout = "LOCAL,BASE,REMOTE / MERGED";
      difftool.prompt = false;
    };

    ignores = [
      ".DS_Store"
      "Thumbs.db"
      ".idea/"
      ".vscode/"
      ".env.local"
      ".env.*.local"
    ];
  };
}
