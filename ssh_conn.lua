
-- module with all features related to ssh connection with a server
local ssh_conn = {}

config = require 'config'

-- PRIVATE FEATURES


local ServerAddress = config.ServerAddress
local PathToSSHKey = config.PathToSSHKey
local KeyPairGenCommand = "ssh-keygen -t rsa"
local CopyKeyToServerCommand = "ssh-copy-id"

local function getTransferFileCommand(localPath, remotePath)
    return string.format("scp -i %s %s %s:%s",
        PathToSSHKey, localPath, ServerAddress, remotePath)
end

-- returns string, which is to be executed to check, if a specific file exists on a remote server
local function getFileExistanceCheckerCommand(fileName)
    return string.format('ssh -i %s %s test -f "%s" && echo "yes" || echo "no";',
        PathToSSHKey, ServerAddress, fileName)
end

-- returns string, which is to be executed to remove file from a remote file
local function getRemoveFileCommand(fileName)
    return string.format('ssh -i %s %s "rm %s"', PathToSSHKey, ServerAddress, fileName)
end

-- check, if file with such path exists on the remote server
local function fileExistsOnRemote(remotePath)
    local command = getFileExistanceCheckerCommand(remotePath)
    local commandHandler = assert(io.popen(command, "r"))
    return commandHandler:read("*l") == "yes"
end

-- remove the file with such path from the remote server
local function removeFileFromRemote(remotePath)
    local command = getRemoveFileCommand(remotePath)
    os.execute(command)
end

-- check, if the connection with a remote server is up
local function serverConnectionIsUp()
    -- place a sample file and read it in order to check, if connection works; then remove
    local randomNum = math.random(1, 1000)
    local fileName = randomNum .. "sample.txt"
    local probeFile = io.open(fileName, "w+")
    probeFile:write(randomNum)
    probeFile:close()

    ssh_conn.transferFile(fileName, "~/" .. fileName)
    local connIsUp = fileExistsOnRemote("~/" .. fileName)
    if connIsUp then
        removeFileFromRemote("~/" .. fileName)
    end
    os.execute("rm " .. fileName)

    return connIsUp
end

-- check, if ssh key pair exists on a local machine
local function keyPairExists()
    local keyFile = io.open(PathToSSHKey, "r")
    if not keyFile then
        return false
    else
        io.close(keyFile)
        return true
    end
end

local function generateSSHKeyPair()
    print("OK: no existing key pair found; generating a new one; choose default file and empty passphrase (just click enter three times)")
    
    -- generate the key pair
    os.execute(KeyPairGenCommand)

    -- check again, if it was really generated
    if not keyPairExists then
        print("Error: cannot generate key pair")
        os.exit()
    end
end


-- PUBLIC FEATURES


-- establich connection with a remote server by exchanging key pair, if needed
function ssh_conn.establishConnection()
    -- check, if the key pair exists and generate-copy it, if not
    if not keyPairExists() then
        generateSSHKeyPair()
        -- copy our generated keys to the server
        print("OK: copying keys to the server")
        os.execute(CopyKeyToServerCommand .. " " .. ServerAddress)
    end

    -- check, if connection is up
    if not serverConnectionIsUp() then
        print("Error: server is down!")
        os.exit()
    end
end

-- transfer file to a remote server
function ssh_conn.transferFile(localPath, remotePath)
    os.execute(getTransferFileCommand(localPath, remotePath))
    return fileExistsOnRemote(remotePath)
end

return ssh_conn