{
  writeShellApplication,
  openssl,
  gum,
}:
writeShellApplication {
  name = "p12";
  runtimeInputs = [openssl gum];
  text = builtins.readFile ./p12.sh;

  meta = {
    description = "A tool for managing P12 certificates";
    mainProgram = "p12";
  };
}
