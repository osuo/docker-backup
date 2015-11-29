#
# 
#
FROM busybox
MAINTAINER Kazumasa Hagihara <hagihara.k@gmail.com>

RUN mkdir -p /usr/local/bin
COPY scripts/dvc_tool.sh /usr/local/bin

VOLUME /backup

#ENTRYPOINT /usr/local/bin/dvc_tool.sh # これだとダメ
ENTRYPOINT ["/usr/local/bin/dvc_tool.sh"]

