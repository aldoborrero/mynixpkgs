{
  buildGo122Module,
  fetchFromGitHub,
  lib,
}:
buildGo122Module rec {
  pname = "helm-dt";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "vmware-labs";
    repo = "distribution-tooling-for-helm";
    rev = "v${version}";
    hash = "sha256-m+XTR+LYTXeDTqo/deFAIQjbUqGn6yD/n5cQvJ+jKPc=";
  };

  vendorHash = "sha256-rovAY4G4ew6JhehyXMz7cDKSEsHu0IQwaNYvClDog2s=";

  ldflags = [
    "-s"
    "-w"
  ];

  postPatch = ''
    sed -i '/^hooks:/,+2 d' plugin.yaml
  '';

  postInstall = ''
    install -dm755 $out/${pname}/bin
    ln -s $out/bin/dt $out/${pname}/bin/dt
    install -m644 -Dt $out/${pname} plugin.yaml
  '';

  subPackages = ["cmd/dt"];

  doCheck = false;

  meta = with lib; {
    description = "Helm Distribution plugin is is a set of utilities and Helm Plugin for making offline work with Helm Charts easier. It is meant to be used for creating reproducible and relocatable packages for Helm Charts that can be moved around registries without hassles. This is particularly useful for distributing Helm Charts into airgapped environments";
    homepage = "https://github.com/vmware-labs/distribution-tooling-for-helm";
    license = licenses.mit;
    maintainers = with maintainers; [aldoborrero];
    mainProgram = "dt";
  };
}
