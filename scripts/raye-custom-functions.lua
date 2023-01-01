
--custom functions for "Vocaloid" monster that summoned Link Monster from EX
Vocaloid={}
function Vocaloid.EffectSpSummon(c)
	local e=Effect.CreateEffect(c)
	e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e:SetType(EFFECT_TYPE_IGNITION)
	e:SetRange(LOCATION_MZONE)
	e:SetCost(Vocaloid.ShuffleDeckCost)
	e:SetTarget(Vocaloid.Target)
	e:SetOperation(Vocaloid.Operation)
	c:RegisterEffect(e)
	return e
end
function Vocaloid.ShuffleDeckCost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function Vocaloid.RemoveCheckFilter(c)
	return c:IsMonster() and c:IsAbleToRemove()
end
function Vocaloid.SpFilter(c,e,tp)
	local lr=c:GetLink()
	return Duel.IsExistingMatchingCard(Vocaloid.RemoveCheckFilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,lr,e:GetHandler())
		and c:IsSetCard(0x90f) and c:IsLinkMonster() and Duel.GetLocationCountFromEx(tp,tp,nil,c) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false)
end
function Vocaloid.Target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Vocaloid.SpFilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if chk==0 then return #g>0 and Duel.GetLocationCountFromEx(tp)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE+LOCATION_GRAVE)
end
function Vocaloid.Operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCountFromEx(tp)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,Vocaloid.SpFilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)>0 then
			local lr=tc:GetLink()
			local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(Vocaloid.RemoveCheckFilter),tp,LOCATION_MZONE+LOCATION_GRAVE,0,tc)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local tg=sg:Select(tp,lr,lr,nil)
			Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
--group function for "GetMutualLinkedGroupCount"
function Auxiliary.CoLinkedGroupCount(group,int_player)
	local g=Duel.GetMatchingGroup(aux.TRUE,int_player,LOCATION_MZONE,0,nil)
	local clink=0
	for tc in aux.Next(g) do
		clink=clink|tc:GetMutualLinkedGroupCount()
	end
	return clink
end