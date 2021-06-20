FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y locales && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.UTF-8

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        libbz2-dev \
        libffi-dev \
        libncurses5-dev \
        libncursesw5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl1.0-dev \
        liblzma-dev \
        llvm \
        make \
        netbase \
        pkg-config \
        tk-dev \
        wget \
        xz-utils \
        zlib1g-dev \
   && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV HOME /root
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/bin:$PATH
RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv && \
    git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv && \
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc && \
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc

RUN for version in 3.6.5 3.7.10 3.8.10 3.9.5; do pyenv install $version; done \
    && find $PYENV_ROOT/versions -type d '(' -name '__pycache__' -o -name 'test' -o -name 'tests' ')' -exec rm -rf '{}' + \
    && find $PYENV_ROOT/versions -type f '(' -name '*.pyo' -o -name '*.exe' ')' -exec rm -f '{}' + \
 && rm -rf /tmp/*

ENV PATH $PYENV_ROOT/shims:$PATH
RUN pyenv global 3.9.5 && \
    python -m pip install -U pip && \
    python -m pip install tox && \
    pyenv rehash

WORKDIR /app
VOLUME /src

RUN pyenv virtualenv -p python3.6 3.6.5 py36 && \
    pyenv virtualenv -p python3.7 3.7.10 py37 && \
    pyenv virtualenv -p python3.8 3.8.10 py38 && \
    pyenv virtualenv -p python3.9 3.9.5 py39

RUN eval "$(pyenv init --path)" && eval "$(pyenv init -)" && pyenv shell py36 py37 py38 py39

CMD ["tox"]
