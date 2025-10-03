{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins;
let
  cfg = config.services.pgweb;
  serviceDataDir = "/var/lib/pgweb";
in
{
  options.services.pgweb = {
    enable = mkEnableOption (mdDoc "pgweb - Cross-platform client for PostgreSQL databases.");

    package = mkOption {
      type = types.package;
      default = pkgs.pgweb;
      defaultText = literalExpression "pkgs.pgweb";
      description = mdDoc ''This option specifies the cloudflared package to use.'';
    };

    url = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc "Database connection string.";
    };

    host = mkOption {
      type = types.str;
      default = "localhost";
      description = mdDoc "Server hostname or IP (default: localhost).";
    };

    port = mkOption {
      type = types.port;
      default = 5432;
      description = mdDoc "Server port (default: 5432).";
    };

    user = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc "Database user.";
    };

    pass = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc "Password for user.";
    };

    db = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc "Database name.";
    };

    ssl = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc "SSL option.";
    };

    bind = mkOption {
      type = types.str;
      default = "localhost";
      description = mdDoc "HTTP server host.";
    };

    listen = mkOption {
      type = types.port;
      default = 8081;
      description = mdDoc "HTTP server listen port.";
    };

    authUser = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc "HTTP basic auth user.";
    };

    authPass = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc "HTTP basic auth password.";
    };

    sessions = mkOption {
      type = types.bool;
      default = true;
      description = mdDoc "Enable multiple database sessions.";
    };

    prefix = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc "Add a url prefix.";
    };

    readOnly = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "Run database connection in readonly mode.";
    };

    lockSession = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "Lock session to a single database connection.";
    };

    bookmark = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc "Bookmark to use for connection. Bookmark files are stored under $HOME/.pgweb/bookmarks/*.toml";
    };

    bookmarksDir = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = mdDoc "Overrides default directory for bookmark files to search.";
    };

    noPrettyJSON = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "Disable JSON formatting feature for result export.";
    };

    noSSH = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "Disable database connections via SSH";
    };

    connectBackend = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc "Enable database authentication through a third party backend.";
    };

    connectToken = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc "Authentication token for the third-party connect backend.";
    };

    connectHeaders = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = mdDoc "List of headers to pass to the connect backend.";
    };

    noIdleTimeout = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "Disable connection idle timeout.";
    };

    idleTimeout = mkOption {
      type = types.int;
      default = 180;
      description = mdDoc "Set connection idle timeout in minutes.";
    };

    cors = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "Enable Cross-Origin Resource Sharing (CORS).";
    };

    corsOrigins = mkOption {
      type = types.listOf types.str;
      default = [ "*" ];
      description = mdDoc "Allowed CORS origins.";
    };

    debug = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "Enable debugging mode.";
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/etc/secrets/pgweb.env";
      description = lib.mdDoc ''
        File containing environment variables to be passed to pgweb service.

        Available settings are listed on
        https://github.com/sosedoff/pgweb/wiki/Usage#environment-variables-available.
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "Open ports in the firewall for pgweb.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.pgweb = {
      description = "pgweb - Cross-platform client for PostgreSQL databases";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        Restart = "on-abort";
        EnvironmentFile = mkIf (cfg.environmentFile != null) cfg.environmentFile;
        AmbientCapabilities = mkIf (cfg.listen < 1024) [ "CAP_NET_BIND_SERVICE" ];
        ExecStart = concatStringsSep " \\\n " (
          [
            "${cfg.package}/bin/pgweb"
            "--skip-open" # won't open browser
            "--bind ${cfg.bind}"
            "--listen ${toString cfg.listen}"
          ]
          ++ (optional (cfg.url != null) "--url ${cfg.url}")
          ++ (optional (cfg.host != null) "--host ${cfg.host}")
          ++ (optional (cfg.port != null) "--port ${toString cfg.port}")
          ++ (optional (cfg.user != null) "--user ${cfg.user}")
          ++ (optional (cfg.pass != null) "--pass ${cfg.pass}")
          ++ (optional (cfg.db != null) "--db ${cfg.db}")
          ++ (optional (cfg.ssl != null) "--ssl ${cfg.ssl}")
          ++ (optional (cfg.authUser != null) "--auth-user ${cfg.authUser}")
          ++ (optional (cfg.authPass != null) "--auth-pass ${cfg.authPass}")
          ++ (optional (cfg.sessions != null) "--sessions")
          ++ (optional (cfg.prefix != null) "--prefix ${cfg.prefix}")
          ++ (optional (cfg.readOnly != null) "--readonly")
          ++ (optional (cfg.lockSession != null) "--lock-session")
          ++ (optional (cfg.bookmark != null) "--bookmark ${cfg.bookmark}")
          ++ (optional (cfg.bookmarksDir != null) "--bookmarks-dir ${cfg.bookmarksDir}")
          ++ (optional cfg.noPrettyJSON "--no-pretty-json")
          ++ (optional cfg.noSSH "--no-ssh")
          ++ (optional (cfg.connectBackend != null) "--connect-backend ${cfg.connectBackend}")
          ++ (optional (cfg.connectToken != null) "--connect-token ${cfg.connectToken}")
          ++ (optionals (cfg.connectHeaders != [ ]) [ "--connect-headers" ] ++ cfg.connectHeaders)
          ++ (optional cfg.noIdleTimeout "--no-idle-timeout")
          ++ (optional (!cfg.noIdleTimeout) "--idle-timeout ${toString cfg.idleTimeout}")
          ++ (optionals cfg.cors [ "--cors --cors-origins" ] ++ cfg.corsOrigins)
          ++ (optional cfg.debug "--debug")
        );
        DynamicUser = true;
        RestartSec = 5;
        WorkingDirectory = serviceDataDir;
        StateDirectory = baseNameOf serviceDataDir;
        TimeoutStartSec = 0;
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.listen ];
    };
  };
}
