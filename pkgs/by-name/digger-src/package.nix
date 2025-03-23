{
  fetchFromGitHub,
  version ? "0.6.87",
}:
fetchFromGitHub {
  owner = "diggerhq";
  repo = "digger";
  rev = "v${version}";
  hash = "sha256-yDBRI7skY/u22F/Sdv37GDvNdq/lkpqGf0gIrktMbT0=";
}
