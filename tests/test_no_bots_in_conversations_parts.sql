-- Test : vérifier qu'il n'y a aucun message avec author_type = 'bot'
select *
from {{ ref('stg_intercom__conversations_parts') }}
where author_type = 'bot'
