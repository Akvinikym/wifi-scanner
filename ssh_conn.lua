
-- module with all features related to ssh connection with a server
local ssh_conn = {}


-- PRIVATE FEATURES

ServerAddress = "root@192.168.0.1"
PathToSSHKey = "~/.ssh/id_rsa.pub"
KeyPairGenCommand = "ssh-keygen -t rsa"
CopyKeyToServerCommand = "ssh-copy-id"
CopyFileToServerCommand = "scp"

local function serverConnectionIsUp()
    -- TODO: extend functionality, so it'll check conenction for a specific user

    response = assert(io.popen("ssh -q" .. ServerAddress .. "exit"))
    if response:read('*n') == 255 then
        response:close()
        return true
    else
        response:close()
        return false   
    end
end

local function keyPairExists()
    local keyFile = io.open(PathToSSHKey, "r")
    if (key == nil) then
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
        os.close()
    end
end

function ssh_conn.transferFile(localPath, remotePath)
    if not serverConnectionIsUp then
        print("Error: cannot transfer the file to remote server!")
        return false
    end
    
    os.execute("%s %s %s:%s",
        CopyFileToServerCommand, localPath, ServerAddress, remotePath)
    return true

    -- TODO: check, if file transfer is sucessfull
end

return ssh_conn