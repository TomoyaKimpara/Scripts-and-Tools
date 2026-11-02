"""
3dsmaxのAlt+Q 孤立ツール。　ショートカットに割り当てて使う。
"""


import hou
import toolutils

# 現在の Scene Viewer を取得
scene_viewer = toolutils.sceneViewer()
if scene_viewer is None:
    hou.ui.displayMessage("Scene View が見つかりません。")
    raise hou.Error("No Scene Viewer found")

viewer_name = scene_viewer.fullName()

# トグル状態を hou.session に保存
state_name = "_toggle_show_all_hide_world"

current_state = getattr(hou.session, state_name, "show_all")

try:
    if current_state == "hide_world":
        # Show All Objects
        hou.hscript("vieweroption -a 1 {}".format(viewer_name))
        setattr(hou.session, state_name, "show_all")
        hou.ui.setStatusMessage("Show All Objects", severity=hou.severityType.Message)

    else:
        # Hide Other Objects (World Space)
        # Houdini 21 以降の World Space 用
        hou.hscript("vieweroption -a 3 {}".format(viewer_name))
        setattr(hou.session, state_name, "hide_world")
        hou.ui.setStatusMessage("Hide Other Objects (World Space)", severity=hou.severityType.Message)

except Exception as e:
    hou.ui.displayMessage(
        "切り替えに失敗しました。\n\n"
        "Houdini 21 以降で試してください。\n"
        "エラー内容:\n{}".format(e)
    )
