FROM golang:1.12-alpine as gobuild

RUN apk --update upgrade \
    && apk --no-cache --no-progress add git mercurial bash gcc musl-dev curl tar ca-certificates tzdata \
    && update-ca-certificates \
    && rm -rf /var/cache/apk/*

WORKDIR /src

COPY go.mod .
COPY go.sum .

RUN GO111MODULE=on GOPROXY=https://proxy.golang.org go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix nocgo -ldflags="-w -s" . 

FROM scratch

COPY --from=gobuild /src/xTeVe /xTeVe

COPY --from=gobuild /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=gobuild /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/


EXPOSE 34400

CMD [ "/xTeVe" ]
