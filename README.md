# これは何？
- Selenium WebDriverでHTTPステータスコードを確認するサンプルです。
- Docker上でSeleniumとRubyのプログラムが動きます。
- 詳しい構成などは `docker-compose.yml` を参照してください。

# 注意事項
- 他の人のサーバに対して、むやみにプログラムを使ってアクセスしてはいけません。
- これはサンプルプログラムです、取り扱いには注意してください。

# 使い方
- `scripts/bootstrap.sh` で各種コンテナが立ち上がります。
  - 終了時は `Ctrl + C` で。
- `scripts/check_status.sh ${url}` で、引数のURLに対してSeleniumからアクセスし、HTTPステータスコードを確認できます。
- SeleniumのノードはVNCを使ってアクセス可能です。
  - ポート番号は `15900` です。
  - PWは `secret` です。
  - Macの場合、ターミナルから `open vnc://localhost:15900/` でアクセス可能。

# 動作確認
- サンプルのnginxコンテナが立ち上がります。
  - nginxのサンプルページでステータスチェック。
    - `scripts/check_status.sh http://example_site/`
  - nginxの存在しないページでステータスチェック。
    - `scripts/check_status.sh http://example_site/notfoud`
