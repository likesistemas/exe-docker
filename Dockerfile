FROM golang:alpine
ARG EXE_NAME=app
RUN apk update && apk add --no-cache git
WORKDIR $GOPATH/src/likesistemas/exe/
COPY favicon.ico versioninfo.json ./
RUN go get github.com/josephspurrier/goversioninfo/cmd/goversioninfo \
 && goversioninfo
COPY go.mod go.sum *.go ./
RUN go get -d -v
RUN go generate
RUN GOOS=windows GOARCH=386 go build -ldflags="-linkmode=internal -w -s -H=windowsgui" -o /go/bin/${EXE_NAME}-x86.exe
RUN GOOS=windows GOARCH=amd64 go build -ldflags="-linkmode=internal -w -s -H=windowsgui" -o /go/bin/${EXE_NAME}-x64.exe
WORKDIR /go/bin/
CMD cp -Rfv *.exe /output/