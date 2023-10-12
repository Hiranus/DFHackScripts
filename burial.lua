-- Allows burial in unowned coffins.
-- Based on Putnam's work (https://gist.github.com/Putnam3145/e7031588f4d9b24b9dda)
local argparse = require('argparse')
local quickfort = reqscript('quickfort')

local cur_zlevel, citizens, pets = false, true, true
argparse.processArgsGetopt({...}, {
    {'z', 'cur-zlevel', handler=function() cur_zlevel = true end},
    {'c', 'citizens-only', handler=function() pets = false end},
    {'p', 'pets-only', handler=function() citizens = false end},
})
local tomb_blueprint = {
    mode = 'zone',
    pos = nil,
    -- Don't pass properties with default values to avoid 'unhandled property' warning
    data = ('T{%s %s}'):format(citizens and '' or 'citizens=false', pets and 'pets=true' or ''),
}

local tomb_count = 0
for _, coffin in pairs(df.global.world.buildings.other.COFFIN) do

    if cur_zlevel and not (coffin.z == df.global.window_z) then
        goto skip
    end
    for _, zone in pairs(coffin.relations) do
        if zone.type == df.civzone_type.Tomb then
            goto skip
        end
    end

    tomb_blueprint.pos = xyz2pos(coffin.x1, coffin.y1, coffin.z)
    quickfort.apply_blueprint(tomb_blueprint)
    tomb_count = tomb_count + 1

    ::skip::
end

print(('Created %s tombs.'):format(tomb_count))
