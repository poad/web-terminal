[![](https://github.com/poad/web-terminal/workflows/Node.js%20modules%20auto%20update%20and%20Docker%20Image%20push/badge.svg?branch=master&event=push)](https://github.com/poad/web-terminal/actions?query=branch%3Amaster+event%3Apush)

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
