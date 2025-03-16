FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && apt-get install -y \
    zsh \
    sudo \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Create a test user
RUN useradd -m -s /bin/zsh testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to testuser
USER testuser
WORKDIR /home/testuser

# Copy your setup files
COPY --chown=testuser:testuser . /home/testuser/dotfiles/

# Entry point that allows interactive testing
ENTRYPOINT ["/bin/zsh"]

