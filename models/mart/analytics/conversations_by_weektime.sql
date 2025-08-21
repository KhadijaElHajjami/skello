with first_user_message as (
  select
    conversation_id,
    min(part_created_at) as conversation_start_at
  from {{ ref('fact_conversation_parts') }}
  where author_type = 'user'
  group by 1
),
localized as (
  select
    conversation_id,
    -- Si tes timestamps sont en UTC, convertis en heure locale :
    convert_timezone('UTC','Europe/Paris', conversation_start_at) as local_start_at
  from first_user_message
),  -- <<< VIRGULE ICI

support_only as (
  select l.conversation_id, l.local_start_at
  from localized l
  join {{ ref('fact_conversations') }} c using (conversation_id)
  where c.assignee_id in (5217337, 5391224, 5440474, 5300290) 
)

select
  dayofweek(local_start_at)                 as dow_num,     -- 0=Dimanche
  dayname(local_start_at)                   as dow_name,    -- Lundi, Mardi, ...
  extract(hour from local_start_at)         as hour_of_day, -- 0..23
  count(*)                                  as conversations_opened
from support_only
group by 1,2,3
order by dow_num, hour_of_day
