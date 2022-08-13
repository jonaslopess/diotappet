# Wasp build
FROM wasp-base

# Copy initialization Script
COPY init ./init

RUN chmod +x init

COPY wasp_config.json ./etc/wasp_config.json

# Configure initialization script as entrypoint
ENTRYPOINT ["./init"]
