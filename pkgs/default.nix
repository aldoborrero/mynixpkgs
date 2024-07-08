{
  perSystem = {
    self',
    pkgs,
    lib,
    system,
    ...
  }: let
    inherit (pkgs) callPackage python311Packages;
  in {
    packages = lib.flakes.platformPkgs system rec {
      # by-name / ac
      actual-server = callPackage ./by-name/ac/actual-server {};

      # by-name / bu
      # buildarr = python311Packages.callPackage ./by-name/bu/buildarr {};

      # by-name / he
      helm-schema = callPackage ./by-name/he/helm-schema {};

      # by-name / je
      jetbrains-fleet = callPackage ./by-name/je/jetbrains-fleet {};

      # by-name / kc
      kcl = callPackage ./by-name/kc/kcl {inherit kclvm kclvm_cli;};
      kcl-language-server = callPackage ./by-name/kc/kcl-language-server {};
      kclvm = callPackage ./by-name/kc/kclvm {};
      kclvm_cli = callPackage ./by-name/kc/kclvm_cli {inherit kclvm;};

      # by-name / ll
      llm = callPackage ./by-name/ll/llm {};

      # by-name / os
      ospeak = callPackage ./by-name/os/ospeak {};

      # by-name / sr
      strip-tags = python311Packages.callPackage ./by-name/sr/strip-tags {};

      # by-name / zo
      zot = callPackage ./by-name/zo/zot {};

      # development / python-modules

      # llm-claude = python311Packages.callPackage ./development/python-modules/llm-claude {inherit llm;};
      # llm-gpt4all = python311Packages.callPackage ./development/python-modules/llm-gpt4all {inherit llm;};

      ctransformers = python311Packages.callPackage ./development/python-modules/ctransformers {};
      gpt4all = python311Packages.callPackage ./development/python-modules/gpt4all {};
      # llm-clip = python311Packages.callPackage ./development/python-modules/llm-clip {inherit llm;};
      # llm-cluster = python311Packages.callPackage ./development/python-modules/llm-cluster {inherit llm;};
      # llm-llama-cpp = python311Packages.callPackage ./development/python-modules/llm-llama-cpp {inherit llm;};
      # llm-mlc = python311Packages.callPackage ./development/python-modules/llm-mlc {inherit llm;};
      # llm-mpt30b = python311Packages.callPackage ./development/python-modules/llm-mpt30b {inherit llm ctransformers;};
      # llm-sentence-transformers = python311Packages.callPackage ./development/python-modules/llm-sentence-transformers {inherit llm;};
      mkdocs-exec = python311Packages.callPackage ./development/python-modules/mkdocs-exec {};
      mkdocs-git-authors-plugin = python311Packages.callPackage ./development/python-modules/mkdocs-git-authors-plugin {};
      mlc-llm = python311Packages.callPackage ./development/python-modules/mlc-llm {};
      # pydanticv2 = python311Packages.callPackage ./development/python-modules/pydanticv2 {};

      emvue-exporter = python311Packages.callPackage ./development/python-modules/emvue-exporter {};
    };

    apps = lib.mapAttrs (_name: drv: lib.flakes.mkApp {inherit drv;}) self'.packages;

    overlayAttrs = self'.packages;
  };
}
