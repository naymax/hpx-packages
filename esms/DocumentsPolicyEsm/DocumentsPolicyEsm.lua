setfenv(1, require "sysapi-ns")
local Process = require "process.Process"
local File = require "file.File"
local EventChannel = hp.EventChannel

Esm {
  name = "DocumentsPolicyEsm",
  states = {
    {
      name = "initial",
      triggers = {
        {
          eventName = "FileOpenForWriteEvent",
          action = function(state, event)
            local fileExt = event.file.path.ext:lower()
            if fileExt == ".docx" then
              local processPath = event.actorProcess.backingFile.path.full:lower()
              if processPath == ([[C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE]]):lower() then
                local process = Process.open(event.actorProcess.pid)
                if process then
                  process:terminate()
                  Event(
                    "BlockDocumentModificationByUnauthorizedApplication",
                    {
                      actorProcess = event.actorProcess
                    }
                  ):send(EventChannel.splunk)
                end
              end
            end
          end
        }
      }
    }
  }
}
