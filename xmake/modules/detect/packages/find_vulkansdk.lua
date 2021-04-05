--!A cross-platform build utility based on Lua
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
-- @author      xq114
-- @file        find_vulkansdk.lua
--

-- imports
import("lib.detect.find_path")
import("lib.detect.find_library")

-- find vulkansdk
--
-- @param opt   the package options. e.g. see the options of find_package()
--
-- @return      see the return value of find_package()
--
function main(opt)

    -- init search paths
    local paths = {
        "$(env VK_SDK_PATH)",
        "$(env VULKAN_SDK)"
    }

    -- find library
    local result = {links = {}, linkdirs = {}, includedirs = {}}

    local libname = (opt.plat == "windows" and "vulkan-1" or "vulkan")
    local libsuffix = ((opt.plat == "windows" and opt.arch == "x86") and "lib32" or "lib")
    local binsuffix = ((opt.plat == "windows" and opt.arch == "x86") and "bin32" or "bin")
    local linkinfo = find_library(libname, paths, {suffixes = libsuffix})
    if linkinfo then
        result.sdkdir = path.directory(linkinfo.linkdir)
        result.bindir = path.join(result.sdkdir, binsuffix)
        table.insert(result.linkdirs, linkinfo.linkdir)
        table.insert(result.links, libname)
    else
        -- not found?
        return
    end

    -- find include
    table.insert(result.includedirs, find_path(path.join("vulkan", "vulkan.h"), paths, {suffixes = "include"}))

    -- ok
    return result
end
