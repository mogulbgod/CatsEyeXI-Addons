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
addon.version   = '0.1';
addon.desc      = 'Custom for CatsEyeXI Private Server. Make Apururu stfu about DI battles that are going to happen.';


require('common');
local chat = require('chat');

local settings = {
    simplemsg = false, -- Change to true for a simplified 1 line message
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
* event: text_in
* desc : Event called when the addon is processing incoming text.
--]]
ashita.events.register('text_in', 'text_in_cb', function (e)

    local msg = e.message_modified;
    for i, v in ipairs(ApuSays) do
        local tNum = string.find(msg, v);
        if (msg:contains(v)) then
            if (settings.simplemsg == true and i <= 6) then
                Simplify(i);
            end

            e.blocked = true;
            return;
        end
    end

end);