# OpenStreetMap Tile Server

OpenStreetMapのタイルサーバを構築するDockerfileです。

## 手順メモ
1. PostgreSQLを別のサーバもしくはクラウドに作成して下さい。
2. PostgreSQLにアクセスするための情報を環境変数に設定するためにDockerfileを編集します。
3. docker buildを実行します。
4. イメージの作成が完了したら、docker runします。Port 80をバインドします。また、/var/lib/mod_tileをローカルディスクにマウントすると再レンダリングが少なくなります。もし、ローカル実行のPostgreSQLを動かしたい場合はデータベースファイルをローカルディスクにマウントしたほうが良いでしょう。
5. script/create_database.shを実行してデータベースを作成します。
6. データベースに書き込む地域を設定するために、script/build_osm_data.shを編集します。
7. script/build_osm_data.shを実行してデーターベースに書き込みます。
8. openstreetmap-carto/scripts/get-external-data.pyを実行します。一部プログラムからダウンロードできないファイルがありますので、手動でダウンロード後、Azure StorageやAWS S3などプログラムからダウンロードできるストレージにアップロードします。URLが決まったら、openstreetmap-carto/exernal-data.yamlを編集してください。
9. Service apache2 startでWebサーバを起動します。
10. renderd -f -c /usr/local/etc/renderd.confでレンダーを起動します。
11. http://xxx.xxx.xxx.xxx/sample_leaflet.html にアクセスして動作を確認します。画像のレンダリングには時間がかかります。