#!/bin/sh

hoge(){
  shift
  for volume in $*; do
    vopts=$vopts" -v $volume"
  done
  echo $vopts
}

hoge a b c
