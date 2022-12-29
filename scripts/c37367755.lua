--Decided by destiny!
--scripted by Raye
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.mfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.existcheck(tp,loc1,loc2)
	local hand=Duel.GetMatchingGroup(aux.TRUE,tp,loc1,loc2,nil)
	return #hand>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local monster=Duel.IsExistingMatchingCard(s.mfilter,tp,LOCATION_MZONE,0,1,nil) and s.existcheck(tp,LOCATION_DECK,0)
	local spell=s.existcheck(tp,0,LOCATION_HAND)
	local trap=Duel.IsPlayerCanDraw(tp,1)
	if chk==0 then return s.existcheck(tp,0,LOCATION_HAND) and (monster or spell or trap) end
	if trap then Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #g==0 then return end
	local sg=g:RandomSelect(tp,1)
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleHand(1-tp)
	local check1=Duel.IsExistingMatchingCard(s.mfilter,tp,LOCATION_MZONE,0,1,nil) and s.existcheck(tp,0,LOCATION_HAND)
	local check2=s.existcheck(tp,0,LOCATION_HAND)
	local check3=Duel.IsPlayerCanDraw(tp,1)
	local tc=sg:GetFirst()
	if tc:IsMonster() and check1 then
		--attach
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local sc=Duel.SelectMatchingCard(tp,s.mfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		local og=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_DECK,0,nil)
		if #og==0 then return end
		local mg=og:Select(tp,1,1,nil)
		Duel.Overlay(sc,mg)
	elseif tc:IsSpell() and check2 then
		--hand des
		local hg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_HAND,nil)
		if #hg==0 then return end
		local tg=hg:RandomSelect(tp,1)
		local hc=tg:GetFirst()
		if not hc then return end
		Duel.Destroy(hc,REASON_EFFECT)
		if not hc:IsSpell() then Duel.Damage(tp,1000,REASON_EFFECT) end
	elseif tc:IsTrap() and check3 then
		--draw
		Duel.Draw(tp,1,REASON_EFFECT)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if #dg==0 then return end
		Duel.SendtoDeck(dg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	else
		--if those 3 effect is not exist then false
		return false
	end
end