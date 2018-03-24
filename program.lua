-- main program

ssh_conn = require "ssh_conn"
scanner = require "scanner"

ScanResultsFile = "scan.txt"
RemoteResultsDirectory = "~/"
DefaultEntriesAmount = 200

local function getScanFileName()
    return string.format("%s%i_scan.txt", RemoteResultsDirectory, os.time())
end

function main()
    ssh_conn.establishConnection()
    scanner.performScan(ScanResultsFile, DefaultEntriesAmount)
    ssh_conn.transferFile(ScanResultsFile, getScanFileName())
end

main()