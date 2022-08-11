# Wasp build
FROM wasp-base

# Copy initialization Script
COPY init ./init

RUN chmod +x init

# Configure initialization script as entrypoint
ENTRYPOINT ["./init"]
