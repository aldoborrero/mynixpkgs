{
  terraform-providers,
  lib,
  homepage ? "https://registry.terraform.io/providers/kevynb/terraform-provider-technitium",
  provider-source-address ? null,
  ...
}:
terraform-providers.mkProvider {
  owner = "kevynb";
  repo = "terraform-provider-technitium";
  rev = "v0.2.0";
  version = "0.2.0";
  vendorHash = "sha256-8FsZALAgLcFEH1w1ybyF4qbhtHFMWVTh/AvdEuvss3A=";
  inherit homepage;
  hash = "sha256-yve3xd17pZDMzcrKwzp4u4rCt5u2KkJ9LCscwWyccto=";
  spdx = "MIT";
}
// lib.optionalAttrs (provider-source-address != null) {
  inherit provider-source-address;
}
