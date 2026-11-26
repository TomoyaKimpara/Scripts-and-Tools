-- FileCache 1.4.1 - named image sequences and current-frame rendering.
local c = comp or composition
assert(c, 'Open a Fusion composition first')
assert(fu:GetRegAttrs('Fuse.FileCacheGate'), 'Install FileCache and restart Resolve before creating this node')
local settings = [[{
 Tools = ordered() {
  FileCache = GroupOperator {
   Colors = { TileColor = { R = 0.584313725490196, G = 0.294117647058824, B = 0.803921568627451 } },
   Inputs = ordered() {
    MainInput1 = InstanceInput { SourceOp = "PR_Input", Source = "Input", Name = "Input" },
    Filename = InstanceInput { SourceOp = "PR_Saver", Source = "Clip", Name = "Filename", Page = "FileCache" },
    OutputFormat = InstanceInput { SourceOp = "PR_Saver", Source = "OutputFormat", Name = "Output Format", Page = "FileCache" },
   },
   Outputs = { MainOutput1 = InstanceOutput { SourceOp = "PR_Switch", Source = "Output", Name = "Output" } },
   Tools = ordered() {
    PR_Input = PipeRouter {},
    PR_Saver = Saver { PassThrough = true, Inputs = {
     OutputFormat = Input { Value = FuID { "OpenEXRFormat" } },
     Clip = Input { Value = Clip { Filename = "Temp:/FileCache_SetFilename.exr", FormatID = "OpenEXRFormat", Saving = true } },
    } },
    PR_Loader = Loader { Clips = { Clip {
     ID = "Clip1", Filename = "Scripts:Support/FileCache_placeholder.png", FormatID = "PNGFormat",
     StartFrame = -1, Length = 1, LengthSetManually = true, TrimIn = 0, TrimOut = 0,
     GlobalStart = 0, GlobalEnd = 0, ExtendFirst = 0, ExtendLast = 0, Loop = 1,
    } } },
    PR_Switch = Fuse.FileCacheGate { Inputs = {
     Live = Input { SourceOp = "PR_Input", Source = "Output" },
     Cache = Input { SourceOp = "PR_Loader", Source = "Output" },
    } },
   },
  },
 },
}]]
c:StartUndo('Create FileCache')
c:Lock()
local ok, err = pcall(function()
 local function button(label, action)
  return { LINKS_Name=label, LINKID_DataType='Number', INPID_InputControl='ButtonControl',
   ICS_ControlPage='FileCache', BTNCS_Execute="local f=assert(loadfile(comp:MapPath('Scripts:Support/FileCache_v13.lua'))); f()('"..action.."', tool, comp)" }
 end
 local parsed=assert(bmd.readstring(settings))
 local controls=assert(bmd.readstring([[{ Controls = ordered() {
  PR_UseCompRange = { LINKS_Name='Use Composition Range', LINKID_DataType='Number', INPID_InputControl='CheckboxControl', ICS_ControlPage='FileCache', INP_Default=1, CBC_TriState=false },
  PR_FirstFrame = { LINKS_Name='Start Frame', LINKID_DataType='Number', INPID_InputControl='ScrewControl', ICS_ControlPage='FileCache', INP_Integer=true, INP_Default=0 },
  PR_LastFrame = { LINKS_Name='End Frame', LINKID_DataType='Number', INPID_InputControl='ScrewControl', ICS_ControlPage='FileCache', INP_Integer=true, INP_Default=240 },
  PR_Render = {}, PR_Current = {}, PR_OpenFolder = {},
 } }]])).Controls
 controls.PR_Render=button('Render Range / Update Proxy...', 'render')
 controls.PR_Current=button('Render Current Frame', 'current')
 controls.PR_OpenFolder=button('Open Containing Folder', 'openfolder')
 parsed.Tools.FileCache.UserControls=controls
 assert(c:Paste(parsed), 'Could not paste FileCache settings')
end)
c:Unlock()
c:EndUndo(ok)
if not ok then error(err) end

