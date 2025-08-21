with first_user_message as (
    select
        conversation_id,
        min(part_created_at) as conversation_start_at
    from {{ ref('fact_conversation_parts') }}
    where author_type = 'user'
    group by 1
),

first_agent_reply as (
    select
        conversation_id,
        min(part_created_at) as first_agent_reply_at
    from {{ ref('fact_conversation_parts') }}
    where author_type = 'admin'
    group by 1
),

delays as (
    select
        u.conversation_id,
        u.conversation_start_at,
        a.first_agent_reply_at,
        case
            when a.first_agent_reply_at is null then null
            else datediff('minute', u.conversation_start_at, a.first_agent_reply_at)
        end as first_response_minutes
    from first_user_message u
    left join first_agent_reply a
      on a.conversation_id = u.conversation_id
)

select
    conversation_id,
    conversation_start_at,
    first_agent_reply_at,
    first_response_minutes,
    case
        when first_response_minutes <= 5 then true
        else false
    end as answered_within_5min
from delays
