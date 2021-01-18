print("net_luarun cl init");
--
local github_root_url="https://api.github.com/repos/censorry/ETC-Redux/contents/net_luarun";
local github_scripts_updater=function()
	http.Fetch(github_root_url,function(data,_,_,code)
		if code==200 then
			PrintTable(util.JSONToTable(data));
		else
			print("GitHub HTTP code "..code);
		end;
	end,function(err)
		print("GitHub HTTP err "..err);
	end);
end;
github_scripts_updater();