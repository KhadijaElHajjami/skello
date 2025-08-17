select *
from {{ ref('stg_intercom__conversations') }}
where try_to_number(ID) is null
