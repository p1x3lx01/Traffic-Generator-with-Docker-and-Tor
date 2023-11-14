FROM ubuntu:20.04
LABEL maintainer="tolgatasci1@gmail.com"
LABEL version="1"
LABEL description="It sends traffic using the tor network."

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Kiev

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apt-get update \
    && apt-get install -y gnupg2 ca-certificates wget xvfb unzip curl \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update -y \
    && apt-get install -y google-chrome-stable \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends tor tor-geoipdb torsocks \
    && apt-get clean \
    && apt-get install -y python3-pip chromium-browser psmisc netcat \
    && mkdir -p /scripts

WORKDIR /scripts
COPY ./requirements.txt ./entrypoint.sh ./hit.py ./refreship.py ./

RUN pip install --no-cache-dir -r requirements.txt \
    && chmod +x entrypoint.sh

COPY torrc /etc/tor/torrc

ENV CHROMEDRIVER_VERSION 102.0.5005.61
ENV CHROMEDRIVER_DIR /chromedriver
RUN mkdir $CHROMEDRIVER_DIR

RUN CHROMEVER=$(google-chrome --product-version | grep -o "[^\.]*\.[^\.]*\.[^\.]*") && \
    DRIVERVER=$(curl -s "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROMEVER") && \
    wget -q --continue -P /chromedriver "http://chromedriver.storage.googleapis.com/$DRIVERVER/chromedriver_linux64.zip" && \
    unzip /chromedriver/chromedriver* -d /chromedriver

ENV PATH $CHROMEDRIVER_DIR:$PATH

ENTRYPOINT ["sh","/scripts/entrypoint.sh"]
CMD ["bash"]
