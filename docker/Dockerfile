FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && apt-get install -y \
    zsh \
    sudo \
    python3 \
    git \
    curl \
    wget \
    nano \
    build-essential \
    procps \
    file \
    coreutils \
    && rm -rf /var/lib/apt/lists/*

# Create a test user
RUN useradd -m -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to testuser
USER testuser
WORKDIR /home/testuser

# Create test directories
RUN mkdir -p /home/testuser/dotfiles

# Entry point for interactive testing
CMD ["/bin/bash"]