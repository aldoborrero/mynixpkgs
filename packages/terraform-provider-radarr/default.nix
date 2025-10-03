{
  pkgs,
  homepage ? "https://registry.terraform.io/providers/devopsarr/radarr",
  provider-source-address ? null,
  ...
}:
with pkgs;
terraform-providers.mkProvider {
  inherit homepage;
  owner = "devopsarr";
  repo = "terraform-provider-radarr";
  rev = "v2.3.2";
  version = "2.3.2";
  hash = "sha256-IsyvSGeLOBsjt1rhPmvOiJYI2FeolPjEiR0/IODqiTU=";
  vendorHash = "sha256-/7oKRDj40N/LXB5Z3KeASie9IwnUMi1nYiFpwpqxNys=";
  spdx = "MIT";
}
// lib.optionalAttrs (provider-source-address != null) {
  inherit provider-source-address;
}
