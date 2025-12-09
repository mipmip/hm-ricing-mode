self: { config, pkgs, lib, ... }:

let
  cfg = config.programs.hm-ricing-mode;
  iniFormat = pkgs.formats.json { };

  inherit (pkgs.stdenv.hostPlatform) system;
  hm-ricing-mode = self.packages.${system}.hm-ricing-mode;

  mipmip = {
    name = "Pim Snel";
    email = "post@pimsnel.com";
    github = "mipmip";
    githubId = 658612;
  };

in {

  meta.maintainers = [ mipmip ];

  options.programs.hm-ricing-mode = {

    enable = lib.mkEnableOption "HM Ricing Mode";

    apps = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule [
        {
          options = {

            type = lib.mkOption {
              type = lib.types.enum [
                "backport"
                "symlink"
              ];
              default= "backport";
              description = ''
                The ricing mode type:
                - `backport` (default): replaces the nix-generated app-config directory with a temporary modifiable copy of this directory. User is responsible for backporting the changes to nix Home Manager.
                - `symlink`: creates symlink to original location in the git repository. This is only relevant for config's using `home.file.recursive = true;`
              '';
            };

            dest_dir = lib.mkOption {
              type = lib.types.str;
              description = ''
                Path of the destination application configuration directory.
              '';
            };

            source_dir = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = ''
                Path of the destination application configuration directory.
              '';
            };
          };
        }

      ]);
      default = { };
      description = "List of apps which allow ricing mode.";
    };
  };

  config =
    let
      cleanedApps = lib.filterAttrsRecursive (name: value: value != null) cfg.apps;

    in lib.mkIf cfg.enable {
      home.file."${config.home.homeDirectory}/.config/hm-ricing-mode/apps.json".source = (iniFormat.generate "hm-ricing-mode" cleanedApps);

      home.packages = [
          hm-ricing-mode
      ];
  };
}
