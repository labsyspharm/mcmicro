FROM ghcr.io/labsyspharm/mcmicro:roadie-latest

RUN apt-get update && \
    apt-get install -y openslide-tools && \
    rm -rf /var/lib/apt/lists/*

RUN python -m pip install --no-cache-dir \
    altair \
    imagecodecs \
    matplotlib \
    openslide-python \
    waitress \
    flask \
    flask_cors \
    scikit-image

RUN git clone https://github.com/labsyspharm/minerva-author.git /app/minerva-author

ADD modules/ext/story.py /app
