{ config, lib, ... }: {

  options.autoCmdGroup = lib.mkOption {
    default = { };
    description = "A list of user commands to add to the configuration.";
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        clear = lib.mkOption {
          type = lib.types.bool;
          description = "Clear existing commands if the group already exists.";
          default = true;
        };
        autoCmds = lib.mkOption {
          type = lib.types.listOf (lib.types.submodule {
            options = (builtins.removeAttrs lib.nixvim.autocmd.autoCmdOptions [ "group" ]);
          });

          default = [ ];
          description = "autocmd definitions";
        };
      };
    });
  };

  config = lib.mkIf (config.autoCmdGroup != { }) {
    autoGroups = lib.mapAttrs (n: v: (removeAttrs v [ "autoCmds" ])) config.autoCmdGroup;

    autoCmd = lib.flatten (lib.mapAttrsToList (group: { autoCmds, ... }:
      ( map (x: x // { inherit group; }) autoCmds )
    ) config.autoCmdGroup);
  };
}
