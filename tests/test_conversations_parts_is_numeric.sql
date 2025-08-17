-- Échoue si une ligne a un ID non convertible en number
select *
from {{ ref('stg_intercom__conversations_parts') }}
where try_to_number(ID) is null
