# platform selection to avoid rosetta bug on macos
FROM --platform=linux/amd64 mcr.microsoft.com/vscode/devcontainers/base:ubuntu-22.04

ARG BAZELISK_VERSION=1.25.0
RUN curl -Lo /usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/download/v${BAZELISK_VERSION}/bazelisk-linux-amd64 \
    && chmod +x /usr/local/bin/bazel

# Install bazel-compile-commands
# ARG BAZEL_COMPILE_COMMANDS_VERSION=0.17.1
# RUN curl -Lo /tmp/bazel-compile-commands_${BAZEL_COMPILE_COMMANDS_VERSION}-jammy_amd64.deb https://github.com/kiron1/bazel-compile-commands/releases/download/v${BAZEL_COMPILE_COMMANDS_VERSION}/bazel-compile-commands_${BAZEL_COMPILE_COMMANDS_VERSION}-jammy_amd64.deb \
#     && apt-get update \
#     && apt-get install -y /tmp/bazel-compile-commands_${BAZEL_COMPILE_COMMANDS_VERSION}-jammy_amd64.deb \
#     && rm /tmp/bazel-compile-commands_${BAZEL_COMPILE_COMMANDS_VERSION}-jammy_amd64.deb
