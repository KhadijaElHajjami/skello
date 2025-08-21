select
  try_to_number(assignee_id) as agent_id,
  assignee_name  as agent_name,
  is_support_team,
from {{ ref('support_team') }}
