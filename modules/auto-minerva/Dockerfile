FROM labsyspharm/roadie:2022-05-24

RUN apt-get update && \
    apt-get install -y openslide-tools

RUN python -m pip install \
    altair \
    imagecodecs \
    matplotlib \
    openslide-python \
    waitress \
    flask \
    flask_cors \
    scikit-image

RUN git clone https://github.com/jmuhlich/auto-minerva.git /app/auto-minerva
RUN git clone https://github.com/labsyspharm/minerva-author.git /app/minerva-author
