FROM alpine:3.20.3  AS builder 

WORKDIR /app/

COPY . .

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
RUN apk update && \
    apk add make build-base ncurses-dev linux-headers

RUN make defconfig && \
    make menuconfig && \
    make

FROM alpine:3.20.3

WORKDIR /app/

COPY --from=builder /app/busybox /bin/busybox

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories && \
    apk update && \
    apk --no-cache add coreutils lftp sshpass openssh findutils bash curl && \
    addgroup -g 5000 smartddi && \
    adduser -u 6666 -G smartddi -D smartddi

USER smartddi
RUN mkdir /tmp/crontabs && \
    touch /tmp/crontabs/smartddi && \
    chmod 644 /tmp/crontabs/smartddi

CMD ["crond", "-c", "/tmp/crontabs", "-d", "2", "-f"]