#!/bin/sh

# dockerコンテナの中で使用をします
# カレントディレクトリに dvc_tool.sh をおく
#
# backup例）
#   $ docker run --rm --volumes-from DVC名 -v $(pwd):/backup busybox /backup/dvc_tool.sh backup tgzファイル
#   
#   コンテナDVCのボリュームをカレントディレクトリのtgzファイルにバックアップします
#
# restore例）
#   docker run --rm --volumes-from DVC名 -v $(pwd):/backup busybox /backup/dvc_tool.sh restore tgzファイル
#
#   カレントディレクトリにあるtgzファイルをコンテナDVCにレストアします
# 
## 
# $1 : [backup | action]
# $2 : tgz ファイル名
#

usage() {
  echo "usage..."
  echo "$0 [backup|restore] tgz"
}

detect_dvc() {
  volumes=$(cat /proc/mounts | \
    grep "^/dev/" | \
    grep -v "/backup" | \
    grep -v "/etc/resolv.conf" | \
    grep -v "/etc/hostname" | \
    grep -v "/etc/hosts" | \
    awk '{print $2;}' | \
    tr '\n' ' ')

  if [ -z "$volumes" ]; then
    echo "No volumes were detected."
    exit 1
  fi
}

create_restore_script() {
  echo "#!/bin/sh" > $2_restore.sh
  echo "#create dvc" >> $2_restore.sh
  echo "docker run -v $1 --name \$1 busybox true" >> $2_restore.sh
  echo "#restore" >> $2_restore.sh
  echo "docker run --rm --volumes-from \$1 -v \$(pwd):/backup osuo/docker-backup restore \$2" >> $2_restore.sh
  chmod +x $2_restore.sh
}

### main

# check
if [ $# -ne 2 ]; then
  usage
  exit 1
fi
if [ "$1" != "backup" -a "$1" != "restore" ]; then
  usage
  exit 1
fi

# set
action=$1
tgz=/backup/$2

# do
if [ "$action" = "backup" ]; then
  detect_dvc
  echo "backup... $volumes"
  create_restore_script $volumes $tgz

  #tar acf $tgz $volumes #busyboxのtarは --auto-compress が使えない
  tar czf $tgz $volumes
else
  echo "restore... $tgz"

  tar xzf $tgz -C /
fi

