PreRender 1.3.2 — Windows Resolve Fusion

Saver＋Loaderを1ノードで運用するGroup＋Luaです。標準バイパスで元入力へ戻ります。
初期色：Violet。名前：PreRender。初期形式：EXR。
Filename・Output Format・範囲・操作ボタンはすべてPreRenderタブに配置しています。

導入
ZIPを展開し、PreRenderフォルダーのInstall.ps1を実行します。
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install.ps1
管理者権限不要。同名の作成スクリプトとMacro登録を更新します。
手動の場合は同梱ScriptsとMacrosの中身を次へ同じ構成でコピーします。
%APPDATA%\Blackmagic Design\DaVinci Resolve\Support\Fusion
新SupportファイルはScripts\Support\PreRender_v13.luaです。
Scripts/Support/PreRender_placeholder.pngも必要です。作成時のOpen File確認を防ぐ透明な仮画像です。
Macros:のパスマップを独自フォルダーに変更している場合は、同梱Macros/PreRender.settingを
そのフォルダーにもコピーしてください。Install.ps1 -MacroPath '独自フォルダーの絶対パス' でも導入できます。
旧PreRender.luaは既存ノードのため残します。
Resolveを再起動し、Select Tool（お使いの環境ではCtrl+Space）でPreRenderを検索。
既存の1.2ノードには新しい欄やボタンは自動追加されません。新版を追加して置き換えてください。
Workspace > Scripts > PreRender Createからも新版を作成できます。

使い方
1. 上流 → PreRender → 下流と接続します。
2. InspectorのFilenameに保存先とベース名を指定。例 D:/Cache/beauty.exr
   初期表示のTemp:/PreRender_SetFilename.exrは仮名です。希望する保存先へ変更してください。
3. Output Formatを選択。初期値はOpenEXRです。
4. PreRenderタブのUse Composition Rangeがオンならコンポジションの範囲を使用。
   オフなら同じタブのStart Frame / End Frameへ範囲を入力します。
   Render Range / Update Proxyで、別の範囲ウィンドウを出さずに書き出します。
5. Render Current Frameは現在位置だけを書き出します（範囲ダイアログなし）。
6. Open Containing FolderでFilenameの親フォルダーを開きます。
通常時と最終レンダーはLoaderからの保存済み画像を使います。
元入力を使う場合は標準のノードバイパスを使用してください。
更新時はノードを有効にしてください。

ファイル名と形式
beauty.exrを指定した場合：beauty.000000.exr、beauty.000001.exr …。
末尾にドットと6桁のコンポジションフレーム番号が付きます。
形式の選択が出力拡張子を決めます（PNGならbeauty.000000.png）。
同じベース名・形式の再実行では対象フレームを上書きします。
日時や世代番号は自動で付けません。manifest.txtなどの付随ファイルは作成しません。
範囲などの管理情報はGroup内部のプロジェクトデータに保持します。
旧版が作成したmanifestや不要フレームは自動削除しません。
範囲短縮時は古い末尾ファイルがディスクに残っていてもLoaderの範囲外にします。
保存先は既存フォルダーを指定してください。自動フォルダー作成機能はありません。

カレントフレーム
同じベース名・形式で既存キャッシュ範囲内のフレームを更新すると、
そのフレームだけを上書きし、既存のLoader範囲を維持します。
キャッシュがない、別名・別形式、または既存範囲外の場合は、その1フレームを
新しいキャッシュ範囲として設定します。それ以外の時間は自動Live復帰しません。

品質と制限
HiQ=true、Proxy=1で通常解像度の明示レンダーを行います。
EXRビット深度・圧縮・色変換はSaver/Loader既定値に依存します。
画像連番専用です。動画形式は拒否します。JPEG等はアルファ・HDRを保持できません。
形式候補は実行環境のSaverに依存し、Saver/Loader双方で画像入出力可能な形式を受け付けます。
別の分岐やViewerが上流を要求する場合、その分の計算は発生します。
自動失効・自動更新はありません。内部PR_ノードの名前や配線は変えないでください。
プロジェクトを保存してください。更新ボタンにはSupportスクリプトが必要です。
0以上の整数フレーム対応。同期レンダー中はUI操作が制限されます。
保存先と書き出し形式を確認し、別のレンダーと同時に更新しないでください。

検証状況
Windows / Resolve Studio 21.1.0.17でEXR・PNG出力、任意名、範囲短縮、
カレントフレームの部分更新、管理用ファイル非生成、Saver後処理を確認しました。
Folder Openの外部起動APIは正常終了しました（画面目視は未実施）。
ボタンと同じ処理に範囲を直接渡す方法で検証しています。
20.x、無料版、EXR/PNG以外の各形式、UI操作全体、保存後再読込、長い実素材、
日本語/ネットワークパス、キャンセル途中の復元、Deep/多層EXRは未検証です。
全フレームの存在・非ゼロサイズを検査しますが、全画素比較はしません。

アンインストール
Macros/PreRender.setting、Scripts/Comp/PreRender Create.lua、
Scripts/Support/PreRender_v13.luaを導入先から削除します。
旧ノード使用中は旧Support/PreRender.luaを削除しないでください。

API参照
https://documents.blackmagicdesign.com/UserManuals/Fusion8_Scripting_Guide.pdf
接続プラグインのFusion 21.1 API、および実機GetRegAttrsの画像形式情報。
