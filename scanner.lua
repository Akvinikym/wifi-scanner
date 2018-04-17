
-- module with all features, related to network scanning
local scanner = {}

config = require 'config'


-- PRIVATE FEATURES

TcpdumpCommand = string.format("%s tcpdump -i %s -I -t -e | grep 'SA' | grep 'signal'", 
    config.SudoIsNeeded and "sudo" or "", config.WirelessInterface)

local function parseTcpdumpString(tcpdumpString)
    timestamp = string.sub(tcpdumpString, 0, 10)
    signalPos = string.find(tcpdumpString, 'signal')
    signal = string.sub(tcpdumpString, signalPos - 7, signalPos - 5)
    macPos = string.find(tcpdumpString, 'SA:')
    mac = string.sub(tcpdumpString, macPos + 6, macPos + 20)
    return string.format("%s %s %s\n", timestamp, mac, signal)
end


-- PUBLIC FEATURES

-- scan for n entries, writing the results into provided file, then terminate
function scanner.performScan(writeToFileMode, scanFilePath, desiredEntriesAmount)
    print("OK: starting scanning")

    scanResults = assert(io.popen(TcpdumpCommand, 'r'))
    currentEntriesAmount = 0

    if writeToFileMode then
        scanFile = io.open(scanFilePath, 'w+')
        for i = 1, desiredEntriesAmount do
            print(currentEntriesAmount, desiredEntriesAmount)
            currentLine = scanResults:read('*l')
            if currentLine then
                scanFile:write(parseTcpdumpString(currentLine))
                currentEntriesAmount = currentEntriesAmount + 1
            end
        end
        scanFile:close()
    else
        for i = 1, desiredEntriesAmount do
            currentLine = scanResults:read('*l')
            if currentLine then
                print(parseTcpdumpString(currentLine))
                currentEntriesAmount = currentEntriesAmount + 1
            end
        end
    end

    scanResults:close()
    print("OK: scan ended")
end

return scanner