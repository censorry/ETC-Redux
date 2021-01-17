CATEGORY=PS.Categories.accessories;
ITEM={};

ITEM.Name='Статус "Игрок"';
ITEM.Model="models/pac/default.mdl";

ITEM.__index=ITEM;
ITEM.ID="usergroup_trusted";
ITEM.Category=CATEGORY.Name;
ITEM.Price=5000;
ITEM.AdminOnly=false;
ITEM.AllowedUserGroups={"user"};
ITEM.SingleUse=true;
ITEM.NoPreview=true;
ITEM.CanPlayerBuy=true;
ITEM.CanPlayerSell=false;
ITEM.CanPlayerEquip=false;
ITEM.CanPlayerHolster=false;
ITEM.OnBuy=function(ply)
	if ply:IsUserGroup("user") then
		--print("Установить группу trusted");
		RunConsoleCommand("ulx","adduserid",ply:SteamID(),"trusted");
	else
		--print("Вернуть ",self.Price," bits");
		ply:PS_GivePoints(self.Price);
		ply:ChatPrint('У Вас уже имеется статус игрока!');
	end;
end;
ITEM.OnSell=function()end;
ITEM.OnEquip=function()end;
ITEM.OnHolster=function()end;
ITEM.OnModify=function()end;
ITEM.ModifyClientsideModel=function(ITEM,ply,model,pos,ang)
	return model,pos,ang;
end;

if CATEGORY.BaseDefine then
	for k,v in pairs(CATEGORY.BaseDefine) do
		ITEM[k]=v;
	end;
end;

if ITEM.Model then
	util.PrecacheModel(ITEM.Model);
end;

PS.Items[ITEM.ID]=ITEM;

ITEM=nil;
CATEGORY=nil;