"""
新規フローティングをmatで表示
"""

import hou

def get_link_group(num=9):
    name = "Group{}".format(num)
    if hasattr(hou.paneLinkType, name):
        return getattr(hou.paneLinkType, name)
    return hou.paneLinkType.FollowSelection

mat = hou.node("/mat")
if mat is None:
    mat = hou.node("/").createNode("mat")

desktop = hou.ui.curDesktop()

# 画像に近い位置・サイズ
pane = desktop.createFloatingPaneTab(
    hou.paneTabType.NetworkEditor,
    position=(1200, 680),
    size=(1600, 800),
    immediate=True
)

pane.setPwd(mat)
pane.setLinkGroup(get_link_group(9))
pane.setShowNetworkControls(True)

# Pを押したパラメータ表示をON
pane.setPref("showparmdialog", "1")
pane.setPref("showparmdialogmax", "5")

# ノードが選択されていれば、そのパラメータを表示
sel = hou.selectedNodes()
if sel:
    pane.setCurrentNode(sel[-1])
