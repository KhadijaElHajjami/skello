{{ config(materialized='table', schema='stg') }}

with raw as (
  select distinct
    ID,
    CREATED_AT, UPDATED_AT, "TYPE", STATE, "OPEN", "READ", PRIORITY,
    WAITING_SINCE, SNOOZED_UNTIL,
    ASSIGNEE, CONVERSATION_RATING_RATING, TAGS,
    _SDC_BATCHED_AT, _SDC_EXTRACTED_AT, _SDC_RECEIVED_AT, _SDC_SEQUENCE, _SDC_TABLE_VERSION
  from CONVERSATIONS_TABLE
  --  élimine toutes les lignes où ID n'est pas un nombre
  where try_to_number(ID) is not null
),

parsed as (
  select
    try_to_number(ID) as numeric_id,
    r.*,
    try_parse_json(replace(ASSIGNEE,'""','"')) as assignee_json,
    try_parse_json(replace(CONVERSATION_RATING_RATING,'""','"')) as rating_json,
    try_parse_json(replace(TAGS,'""','"')) as tags_json
  from raw r
),

tags_agg as (
  select
    p.numeric_id,
    listagg(f.value:name::string, ', ') within group (order by f.index) as tags_concat
  from parsed p,
       lateral flatten(input => p.tags_json) f
  where f.value:name is not null
  group by p.numeric_id
)

select
  p.numeric_id as ID,
  p.CREATED_AT, p.UPDATED_AT, p."TYPE", p.STATE, p."OPEN", p."READ", p.PRIORITY,
  p.WAITING_SINCE, p.SNOOZED_UNTIL,
  p._SDC_BATCHED_AT, p._SDC_EXTRACTED_AT, p._SDC_RECEIVED_AT, p._SDC_SEQUENCE, p._SDC_TABLE_VERSION,

  try_to_number(p.assignee_json:id::string)          as assignee_id,
  p.assignee_json:type::string                       as assignee_type,

  try_to_number(p.rating_json:rating::string)        as rating,
  p.rating_json:remark::string                       as remark,
  try_to_number(p.rating_json:teammate:id::string)   as teammate_id,
  p.rating_json:teammate:type::string                as teammate_type,

  t.tags_concat
from parsed p
left join tags_agg t
  on t.numeric_id = p.numeric_id -- Left afin de garder les convers. sans tags
