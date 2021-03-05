<CsoundSynthesizer>
<CsOptions>
-m35 -d
</CsOptions>
<CsInstruments>
sr =    48000
ksmps =   100
nchnls =    1

    lua_opdef   "luatest", {{
local ffi = require("ffi")
ffi.cdef[[
    int csoundGetKsmps(void *);
    double csoundGetSr(void *);
    struct luatest_t {
    };
]]

local luatest_ct = ffi.typeof('struct luatest_t')

function luatest_init(csound, opcode, carguments)
    print("In luatest_init.")
    return 0
end

function luatest_kontrol(csound, opcode, carguments)
    return 0
end
}}

instr 1
    lua_ikopcall "luatest"
endin

</CsInstruments>

<CsScore>
i 1 0 1
</CsScore>

</CsoundSynthesizer>
