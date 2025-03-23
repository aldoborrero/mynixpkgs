{
  buildGoModule,
  installShellFiles,
  lib,
  digger-src,
}:
buildGoModule rec {
  pname = "digger-dgctl";
  version = "0.6.87";

  src = digger-src;

  vendorHash = "sha256-fjX4iqrlWkuZrEOOfgEmDpqHs8qMrH9ZupLSzzFM7qo=";
  proxyVendor = true;

  env.CGO_ENABLED = 0;

  patches = [
    ./001-dgctl-extra-cmd.patch
  ];

  ldflags = [
    "-s"
    "-w"
    "-X digger/pkg/utils.version=${version}"
  ];

  subPackages = ["dgctl"];

  nativeBuildInputs = [installShellFiles];

  postInstall = ''
    installShellCompletion --cmd dgctl \
      --bash <($out/bin/dgctl completion bash) \
      --fish <($out/bin/dgctl completion fish) \
      --zsh <($out/bin/dgctl completion zsh)
  '';

  meta = with lib; {
    description = "Digger is an open source IaC orchestration tool. Digger allows you to run IaC in your existing CI pipeline";
    homepage = "https://github.com/diggerhq/digger";
    license = licenses.asl20;
    mainProgram = "dgctl";
    maintainers = with maintainers; [aldoborrero];
  };
}
