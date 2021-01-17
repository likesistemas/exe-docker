ARG EXE_NAME=app
ARG EXE_NAME_X86=${EXE_NAME}-x86.exe
ARG EXE_NAME_X64=${EXE_NAME}-x64.exe
ARG EXE_NAME_X86_SIGNED=${EXE_NAME}-x86_signed.exe
ARG EXE_NAME_X64_SIGNED=${EXE_NAME}-x64_signed.exe
ARG CERTIFICATE_FILE=certificate.pfx
ARG CERTIFICATE_PASSWORD=123456

FROM golang:alpine as compile
ARG EXE_NAME_X86
ARG EXE_NAME_X64

RUN apk update && apk add --no-cache git
WORKDIR $GOPATH/src/likesistemas/exe/
COPY favicon.ico versioninfo.json ./
RUN go get github.com/josephspurrier/goversioninfo/cmd/goversioninfo \
 && goversioninfo
COPY go.mod go.sum *.go ./
RUN go get -d -v
RUN go generate
RUN GOOS=windows GOARCH=386 go build -ldflags="-linkmode=internal -w -s -H=windowsgui" -o /go/bin/${EXE_NAME_X86}
RUN GOOS=windows GOARCH=amd64 go build -ldflags="-linkmode=internal -w -s -H=windowsgui" -o /go/bin/${EXE_NAME_X64}

FROM likesistemas/exe-sign:latest as sign-x86
ARG EXE_NAME_X86
ARG CERT_FILE
ARG CERT_PASSWORD

WORKDIR /work/
COPY ${CERTIFICATE_FILE} .
COPY --from=compile /go/bin/${EXE_NAME_X86} ./${EXE_FILE}
RUN sign

FROM likesistemas/exe-sign:latest as sign-x64
ARG EXE_NAME_X64
ARG CERTIFICATE_FILE
ARG CERTIFICATE_PASSWORD

WORKDIR /work/
COPY ${CERTIFICATE_FILE} .
COPY --from=compile /go/bin/${EXE_NAME_X64} ./${EXE_FILE}
RUN sign

FROM debian:10-slim
ARG EXE_NAME_X86
ARG EXE_NAME_X64
ARG EXE_NAME_X86_SIGNED
ARG EXE_NAME_X64_SIGNED

WORKDIR /go/bin/
COPY --from=compile /go/bin/${EXE_NAME_X86} ./
COPY --from=compile /go/bin/${EXE_NAME_X64} ./
COPY --from=sign-x86 /work/app_signed.exe ./${EXE_NAME_X86_SIGNED}
COPY --from=sign-x64 /work/app_signed.exe ./${EXE_NAME_X64_SIGNED}
CMD cp -Rfv *.exe /output/