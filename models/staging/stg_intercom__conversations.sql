{{ config(
    materialized='table',
    schema='stg',
    query_comment=''
) }}

-- 1) Source brute (uniquement colonnes existantes)
with raw as (
  select
    ID,
    CREATED_AT,
    UPDATED_AT,
    "TYPE",
    STATE,
    "OPEN",
    "READ",
    PRIORITY,
    WAITING_SINCE,
    SNOOZED_UNTIL,
    TAGS,
    _SDC_BATCHED_AT,
    _SDC_EXTRACTED_AT,
    _SDC_RECEIVED_AT,
    _SDC_SEQUENCE,
    _SDC_TABLE_VERSION
  from CONVERSATIONS_TABLE
),

-- 2) Parse uniquement TAGS (les colonnes ASSIGNEE / CONVERSATION_RATING n'existent pas ici)
parsed as (
  select
    r.*,
    try_parse_json(r.TAGS) as tags_json
  from raw r
),

-- 3) Agrégation des noms de tags
tags_agg as (
  select
    p.ID,
    listagg(f.value:name::string, ',') within group (order by f.index) as TAG_NAMES
  from parsed p,
       lateral flatten(input => p.tags_json) f
  group by p.ID
)

-- 4) Sélection finale
select
  p.ID,
  p.CREATED_AT,
  p.UPDATED_AT,
  p."TYPE",
  p.STATE,
  p."OPEN",
  p."READ",
  p.PRIORITY,
  p.WAITING_SINCE,
  p.SNOOZED_UNTIL,
  p._SDC_BATCHED_AT,
  p._SDC_EXTRACTED_AT,
  p._SDC_RECEIVED_AT,
  p._SDC_SEQUENCE,
  p._SDC_TABLE_VERSION,

  -- Colonnes issues de TAGS
  coalesce(t.TAG_NAMES, '') as TAG_NAMES,

  -- Colonnes attendues mais absentes dans la source -> NULL pour garder un schéma stable
  cast(null as number)         as ASSIGNEE_ID,
  cast(null as string)         as ASSIGNEE_TYPE,
  cast(null as timestamp_ntz)  as RATING_CREATED_AT,
  cast(null as number)         as RATING_SCORE,
  cast(null as string)         as RATING_REMARK,
  cast(null as number)         as teammate_id,
  cast(null as string)         as teammate_type

from parsed p
left join tags_agg t
  on t.ID = p.ID