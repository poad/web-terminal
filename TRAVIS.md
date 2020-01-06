# Travis CI を使用した GitHub push 時の注意点

基本手順は <https://qiita.com/koyayashi/items/13d4ac3a4d84d40b4690> で良い。

## 注意点

### Travis CLI のインストール

```$sh
ERROR:  While executing gem ... (Gem::FilePermissionError)
    You don't have write permissions for the /usr/bin directory.
```

対策は `sudo gem install travis -n /usr/local/bin`

#### 参照

<https://qiita.com/usagisystem/items/71cf3b064fe00cf1608e#詳細>

### Travis CLI からのログイン

MFA 設定の影響もあるのか、以下の2オプション付きでしかログイン出来なかった。

```$sh
travis login --org --auto
```
