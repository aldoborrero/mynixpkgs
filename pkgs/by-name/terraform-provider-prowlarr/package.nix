{
  terraform-providers,
  lib,
  homepage ? "https://registry.terraform.io/providers/devopsarr/prowlarr",
  provider-source-address ? null,
  ...
}:
terraform-providers.mkProvider {
  inherit homepage;
  owner = "devopsarr";
  repo = "terraform-provider-prowlarr";
  rev = "v3.0.2";
  version = "3.0.2";
  vendorHash = "sha256-vwASX0WQn89kIlC/X8zeZSVjJHPEGkuvwT5T+z4m8fU=";
  hash = "sha256-mTwYYsD9FdruBO1skADyq0HrE9ZhVadngn/mLptqczY=";
  spdx = "MIT";
}
// lib.optionalAttrs (provider-source-address != null) {
  inherit provider-source-address;
}
