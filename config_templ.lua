
-- template for a config file; to use, remove "_temlp" suffix from everything and
-- substite your settings
local config_templ = {}

-- from which interface scan should be performed
config_templ.WirelessInterface = ""

-- address of remote server, to which results of scan will be uploaded
config_templ.ServerAddress = ""

-- desired path for SSH key on local computer; recommended YOUR_USERNAME/.ssh/id_rsa
config_templ.PathToSSHKey = ""

-- if you are not root, leave it true; otherwise, change to false
config_templ.SudoIsNeeded = true

return config_templ