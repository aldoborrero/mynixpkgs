{
  terraform-providers,
  lib,
  homepage ? "https://registry.terraform.io/providers/devopsarr/sonarr",
  provider-source-address ? null,
  ...
}:
terraform-providers.mkProvider {
  inherit homepage;
  owner = "devopsarr";
  repo = "terraform-provider-sonarr";
  rev = "v3.4.0";
  version = "3.4.0";
  hash = "sha256-Laip+WMdjHyq9og/QWRdnxuj/UGp9HnaJsad+Q7CNIM=";
  vendorHash = "sha256-UDtVDnQDyQfZdx6ba3K1Chx2/ffHYlUX7eiDm1R0iFg=";
  spdx = "MIT";
}
// lib.optionalAttrs (provider-source-address != null) {
  inherit provider-source-address;
}
