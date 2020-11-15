FROM nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04
ENV DEBIAN_FRONTEND=noninteractive

ENV LANG C.UTF-8
ENV PYTHON_VERSION="3.8.5"
ENV OPENCV_VERSION="4.5.0"
ENV NUMPY_VERSION="1.17.4"
ENV PYTHON_PIP_VERSION="19.3.1"

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    git \
    curl \
    wget \
    unzip \
    nasm \
    yasm \
    openssl \
    libssl-dev \
    pkg-config \
    libswscale-dev \
    libtbb2 \
    libtbb-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libgtk2.0-dev \
    libavformat-dev \
    libpq-dev \
    libffi-dev \
    lsb-release \
    libreadline-dev \
    libsqlite3-dev \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*
    
RUN set -ex \
	&& buildDeps=' \
		dpkg-dev \
		tcl-dev \
		tk-dev \
	' \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends \
	\
	&& wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
	&& wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& rm -rf "$GNUPGHOME" python.tar.xz.asc \
	&& mkdir -p /usr/src/python \
	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
	&& rm python.tar.xz \
	\
	&& cd /usr/src/python \
	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
	&& ./configure \
		--build="$gnuArch" \
		--enable-loadable-sqlite-extensions \
		--enable-shared \
		--with-system-expat \
		--with-system-ffi \
		--without-ensurepip \
	&& make -j "$(nproc)" \
	&& make install \
	&& ldconfig

# make some useful symlinks that are expected to exist
RUN cd /usr/local/bin \
	&& ln -s idle3 idle \
	&& ln -s pydoc3 pydoc \
	&& ln -s python3 python \
	&& ln -s python3-config python-config

RUN set -ex; \
	\
	wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py'; \
	\
	python get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		"pip==$PYTHON_PIP_VERSION" \
	; \
	pip --version; \
	\
	find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' +; \
	rm -f get-pip.py

RUN pip3 install numpy==${NUMPY_VERSION}

RUN cd / \
    && wget -O opencv.zip https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip \
    && wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip \
    && unzip opencv.zip \
    && unzip opencv_contrib.zip \
    && mkdir /opencv-${OPENCV_VERSION}/cmake_binary \
    && cd /opencv-${OPENCV_VERSION}/cmake_binary \
    && cat /usr/include/cudnn.h | grep CUDNN_MAJOR -A 2 \
    && cmake -DOPENCV_EXTRA_MODULES_PATH=/opencv_contrib-${OPENCV_VERSION}/modules \
             -DBUILD_TIFF=ON \
             -DBUILD_opencv_java=OFF \
             -DWITH_CUDA=ON \
             -DWITH_CUDNN=ON \
             -DOPENCV_DNN_CUDA=ON \
             -DENABLE_FAST_MATH=1 \
             -DCUDA_FAST_MATH=1 \
             -DCUDA_ARCH_BIN=7.5 \
             -DWITH_CUBLAS=1 \
             -DWITH_OPENGL=OFF \
             -DWITH_OPENCL=OFF \
             -DWITH_IPP=ON \
             -DWITH_TBB=ON \
             -DWITH_EIGEN=ON \
             -DWITH_V4L=ON \
             -DBUILD_TESTS=OFF \
             -DBUILD_PERF_TESTS=OFF \
             -DCMAKE_BUILD_TYPE=RELEASE \
             -DCMAKE_INSTALL_PREFIX=$(python3 -c "import sys; print(sys.prefix)") \
             -DPYTHON_EXECUTABLE=$(which python3) \
             -DPYTHON_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
             -DPYTHON_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
             .. \
    && make install \
    && rm /opencv.zip /opencv_contrib.zip \
    && rm -r /opencv-${OPENCV_VERSION} \
    && rm -r /opencv_contrib-${OPENCV_VERSION}
