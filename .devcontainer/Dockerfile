# platform selection to avoid rosetta bug on macos
FROM --platform=linux/amd64 mcr.microsoft.com/vscode/devcontainers/base:ubuntu-22.04

ARG BAZELISK_VERSION=v1.25.0
RUN curl -Lo /usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/download/${BAZELISK_VERSION}/bazelisk-linux-amd64 \
    && chmod +x /usr/local/bin/bazel
