--Ganyu, The Qixing Adeptus
--scripted by Raye
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
function s.spfilter(c,e,tp)
	return c:IsCode(16188701) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)>0 and not tc:IsForbidden() and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		--check the column of the card
		local seq=tc:GetSequence()
		if seq==0 then seq=1 elseif seq==1 then seq=2
		elseif seq==2 then seq=4 elseif seq==3 then seq=8
		elseif seq==4 then seq=16 end
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		if Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true,seq) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			tc:RegisterEffect(e1)
		end
	end
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,nil) end
	local filter=0
	for i=1,16 do
		filter=filter|i<<16
	end
	Duel.Hint(HINT_SELECTMSG,tp,e:GetDescription())
	local zone=Duel.SelectFieldZone(tp,1,0,LOCATION_ONFIELD,~filter)
	e:SetLabel(zone)
	Duel.Hint(HINT_ZONE,tp,zone)
	Duel.Hint(HINT_ZONE,1-tp,zone>>16)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.seqfilter(c,zone,tp)
	local cloc=c:GetLocation()
	local cseq=c:GetSequence()
	local faceup=c:IsFaceup()
	if math.log(zone>>16,2)==0 then
		return (cloc==LOCATION_MZONE and cseq==0 or cloc==LOCATION_SZONE and cseq==1) and faceup
	elseif math.log(zone>>16,2)==1 then
		return (cloc==LOCATION_MZONE and cseq==1 or cloc==LOCATION_SZONE
			and cseq==2 or cloc==LOCATION_SZONE and cseq==0) and faceup
	elseif math.log(zone>>16,4)==1 then
		return (cloc==LOCATION_MZONE and cseq==2 or cloc==LOCATION_SZONE
			and cseq==1 or cloc==LOCATION_SZONE and cseq==3) and faceup
	elseif math.log(zone>>16,8)==1 then
		return (cloc==LOCATION_MZONE and cseq==3 or cloc==LOCATION_SZONE
			and cseq==2 or cloc==LOCATION_SZONE and cseq==4) and faceup
	elseif math.log(zone>>16,16)==1 then
		return (cloc==LOCATION_MZONE and cseq==4 or cloc==LOCATION_SZONE and cseq==3) and faceup
	end
	return (cloc and cseq) and not c:IsDisabled()
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=e:GetLabel()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,#g,nil)
	if #tg==0 then return end
	local ct=Duel.SendtoGrave(tg,REASON_EFFECT)
	if ct>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local dg=Duel.SelectMatchingCard(tp,s.seqfilter,tp,0,LOCATION_ONFIELD,ct,ct,nil,zone,tp)
		for tc in aux.Next(dg) do
			if tc:IsFaceup() and not tc:IsDisabled() and tc:IsControler(1-tp) then
				Duel.NegateRelatedChain(tc,RESET_TURN_SET)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e2)
			end
		end
	end
end