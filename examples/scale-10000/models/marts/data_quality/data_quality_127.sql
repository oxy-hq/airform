select session_id, user_id, started_at, ended_at, duration_seconds
from {{ ref('stg_users_027') }}
