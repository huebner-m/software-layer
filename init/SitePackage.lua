require("strict")
local hook = require("Hook")

-- from https://stackoverflow.com/a/40195356
--- Check if a file or directory exists in this path
function exists(file)
	local ok, err, code = os.rename(file, file)
	if not ok then
		if code == 13 then
			-- Permission denied, but it exists
			return true
		end
	end
	return ok, err
end

local function visible_hook(modT)
	local frameStk  = require("FrameStk"):singleton()
	local mt        = frameStk:mt()
	local cudaDir = string.gsub(os.getenv('EESSI_SOFTWARE_PATH') or "", 'versions', 'host_injections')
	local cudaDirExists = exists(cudaDir)
	if not cudaDirExists then
		local haveGpu = mt:haveProperty(modT.sn,"arch","gpu")
		if haveGpu then
			modT.isVisible = false
		end
	end
end

local function cuda_load_hook(t)
	local frameStk  = require("FrameStk"):singleton()
	local simpleName = string.match(t.modFullName, "(.-)/")
	if string.match(simpleName, 'CUDA') ~= nil then
		local cudaDir = string.gsub(os.getenv('EESSI_SOFTWARE_PATH') or "", 'versions', 'host_injections')
		local cudaDirExists = exists(cudaDir)
		if not cudaDirExists then
			io.stderr:write("You requested to load ",simpleName,"\n")
			io.stderr:write("While the module file exists, the actual software is not shipped with EESSI.\n")
			io.stderr:write("In order to be able to use the CUDA module, please follow the instructions in the\n")
			io.stderr:write("gpu_support folder. Adding the CUDA software can be as easy as a simple:\n")
			io.stderr:write("./add_nvidia_gpu_support.sh\n")
			frameStk:__clear()
		end
	end
end

hook.register("load", cuda_load_hook)
hook.register("isVisibleHook", visible_hook)
