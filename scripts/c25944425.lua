--Sacred Pearl
--scripted by Raye
local s,id=GetID()
function s.initial_effect(c)
	--self des
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EFFECT_SELF_DESTROY)
	e0:SetCondition(s.descon)
	c:RegisterEffect(e0)
	local e1=e0:Clone()
	e1:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e1)
	--mzone effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(id)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetValue(s.indval)
	c:RegisterEffect(e5)
	--szone effect
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(s.damcon)
	e6:SetOperation(s.damop)
	c:RegisterEffect(e6)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(6564620)
end
function s.descon(e)
	return not Duel.IsExistingMatchingCard(s.cfilter,0,LOCATION_MZONE,0,1,nil)
end
function s.indval(e,re,tp)
	return e:GetHandler():GetControler()~=tp
end
function s.filter(c,sp)
	return c:GetSummonPlayer()==sp
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,1-tp)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Damage(1-tp,100,REASON_EFFECT)
end