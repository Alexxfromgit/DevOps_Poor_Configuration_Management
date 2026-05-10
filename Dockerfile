FROM ubuntu:16.04

RUN apt-get update && apt-get install -y \
    git \
    cron \
    ntp \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root/task4_2
COPY ntp_deploy.sh ntp_verify.sh ./
RUN chmod +x ntp_deploy.sh ntp_verify.sh

CMD ["/bin/bash"]
