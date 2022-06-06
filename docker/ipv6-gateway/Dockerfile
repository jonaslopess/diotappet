FROM gateway-base

# Copy application and dependencies
COPY smart-contract-abi.json ./smart-contract-abi.json
COPY smart-contract-bytecode.json ./smart-contract-bytecode.json
COPY ipv6-echo-tester ./ipv6-echo-tester

# Copy initialization Script
COPY init ./init

# Configure initialization script as entrypoint
ENTRYPOINT ["./init"]
