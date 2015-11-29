# docker-backup
Data Volume Containerのバックアップを行うDockerコンテナイメージです。

## 提供する機能
1. Dava Volume Containerが提供する**Volume**(*1)をtarボールにバックアップする
2. リストアしやすいように、リストア用のスクリプトを提供する

(*1) ... docker inspect で参照できるやつ。
```
$ docker inspect -f "{{ .Config.Volumes }}" DVC
map[/hogehoge:{}]
```
## 使い方
### バックアップ
```
$ docker run --rm --volumes-from バックアップするDVC -v $(pwd):/backup osuo/docker-backup backup バックアップファイル名
```
もしくは上記の処理をラップしたバックアップスクリプトを実行します。（wapperディレクトリにあります）
```
$ ./wrapper/backup.sh バックアップするDVC バックアップファイル
```
カレントディレクトリにバックアップファイルとリストア用のスクリプトが生成されます。

### 実行例
```
$ docker inspect -f "{{ .Config.Volumes }}" work-dvc
map[/hogehoge:{}]

$ ./wrapper/backup.sh work-dvc hoge.tgz
backup...
volumes = /hogehoge
file = /backup/hoge.tgz
create restore script ... /backup/hoge_restore.sh
```

### リストア
リストアする環境に移動・接続するなどし、
カレントディレクトリにバックアップ処理で生成された、
バックアップファイルとリストア用スクリプトを用意します。
それらのファイルがあるディレクトリに移動して、リストアスクリプトを実行します。
```
$ ./リストアスクリプト 生成するDVC リストアするTGZ
```

### 実行例
```
$ docker inspect -f "{{ .Configure.Volumes }}" work-hoge
rror: No such image or container: work-hoge

$ ./hoge_restore.sh work-hoge hoge.tgz
restore...
docker run -v /hogehoge --name work-hoge busybox true
docker run --rm --volumes-from work-hoge -v /Users/hagi/backup:/backup osuo/docker-backup restore hoge.tgz
```
