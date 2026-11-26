FileCache 1.4.1 — Windows Resolve Fusion

PreRenderからFileCacheへ名称変更。初期色はVioletです。
重要：既存ノードの名前を変更しても内部の切替方式は変わりません。
この版は専用Fuseを追加するため、導入後のResolve再起動が必要です。

インストール
1. ZIPをすべて展開します。
2. FileCache内のInstall.ps1を実行します。
   powershell -NoProfile -ExecutionPolicy Bypass -File .\Install.ps1
3. プロジェクトを保存し、Resolveを再起動します。
4. Select Tool（この環境ではCtrl+Space）でFileCacheを検索します。
   Workspace > Scripts > FileCache Createからも追加できます。
Macros:を独自フォルダーへ変更している場合：
   powershell -NoProfile -ExecutionPolicy Bypass -File .\Install.ps1 -MacroPath '独自フォルダーの絶対パス'
管理者権限は不要です。旧PreRenderのファイルは既存ノード維持のため残します。

コピー先（別PCも同じ）
%APPDATA%/Blackmagic Design/DaVinci Resolve/Support/Fusion/
  Scripts/Comp/FileCache Create.lua
  Scripts/Support/FileCache_v13.lua
  Scripts/Support/FileCache_placeholder.png
  Macros/FileCache.setting
  Fuses/FileCacheGate.fuse
手動の場合も、この構成ですべてコピーしてから再起動してください。

使い方
上流 → FileCache → 下流と接続します。
InspectorのFileCacheタブでFilenameに保存先と名前を入力します。
例 D:/Cache/beauty.exr → beauty.000000.exr、beauty.000001.exr…
Output FormatはEXRが初期値。SaverとLoaderの両方が扱える画像形式を選べます。
動画形式は対象外です。形式はOutput Format欄で指定してください。
初期範囲はStart Frame=0、End Frame=240、Use Composition Rangeはオン。
Render Range / Update Proxyで範囲を更新します。
Render Current Frameは現在位置のみを更新します。
同じキャッシュ範囲内の1フレーム更新では、既存の全体範囲を維持します。
Open Containing FolderでFilenameの親フォルダーを開きます。
更新成功後は完了ダイアログを表示します。

通常時は専用GateがCache入力だけを要求します。
Live入力はINP_SendRequest=falseとし、通常Processでは参照しません。
標準バイパス時に元入力へ戻ります。新Fuseでの通常出力と標準バイパスを実機確認済みです。
再レンダリング時は元入力を計算します。HiQ=true、Proxy=1で要求します。
ほかのビューアや別分岐から同じ上流を要求すれば、その経路では計算されます。

同名の連番は上書きします。フォルダーは先に作成してください。
範囲外への自動Live切替はありません。必要な全範囲を書き出してください。
manifest等の付随ファイルは作りません。キャッシュ情報はプロジェクト内へ保存します。
インストーラーは既存ノードを自動置換しません。既存キャッシュも削除しません。
この検証セッションの既存3ノードは、個別にキャッシュと接続を引き継いで更新しました。

検証状況はTEST_RESULTS_JA.txtを参照してください。
