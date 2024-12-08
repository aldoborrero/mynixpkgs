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
      type = types.str;
      default = "split-pro";
      description = "User account under which Split-pro runs. If specified, DynamicUser will be disabled.";
    };

    group = mkOption {
      type = types.str;
      default = "split-pro";
      description = "Group under which Split-pro runs. If specified, DynamicUser will be disabled.";
    };

    credentialsFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/run/secrets/split-pro.env";
      description = ''
        File containing sensitive environment variables:
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

    settings = {
      database = {
        createLocally = mkOption {
          type = types.bool;
          default = false;
          description = "Create a local PostgreSQL database";
        };
      };

      nextauth = {
        url = mkOption {
          type = types.str;
          example = "https://split-pro.example.com";
          description = "Base URL of the application";
        };
      };

      auth = {
        providers = mkOption {
          type = types.str;
          description = "Enabled authentication providers";
        };
      };

      email = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable email functionality";
        };

        from = mkOption {
          type = types.str;
          default = "";
          description = "From email address";
        };

        server = {
          host = mkOption {
            type = types.str;
            default = "";
            description = "SMTP server host";
          };

          port = mkOption {
            type = types.port;
            default = 587;
            description = "SMTP server port";
          };
        };
      };

      storage = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable R2 storage";
        };

        r2 = {
          bucket = mkOption {
            type = types.str;
            default = "";
            description = "R2 bucket name";
          };

          url = mkOption {
            type = types.str;
            default = "";
            description = "R2 endpoint URL";
          };

          publicUrl = mkOption {
            type = types.str;
            default = "";
            description = "R2 public URL";
          };
        };
      };

      webPush = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable web push notifications";
        };

        email = mkOption {
          type = types.str;
          default = "";
          description = "Web Push email";
        };
      };

      feedback = {
        email = mkOption {
          type = types.str;
          default = "";
          description = "Feedback email address";
        };

        discordWebhook = mkOption {
          type = types.str;
          default = "";
          description = "Discord webhook URL for feedback";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.credentialsFile != null;
        message = "services.split-pro.credentialsFile must be set";
      }
    ];

    systemd.services.split-pro = {
      description = "Split-pro expense sharing application";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];

      environment =
        {
          PORT = toString cfg.port;
          NEXTAUTH_URL = cfg.settings.nextauth.url;
          AUTH_PROVIDERS = cfg.settings.auth.providers;
          ENABLE_SENDING_INVITES = toString cfg.settings.email.enable;
        }
        // optionalAttrs (cfg.settings.email.enable) {
          FROM_EMAIL = cfg.settings.email.from;
          EMAIL_SERVER_HOST = cfg.settings.email.server.host;
          EMAIL_SERVER_PORT = toString cfg.settings.email.server.port;
        }
        // optionalAttrs (cfg.settings.storage.enable) {
          R2_BUCKET = cfg.settings.storage.r2.bucket;
          R2_URL = cfg.settings.storage.r2.url;
          R2_PUBLIC_URL = cfg.settings.storage.r2.publicUrl;
        }
        // optionalAttrs (cfg.settings.webPush.enable) {
          WEB_PUSH_EMAIL = cfg.settings.webPush.email;
        }
        // optionalAttrs (cfg.settings.feedback.email != "") {
          FEEDBACK_EMAIL = cfg.settings.feedback.email;
          DISCORD_WEBHOOK_URL = cfg.settings.feedback.discordWebhook;
        };

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
