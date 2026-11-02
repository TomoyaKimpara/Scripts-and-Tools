"""
選択したVrayLightをVisible[ON/OFF] で Enable[ON/OFF] をリンクさせる。
"""
import hou

def main():
    expr = "int(hou.pwd().isDisplayFlagSet())"
    count = 0

    for node in hou.selectedNodes():
        if not node.type().name().startswith("VRayNodeLight"):
            continue

        parm = node.parm("enabled")
        if parm is None:
            continue

        parm.deleteAllKeyframes()
        parm.setExpression(
            expr,
            language=hou.exprLanguage.Python
        )

        print("Applied:", node.path())
        count += 1

    hou.ui.displayMessage(
        f"{count} 個のV-Rayライトに設定しました。"
    )

if __name__ == "__main__":
    main()
