FROM ubuntu:latest

# Prevent interactive prompts during package installs
ENV DEBIAN_FRONTEND=noninteractive

# Update and install core packages including SSH and Python
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-server \
        curl \
        wget \
        unzip \
        sudo \
        gnupg \
        software-properties-common \
        python3 \
        python3-pip \
        python3-venv \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Create SSH directories and set root password
RUN mkdir /var/run/sshd && \
    echo "root:tofuadmin" | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Create Desktop folder for root user
RUN mkdir -p /root/Desktop

# Create app/log folders
RUN mkdir -p /opt/python-scripts /etc/filebeat

# Copy Filebeat binary (installed by Semaphore block)
COPY ../filebeat/filebeat.yml /etc/filebeat/filebeat.yml

# Install Google Chrome
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb && \
    apt-get update && \
    apt-get install -y /tmp/chrome.deb && \
    rm /tmp/chrome.deb

# Install matching ChromeDriver and move it to Desktop
RUN CHROME_VERSION=$(google-chrome --version | grep -oP '\d+\.\d+\.\d+') && \
    CHROMEDRIVER_VERSION=$(curl -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROME_VERSION) && \
    wget -q https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip -O /tmp/chromedriver.zip && \
    unzip /tmp/chromedriver.zip -d /root/Desktop && \
    chmod +x /root/Desktop/chromedriver && \
    rm /tmp/chromedriver.zip




# Expose SSH port
EXPOSE 22

# Start SSH service and keep container running
CMD ["/usr/sbin/sshd", "-D"]
