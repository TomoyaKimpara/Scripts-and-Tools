-- PreRender 1.3. Cache metadata stays inside the project; no sidecar files.
return function(action,g,c,options)
 local originalTime=c and c.CurrentTime
 local function locked(fn)
  c:Lock()
  local ok,r=pcall(fn)
  c:Unlock()
  assert(ok,r)
  return r
 end
 local function exists(path)
  local f=io.open(path,'rb'); if not f then return false end
  local n=f:seek('end'); f:close(); return n and n>0
 end
 local function run()
  assert(g and c,'Open a Fusion composition first')
  local nodes={}
  for _,t in pairs(g:GetChildrenList(false)) do
   nodes[t:GetAttrs().TOOLS_Name:gsub('_%d+$','')]=t
  end
  local input,saver,loader,switch=nodes.PR_Input,nodes.PR_Saver,nodes.PR_Loader,nodes.PR_Switch
  assert(input and saver and loader and switch,'PreRender internal nodes are missing')
  local T=fu.TIME_UNDEFINED or -2000000000
  local target=options and options.Filename or saver.Clip[T] or ''
  assert(type(target)=='string' and target~='','Set Filename in the Inspector first')
  assert(target~='Temp:/PreRender_SetFilename.exr', 'Set your output Filename in the Inspector first')
  target=c:MapPath(target):gsub('\\','/')
  local folder,leaf=target:match('^(.*)/([^/]+)$')
  assert(folder and folder~='' and leaf~='','Filename must include an existing destination folder')
  if action=='openfolder' then
   assert(type(bmd.openfileexternal)=='function','External folder opening is unavailable')
   bmd.openfileexternal(folder)
   return
  end
  assert(action=='render' or action=='current','Unknown action')
  assert(not g:GetAttrs().TOOLB_PassThrough,'Enable PreRender before updating its proxy')
  assert(input.Input:GetConnectedOutput(),'Connect an image to PreRender first')
  local format=tostring(options and options.Format or saver:GetInput('OutputFormat') or 'OpenEXRFormat')
  local reg=assert(fu:GetRegAttrs(format),'Unknown output format')
  assert(reg.REGB_MediaFormat_CanSaveImages and reg.REGB_MediaFormat_CanLoadImages,
   'Choose an image format Saver can write and Loader can read')
  assert(not reg.REGB_MediaFormat_CanSaveMulti,'Image sequences only; movies are not supported')
  local extension=assert(reg.REGST_MediaFormat_Extension and reg.REGST_MediaFormat_Extension[1],
   'This format does not declare an extension'):gsub('^%.','')
  local stem=leaf:gsub('%.[^%.]+$','')
  assert(stem~='' and not stem:find('[<>:"|?*]'),'Invalid filename')
  local prefix=folder..'/'..stem..'.'
  local function framepath(n) return prefix..string.format('%06d',n)..'.'..extension end
  local a=c:GetAttrs()
  local first,last
  if action=='current' then first,last=originalTime,originalTime
  else
   local d=options
   if not d and g:GetInput('PR_UseCompRange')~=nil then
    if g:GetInput('PR_UseCompRange')>0 then d={First=a.COMPN_RenderStart,Last=a.COMPN_RenderEnd}
    else d={First=g:GetInput('PR_FirstFrame'),Last=g:GetInput('PR_LastFrame')} end
   end
   d=d or c:AskUser('PreRender Range',{
    {'First','Slider',Name='First composition frame',Default=a.COMPN_RenderStart,Integer=true},
    {'Last','Slider',Name='Last composition frame',Default=a.COMPN_RenderEnd,Integer=true},
   })
   if not d then return end
   first,last=tonumber(d.First),tonumber(d.Last)
  end
  assert(first and last and first==math.floor(first) and last==math.floor(last)
   and first>=0 and last>=first,'Use non-negative integer composition frames')
  local old=g:GetData('PreRender.Cache')
  local cacheFirst,cacheLast=first,last
  if action=='current' and old and old.prefix==prefix and old.extension==extension
   and first>=old.first and first<=old.last then cacheFirst,cacheLast=old.first,old.last end
  local chosenClip=saver.Clip[T]
  local chosenFormat=saver:GetInput('OutputFormat')
  local oldMix=switch:GetInput('Mix')
  local ok,err=pcall(function()
   locked(function()
    saver.Input:ConnectTo(input.Output)
    saver.Clip[T]=framepath(first)
    saver.OutputFormat[T]=format
    saver:SetAttrs({TOOLB_PassThrough=false})
   end)
   local result=locked(function()
    return c:Render({Start=first,End=last,Wait=true,Tool=saver,HiQ=true,Proxy=1})
   end)
   assert(result~=false,'Render failed or cancelled (check the destination folder)')
   for i=cacheFirst,cacheLast do assert(exists(framepath(i)),'Missing/empty frame: '..i) end
   locked(function()
    loader.Clip[T]=''
    loader.Clip[T]=framepath(cacheFirst)
    loader.GlobalOut=cacheLast
    loader.GlobalIn=cacheFirst
    loader.ClipTimeStart=0
    loader.ClipTimeEnd=cacheLast-cacheFirst
    loader.HoldFirstFrame=0
    loader.HoldLastFrame=0
    loader.Loop=0
    local la=loader:GetAttrs()
    assert(la.TOOLNT_Clip_Start[1]==cacheFirst and la.TOOLNT_Clip_End[1]==cacheLast,
     'Loader global range mismatch')
    assert(la.TOOLIT_Clip_TrimIn[1]==0 and la.TOOLIT_Clip_TrimOut[1]==cacheLast-cacheFirst,
     'Loader trim mismatch')
   end)
   g:SetData('PreRender.Cache',{prefix=prefix,extension=extension,format=format,
    first=cacheFirst,last=cacheLast})
  end)
  locked(function()
   saver:SetAttrs({TOOLB_PassThrough=true})
   saver.Input:ConnectTo(nil)
   saver.Clip[T]=chosenClip
   if chosenFormat then saver.OutputFormat[T]=chosenFormat end
  end)
  if not ok then switch:SetInput('Mix',oldMix); error(err) end
  switch:SetInput('Mix',1)
  print('PreRender complete: '..framepath(first)..' ['..first..'..'..last..']')
 end
 local ok,err=pcall(run)
 if originalTime then c.CurrentTime=originalTime end
 if not ok then print('PreRender ERROR: '..tostring(err)); error(err) end
end
