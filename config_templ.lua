
-- template for a config file; to use, remove "_temlp" suffix from everything and
-- substite your settings
local config_templ = {}

-- from which interface scan should be performed
config_templ.WirelessInterface = ""

-- if your interface is configured to be in monitor mode by default, set it to false
config_templ.MonitorOptionIsNeeded = true

-- address of remote server, to which results of scan will be uploaded
config_templ.ServerAddress = ""

-- desired path for SSH key on local computer; recommended YOUR_USERNAME/.ssh/id_rsa
config_templ.PathToSSHKey = ""

-- if you are not root, leave it true; otherwise, change to false
config_templ.SudoIsNeeded = true

return config_templ