# base image
FROM golang:1.22.2-alpine3.19 AS builder

# working directory
WORKDIR /usr/src/app

# copy source code to current working directory
COPY . .

# download all dependencies listed in go.mod
RUN go get -d -v

# build the executable
RUN go build -v -o app main.go

FROM alpine

RUN set -eux ; \
    apk update ; \
    apk upgrade ; \
    apk add --no-cache tar xz ; \
    wget https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-arm64-static.tar.xz ; \
    tar xvf ffmpeg-git-arm64-static.tar.xz ; \
    FFMPEG_DIR=$(ls | grep "ffmpeg-git-[0-9]*-arm64-static") ; \
    mv ${FFMPEG_DIR}/ffmpeg /usr/bin/ffmpeg ; \
    rm -rf ${FFMPEG_DIR} ffmpeg-git-arm64-static.tar.xz;

# copy the built executable from the last stage to alpine image
# so we can try it with ffmpeg
COPY --from=builder /usr/src/app/app /usr/bin/app

# run app
CMD ["app"]