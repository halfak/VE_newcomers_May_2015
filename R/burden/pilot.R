source("loader/pilot_users.R")
source("loader/pilot_user_metrics.R")
source("loader/pilot_user_blocks.R")

users = load.pilot_users(reload=T)
metrics = load.pilot_user_metrics(reload=T)
blocks = load.pilot_user_blocks(reload=T)

block_stats = merge(users, blocks, by="user_id", all=T)[,
    list(
        blocked_for_damage = !is.na(type) & sum(type %in% c('spam', 'vandalism')) > 0,
        blocked = !is.na(type) & length(type) > 0
    ),
    user_id
]

user_block_metrics = merge(
    merge(users, metrics, by="user_id"),
    block_stats,
    by="user_id"
)

user_block_metrics[,
    list(
        blocked.k = sum(blocked),
        blocked.p = sum(blocked)/length(user_id),
        reverted.k = sum(day_reverted_main_revisions > 0),
        reverted.p = sum(day_reverted_main_revisions > 0)/length(user_id),
        blocked_for_damage.k = sum(blocked_for_damage),
        blocked_for_damage.p = sum(blocked_for_damage)/length(user_id),
        n = length(user_id)
    ),
    list(bucket, via_mobile)
]

user_block_metrics[,
    list(
        reverted.k = sum(day_reverted_main_revisions > 0),
        editing.k = sum(day_revisions > 0),
        main_editing.k = sum(day_main_revisions > 0)
    ),
    list(bucket, via_mobile)
]
