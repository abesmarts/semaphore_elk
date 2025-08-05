FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update && apt-get install -y \
    python3 python3-pip \
    openssh-server \
    curl wget unzip gnupg cron \
    software-properties-common \
    ca-certificates \
    sudo \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*


RUN mkdir -p /var/run/sshd /root/Desktop /var/log /opt/python-scripts && \
    echo "root:tofuadmin" | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config



RUN pip3 install --no-cache-dir -r /opt/python-scripts/requirements.txt


RUN wget -q -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get update && \
    apt-get install -y /tmp/google-chrome.deb && \
    rm /tmp/google-chrome.deb


RUN CHROME_VERSION=$(google-chrome --version | grep -oP '\d+\.\d+\.\d+') && \
    CHROMEDRIVER_VERSION=$(curl -s "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_VERSION}") && \
    wget -q -O /tmp/chromedriver.zip https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip && \
    unzip -o /tmp/chromedriver.zip -d /root/Desktop && \
    chmod +x /root/Desktop/chromedriver && \
    rm /tmp/chromedriver.zip


CMD ["/usr/sbin/sshd", "-D"]
