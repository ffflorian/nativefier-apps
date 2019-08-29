#!/usr/bin/env bash

set -e

SCRIPT_NAME="${0##*/}"
TEMP_DIR="$(mktemp -d)"

INSTALL_DIR=""
EXECUTABLE_NAME=""

APP_NAME=""
APP_LOGO=""
APP_SHORT_NAME=""
APP_URL=""
FORCE="no"

_print_usage() {
cat <<EOF
Usage: ${SCRIPT_NAME} [options] <switches>

Switches:
 --logo        (-l)     App logo (png file, e.g. "./my-app.png")
 --name        (-n)     App name (e.g. "MyApp")
 --short-name  (-s)     Short app name (e.g. "my-app")
 --url         (-u)     App URL without protocol (e.g. "web.my-app.com")

Options:
 --force       (-f)     Force overwriting existing installations (default is false)
 --install-dir (-i)     App installation dir (default is "/opt/<my-app>")

Commands:
 --help        (-h)     Display this help message
EOF
}

_cleanup() {
  rm -rf "${TEMP_DIR}"
}

check_capabilities() {
  if ! command -v "npx" > /dev/null; then
    echo "npx not found. Please install the npm >= 5.2.0."
    exit 1
  fi
}

check_installation() {
  echo "Checking existing ${APP_NAME} installations ..."

  if [ -d "${INSTALL_DIR}" ] && [ "${FORCE}" == "no" ]; then
    read -rp "${APP_NAME} already exists in \"${INSTALL_DIR}\". Would you like to overwrite? [y/N] " RESPONSE
    case "${RESPONSE}" in
      [yY][eE][sS]|[yY] ) FORCE="yes" ;;
                      * ) exit 0 ;;
    esac
  fi
}

copy_app() {
  echo "Copying app to \"${INSTALL_DIR}\" ..."

  #mkdir -p "${INSTALL_DIR}"
  rm -rf "${INSTALL_DIR}" > /dev/null 2>&1 || sudo rm -rf "${INSTALL_DIR}"
  cp -r "${TEMP_DIR}/${EXECUTABLE_NAME}-linux-x64" "${INSTALL_DIR}" > /dev/null 2>&1 || sudo cp -r "${TEMP_DIR}/${EXECUTABLE_NAME}-linux-x64" "${INSTALL_DIR}"
}

create_desktop_entry() {
  echo "Creating desktop entry ..."

  APPLICATIONS_DIR="${HOME}/.local/share/applications/"
  mkdir -p "${APPLICATIONS_DIR}"

cat > "${APPLICATIONS_DIR}/${APP_SHORT_NAME}.desktop" <<EOL
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Exec=${INSTALL_DIR}/${EXECUTABLE_NAME}
Name=${APP_NAME}
Icon=${INSTALL_DIR}/resources/app/icon.png
StartupWMClass=${EXECUTABLE_NAME}
EOL
}

fix_chrome_sandbox() {
  chown root "${INSTALL_DIR}/chrome-sandbox" > /dev/null 2>&1 || sudo chown root "${INSTALL_DIR}/chrome-sandbox"
  chmod 4755 "${INSTALL_DIR}/chrome-sandbox" > /dev/null 2>&1 || sudo chmod 4755 "${INSTALL_DIR}/chrome-sandbox"
}

create_app() {
  echo "Building ${APP_NAME} for Linux ..."

  check_capabilities
  check_installation

  echo "Creating app ..."

  cp "${APP_LOGO}" "${TEMP_DIR}/icon.png"

  cd "${TEMP_DIR}" || exit 1
  npx nativefier --single-instance -i "icon.png" -n "${APP_NAME}" "${APP_URL}"

  EXECUTABLE_PATH="$(find . -maxdepth 2 -type f -executable -print | grep -vP '\.so|sandbox')"
  EXECUTABLE_NAME="$(basename "${EXECUTABLE_PATH}")"

  copy_app
  create_desktop_entry
  fix_chrome_sandbox

  echo "Done."
}

trap _cleanup EXIT

while :
do
    case "${1}" in
        -n|--name )
            APP_NAME="${2}"
            shift 2
            ;;
        -s|--short-name )
            APP_SHORT_NAME="${2}"
            INSTALL_DIR="$(readlink -f "${INSTALL_DIR:-/opt/${APP_SHORT_NAME}}")"
            shift 2
            ;;
        -l|--logo )
            APP_LOGO="${2}"
            shift 2
            ;;
        -i|--install-dir )
            INSTALL_DIR="$(readlink -f "${2}")"
            shift 2
            ;;
        -u|--url )
            APP_URL="${2}"
            shift 2
            ;;
        -f|--force )
            FORCE="yes"
            shift
            ;;
        -h|--help )
            _print_usage
            exit 0
            ;;
        * )
            break
            ;;
    esac
done

if [ -z "${APP_NAME}" ]; then
   echo "No app name set."
    _print_usage
    exit 1
fi

if [ -z "${APP_SHORT_NAME}" ]; then
   echo "No app short name set."
    _print_usage
    exit 1
fi

if [ -z "${APP_LOGO}" ]; then
   echo "No app logo set."
    _print_usage
    exit 1
fi

if [ -z "${APP_URL}" ]; then
   echo "No app URL set."
    _print_usage
    exit 1
fi

create_app
