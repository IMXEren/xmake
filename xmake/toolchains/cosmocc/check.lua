--!A cross-toolchain build utility based on Lua
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Copyright (C) 2015-present, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        check.lua
--

-- imports
import("core.project.config")
import("lib.detect.find_path")
import("lib.detect.find_tool")
import("detect.sdks.find_cross_toolchain")

-- check the cross toolchain
function main(toolchain)

    -- get sdk directory
    local sdkdir = toolchain:sdkdir()
    local bindir = toolchain:bindir()

    -- find and locate sdk directory
    if not sdkdir then
        import("lib.detect.find_tool")
        local tool = find_tool("cosmocc", { paths = "$(env PATH)" })
        local sh = find_tool("sh") or find_tool("bash") or find_tool("zsh")
        local cosmocc
        if sh then
            local find
            if os.is_host("windows") then
                find = "where cosmocc || echo"
            else
                find = "command -v cosmocc || echo"
            end
            cosmocc, _ = os.iorunv(sh.program, { "-c", find })
            local first_line = string.gmatch(cosmocc, "[^\n]+")()
            if first_line then
                cosmocc = first_line:trim()
            end
        end

        if tool and path.basename(tool.program) == "cosmocc" then
            cosmocc = tool.program
        end
        if cosmocc then
            sdkdir = path.directory(path.directory(path.translate(cosmocc)))
        end
    end

    -- find cross toolchain from external envirnoment
    local cross_toolchain = find_cross_toolchain(sdkdir, {bindir = bindir})
    if not cross_toolchain then
        -- find it from packages
        for _, package in ipairs(toolchain:packages()) do
            local installdir = package:installdir()
            if installdir and os.isdir(installdir) then
                cross_toolchain = find_cross_toolchain(installdir)
                if cross_toolchain then
                    break
                end
            end
        end
    end
    if cross_toolchain then
        toolchain:config_set("cross", cross_toolchain.cross)
        toolchain:config_set("bindir", cross_toolchain.bindir)
        toolchain:config_set("sdkdir", cross_toolchain.sdkdir)
        toolchain:configs_save()
    else
        raise("cosmocc toolchain not found!")
    end
    return cross_toolchain
end
