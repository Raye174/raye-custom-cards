--Timeleap
--scripted by Raye
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--register
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
end
function s.egfilter(c,tp)
	return c:IsControler(tp)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(s.egfilter,nil,tp)
	if #g==0 then return end
	g:KeepAlive()
	--timeleap
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetLabelObject(g)
	e2:SetTarget(s.pgtg)
	e2:SetOperation(s.pgop)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e2)
end
function s.pgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject()
	if chk==0 then return g:IsExists(s.egfilter,1,nil,tp) end
	Duel.Hint(HINT_OPSELECTED,tp,e:GetDescription())
	Duel.SetTargetCard(g)
	Duel.SetChainLimit(s.chlimit)
end
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.presq(c,...)
	local args={...}
	local pseq=c:GetPreviousSequence()
	for _,v in ipairs(args) do
		if pseq==v then return true end
	end
	return false
end
function s.chk(tc)
	local seq=0
	if s.presq(tc,0) then seq=1+256 end
	if s.presq(tc,1) then seq=2+512 end
	if s.presq(tc,2) then seq=4+1024 end
	if s.presq(tc,3) then seq=8+2048 end
	if s.presq(tc,4) then seq=10+4096 end
	return seq
end
function s.pgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	for tc in aux.Next(g) do 
		--check for extra deck
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_BECOME_LINKED_ZONE)
		e1:SetValue(0xffffff)
		Duel.RegisterEffect(e1,tp)
		Duel.MoveToField(tc,tp,tp,tc:GetPreviousLocation(),tc:GetPreviousPosition(),true,s.chk(tc))
	end
end