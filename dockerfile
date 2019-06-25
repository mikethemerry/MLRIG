
# Based on https://github.com/floydhub/dl-docker/blob/master/Dockerfile.cpu
# by Sai Soundararaj <saip@outlook.com> and
# https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/dockerfiles/dockerfiles/devel-gpu-jupyter.Dockerfile
# by Tensorflow team


ARG UBUNTU_VERSION=18.04

ARG ARCH=
ARG CUDA=10.0
FROM nvidia/cuda${ARCH:+-$ARCH}:${CUDA}-base-ubuntu${UBUNTU_VERSION} as base
# ARCH and CUDA are specified again because the FROM directive resets ARGs
# (but their default value is retained if set previously)
ARG ARCH
ARG CUDA
ARG CUDNN=7.4.1.5-1
ARG CUDNN_MAJOR_VERSION=7
ARG LIB_DIR_PREFIX=x86_64

ARG PYTHON_VERSION=3.6

MAINTAINER Mike Merry <dev@mikemerry.nz>



# Fixes for TZData configuration stall
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Pacific/Auckland

# Needed for string substitution 
SHELL ["/bin/bash", "-c"]
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cuda-command-line-tools-${CUDA/./-} \
        cuda-cublas-dev-${CUDA/./-} \
        cuda-cudart-dev-${CUDA/./-} \
        cuda-cufft-dev-${CUDA/./-} \
        cuda-curand-dev-${CUDA/./-} \
        cuda-cusolver-dev-${CUDA/./-} \
        cuda-cusparse-dev-${CUDA/./-} \
        libcudnn7=${CUDNN}+cuda${CUDA} \
        libcudnn7-dev=${CUDNN}+cuda${CUDA} \
        libcurl3-dev \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libzmq3-dev \
        pkg-config \
        rsync \
        software-properties-common \
        unzip \
        zip \
        zlib1g-dev \
        wget \
        git \
        && \
    find /usr/local/cuda-${CUDA}/lib64/ -type f -name 'lib*_static.a' -not -name 'libcudart_static.a' -delete && \
    rm /usr/lib/${LIB_DIR_PREFIX}-linux-gnu/libcudnn_static_v7.a

RUN [[ "${ARCH}" = "ppc64le" ]] || { apt-get update && \
        apt-get install nvinfer-runtime-trt-repo-ubuntu1804-5.0.2-ga-cuda${CUDA} \
        && apt-get update \
        && apt-get install -y --no-install-recommends \
            libnvinfer5=5.0.2-1+cuda${CUDA} \
            libnvinfer-dev=5.0.2-1+cuda${CUDA} \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*; }


## CONDA

RUN apt-get update && apt-get install -y --no-install-recommends \
         build-essential \
         cmake \
         git \
         curl \
         ca-certificates \
         libjpeg-dev \
         libpng-dev && \
     rm -rf /var/lib/apt/lists/*

RUN curl -o ~/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
     chmod +x ~/miniconda.sh && \
     ~/miniconda.sh -b -p /opt/conda && \
     rm ~/miniconda.sh && \
     /opt/conda/bin/conda install -y python=$PYTHON_VERSION numpy pyyaml scipy ipython mkl mkl-include ninja cython typing && \
     /opt/conda/bin/conda install -y -c pytorch magma-cuda100 && \
     /opt/conda/bin/conda clean -ya
ENV PATH /opt/conda/bin:$PATH

#######################################################
## The following is to install CUDA but this isn't currently working

# # This must be done before pip so that requirements.txt is available
# WORKDIR /opt/pytorch
# COPY . .

# RUN git submodule update --init --recursive
# RUN TORCH_CUDA_ARCH_LIST="3.5 5.2 6.0 6.1 7.0+PTX" TORCH_NVCC_FLAGS="-Xfatbin -compress-all" \
#     CMAKE_PREFIX_PATH="$(dirname $(which conda))/../" \
#     pip install -v .

# RUN git clone https://github.com/pytorch/vision.git && cd vision && pip install -v .
#######################################################

#######################################################
# Uncomment to install opencv
# RUN conda install -y -c menpo opencv
#######################################################
RUN conda install -y jupyter \
	pandas \
	numpy \
	scipy \
	vispy \ 
	ipython \
	python-graphviz



RUN mkdir /src && mkdir /app
RUN cd /src && \
    git clone https://github.com/mikethemerry/MLRIG && \
    cd MLRIG && \
    conda install -y --file requirements.txt
WORKDIR /src


EXPOSE 8787

WORKDIR "/app"
CMD ["/bin/bash"]