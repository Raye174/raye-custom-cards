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
	g:KeepAlive()
	--timeleap
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
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
	g:Clear()
end
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.pgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	Duel.HintSelection(g)
	for tc in aux.Next(g) do 
		--starting from the left is box 1 and goes to the right which is box 5
		local j=0
		local szone=tc:IsLocation(LOCATION_SZONE)
		if tc:GetPreviousSequence()==0 then j=0x1 --box 1
			if szone then j=0x100 end
		end
		if tc:GetPreviousSequence()==1 then j=0x2 --box 2
			if szone then j=0x200 end
		end
		if tc:GetPreviousSequence()==2 then j=0x4 --box 3
			if szone then j=0x400 end
		end
		if tc:GetPreviousSequence()==3 then j=0x8 --box 4
			if szone then j=0x800 end
		end
		if tc:GetPreviousSequence()==4 then j=0x10 --box 5
			if szone then j=0x1000 end
		end
		--check for pendulum
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_BECOME_LINKED_ZONE)
		e1:SetValue(0xffffff)
		Duel.RegisterEffect(e1,tp)
		Duel.MoveToField(tc,tp,tp,tc:GetPreviousLocation(),tc:GetPreviousPosition(),true,j)
	end
end