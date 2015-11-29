#!/bin/sh

# dockerコンテナの中で使用をします
# カレントディレクトリに dvc_tool.sh をおく
#
# backup例）
#   $ docker run --rm --volumes-from DVC名 -v $(pwd):/backup busybox /backup/dvc_tool.sh backup tgzファイル
#   
#   コンテナDVCのボリュームをカレントディレクトリのtgzファイルにバックアップします
#   合わせてリストア用のスクリプトを生成します
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
  exit 1
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
  restore_file=${2##*/}
  restore_script=${2%.*}_restore.sh

  echo "create restore script ... $restore_script"

  cat <<- EOS > $restore_script
	#!/bin/sh

	if [ \$# -ne 1 ]; then
	  echo "usage..."
	  echo "\$0 DVC"
	  exit 1
	fi

	echo "restore..."

	#create dvc
	echo "docker run -v $1 --name \$1 busybox true"
	docker run -v $1 --name \$1 busybox true

	#restore
	echo "docker run --rm --volumes-from \$1 -v \$(pwd):/backup osuo/docker-backup restore $restore_file"
	docker run --rm --volumes-from \$1 -v \$(pwd):/backup osuo/docker-backup restore $restore_file
	EOS

  chmod +x $restore_script
}

### main

# check
if [ $# -ne 2 ]; then
  usage
fi
if [ "$1" != "backup" -a "$1" != "restore" ]; then
  usage
fi

# set
action=$1
tgz=/backup/$2

# do
if [ "$action" = "backup" ]; then
  echo "backup..."
  detect_dvc

  echo "valumes = $volumes"
  echo "file = $tgz"
  create_restore_script $volumes $tgz

  #tar acf $tgz $volumes #busyboxのtarは --auto-compress が使えない
  tar czf $tgz $volumes
else
  tar xzf $tgz -C /
fi

