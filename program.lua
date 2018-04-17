-- main program

ssh_conn = require "ssh_conn"
scanner = require "scanner"

-- some constants
ScanResultsFile = "scan.txt"
RemoteResultsDirectory = "~/"
EntriesAmount = 1000
IterationsAmount = 1

-- run modes, depending on program's arguments
WriteToFileMode = false
TransferToServerMode = false
ForeverMode = false

-- main section

local function getScanFileName()
    return string.format("%s%i_scan.txt", RemoteResultsDirectory, os.time())
end

local function showHelp()
    print([[

    Welcome to Wi-Fi Scanner Alpha318! This guide will help you to configure your program in a proper way.

    Firstly, set all attributes of 'config.lua' to the ones you want to use.

    Secondly, you can use the following command line arguments:

        -w      Write all program's output into some file, specified right after the -w argument

        -t      Transfer all gathered information to some remote server, which attributes are in config. 
                Program will firstly write results into default 'scan.txt' file, if another one was not 
                specified by previous command, then send it to server

        -n      Number of entries you want to get; default 1000

        -i      Number of scan iteration you want from the program; default 1

        -f      Run program with all specified arguments forever (you will have to interrupt it manually)

        -h      Show this help

    Example of usage:

            lua program.lua -w out.txt -t -n 100 -i 5

            Gather 100 entries, write them into local out.txt file and then tranfer it to the remote server;
            repeat 5 times
    ]])
end

local function parseProgramArguments()
    numberOfArguments = #arg
    for i = 1, numberOfArguments do

        if arg[i] == '-w' then
            WriteToFileMode = true
            i = i + 1
            if not arg[i] then
                print("Error: output file is not specified")
                os.exit()
            end
            ScanResultsFile = arg[i]
        elseif arg[i] == '-t' then
            TransferToServerMode = true
            WriteToFileMode = true
        elseif arg[i] == '-n' then
            i = i + 1
            if not arg[i] then
                print('Error: desired number of entries is not specified')
                os.exit()
            end
            EntriesAmount = tonumber(arg[i])
        elseif arg[i] == '-i' then
            i = i + 1
            if not arg[i] then
                print('Error: desired number of iterations is not specified')
                os.exit()
            end
            IterationsAmount = tonumber(arg[i])
        elseif arg[i] == '-h' then
            showHelp()
            os.exit()
        elseif arg[i] == '-f' then
            ForeverMode = true
        elseif arg[i] == ScanResultsFile or tonumber(arg[i]) == EntriesAmount or 
                tonumber(arg[i]) == IterationsAmount then
        else
            print("Error: unknown or incorrect command line arguments")
            os.exit()
        end

    end
end

function main()

    parseProgramArguments()

    currentIterations = 0
    while currentIterations < IterationsAmount do
        if TransferToServerMode then
            ssh_conn.establishConnection()
        end

        scanner.performScan(WriteToFileMode, ScanResultsFile, EntriesAmount)

        if TransferToServerMode then
            ssh_conn.transferFile(ScanResultsFile, getScanFileName())
        end

        if not ForeverMode then
            currentIterations = currentIterations + 1
        end
    end

end

main()