{
  buildGoModule,
  installShellFiles,
  lib,
  digger-src,
}:
buildGoModule rec {
  pname = "digger-cli";
  version = "0.6.87";

  src = digger-src;

  vendorHash = "sha256-fjX4iqrlWkuZrEOOfgEmDpqHs8qMrH9ZupLSzzFM7qo=";
  proxyVendor = true;

  env.CGO_ENABLED = 0;

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
