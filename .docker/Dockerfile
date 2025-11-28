# base
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update -y && apt-get upgrade -y && \
    useradd -m docker && \
    apt-get install -y --no-install-recommends \
        build-essential ca-certificates curl file git jq \
        libffi-dev libssl-dev nodejs npm openssh-client \
        python3 python3-dev python3-pip python3-venv \
        unzip wget zip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*



# Download and extract GitHub Actions runner
RUN RUNNER_VERSION=$(curl -sI https://github.com/actions/runner/releases/latest | \
    grep -i '^location:' | awk -F '/tag/v' '{print $2}' | tr -d '\r') && \
    echo "RUNNER_VERSION=${RUNNER_VERSION}" && \
    cd /home/docker && \
    mkdir actions-runner && cd actions-runner && \
    curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    chown -R docker ~docker

# Install runner dependencies
RUN /home/docker/actions-runner/bin/installdependencies.sh

# copy over the start.sh script
COPY .docker/start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]
