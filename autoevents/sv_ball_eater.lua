if ball_eater_inited then return end;
ball_eater_inited=true;

local active;
local ball_eaters={};
local goal={};
local alerted={};
local pos_death={};

--

local SendNotify;
do
	local title=Color(0,255,255);
	local def=Color(200,200,200);
	SendNotify=function(ply,msg)
		ULib.tsayColor(ply,nil,title,"[Ball Eater] ",def,msg);
	end;
end;

--

local SetPlayerSize=function(ply,scale)
	ply:SetViewOffset(Vector(0,0,64*scale));
	ply:SetViewOffsetDucked(Vector(0,0,28*scale));
	ply:SetModelScale(scale,0);
end;

local ResetPlayerSize=function(ply)
	ply:SetViewOffset(Vector(0,0,64));
	ply:SetViewOffsetDucked(Vector(0,0,28));
	ply:SetModelScale(1,0);
end;

--

local Do_SendBall_SizeUpper,Do_SendBall_Normal;
do
	local sent_ball=scripted_ents.GetStored("sent_ball").t;
	do
		local score;
		Do_SendBall_SizeUpper=function()
			sent_ball.Use=function(self,activator)
				if goal[activator] then
					if alerted[activator] then
					else
						alerted[activator]=true;
						SendNotify(activator,"Ты уже наелся!");
					end;
				else
					self:Remove();
					--
					if activator:IsPlayer() then
						score=ball_eaters[activator]||0;
						score=score+0.01;
						ball_eaters[activator]=score;
						SetPlayerSize(activator,1+score);
						--
						score=100-score*100;
						if score<0 then
							goal[activator]=true;
							--
							pos_death[activator]=activator:GetPos();
							activator:Kill();
							--
							for ply in pairs(ball_eaters) do
								if IsValid(ply) then
									SendNotify(ply,activator:Nick().." наелся и спит.");
								end;
							end;
						else
							activator:SetHealth(score);
						end;
					end;
				end;
			end;
		end;
	end;

	Do_SendBall_Normal=function()
		sent_ball.Use=function(self,activator)
			self:Remove();
			if activator:IsPlayer() then
				local health=activator:Health();
				activator:SetHealth(health+5);
				activator:SendLua("achievements.EatBall()");
			end;
		end;
	end;
end;

--

local StopEvent;
do
	local score,winners,winners_str;
	StopEvent=function()
		winners={};
		--
		for ply in pairs(ball_eaters) do
			if IsValid(ply) then
				score=ball_eaters[ply];
				if score==0 then
				else
					table.insert(winners,{ply:Nick(),score/0.01});
				end;
				ResetPlayerSize(ply);
			end;
		end;
		--
		table.sort(winners,function(a,b)
			return a[2]>b[2];
		end);

		winners_str="Ивент окончен!\n\nУчастники:\n";
		for _,tbl in pairs(winners) do
			winners_str=winners_str..tbl[1].." - "..tbl[2].."\n";
		end;

		for ply in pairs(ball_eaters) do
			if IsValid(ply) then
				SendNotify(ply,winners_str);
			end;
		end;
		--
		ball_eaters={};
		goal={};
		alerted={};
		--
		for _,ent in pairs(ents.FindByClass("sent_ball")) do
			ent:Remove();
		end;
		--
		hook.Remove("PlayerSpawn","ball_eater");
		pos_death={};
	end;
end;

--

local allow_group={
	superadmin=true;
	eventer=true;
};

local allow_sid={
	["STEAM_0:1:72403652"]=true;--censor
	["STEAM_0:1:88222686"]=true;--willow
};

local ball_eater_toggle=function(ply)
	if allow_group[ply:GetUserGroup()]||allow_sid[ply:SteamID()] then
		if active then
			active=false;
			--
			StopEvent(ply);
			--
			Do_SendBall_Normal();
		else
			hook.Add("PlayerSpawn","ball_eater",function(ply)
				if pos_death[ply] then
					ResetPlayerSize(ply);
					ply:SetPos(pos_death[ply]);
					pos_death[ply]=nil;
				end;
			end);
			--
			Do_SendBall_SizeUpper();
			--
			ball_eaters[ply]=ball_eaters[ply]||0;
			active=true;
			--
			for _,loc_ply in pairs(Location.GetPlayersInLocation(ply:GetLocation())) do
				SendNotify(loc_ply,"Ивент начался!");
			end;
		end;
	else
		SendNotify(ply,"Тебе это недоступно!");
	end;
end;
concommand.Add("ball_eater_toggle",ball_eater_toggle);