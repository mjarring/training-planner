FROM ghcr.io/actions/actions-runner:2.338.0

USER root
# Install packages
RUN apt-get update \
 && apt-get install -y --no-install-recommends git jq curl ca-certificates xz-utils \
 && rm -rf /var/lib/apt/lists/*

# Create nix directory
RUN mkdir /nix \
 && chown runner:runner /nix

COPY --chown=runner:runner --chmod=755 entrypoint.sh /home/runner/entrypoint.sh

USER runner

# Install nix
RUN curl -fsSL -o /tmp/nix-install.sh https://nixos.org/nix/install \
 && sh /tmp/nix-install.sh --no-daemon \
 && rm /tmp/nix-install.sh

# Write nix.conf
RUN mkdir -p /home/runner/.config/nix \
 && printf 'experimental-features = nix-command flakes\nsandbox = false\n' > /home/runner/.config/nix/nix.conf

# Put nix on PATH
ENV PATH="/home/runner/.nix-profile/bin:${PATH}"

WORKDIR /home/runner
ENTRYPOINT ["/home/runner/entrypoint.sh"]
