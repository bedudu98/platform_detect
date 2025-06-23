-- Function to detect OS architecture
function get_os_architecture()
  local strOsArchitecture

  if io.popen == nil then
    print('Unable to detect the OS architecture: io.popen is not available.')
  else
    local tFile, strError = io.popen('uname -m')
    if tFile == nil then
      print(string.format('Failed to get the OS architecture with "uname -m": %s', strError))
    else
      local strArch = tFile:read('*l')
      tFile:close()
      if strArch ~= nil then
        if strArch == 'x86_64' then
          strOsArchitecture = 'x86_64'
        elseif strArch == 'aarch64' then
          strOsArchitecture = 'arm64'
        elseif strArch:match('arm') then
          strOsArchitecture = 'arm'
        elseif strArch:match('riscv64') then
          strOsArchitecture = 'riscv64'
        elseif strArch:match('i%d86') then
          strOsArchitecture = 'x86'
        else
          strOsArchitecture = strArch
        end
      end
    end
  end

  return strOsArchitecture
end

function __linux_get_os_architecture_getconf()
  local strOsArchitecture

  if io.popen==nil then
    self.tLog.info('Unable to detect the OS architecture: io.popen is not available.')
    return nil
  end

  -- Step 1: Check OS bitness
  local tFile, strError = io.popen('getconf LONG_BIT')
  if tFile==nil then
    self.tLog.info('Failed to get the OS architecture with "getconf": %s', strError)
    return nil
  end
  local strOutput = tFile:read('*a')
  tFile:close()
  local strValue = string.match(strOutput, '^%s*(%d+)%s*$')
  if strValue==nil then
    self.tLog.info('Invalid output from "getconf": "%s"', strOutput)
    return nil
  end
  print ("getconf LONG_BIT output: " .. strValue)

  -- Step 2: Use uname -m for detailed architecture
  local tUname, strUnameError = io.popen('uname -m')
  
  if tUname==nil then
    self.tLog.info('Failed to get the architecture with "uname -m": %s', strUnameError)
    return nil
  end
  local strArch = tUname:read('*l')
  tUname:close()

  -- Normalize architectures
  if strValue == '64' then
    if strArch == 'x86_64' then
      strOsArchitecture = 'x86_64'
    elseif strArch == 'aarch64' then
      strOsArchitecture = 'arm64'
    elseif strArch == 'riscv64' then
      strOsArchitecture = 'riscv64'
    else
      strOsArchitecture = strArch
    end
  elseif strValue == '32' then
    if strArch:match('i%d86') then
      strOsArchitecture = 'x86'
    elseif strArch:match('arm') then
      strOsArchitecture = 'arm'
    else
      strOsArchitecture = strArch
    end
  else
    self.tLog.info('Unknown bit size from "getconf": "%s"', strOutput)
    strOsArchitecture = strArch
  end
  print("[Debug] OS architecture: " .. strOsArchitecture)
  return strOsArchitecture
end

-- Main program
local arch = get_os_architecture()
local os = __linux_get_os_architecture_getconf()
if arch then
  print("Detected architecture: " .. arch)
else
  print("Could not detect architecture.")
end

if os then
  print("Detected os architecture: " .. os)
else
  print("Could not detect os architecture.")
end