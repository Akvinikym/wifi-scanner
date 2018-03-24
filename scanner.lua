
-- module with all features, related to network scanning
local scanner = {}


-- PRIVATE FEATURES

TcpdumpCommand = "sudo tcpdump -i en1 -I -t -e | grep 'BSSID' | grep 'signal'"

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
end

return scanner