addon.name      = 'CurePlease_Addon';
addon.author    = 'Thorny';
addon.version   = '1.0';
addon.desc      = 'Allows the CurePlease program to better interface with FFXI.';
addon.link      = 'https://ashitaxi.com/';

require('common');
local chat = require('chat');
local socket = require('socket');
local sender = socket.udp();
local ip = '127.0.0.1';
local port = 19769;

local function SocketSend(data)
    sender:sendto(data, ip, port);
end

local function HandleBuffUpdate(e)
    local partyBuffTable = {};
    for i = 0,4 do
        local memberOffset = 0x04 + (0x30 * i) + 1;
        local memberIndex = struct.unpack('L', e.data, memberOffset + 4);
        if memberIndex > 0 then
            local buffs = {};
            local empty = false;
            for j = 0,31 do
                if empty then
                    buffs[j + 1] = -1;
                else
                    local highBits = bit.lshift(ashita.bits.unpack_be(e.data_raw, memberOffset + 7, j * 2, 2), 8);
                    local lowBits = struct.unpack('B', e.data, memberOffset + 0x10 + j);
                    local buff = highBits + lowBits;
                    if (buff == 255) then
                        buffs[j + 1] = -1;
                        empty = true;
                    else
                        buffs[j + 1] = buff;
                    end
                end
            end
            partyBuffTable[memberIndex] = buffs;
        end
    end

    for index,buffs in pairs(partyBuffTable) do
        local charName = AshitaCore:GetMemoryManager():GetEntity():GetName(index);
        if (type(charName) == 'string') and (string.len(charName) > 2) then
            local outString = 'CUREPLEASE_buffs_' .. charName .. '_';
            for buffIndex,buff in ipairs(buffs) do
                if buffIndex == 1 then
                    outString = outString .. buff;
                else
                    outString = outString .. ',' .. buff;
                end
            end
            SocketSend(outString);
        end
    end
end

ashita.events.register('packet_in', 'packet_in_cb', function (e)
    -- Packet: Action
    if (e.id == 0x0028) then
        local actor = struct.unpack('L', e.data_modified, 0x05 + 1);
        if actor == AshitaCore:GetMemoryManager():GetParty():GetMemberServerId(0) then
            local category = ashita.bits.unpack_be(e.data_raw, 0, 82, 4);
            if category == 4 then
               SocketSend('CUREPLEASE_casting_finished');
            elseif category == 8 then
                local param = ashita.bits.unpack_be(e.data_raw, 0, 86, 16);
                if param == 28787 then
                  SocketSend('CUREPLEASE_casting_interrupted');
                elseif param == 24931 then
                    SocketSend('CUREPLEASE_casting_blocked');
                end
            end
        end
    elseif (e.id == 0x76) then
        HandleBuffUpdate(e);
    end
end);

ashita.events.register('command', 'cb_HandleCommand', function (e)
    local args = e.command:args();
    if (#args == 0) or (string.lower(args[1]) ~= '/cpaddon') then
        return;
    end
    e.blocked = true;

    if (#args >= 4 and args[2] == 'settings') then
        ip = args[3];
        port = args[4];
        print(chat.header('CurePlease') .. chat.message('Network settings updated.  IP:') .. chat.color1(2, ip) .. chat.message(' Port:') .. chat.color1(2, port));
        SocketSend('CUREPLEASE_confirmed');
    elseif (#args == 2 and args[2] == 'check') then
        print(chat.header('CurePlease') .. chat.message('IP:') .. chat.color1(2, ip) .. chat.message(' Port:') .. chat.color1(2, port));
    elseif args[2] == "verify" then
        print(chat.header('CurePlease') .. chat.message('Sending verify packet.  IP:') .. chat.color1(2, ip) .. chat.message(' Port:') .. chat.color1(2, port));
        SocketSend('CUREPLEASE_confirmed');
    elseif args[2] == "cmd" then
        SocketSend(string.format('CUREPLEASE_command_%s', string.lower(args[3])));
    end
end); 