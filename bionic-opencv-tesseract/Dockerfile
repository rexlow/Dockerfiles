FROM rexlow/bionic-opencv:latest

RUN LEPTONICA_VERSION="1.78.0" \
      && mkdir -p /home/build_workspace/leptonica \
      && cd /home/build_workspace/leptonica \
      && curl -L "https://github.com/DanBloomberg/leptonica/releases/download/$LEPTONICA_VERSION/leptonica-$LEPTONICA_VERSION.tar.gz" | tar zx \
      && cd "/home/build_workspace/leptonica/leptonica-$LEPTONICA_VERSION" \
      && mkdir build \
      && cd build \
      && ../configure \
      && make \
      && make install \
      && make -j4

RUN TESSERACT_VERSION="4.1.0" \
      && apt-get install -y automake libtool \
      && mkdir -p /home/build_workspace/tesseract \
      && cd /home/build_workspace/tesseract \
      && curl -L "https://github.com/tesseract-ocr/tesseract/archive/$TESSERACT_VERSION.tar.gz" | tar zx \
      && cd "/home/build_workspace/tesseract/tesseract-$TESSERACT_VERSION" \
      && ./autogen.sh \
      && ./configure \
      && make \
      && make install \
      && ldconfig

RUN apt-get install -y tesseract-ocr-eng \
      && wget https://github.com/tesseract-ocr/tessdata/raw/master/eng.traineddata \
      && mv -v eng.traineddata /usr/local/share/tessdata/