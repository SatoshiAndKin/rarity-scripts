FROM python:3.9

COPY docker/apt-install.sh /usr/sbin/

RUN apt-install.sh \
    libffi-dev \
    npm \
    python3-venv \
    python3-pip \
;

# setup python virtualenv
ENV PATH /venv/bin:$PATH
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

# intstall the python dependencies
COPY requirements.txt /rarity-brownie/
RUN --mount=type=cache,target=/root/.cache { set -eux; \
    pip install \
        --use-feature=in-tree-build \
        --disable-pip-version-check \
        -r /rarity-brownie/requirements.txt \
    ; \
}

# install our code
COPY . /rarity-brownie/
RUN --mount=type=cache,target=/root/.cache { set -eux; \
    pip install \
        --use-feature=in-tree-build \
        --disable-pip-version-check \
        -r /rarity-brownie/requirements.txt -e /rarity-brownie/ \
    ; \
}

WORKDIR /rarity-brownie/
ENTRYPOINT ["./docker/entrypoint.sh"]
