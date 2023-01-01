--Vocaloid - Intense Voice of Miku
--scripted by Raye
Duel.LoadScript("raye-custom-functions.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x90f}
function s.rmfilter(c)
	return c:IsMonster() and c:IsAbleToRemove()
end
function s.spfilter(c,e,tp)
	local lr=c:GetLink()
	return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK,0,lr,e:GetHandler())
		and c:IsSetCard(0x90f) and c:IsLinkMonster() and Duel.GetLocationCountFromEx(tp,tp,nil,c) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false)
end
function s.tdfilter(c)
	return c:IsSetCard(0x90f) and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local clink=aux.CoLinkedGroupCount(g,tp)
	local eff1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) and Duel.GetLocationCountFromEx(tp)>0
	local eff2=Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_REMOVED,0,3,nil)
	local eff3=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return (eff1 and clink>=1 or eff2 and clink>=2 or eff3 and clink>=3) end
	if eff1 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
	if eff2 then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_REMOVED)
	end
	if eff3 then
		local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,nil)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local clink=aux.CoLinkedGroupCount(g,tp)
	local eff1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	local eff2=Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_REMOVED,0,3,nil)
	local eff3=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,nil)
	if eff1 and clink>=1 then
		if Duel.GetLocationCountFromEx(tp)<1 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)>0 then
			local lr=tc:GetLink()
			local sg=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_DECK,0,tc)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local tg=sg:Select(tp,lr,lr,nil)
			Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
		end
	end
	if eff2 and clink>=2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_REMOVED,0,3,3,nil)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		local handsucess=false
		if tc and tc:IsAbleToHand() then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ShuffleHand(tp)
			g:RemoveCard(tc)
			handsucess=true
		end
		if handsucess then Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) end
	end
	if eff3 and clink>=3 then
		local tg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,nil)
		if #tg==0 then return end
		Duel.SendtoDeck(tg,nil,2,REASON_EFFECT)
	end
end