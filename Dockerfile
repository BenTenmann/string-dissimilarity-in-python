FROM python:3.7-bullseye

COPY requirements/ .
RUN apt update && \
    apt install $(cat debian.txt) -y

ARG VERSION=v4.9.6
ARG BINARY=yq_linux_386
RUN wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY} -O /usr/bin/yq && \
    chmod +x /usr/bin/yq

RUN pip install -r python.txt

ENV CRAN=https://cloud.r-project.org
RUN cat r-base.txt | R -e 'install.packages(readLines(file("stdin")))'

COPY . exp
WORKDIR /exp

ARG APP_HOME=/exp
ENV APP_HOME=$APP_HOME
ENTRYPOINT ["./scripts/run_metrics.sh"]
