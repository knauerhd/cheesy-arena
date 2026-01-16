# Build stage
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY . .
RUN go build -o cheesy-arena .

# Final stage
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/cheesy-arena .
# Copy your asset folders
COPY LICENSE README.md fix_avatar_colors_for_overlay font schedules static switch_config.txt templates tunnel ./
EXPOSE 8080
CMD ["./cheesy-arena"]