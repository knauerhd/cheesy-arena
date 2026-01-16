# --- STAGE 1: Build the binary ---
FROM golang:1.25-bookworm AS builder

# Install git to pull the source
RUN apt-get update && apt-get install -y git

# Set working directory
WORKDIR /src

# 1. Clone the repository (latest version)
RUN git clone https://github.com/knauerhd/cheesy-arena.git

# 2. Download Go dependencies
RUN go mod download

# 3. Build the application statically
# We use CGO_ENABLED=0 to ensure it works on any Linux base
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/cheesy-arena .

# --- STAGE 2: Run the binary ---
FROM debian:bookworm-slim

# Install certificates for TBA (The Blue Alliance) sync
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy only the compiled binary from the builder stage
COPY --from=builder /app/cheesy-arena /app/cheesy-arena

# Copy the static assets (schedules, templates, etc.) from the builder
# Cheesy Arena needs these files to run!
COPY --from=builder /src/static /app/static
COPY --from=builder /src/templates /app/templates
COPY --from=builder /src/schedules /app/schedules

RUN chmod +x /app/cheesy-arena

EXPOSE 8080 1160 1750

CMD ["./cheesy-arena"]