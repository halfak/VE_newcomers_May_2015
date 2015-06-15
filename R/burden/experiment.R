source("loader/experimental_users.R")
source("loader/experimental_user_metrics.R")
source("loader/experimental_user_blocks.R")

users = load.experimental_users(reload=T)
metrics = load.experimental_user_metrics(reload=T)
blocks = load.experimental_user_blocks(reload=T)

block_stats = merge(users, blocks, by="user_id", all=T, allow.cartesian=T)[,
    list(
        blocked_for_damage = sum(!is.na(type) & type %in% c('spam', 'vandalism')) > 0,
        blocked = sum(!is.na(type)) > 0,
        blocks = length(type)
    ),
    user_id
]

user_block_metrics = merge(
    merge(users, metrics, by="user_id"),
    block_stats,
    by="user_id"
)


with(
    user_block_metrics,
    wilcox.test(
        day_reverted_main_revisions[!via_mobile & bucket == "control"],
        day_reverted_main_revisions[!via_mobile & bucket == "experimental"]
    )
)
with(
    user_block_metrics,
    wilcox.test(
        week_reverted_main_revisions[!via_mobile & bucket == "control"],
        week_reverted_main_revisions[!via_mobile & bucket == "experimental"]
    )
)


wiki.table(
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
)
