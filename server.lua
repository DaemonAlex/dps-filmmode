-- dps-filmmode server: ace check and the auto ace lines. Nothing else lives here.

if Config.AutoAces then
    for _, group in ipairs(Config.AceGroups or {}) do
        ExecuteCommand(('add_ace group.%s %s allow'):format(group, Config.Ace))
    end
    lib.print.info(('film mode ace %s added for groups: %s'):format(Config.Ace, table.concat(Config.AceGroups or {}, ' ')))
end

lib.callback.register('dps-filmmode:server:allowed', function(source)
    return IsPlayerAceAllowed(source, Config.Ace) == true
end)
