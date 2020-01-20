[![Docker Automated build](https://img.shields.io/docker/cloud/automated/poad/web-terminal?style=flat-square)](https://hub.docker.com/r/poad/web-terminal)
[![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/poad/web-terminal)](https://hub.docker.com/r/poad/web-terminal/builds)
[![](https://github.com/poad/web-terminal/workflows/.github/workflows/main.yml/badge.svg)](https://github.com/poad/web-terminal/actions)

# About

The terminal emulator on Web browser.

# Tags

## xtermjs based images

These images are based by [xterm.js](https://xtermjs.org).

`docker run --rm -it -p 3000:3000 poad/web-terminal:_tag_`

### xtermjs

The base image for each images by xtermjs.

### xtermjs-jshell

The JShell by [AdoptOpenJDK 11 Hostspot VM](https://adoptopenjdk.net/?variant=openjdk11&jvmVariant=hotspot).

### xtermjs-sbt-console

The [sbt](https://www.scala-sbt.org/index.html) console.

### xtermjs-rust

The Rust REPL by [Evcxr REPL](https://github.com/google/evcxr/tree/master/evcxr_repl)

## web-terminal based images

These images are based by [web-terminal](https://github.com/rabchev/web-terminal).

`docker run --rm -it -p 3000:3000 poad/web-terminal:_tag_`

### jshell

The JShell by [AdoptOpenJDK 11 Hostspot VM](https://adoptopenjdk.net/?variant=openjdk11&jvmVariant=hotspot).

### sbt-console

The [sbt](https://www.scala-sbt.org/index.html) console.

### rust

The Rust REPL by [Evcxr REPL](https://github.com/google/evcxr/tree/master/evcxr_repl)

# Attention

## Safari with IME

日本語版のmacOSの場合、英数字入力モードではキー入力を受け付けてくれないようです。
解決方法などは下記をご参照ください。

<https://ytooyama.hatenadiary.jp/entry/2019/06/20/223936>

# License

see [LICENSE](blob/master/LICENSE)
