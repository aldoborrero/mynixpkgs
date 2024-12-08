{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.split-pro;
in {
  options.services.split-pro = {
    enable = mkEnableOption "Split-pro expense sharing application";

    package = mkPackageOption pkgs "split-pro" {};

    address = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = ''
        The IP address on which Split-pro will listen.
        If empty, listens on all interfaces.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 3000;
      description = "Port on which Split-pro listens";
    };

    user = mkOption {
      type = types.nullOr types.str;
      default = "split-pro";
      description = "User account under which Split-pro runs.";
    };

    group = mkOption {
      type = types.nullOr types.str;
      default = "split-pro";
      description = "Group under which Split-pro runs.";
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = ''
        Configuration of the split-pro service.

        See [the split-pro docker-compose config options](https://github.com/oss-apps/split-pro/blob/main/docker/prod/compose.yml#L28) for available options and default values.
      '';
      example = {
        ALLOW_SIGNUP = "false";
      };
    };

    credentialsFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/run/secrets/split-pro.env";
      description = ''
        File containing sensitive environment variables in the format of systemd environment file format:
        - DATABASE_URL
        - NEXTAUTH_SECRET
        - GOOGLE_CLIENT_ID
        - GOOGLE_CLIENT_SECRET
        - EMAIL_SERVER_USER
        - EMAIL_SERVER_PASSWORD
        - R2_ACCESS_KEY
        - R2_SECRET_KEY
        - WEB_PUSH_PRIVATE_KEY
        - WEB_PUSH_PUBLIC_KEY
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.split-pro = {
      description = "Split-pro expense sharing application";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];

      # environment =
      #   {
      #     PORT = toString cfg.port;
      #     NEXTAUTH_URL = cfg.settings.nextauth.url;
      #     AUTH_PROVIDERS = cfg.settings.auth.providers;
      #     ENABLE_SENDING_INVITES = toString cfg.settings.email.enable;
      #   }
      #   // optionalAttrs (cfg.settings.email.enable) {
      #     FROM_EMAIL = cfg.settings.email.from;
      #     EMAIL_SERVER_HOST = cfg.settings.email.server.host;
      #     EMAIL_SERVER_PORT = toString cfg.settings.email.server.port;
      #   }
      #   // optionalAttrs (cfg.settings.storage.enable) {
      #     R2_BUCKET = cfg.settings.storage.r2.bucket;
      #     R2_URL = cfg.settings.storage.r2.url;
      #     R2_PUBLIC_URL = cfg.settings.storage.r2.publicUrl;
      #   };

      environment =
        {
          PORT = toString cfg.port;
        }
        // (builtins.mapAttrs (_: val: toString val) cfg.settings);

      serviceConfig = {
        Type = "simple";
        DynamicUser = mkIf (cfg.user == "" && cfg.group == "") true;
        User = mkIf (cfg.user != "") cfg.user;
        Group = mkIf (cfg.group != "") cfg.group;
        ExecStart = "${cfg.package}/bin/split-pro";
        Restart = "always";
        RestartSec = "10";

        # Credentials
        EnvironmentFile = [cfg.credentialsFile];

        # Security options
        PrivateDevices = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
      };
    };

    users.users = mkIf (cfg.user != "") {
      ${cfg.user} = {
        isSystemUser = true;
        group = cfg.group;
        description = "Split-pro service user";
      };
    };

    users.groups = mkIf (cfg.group != "") {
      ${cfg.group} = {};
    };
  };
}
