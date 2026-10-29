
FROM alpine:3.21 AS source
RUN apk add --no-cache unzip
WORKDIR /tmp/source
COPY manikur_archive.zip /tmp/source.zip
RUN unzip -q /tmp/source.zip \
    && test -f /tmp/source/app/package.json \
    && mv /tmp/source/app /project

FROM oven/bun:1.4.4 AS builder
WORKDIR /app
COPY --from=source /project/ ./
RUN bun install --frozen-lockfile
ENV NITRO_PRESET=node-server
RUN bun run build

FROM node:24-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production HOST=0.0.0.0
COPY --from=builder /app/.output ./.output
EXPOSE 10000
CMD ["node", ".output/server/index.mjs"]
