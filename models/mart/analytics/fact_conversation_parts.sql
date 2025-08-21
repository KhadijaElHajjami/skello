-- grain : 1 ligne = 1 message (part) d'une conversation
with src as (
    select
        try_to_number(CONVERSATION_ID) as conversation_id,
        CREATED_AT                     as part_created_at,
        UPDATED_AT                     as part_updated_at,
        NOTIFIED_AT,
        PART_GROUP,
        "TYPE"                         as part_type,
        ID                             as part_id,      
        AUTHOR_ID,
        AUTHOR_TYPE,
        _SDC_SEQUENCE                  -- utilisé seulement pour ordonner
    from {{ ref('stg_intercom__conversations_parts') }}
),

ordered as (
    select
        conversation_id,
        part_id,
        part_created_at,
        part_updated_at,
        notified_at,
        part_group,
        part_type,
        author_id,
        author_type,
        row_number() over (
            partition by conversation_id
            order by part_created_at, _SDC_SEQUENCE
        ) as part_ordinal
    from src
)

select
    conversation_id,
    part_id,
    part_created_at,
    part_updated_at,
    notified_at,
    part_group,
    part_type,
    author_id,
    author_type,
    part_ordinal
from ordered
