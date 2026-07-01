# react-survey-builder — dev server image
# Repo: https://github.com/Forhath-Hosain-Ome/react-survey-builder
#
# Fixes applied here:
#   1. WebSocket disconnect loop — webpack-dev-server now listens on the
#      SAME port (8088) that's exposed/mapped, so the HMR client's WS
#      handshake matches what the browser can actually reach.
#   2. "Accessing element.ref was removed in React 19" — this project's
#      drag-and-drop (react-dnd@11 / react-dnd-html5-backend@11) uses the
#      old decorator API that reads element.ref directly, which React 19
#      only supports via a deprecated compat shim. We pin React back to
#      18.3.1, which is what react-dnd@11 was actually built against, so
#      the warning goes away cleanly instead of patching library internals.

FROM node:18-bullseye

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install project deps first (cached layer unless lockfiles change)
COPY package.json package-lock.json* yarn.lock* ./
RUN if [ -f yarn.lock ]; then \
      yarn install --frozen-lockfile; \
    else \
      npm install; \
    fi

# Pin React to 18.3.1 — matches what react-dnd@11's decorator-based
# ref handling expects, removing the React 19 ref-deprecation warning.
RUN npm install react@18.3.1 react-dom@18.3.1 --save-exact

COPY . .

EXPOSE 8088

CMD ["npx", "webpack-dev-server", "--hot", "--mode", "development", "--host", "0.0.0.0", "--port", "8088"]