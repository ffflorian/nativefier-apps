#!/usr/bin/env bash

set -e

if ! command -v "npx" > /dev/null; then
  echo "npx not found. Please install the latest version of npm."
  exit 1
fi

TEMP_DIR="$(mktemp -d)"
INSTALL_DIR="/opt/threema"
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
    read -rp "Threema already exists in \"${INSTALL_DIR}\". Would you like to overwrite? [y/N] " RESPONSE
    case "${RESPONSE}" in
      [nN][oO]|[nN]|"" ) exit 0 ;;
    esac
  fi
}

create_app() {
  echo "Creating app ..."
  cd "${TEMP_DIR}" || exit 1
  nativefier --single-instance -i "${SCRIPT_DIR}/threema.png" -n "Threema" "web.threema.ch"
  ls -lAh
}

move_app() {
  echo "Moving app to \"${INSTALL_DIR}\" ..."
  sudo rm -rf "${INSTALL_DIR}"
  sudo cp -r "${TEMP_DIR}/threema-linux-x64" "${INSTALL_DIR}"
}

create_desktop_entry() {
  echo "Creating desktop entry ..."

  APPLICATIONS_DIR="${HOME}/.local/share/applications/"
  mkdir -p "${APPLICATIONS_DIR}"

cat > "${APPLICATIONS_DIR}/threema.desktop" <<EOL
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Exec=${INSTALL_DIR}/threema
Name=Threema
Icon=${INSTALL_DIR}/resources/app/icon.png
StartupWMClass=threema
EOL
}

fix_chrome_sandbox() {
  sudo chown root "${INSTALL_DIR}/chrome-sandbox"
  sudo chmod 4755 "${INSTALL_DIR}/chrome-sandbox"
}

trap _cleanup EXIT

echo "Building Threema for Linux ..."

check_sudo
check_installation
create_app
move_app
create_desktop_entry
fix_chrome_sandbox

echo "Done."
