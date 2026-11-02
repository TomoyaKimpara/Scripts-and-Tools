"""
選択したノードの段階のキャッシュを作るノード。その階層に　[階層名]_cache　というノードが作られる。バッチ処理
"""


import hou


def get_cache_ropnet(parent):
    base_name = parent.name() + "_cache"
    marker = "sop_cache_ropnet"

    def apply_style(ropnet):
        # 黄色
        ropnet.setColor(hou.Color((1.0, 1.0, 0.0)))

        # 丸型
        ropnet.setUserData("nodeshape", "circle")

        return ropnet

    # このスクリプトで作成したROP Networkを再利用
    for child in parent.children():
        if (
            child.type().name() == "ropnet"
            and child.userData(marker) == "1"
        ):
            return apply_style(child)

    # 同名のROP Networkがあれば再利用
    existing = parent.node(base_name)

    if existing is not None and existing.type().name() == "ropnet":
        existing.setUserData(marker, "1")
        return apply_style(existing)

    # ROP Networkを新規作成
    # 同名の別種ノードがある場合は、自動で番号を付ける
    ropnet = parent.createNode("ropnet")
    ropnet.setName(base_name, unique_name=True)
    ropnet.setUserData(marker, "1")
    ropnet.moveToGoodPosition()

    return apply_style(ropnet)


def create_nodes():
    selected = [
        node
        for node in hou.selectedNodes()
        if node.type().category() == hou.sopNodeTypeCategory()
    ]

    if not selected:
        hou.ui.displayMessage("SOPノードを選択してください。")
        return

    created = []

    with hou.undos.group("Create SOP Cache"):
        for node in selected:
            parent = node.parent()

            # 親ネットワーク内にROP Networkを作成・再利用
            # 例: /obj/geo → /obj/geo/geo_cache
            ropnet = get_cache_ropnet(parent)

            # Geometry ROPを作成
            rop = ropnet.createNode("geometry", node.name())
            rop.moveToGoodPosition()

            # File SOP作成前に既存の接続と表示状態を保存
            connections = list(node.outputConnections())
            display_flag = node.isDisplayFlagSet()

            # File SOPを作成
            file_node = parent.createNode("file")
            file_node.setPosition(
                node.position() + hou.Vector2(0, -1.5)
            )

            # 元ノード → File SOP
            file_node.setInput(0, node)

            # 既存の後続ノードをFile SOPにつなぎ直す
            for conn in connections:
                downstream = conn.outputNode()
                input_index = conn.inputIndex()

                downstream.setInput(input_index, file_node)

            # Geometry ROPの出力元
            rop.parm("soppath").set(node.path())

            # 出力ファイル名
            rop.parm("sopoutput").set(
                "$HIP/geo/" + node.name() + ".$F4.bgeo.sc"
            )

            # File SOPがGeometry ROPの出力先を参照
            path_expr = '`chs("' + rop.path() + '/sopoutput")`'
            file_node.parm("file").set(path_expr)

            # File SOPを読み込み専用に設定
            mode = file_node.parm("filemode")
            if mode is not None:
                mode.set(1)

            # ファイルが存在しないときは空ジオメトリ
            missing = file_node.parm("missingframe")
            if missing is not None:
                missing.set(1)

            # 表示フラグを引き継ぐ
            if display_flag:
                file_node.setDisplayFlag(True)

            created.append(
                rop.path() + " / " + file_node.path()
            )

    hou.ui.setStatusMessage(
        "Created: " + " | ".join(created),
        severity=hou.severityType.ImportantMessage
    )


create_nodes()
