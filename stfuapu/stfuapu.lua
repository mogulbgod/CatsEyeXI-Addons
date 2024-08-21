--[[
* STFUApu is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* STFUApu is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Ashita.  If not, see <https://www.gnu.org/licenses/>.
--]]

addon.name      = 'stfuapu';
addon.author    = 'mogul';
addon.version   = '0.2';
addon.desc      = 'Custom for CatsEyeXI Private Server. Make Apururu stfu about DI battles that are going to happen.';


require('common');
local chat = require('chat');

local settings = {
    simplemsg = false,
    lastmsg = '';
};

local ispaused = false;

local ApuSays = T{
    'Oh dear, one of our members-wembers in Ceizak Battlegrounds says that Colkhab could appear anytime in the next 5 minutes.',
    'Oh dear, one of our members-wembers in Morimar Basalt Fields says that Achuka could appear anytime in the next 5 minutes.',
    'Oh dear, one of our members-wembers in Yorcia Weald says that Yumcax could appear anytime in the next 5 minutes.',
    'Oh dear, one of our members-wembers in Marjami Ravine says that Hurkan could appear anytime in the next 5 minutes.',
    'Oh dear, one of our members-wembers in Kamihr Drifts says that Kumhau could appear anytime in the next 5 minutes.',
    'Oh dear, one of our members-wembers in Foret de Hennetiel says that Tchakka could appear anytime in the next 5 minutes.',
    'Looks like our forces-warses are gathering for domain invasion!',
    'Would you please go and see if she\'s alrightaru?',
};

local SimpleApuSays = T{
    'Colkhab @ [Ceizak Battlegrounds]',
    'Achuka @ [Morimar Basalt Fields]',
    'Yumcax @ [Yorcia Weald]',
    'Hurkan @ [Marjami Ravine]',
    'Kumhau @ [Kamihr Drifts]',
    'Tchakka @ [Foret de Hennetiel]',
};

function Simplify(index)
    print(chat.header(addon.name):append(SimpleApuSays[index]));
end

--[[
* desc : Checks to see the current state of scanning (paused or unpaused)
--]]
function CheckPaused()
    local pausednow = '';
    if ispaused == true then
        pausednow = 'PAUSED';
    elseif ispaused == false then
        pausednow = 'UNPAUSED';
    end
    print(chat.header(addon.name):append(chat.message('STFUApu is currently: ' .. chat.success(pausednow))));
end

--[[
* desc : Prints out the commands list when there is an error with commands or 'help' is used
--]]
function PrintHelpCommands(isError)
    local cmds = T{
        {'/stfuapu or /apu', 'The two command triggers, you can use either. Will display if addon is paused/unpaused.'},
        {'/stfuapu pause/unpause or off/on', 'Will pause the blocking of Apu\'s messages.'},
        {'/stfuapu last', 'Will print the last detailed Apu messaged received but simplified.'},
        {'/stfuapu simple on/off', 'Turns on/off simple reporting of Apu\'s messages. No on/off returns the current setting.'},
        {'/stfuapu help', 'Shows this command list.'},
    };

    if (isError) then
        print(chat.header(addon.name):append(chat.error('Invalid command syntax for command: ')):append(chat.success('/' .. addon.name)));
    else
        print(chat.header(addon.name):append(chat.message('Available commands:')));
    end

    cmds:ieach(function (v)
        print(chat.header(addon.name):append(chat.error('Usage: ')):append(chat.message(v[1]):append(' - ')):append(chat.color1(6, v[2])));
    end);

end

--[[
* event: text_in
* desc : Event called when the addon is processing incoming text.
--]]
ashita.events.register('text_in', 'text_in_cb', function (e)

    if (ispaused == true) then --If paused (true) just jump out of this
        return;
    end
    local msg = e.message_modified;
    for i, v in ipairs(ApuSays) do
        local tNum = string.find(msg, v);
        if (msg:contains(v)) then
            if (settings.simplemsg == true and i <= 6) then
                Simplify(i);
            end
            if (i <= 6) then --We write the last message that gives detail to a variable
                settings.lastmsg = SimpleApuSays[i]; --Write the last detailed message as a simplified message
            end
            e.blocked = true;
            return;
        end
    end

end);


--[[
* event: command
* desc : Event called when the addon is processing a command.
--]]
ashita.events.register('command', 'command_cb', function (e)

    local args = e.command:args();
    if (#args == 0 or not args[1]:any('/stfuapu', '/apu')) then
        return;
    end

    -- Block all related commands..
    e.blocked = true;

    -- Handle: /stfuapu or /apu
    if (#args == 1) then
        CheckPaused(); --Will print if paused or not if no command is given
        return;
    elseif (#args == 2) then
        if (args[2]:any('pause', 'off')) then
            if (ispaused == true) then --Check if already paused and if it is tell the user
                print(chat.header(addon.name):append(chat.message('STFUApu is already ' .. chat.success('PAUSED'))));
                return;
            end
            ispaused = true;
            CheckPaused();
        elseif (args[2]:any('unpause', 'on')) then
            if (ispaused == false) then --Check if already unpaused and if it is tell the user
                print(chat.header(addon.name):append(chat.message('STFUApu is already ' .. chat.success('UNPAUSED'))));
                return;
            end
            ispaused = false;
            CheckPaused();
        elseif (args[2]:any('last')) then
            if not (settings.lastmsg == '') then
                print(chat.header(addon.name):append(chat.message('Last message (simplified): ' .. chat.success(settings.lastmsg))));
            else
                print(chat.header(addon.name):append(chat.message('There is no current last message from Apururu.')));
            end
        elseif (args[2]:any('simple')) then
            if (settings.simplemsg == true) then
                print(chat.header(addon.name):append(chat.message('STFUApu Simple Messages are set to: ' .. chat.success('ACTIVE'))));
            elseif (settings.simplemsg == false) then
                print(chat.header(addon.name):append(chat.message('STFUApu Simple Messages are set to: ' .. chat.success('INACTIVE'))));
            end
        elseif (args[2] == 'help') then
            PrintHelpCommands();
        else
            PrintHelpCommands(true);
        end
    elseif (#args >= 3) then
        if (args[2]:any('simple')) then
            if (args[3]:any('on')) then
                if (settings.simplemsg == true) then
                    print(chat.header(addon.name):append(chat.message('STFUApu Simple Messages are already ' .. chat.success('ACTIVE'))));
                    return;
                end
                settings.simplemsg = true;
                print(chat.header(addon.name):append(chat.message('STFUApu Simple Messages are set to: ' .. chat.success('ACTIVE'))));
            elseif (args[3]:any('off')) then
                if (settings.simplemsg == false) then
                    print(chat.header(addon.name):append(chat.message('STFUApu Simple Messages are already ' .. chat.success('INACTIVE'))));
                    return;
                end
                settings.simplemsg = false;
                print(chat.header(addon.name):append(chat.message('STFUApu Simple Messages are set to: ' .. chat.success('INACTIVE'))));
            else
                PrintHelpCommands(true);
            end
        end
    end
end);