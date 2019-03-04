FROM rexlow/bionic-opencv:cv2-3.4.3

RUN LEPTONICA_VERSION="1.76.0" \
      && mkdir -p /home/build_workspace/leptonica \
      && cd /home/build_workspace/leptonica \
      && curl -L "https://github.com/DanBloomberg/leptonica/releases/download/$LEPTONICA_VERSION/leptonica-$LEPTONICA_VERSION.tar.gz" | tar zx \
      && cd "/home/build_workspace/leptonica/leptonica-$LEPTONICA_VERSION" \
      && mkdir build \
      && cd build \
      && ../configure \
      && make \
      && make install \
      && make -j4 check

RUN TESSERACT_VERSION="4.0.0" \
      && mkdir -p /home/build_workspace/tesseract \
      && cd /home/build_workspace/tesseract \
      && curl -L "https://github.com/tesseract-ocr/tesseract/archive/$TESSERACT_VERSION.tar.gz" | tar zx \
      && cd "/home/build_workspace/tesseract/tesseract-$TESSERACT_VERSION" \
      && ./autogen.sh \
      && ./configure \
      && make \
      && make install \
      && ldconfig