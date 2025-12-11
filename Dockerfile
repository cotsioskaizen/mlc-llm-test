FROM ubuntu:22.04 AS builder

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    git-lfs \
    wget \
    vulkan-tools \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

ENV CONDA_DIR=/opt/conda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /miniconda.sh && \
    bash /miniconda.sh -b -p $CONDA_DIR && \
    rm /miniconda.sh

ENV PATH="$CONDA_DIR/bin:$PATH"

RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main \
    && conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

RUN conda init bash && . /opt/conda/etc/profile.d/conda.sh && conda create -n mlc-build -y -c conda-forge \
    python=3.13 \
    cmake=3.24 \
    rust \
    git \
    && conda clean --all -y

ENV CONDA_DEFAULT_ENV=mlc-build
ENV TVM_SOURCE_DIR=3rdparty/tvm
ENV PATH="$CONDA_DIR/envs/$CONDA_DEFAULT_ENV/bin:$PATH"

RUN pip install --no-cache-dir wheel setuptools

WORKDIR /workspace

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]