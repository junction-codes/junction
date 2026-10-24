FROM chromedp/headless-shell:latest

# Install fonts required for proper rendering in headless Chrome. These are the
# same fonts available in CI (GitHub Actions) and are metric-compatible with the
# Arial and Helvetica font stacks used in the application.
RUN apt-get update \
  && apt-get install --no-install-recommends -y fonts-liberation fonts-dejavu-core \
  && rm -rf /var/lib/apt/lists/*
