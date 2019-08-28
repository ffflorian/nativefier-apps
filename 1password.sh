#!/usr/bin/env bash

set -e

if ! command -v "npx" > /dev/null; then
  echo "npx not found. Please install the latest version of npm."
  exit 1
fi

TEMP_DIR="$(mktemp -d)"
INSTALL_DIR="/opt/1-password"
SCRIPT_DIR="$(realpath "$(dirname "$0")")"

_cleanup() {
  rm -rf "${TEMP_DIR}"
}

check_sudo() {
  echo "Asking for sudo rights ..."
  sudo true
}

check_installation() {
  echo "Checking existing installations ..."

  if [ -d "${INSTALL_DIR}" ]; then
    read -rp "1Password already exists in \"${INSTALL_DIR}\". Would you like to overwrite? [y/N] " RESPONSE
    case "${RESPONSE}" in
      [nN][oO]|[nN]|"" ) exit 0 ;;
    esac
  fi
}

create_app() {
  echo "Creating app ..."
  cd "${TEMP_DIR}" || exit 1
  nativefier --single-instance -i "${SCRIPT_DIR}/1password.png" -n "1Password" "my.1password.com"
  ls -lAh
}

move_app() {
  echo "Moving app to \"${INSTALL_DIR}\" ..."
  sudo rm -rf "${INSTALL_DIR}"
  sudo cp -r "${TEMP_DIR}/1-password-linux-x64" "${INSTALL_DIR}"
}

create_desktop_entry() {
  echo "Creating desktop entry ..."

  APPLICATIONS_DIR="${HOME}/.local/share/applications/"
  mkdir -p "${APPLICATIONS_DIR}"

cat > "${APPLICATIONS_DIR}/1-password.desktop" <<EOL
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Exec=${INSTALL_DIR}/1-password
Name=1Password
Icon=${INSTALL_DIR}/resources/app/icon.png
StartupWMClass=1-password
EOL
}

fix_chrome_sandbox() {
  sudo chown root "${INSTALL_DIR}/chrome-sandbox"
  sudo chmod 4755 "${INSTALL_DIR}/chrome-sandbox"
}

trap _cleanup EXIT

echo "Building 1Password for Linux ..."

check_sudo
check_installation
create_app
move_app
create_desktop_entry
fix_chrome_sandbox

echo "Done."
