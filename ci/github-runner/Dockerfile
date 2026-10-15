FROM ghcr.io/actions/actions-runner:2.338.0

USER root
RUN apt-get update \
 && apt-get install -y --no-install-recommends git python3 python3-venv jq curl ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && python3 -m venv /opt/precommit \
 && /opt/precommit/bin/pip install --no-cache-dir pre-commit \
 && ln -s /opt/precommit/bin/pre-commit /usr/local/bin/pre-commit

COPY --chown=runner:runner --chmod=755 entrypoint.sh /home/runner/entrypoint.sh

USER runner
WORKDIR /home/runner
ENTRYPOINT ["/home/runner/entrypoint.sh"]
