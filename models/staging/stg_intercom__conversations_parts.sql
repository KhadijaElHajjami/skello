{{ config(materialized='table', schema='stg') }}

with raw as (
  select
    CONVERSATION_ID,
    CONVERSATION_CREATED_AT,
    CONVERSATION_UPDATED_AT,
    CREATED_AT,
    UPDATED_AT,
    NOTIFIED_AT,
    PART_GROUP,
    "TYPE",
    ID,
    AUTHOR,               -- il faut faire parsing
    _SDC_BATCHED_AT,
    _SDC_EXTRACTED_AT,
    _SDC_RECEIVED_AT,
    _SDC_SEQUENCE,
    _SDC_TABLE_VERSION
  from CONVERSATIONS_PARTS_TABLE
),

parsed as (
  select
    r.*,
    try_parse_json(r.AUTHOR) as author_json
  from raw r
),
-- on filtre uniquement les ID qui sont de type num.
cleaned as (
    select *
    from parsed
    where try_to_number(ID) is not null
)
select
  CONVERSATION_ID,
  CONVERSATION_CREATED_AT,
  CONVERSATION_UPDATED_AT,
  CREATED_AT,
  UPDATED_AT,
  NOTIFIED_AT,
  PART_GROUP,
  "TYPE",
  try_to_number(c.ID) as ID,
  _SDC_BATCHED_AT,
  _SDC_EXTRACTED_AT,
  _SDC_RECEIVED_AT,
  _SDC_SEQUENCE,
  _SDC_TABLE_VERSION,

  -- Parse AUTHOR -> author_id, author_type
  try_to_number(author_json:id::string)  as author_id,
  author_json:type::string               as author_type

from cleaned c
where author_type != 'bot'   --  exclure les bots
