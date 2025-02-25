#!/bin/bash


# VARIABLES

JDK_VERSION="18.0.2.1+1"
ANDROID_CMD_VERSION="11076708"
ANDROID_PLATFORM_VERSION="35"

JDK_PATH_ROOT="$HOME/.local/share/jdk"

ANDROID_SDK_PATH="$HOME/.local/share/android-sdk"
ANDROID_CMD_PATH="$ANDROID_SDK_PATH/cmdline-tools"

JDK_DOWNLOAD_URL="https://github.com/adoptium/temurin18-binaries/releases/download/jdk-${JDK_VERSION}/OpenJDK18U-jdk_x64_linux_hotspot_${JDK_VERSION//+/_}.tar.gz"
ANDROID_CMD_DOWNLOAD_URL="https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMD_VERSION}_latest.zip"

JDK_DOWNLOAD_FILE="/tmp/jdk-${JDK_VERSION}.tar.gz"
ANDROID_CMD_DOWNLOAD_FILE="/tmp/android-cmd-${ANDROID_CMD_VERSION}.zip"


# FUNCTIONS

function join_by {
  local d=${1-} f=${2-}
  if shift 2; then
    printf %s "$f" "${@/#/$d}"
  fi
}

function wrap_with_comments {
  printf %s "# $1 begin\n\n$2\n\n# $1 end"
}


# BASHRC

BASHRC_JDK_ROWS=(
  "VERSION=\"$JDK_VERSION\""
  "JDK_PATH=\"$JDK_PATH_ROOT/jdk-\$VERSION\""
  ""
  "export PATH=\"\$PATH:\$JDK_PATH/bin\""
  "export JAVA_HOME=\"\$JDK_PATH\""
)
BASHRC_JDK=$(join_by "\n" "${BASHRC_JDK_ROWS[@]}")
BASHRC_JDK_WRAPPED=$(wrap_with_comments "JDK" "$BASHRC_JDK")

BASHRC_ANDROID_ROWS=(
  "ANDROID_SDK_PATH=\"$ANDROID_SDK_PATH\""
  ""
  "export PATH=\"\$PATH:\$ANDROID_SDK_PATH/cmdline-tools/latest/bin\""
  "export PATH=\"\$PATH:\$ANDROID_SDK_PATH/platform-tools\""
  "export PATH=\"\$PATH:\$ANDROID_SDK_PATH/emulator\""
  "export ANDROID_HOME=\"\$ANDROID_SDK_PATH\""
)
BASHRC_ANDROID=$(join_by "\n" "${BASHRC_ANDROID_ROWS[@]}")
BASHRC_ANDROID_WRAPPED=$(wrap_with_comments "ANDROID" "$BASHRC_ANDROID")

BASHRC_CONTENT_PARTS=("" "$BASHRC_JDK_WRAPPED" "$BASHRC_ANDROID_WRAPPED")
BASHRC_CONTENT=$(join_by "\n\n\n" "${BASHRC_CONTENT_PARTS[@]}")

echo -e "$BASHRC_CONTENT" >> "$HOME/.bashrc"
source "$HOME/.bashrc"


# DOWNLOADS

wget -O $JDK_DOWNLOAD_FILE $JDK_DOWNLOAD_URL
wget -O $ANDROID_CMD_DOWNLOAD_FILE $ANDROID_CMD_DOWNLOAD_URL


# INSTALL

mkdir -p $JDK_PATH_ROOT
tar -xzf $JDK_DOWNLOAD_FILE -C $JDK_PATH_ROOT
rm $JDK_DOWNLOAD_FILE

mkdir -p $ANDROID_CMD_PATH
unzip -q $ANDROID_CMD_DOWNLOAD_FILE -d $ANDROID_CMD_PATH
mv $ANDROID_CMD_PATH/cmdline-tools $ANDROID_CMD_PATH/latest
rm $ANDROID_CMD_DOWNLOAD_FILE


# SDK

yes | sdkmanager \
  "platform-tools" \
  "emulator" \
  "platforms;android-$ANDROID_PLATFORM_VERSION" \
  "build-tools;$ANDROID_PLATFORM_VERSION.0.0" \
  "system-images;android-$ANDROID_PLATFORM_VERSION;google_apis_playstore;x86_64"

yes | sdkmanager --licenses


# END

echo -e "\n\n\n"
echo "Installation completed!"
