-- PreRender 1.3 - named image sequences and current-frame rendering.
local c = comp or composition
assert(c, 'Open a Fusion composition first')
local settings = [[{
 Tools = ordered() {
  PreRender = GroupOperator {
   Colors = { TileColor = { R = 0.584313725490196, G = 0.294117647058824, B = 0.803921568627451 } },
   Inputs = ordered() {
    MainInput1 = InstanceInput { SourceOp = "PR_Input", Source = "Input", Name = "Input" },
    Filename = InstanceInput { SourceOp = "PR_Saver", Source = "Clip", Name = "Filename", Page = "PreRender" },
    OutputFormat = InstanceInput { SourceOp = "PR_Saver", Source = "OutputFormat", Name = "Output Format", Page = "PreRender" },
   },
   Outputs = { MainOutput1 = InstanceOutput { SourceOp = "PR_Switch", Source = "Output", Name = "Output" } },
   Tools = ordered() {
    PR_Input = PipeRouter {},
    PR_Saver = Saver { PassThrough = true, Inputs = {
     OutputFormat = Input { Value = FuID { "OpenEXRFormat" } },
     Clip = Input { Value = Clip { Filename = "Temp:/PreRender_SetFilename.exr", FormatID = "OpenEXRFormat", Saving = true } },
    } },
    PR_Loader = Loader { Clips = { Clip {
     ID = "Clip1", Filename = "Scripts:Support/PreRender_placeholder.png", FormatID = "PNGFormat",
     StartFrame = -1, Length = 1, LengthSetManually = true, TrimIn = 0, TrimOut = 0,
     GlobalStart = 0, GlobalEnd = 0, ExtendFirst = 0, ExtendLast = 0, Loop = 1,
    } } },
    PR_Switch = Dissolve { Inputs = {
     Background = Input { SourceOp = "PR_Input", Source = "Output" },
     Foreground = Input { SourceOp = "PR_Loader", Source = "Output" },
     Mix = Input { Value = 1 },
    } },
   },
  },
 },
}]]
c:StartUndo('Create PreRender')
c:Lock()
local ok, err = pcall(function()
 local function button(label, action)
  return { LINKS_Name=label, LINKID_DataType='Number', INPID_InputControl='ButtonControl',
   ICS_ControlPage='PreRender', BTNCS_Execute="local f=assert(loadfile(comp:MapPath('Scripts:Support/PreRender_v13.lua'))); f()('"..action.."', tool, comp)" }
 end
 local parsed=assert(bmd.readstring(settings))
 parsed.Tools.PreRender.UserControls = {
  PR_UseCompRange = { LINKS_Name='Use Composition Range', LINKID_DataType='Number', INPID_InputControl='CheckboxControl', ICS_ControlPage='PreRender', INP_Default=1, CBC_TriState=false },
  PR_FirstFrame = { LINKS_Name='Start Frame', LINKID_DataType='Number', INPID_InputControl='ScrewControl', ICS_ControlPage='PreRender', INP_Integer=true, INP_Default=0 },
  PR_LastFrame = { LINKS_Name='End Frame', LINKID_DataType='Number', INPID_InputControl='ScrewControl', ICS_ControlPage='PreRender', INP_Integer=true, INP_Default=119 },
  PR_Render = button('Render Range / Update Proxy...', 'render'),
  PR_Current = button('Render Current Frame', 'current'),
  PR_OpenFolder = button('Open Containing Folder', 'openfolder'),
 }
 local a=c:GetAttrs()
 parsed.Tools.PreRender.Inputs.PR_FirstFrame={__ctor='Input',Value=a.COMPN_RenderStart}
 parsed.Tools.PreRender.Inputs.PR_LastFrame={__ctor='Input',Value=a.COMPN_RenderEnd}
 assert(c:Paste(parsed), 'Could not paste PreRender settings')
end)
c:Unlock()
c:EndUndo(ok)
if not ok then error(err) end
