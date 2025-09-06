###############
# Build Stage #
###############
FROM hugomods/hugo:exts AS builder

# Base URL can be overridden at build time
ARG HUGO_BASEURL
ENV HUGO_BASEURL=${HUGO_BASEURL}

# Copy source code
COPY . /src

# Build site with optional baseURL override
RUN if [ -z "$HUGO_BASEURL" ]; then \
      echo "Building site using baseURL from hugo.toml"; \
      hugo --minify --gc --enableGitInfo --destination /build; \
    else \
      echo "Building site with HUGO_BASEURL=$HUGO_BASEURL"; \
      hugo --minify --gc --enableGitInfo --destination /build --baseURL "$HUGO_BASEURL"; \
    fi

# Optional: fallback 404 page for multi-language sites
# RUN cp ./public/en/404.html ./public/404.html

###############
# Final Stage #
###############
FROM hugomods/hugo:nginx

# Copy built static site
COPY --from=builder /build /site
