-- CSAT global (par défaut: satisfaits => rating >= 4)
select
  count_if(conversation_rating is not null)                       as rated_conversations,
  count_if(conversation_rating >= 4)                              as satisfied_conversations,
  case
    when count_if(conversation_rating is not null) = 0 then null
    else count_if(conversation_rating >= 4) * 100.0 / count_if(conversation_rating is not null)
  end                                                as csat_pct
from {{ ref('fact_conversations') }}
