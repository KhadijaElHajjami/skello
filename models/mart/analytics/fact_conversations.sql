-- grain : 1 ligne = 1 conversation
select
  ID                       as conversation_id,
  CREATED_AT               as created_at,
  UPDATED_AT               as updated_at,
  "TYPE"                   as type,
  STATE                    as state,
  "OPEN"                   as is_open,
  "READ"                   as is_read,
  PRIORITY                 as priority,
  WAITING_SINCE            as waiting_since,
  SNOOZED_UNTIL            as snoozed_until,
  ASSIGNEE_ID              as assignee_id,
  ASSIGNEE_TYPE            as assignee_type,
  RATING                   as conversation_rating,
  REMARK                   as remark,
  TEAMMATE_ID              as teammate_id,
  TEAMMATE_TYPE            as teammate_type,
  TAGS_CONCAT              as tags_concat
from {{ ref('stg_intercom__conversations') }}

