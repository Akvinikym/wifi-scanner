-- main program

ssh_conn = require "ssh_conn"
scanner = require "scanner"

ScanResultsFile = "scan.txt"
RemoteResultsDirectory = "~/"
DefaultEntriesAmount = 1000
NumberOfScans = 5

local function getScanFileName()
    return string.format("%s%i_scan.txt", RemoteResultsDirectory, os.time())
end

function main()
    ssh_conn.establishConnection()
    for i = 0, NumberOfScans do
        scanner.performScan(ScanResultsFile, DefaultEntriesAmount)
        ssh_conn.transferFile(ScanResultsFile, getScanFileName())
    end
end

main()