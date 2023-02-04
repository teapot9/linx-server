FROM golang:1.20-alpine3.17 AS build

WORKDIR /app
COPY . .

RUN go get github.com/nkovacs/go.rice/rice
RUN go install github.com/nkovacs/go.rice/rice
RUN go build -v -o /linx-server .
RUN rice append --exec /linx-server

FROM alpine:3.17

WORKDIR /

COPY --from=build /linx-server /linx-server
RUN chmod +x /linx-server

RUN mkdir -p /data/files
RUN mkdir -p /data/meta
RUN chown -R 65534:65534 /data

VOLUME ["/data/files", "/data/meta"]

EXPOSE 8080
USER nobody
ENTRYPOINT ["/linx-server", "-bind=0.0.0.0:8080", "-filespath=/data/files/", "-metapath=/data/meta/"]
CMD ["-sitename=linx", "-allowhotlink"]
