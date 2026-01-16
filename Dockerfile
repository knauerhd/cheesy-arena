# Build Stage
FROM --platform=$BUILDPLATFORM golang:1.22-alpine AS builder

# Provided automatically by Buildx
ARG TARGETOS
ARG TARGETARCH

WORKDIR /app
COPY . .

# Use Go's cross-compilation
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o cheesy-arena .

# Final Stage
FROM alpine:latest
WORKDIR /app
# Install dependencies for assets if needed (like zip/unzip)
RUN apk add --no-cache ca-certificates tzdata

COPY --from=builder /app/cheesy-arena .
# Copy your specific asset files/folders
COPY LICENSE README.md fix_avatar_colors_for_overlay font schedules static switch_config.txt templates tunnel ./

EXPOSE 8080
CMD ["./cheesy-arena"]