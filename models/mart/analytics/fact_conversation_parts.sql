select
    try_to_number(CONVERSATION_ID) as conversation_id,
    CREATED_AT                     as part_created_at,
    UPDATED_AT                     as part_updated_at,
    NOTIFIED_AT                    as notified_at,
    PART_GROUP                     as part_group,
    "TYPE"                         as part_type,
    ID                             as part_id,
    AUTHOR_ID                      as author_id,
    AUTHOR_TYPE                    as author_type
from {{ ref('stg_intercom__conversations_parts') }}
