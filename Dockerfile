FROM golang:1.12-alpine

RUN apk add --no-cache --quiet git

RUN go get -u github.com/rakyll/hey

