FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ----------------------------------------------------
# Base system setup
# ----------------------------------------------------
RUN apt-get update && apt-get install -y \
    python3 python3-venv python3-pip \
    wget curl unzip gnupg2 ca-certificates apt-transport-https \
    openssh-server sudo lsb-release \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------
# Setup SSH access
# ----------------------------------------------------
RUN mkdir /var/run/sshd \
 && echo "root:tofuadmin" | chpasswd \
 && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
 && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# ----------------------------------------------------
# Install Google Chrome (latest stable)
# ----------------------------------------------------
RUN apt-get update && apt-get install -y wget gnupg2 ca-certificates apt-transport-https \
 && wget -q https://dl.google.com/linux/linux_signing_key.pub -O- | gpg --dearmor > /usr/share/keyrings/google-linux-keyring.gpg \
 && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
    > /etc/apt/sources.list.d/google-chrome.list \
 && apt-get update && apt-get install -y google-chrome-stable \
 && rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------
# Install matching ChromeDriver
# ----------------------------------------------------
RUN CHROME_VERSION=$(google-chrome --version | grep -oP '\d+\.\d+\.\d+') \
 && DRIVER_VERSION=$(wget -qO- "https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json" \
     | grep -B1 "$CHROME_VERSION" | grep "version" | head -1 | grep -oP '\d+\.\d+\.\d+\.\d+') \
 && wget -q "https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/$DRIVER_VERSION/linux64/chromedriver-linux64.zip" \
 && unzip chromedriver-linux64.zip \
 && mv chromedriver-linux64/chromedriver /usr/local/bin/chromedriver \
 && chmod +x /usr/local/bin/chromedriver \
 && rm -rf chromedriver-linux64.zip chromedriver-linux64

# ----------------------------------------------------
# Install Filebeat (Elastic 8.x)
# ----------------------------------------------------
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor > /usr/share/keyrings/elastic.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" \
    > /etc/apt/sources.list.d/elastic-8.x.list \
 && apt-get update && apt-get install -y filebeat \
 && rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------
# Add ChromeDriver to Desktop for visibility
# ----------------------------------------------------
RUN mkdir -p /root/Desktop && ln -s /usr/local/bin/chromedriver /root/Desktop/chromedriver

# ----------------------------------------------------
# Expose SSH port
# ----------------------------------------------------
EXPOSE 22

# ----------------------------------------------------
# Default command (keep container running with SSH)
# ----------------------------------------------------
CMD ["/usr/sbin/sshd", "-D"]
