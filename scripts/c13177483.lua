--Vocaloid - Rin and Len Alter
--scripted by Raye
Duel.LoadScript("raye-custom-functions.lua")
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_CYBERSE),2,2)
	c:EnableReviveLimit()
	--disable
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
end
s.listed_series={0x90f}
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLinked()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local zone=Duel.SelectFieldZone(tp,1,0,LOCATION_ONFIELD,0)
	Duel.Hint(HINT_ZONE,tp,zone)
	Duel.Hint(HINT_ZONE,1-tp,zone>>16)
	e:SetLabel(zone)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetLabel()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(0,LOCATION_ONFIELD)
	e1:SetTarget(s.target)
	e1:SetLabel(zone)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.target(e,c)
	return applyseq(e,c)
end
function oppseq(e,hex,val)
	local zone=e:GetLabel()
	return math.log(zone>>16,hex)==val
end
function applyseq(e,c)
	local cseq=c:GetSequence()
	local cloc=c:GetLocation()
	--szone check
	if oppseq(e,SZONE_1,1) then
		return cseq==0 and cloc==LOCATION_SZONE
	elseif oppseq(e,SZONE_2,1) then
		return cseq==1 and cloc==LOCATION_SZONE
	elseif oppseq(e,SZONE_3,1) then
		return cseq==2 and cloc==LOCATION_SZONE
	elseif oppseq(e,SZONE_4,1) then
		return cseq==3 and cloc==LOCATION_SZONE
	elseif oppseq(e,SZONE_5,1) then
		return cseq==4 and cloc==LOCATION_SZONE
	--mzone check
	elseif oppseq(e,MZONE_2,0) then
		return cseq==0 and cloc==LOCATION_MZONE
	elseif oppseq(e,MZONE_2,1) then
		return cseq==1 and cloc==LOCATION_MZONE
	elseif oppseq(e,MZONE_3,1) then
		return cseq==2 and cloc==LOCATION_MZONE
	elseif oppseq(e,MZONE_4,1) then
		return cseq==3 and cloc==LOCATION_MZONE
	elseif oppseq(e,MZONE_5,1) then
		return cseq==4 and cloc==LOCATION_MZONE
	--extra zone
	elseif oppseq(e,EXTRA_MZONE_1+EXTRA_MZONE_2,1) then
		return cseq>4 and cloc==LOCATION_MZONE
	end
	return 0
end