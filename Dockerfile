FROM python:3.9

# setup entrypoint that we will copy later
WORKDIR /root
ENTRYPOINT ["/rarity-scripts/docker/entrypoint.sh"]

COPY docker/apt-install.sh /usr/sbin/

RUN apt-install.sh \
    libffi-dev \
    npm \
    python3-venv \
    python3-pip \
;

# setup python virtualenv
ENV PATH /venv/bin:/rarity-scripts/scripts:$PATH
RUN --mount=type=cache,target=/root/.cache { set -eux; \
    \
    python3.9 -m venv /venv; \
    pip install -U pip setuptools wheel; \
}

# ganache and hardhat for development
# TODO: install using package.json? install just one of these?
RUN --mount=type=cache,target=/root/.cache { set -eux; \
    \
    npm install -g hardhat ganache-cli; \
}

# install the python dependencies
COPY requirements.txt /rarity-scripts/
RUN --mount=type=cache,target=/root/.cache { set -eux; \
    pip install \
        --use-feature=in-tree-build \
        --disable-pip-version-check \
        -r /rarity-scripts/requirements.txt \
    ; \
}

# install our code
COPY . /rarity-scripts/
RUN --mount=type=cache,target=/root/.cache { set -eux; \
    pip install \
        --use-feature=in-tree-build \
        --disable-pip-version-check \
        -r /rarity-scripts/requirements.txt -e /rarity-scripts/ \
    ; \
    build_dir=/rarity-scripts/build; \
    persist_dir=/root/build/rarity-scripts; \
    rm -rf "$build_dir"; \
    mkdir -p "$persist_dir"; \
    ln -sfv "$persist_dir" "$build_dir"; \
}
