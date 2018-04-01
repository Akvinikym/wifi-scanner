
-- module with all features, related to network scanning
local scanner = {}

config = require 'config'


-- PRIVATE FEATURES

--TcpdumpCommand = ""
--if config.SudoIsNeeded then
--    TcpdumpCommand = string.format(
--        "sudo tcpdump -i %s -I -t -e | grep 'BSSID' | grep 'signal'", config.WirelessInterface)
--else
--    TcpdumpCommand = string.format(
--        "tcpdump -i %s -I -t -e | grep 'BSSID' | grep 'signal'", config.WirelessInterface)
--end

TcpdumpCommand = string.format("%s tcpdump -i %s %s -t -e | grep 'BSSID' | grep 'signal'", 
    config.SudoIsNeeded and "sudo" or "", config.WirelessInterface, config.MonitorOptionIsNeeded and "-I" or "")

local function parseTcpdumpString(tcpdumpString)
    timestamp = string.sub(tcpdumpString, 0, 10)
    signalPos = string.find(tcpdumpString, 'signal')
    signal = string.sub(tcpdumpString, signalPos - 7, signalPos - 5)
    macPos = string.find(tcpdumpString, 'BSSID:')
    mac = string.sub(tcpdumpString, macPos + 6, macPos + 22)
    return string.format("%s %s %s\n", timestamp, mac, signal)
end


-- PUBLIC FEATURES

-- scan for n seconds, writing the results into provided file, then terminate
function scanner.performScan(scanFilePath, desiredEntriesAmount)
    print("OK: starting scanning")
    scanFile = io.open(scanFilePath, 'w+')
    fileHandler = assert(io.popen(TcpdumpCommand, 'r'))

    currentEntriesAmount = 0
    while currentEntriesAmount < desiredEntriesAmount do
        print(currentEntriesAmount, desiredEntriesAmount)
        currentLine = fileHandler:read('*l')
        if currentLine then
            scanFile:write(parseTcpdumpString(currentLine))
            currentEntriesAmount = currentEntriesAmount + 1
        end
    end

    fileHandler:close()
    scanFile:close()
    print("OK: scan ended")
end

return scanner