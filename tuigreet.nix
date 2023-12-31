{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption optionalString mkIf types;
  dmcfg = config.services.xserver.displayManager;
  cfg = config.personal.desktop.displayManager.tuigreet;
  gduser = config.services.greetd.settings.default_session.user;
in {
  options.personal.desktop.displayManager.tuigreet = {
    enable = mkEnableOption "enables tuigreet";
    args = mkOption {
      default = "--time --asterisks --remember -s ${dmcfg.sessionData.desktops}/share/wayland-sessions:${dmcfg.sessionData.desktops}/share/xsessions";
      type = types.str;
    };
  };
  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet ${cfg.args}";
          user = "greeter";
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/cache/tuigreet/ 0755 greeter ${gduser} - -"
    ];
  };
}
