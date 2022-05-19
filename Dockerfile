
ARG SWIFT_VERSION=5.5
ARG BASE_OS=focal
# ================================
# Build image
# ================================

FROM docker.apple.com/apple-swift/swift:${SWIFT_VERSION}-${BASE_OS} as build

# Install OS updates and, if needed, sqlite3
FROM docker.apple.com/apple-swift/swift:${SWIFT_VERSION}-${BASE_OS} as build
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && rm -rf /var/lib/apt/lists/*

RUN apt update -y && apt install build-essential -y

    

# Set up a build area
WORKDIR /build

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./


# Now build the application
RUN swift package resolve

# Copy entire repo into container
COPY . .

# Build everything, with optimizations
RUN swift build -c release
# Switch to the staging area
WORKDIR /staging

