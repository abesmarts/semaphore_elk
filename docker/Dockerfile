FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Update and install base packages
RUN apt-get update && apt-get install -y \
    python3 python3-venv python3-pip \
    wget curl unzip gnupg \
    openssh-server \
    sudo \
    apt-transport-https \
    ca-certificates \
    lsb-release \
    gnupg-agent \
    && rm -rf /var/lib/apt/lists/*

# Setup SSH
RUN mkdir /var/run/sshd
RUN echo "root:tofuadmin" | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Install Chrome (latest stable)
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /usr/share/keyrings/google.gpg \
 && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list \
 && apt-get update && apt-get install -y google-chrome-stable

# Install matching ChromeDriver
RUN CHROME_VERSION=$(google-chrome --version | grep -oP '\d+\.\d+\.\d+') \
 && DRIVER_VERSION=$(wget -qO- "https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json" \
     | grep -B1 "$CHROME_VERSION" | grep "version" | head -1 | grep -oP '\d+\.\d+\.\d+\.\d+') \
 && wget -q "https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/$DRIVER_VERSION/linux64/chromedriver-linux64.zip" \
 && unzip chromedriver-linux64.zip \
 && mv chromedriver-linux64/chromedriver /usr/local/bin/chromedriver \
 && chmod +x /usr/local/bin/chromedriver \
 && rm -rf chromedriver-linux64.zip chromedriver-linux64

# Install Filebeat (Elastic 8.x)
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor > /usr/share/keyrings/elastic.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" > /etc/apt/sources.list.d/elastic-8.x.list \
 && apt-get update && apt-get install -y filebeat

# Optional: Add ChromeDriver to Desktop for visibility
RUN mkdir -p /root/Desktop && ln -s /usr/local/bin/chromedriver /root/Desktop/chromedriver

# Expose SSH
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
