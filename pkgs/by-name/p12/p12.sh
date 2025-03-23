#!/usr/bin/env bash

set -eo pipefail

VERSION="1.0.0"

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if required commands exist
if ! command_exists openssl; then
  error "OpenSSL is not installed. Please install it and try again."
fi

if ! command_exists gum; then
  error "gum is not installed. Please install charmbracelet/gum and try again."
fi

# Create a unique temporary directory
tmp_dir=$(mktemp -d /tmp/p12_verify.XXXXXX)
trap 'rm -rf "$tmp_dir"' EXIT

error() {
  echo "ERROR: $*" >&2
  exit 1
}

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

show_help() {
  echo "Usage: $0 <command> [options]"
  echo
  echo "Commands:"
  echo "  info              Display information about the p12 file"
  echo "  verify            Verify the p12 file and its contents"
  echo "  change-password   Change the password of the p12 file"
  echo "  version           Display version information"
  echo "  help              Display this help message"
  echo
  echo "Options:"
  echo "  -f, --file        Specify the p12 file path"
  echo
  echo "Example:"
  echo "  $0 info -f /path/to/certificate.p12"
}

get_p12_file() {
  local file="$1"
  if [[ -n $file ]]; then
    p12_file="$file"
  else
    p12_file=$(gum input --prompt "Enter the path to your p12 file: ")
  fi

  [[ -f $p12_file ]] || error "File not found: $p12_file"
}

get_p12_password() {
  p12_password=$(gum input --prompt "Enter the password for your p12 file" --password)
}

run_openssl_command() {
  if [[ -z $p12_password ]]; then
    openssl "$@"
  else
    echo "$p12_password" | openssl "$@"
  fi
}

display_p12_info() {
  log "Displaying information about the p12 file..."
  run_openssl_command pkcs12 -info -in "$p12_file" -nokeys
}

verify_p12() {
  log "Verifying general integrity of the p12 file..."
  if ! run_openssl_command pkcs12 -info -in "$p12_file" -noout; then
    error "P12 file integrity check failed."
  fi
  log "P12 file integrity check passed."

  log "Extracting and verifying certificate..."
  if ! run_openssl_command pkcs12 -in "$p12_file" -clcerts -nokeys -out "$tmp_dir/cert.pem"; then
    error "Failed to extract certificate."
  fi
  openssl x509 -in "$tmp_dir/cert.pem" -text -noout

  log "Extracting and verifying private key..."
  if ! run_openssl_command pkcs12 -in "$p12_file" -nocerts -out "$tmp_dir/key.pem"; then
    error "Failed to extract private key."
  fi
  openssl rsa -in "$tmp_dir/key.pem" -check

  log "Checking if certificate and private key match..."
  cert_md5=$(openssl x509 -noout -modulus -in "$tmp_dir/cert.pem" | openssl md5)
  key_md5=$(openssl rsa -noout -modulus -in "$tmp_dir/key.pem" | openssl md5)

  if [[ $cert_md5 == "$key_md5" ]]; then
    log "Certificate and private key match."
  else
    error "Certificate and private key do not match."
  fi

  if run_openssl_command pkcs12 -in "$p12_file" -cacerts -nokeys -out "$tmp_dir/cacerts.pem" 2>/dev/null; then
    log "CA certificates found and extracted."
    log "Verifying certificate against CA certificates..."
    if openssl verify -CAfile "$tmp_dir/cacerts.pem" "$tmp_dir/cert.pem"; then
      log "Certificate verified successfully against CA certificates."
    else
      log "Warning: Certificate verification against CA certificates failed."
    fi
  else
    log "No CA certificates found in the p12 file."
  fi

  log "P12 certificate verification complete."
}

change_p12_password() {
  new_password=$(gum input --prompt "Enter the new password for your p12 file: " --password)
  confirm_password=$(gum input --prompt "Confirm the new password: " --password)

  if [[ $new_password != "$confirm_password" ]]; then
    error "Passwords do not match."
  fi

  if run_openssl_command pkcs12 -in "$p12_file" -out "$tmp_dir/new.p12" -export -passout "pass:$new_password"; then
    mv "$tmp_dir/new.p12" "$p12_file"
    log "Password changed successfully."
  else
    error "Failed to change password."
  fi
}

main() {
  local cmd="$1"
  shift

  local p12_file=""

  case "$cmd" in
  info | verify | change-password)
    while getopts ":f:" opt; do
      case ${opt} in
      f)
        p12_file="$OPTARG"
        ;;
      \?)
        error "Invalid option: $OPTARG"
        ;;
      :)
        error "Invalid option: $OPTARG requires an argument"
        ;;
      esac
    done
    shift $((OPTIND - 1))

    # If p12_file is still empty, use the first remaining argument
    if [[ -z $p12_file && $# -gt 0 ]]; then
      p12_file="$1"
    fi

    get_p12_file "$p12_file"
    get_p12_password

    case "$cmd" in
    info) display_p12_info ;;
    verify) verify_p12 ;;
    change-password) change_p12_password ;;
    esac
    ;;
  version)
    echo "p12_tool version $VERSION"
    ;;
  help | --help | -h)
    show_help
    ;;
  *)
    show_help
    ;;
  esac
}

main "$@"
