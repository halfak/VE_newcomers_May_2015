source("loader/pilot_users.R")
source("loader/pilot_user_metrics.R")
source("loader/pilot_user_blocks.R")

users = load.pilot_users(reload=T)
metrics = load.pilot_user_metrics(reload=T)
blocks = load.pilot_user_metrics(reload=T)

block_stats = blocks[,
    list(
        blocked_for_damage = sum(type %in% list('spam', 'vandalism')) > 0,
        blocked = length(type) > 0
    )
    user_id,
]
