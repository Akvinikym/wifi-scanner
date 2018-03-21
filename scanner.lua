
-- module with all features, related to network scanning
local scanner = {}


-- PRIVATE FEATURES

TcpdumpCommand = "sudo tcpdump -i en1 -I -t -e | grep 'BSSID' | grep 'signal'"

local function parseTcpdumpString(tcpdumpString)
    -- can be rewritten as string.match()
    timestamp = string.sub(tcpdumpString, 0, 10)
    signalPos = string.find(tcpdumpString, 'signal')
    signal = string.sub(tcpdumpString, signalPos - 7, signalPos - 5)
    macPos = string.find(tcpdumpString, 'BSSID:')
    mac = string.sub(tcpdumpString, macPos + 6, macPos + 22)
    return string.format("%s %s %s\n", timestamp, mac, signal)
end


-- PUBLIC FEATURES

-- scan for n seconds, writing the results into provided file, then terminate
function scanner.performScan(scanFilePath, scanDuration)
    scanFile = io.open(scanFilePath, 'w+')
    fileHandler = assert(io.popen(TcpdumpCommand, 'r'))

    initialTime = os.clock()
    while (os.clock() - initialTime) < scanDuration do
        currentLine = fileHandler:read('*l')
        if currentLine then
            scanFile:write(parseTcpdumpString(currentLine))
        end
    end

    fileHandler:close()
    scanFile:close()
end

return scanner