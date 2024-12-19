FROM python:3.11-slim-bookworm

LABEL org.opencontainers.image.source = "https://github.com/muselab-d2x/d2x"
ENV CHROMEDRIVER_VERSION 2.19
ENV CHROMEDRIVER_DIR /chromedriver


# Install sfdx
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y gnupg wget curl git
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash && \
    export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && \
    nvm install 20.17.0 && \
    nvm use 20.17.0 && \
    nvm alias default 20.17.0
RUN npm install --global npm jq commander
RUN npm install --global @salesforce/cli
RUN npm install --global prettier prettier-plugin-apex

RUN apt-get install gcc python3-dev -y

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg;
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null;
RUN apt-get install -y gh
# Install Salesforce CLI plugins:
RUN sfdx plugins:install @salesforce/sfdx-scanner

# Download a specific Chrome for Testing version.
RUN npx @puppeteer/browsers install chrome@116

# Download a specific ChromeDriver version.
RUN npx @puppeteer/browsers install chromedriver@116.0.5793.0

# Install CumulusCI
RUN pip install --no-cache-dir --upgrade pip pip-tools && \
  pip install --no-cache-dir cumulusci cookiecutter

# Copy devhub auth script and make it executable
COPY devhub.sh /usr/local/bin/devhub.sh
COPY ./scripts/log_package.py /usr/local/bin/log_package.py
COPY ./scripts/extract_failed.py /usr/local/bin/extract_failed.py
RUN chmod +x /usr/local/bin/devhub.sh

# Create d2x user
RUN useradd -r -m -s /bin/bash -c "D2X User" d2x

# Setup PATH
RUN echo 'export PATH=~/.local/bin:$PATH' >> /root/.bashrc
RUN echo 'export PATH=~/.local/bin:$PATH' >> /home/d2x/.bashrc
RUN echo '/usr/local/bin/devhub.sh' >> /root/.bashrc
RUN echo '/usr/local/bin/devhub.sh' >> /home/d2x/.bashrc

USER d2x
CMD ["bash"]

