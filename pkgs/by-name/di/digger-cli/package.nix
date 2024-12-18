{
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  lib,
}:
buildGoModule rec {
  pname = "digger-cli";
  version = "0.6.79";

  src = fetchFromGitHub {
    owner = "diggerhq";
    repo = "digger";
    rev = "v${version}";
    hash = "sha256-/R52dwgKqpU9ffka5bz9xb7NyoCIu2/AgiWG0TT8nd0=";
  };

  vendorHash = "sha256-qcItUM2wQ4fgFDMGkyymxQugGaRQvn7rrmSzaLtL76Q=";
  proxyVendor = true;

  CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X digger/pkg/utils.version=${version}"
  ];

  subPackages = ["cli/cmd/digger"];

  nativeBuildInputs = [installShellFiles];

  postInstall = ''
    installShellCompletion --cmd digger \
      --bash <($out/bin/digger completion bash) \
      --fish <($out/bin/digger completion fish) \
      --zsh <($out/bin/digger completion zsh)
  '';

  meta = with lib; {
    description = "Digger is an open source IaC orchestration tool. Digger allows you to run IaC in your existing CI pipeline";
    homepage = "https://github.com/diggerhq/digger";
    license = licenses.asl20;
    mainProgram = "digger";
    maintainers = with maintainers; [aldoborrero];
  };
}
