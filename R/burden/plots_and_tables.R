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

print(
    with(
        user_block_metrics[via_mobile == 0,],
        wilcox.test(
            day_reverted_main_revisions[bucket == "control"],
            day_reverted_main_revisions[bucket == "experimental"]
        )
    )
)
print(
    with(
        user_block_metrics[via_mobile == 0,],
        wilcox.test(
            week_reverted_main_revisions[bucket == "control"],
            week_reverted_main_revisions[bucket == "experimental"]
        )
    )
)

bucket_metrics = user_block_metrics[via_mobile == 0,
    list(
        blocked.k = sum(blocked),
        blocked.p = sum(blocked)/length(user_id),
        blocked_for_damage.k = sum(blocked_for_damage),
        blocked_for_damage.p = sum(blocked_for_damage)/length(user_id),
        n = length(user_id)
    ),
    list(bucket)
]
wiki.table(bucket_metrics)

svg("burden/plots/block_rate.svg", height=5, width=7)
ggplot(
    with(
        bucket_metrics,
        rbind(
            data.table(
                reason = "any",
                bucket,
                p = blocked.p,
                k = blocked.k,
                se = sqrt(blocked.p*(1-blocked.p)/n)
            ),
            data.table(
                reason = "for damage",
                bucket,
                p = blocked_for_damage.p,
                k = blocked_for_damage.k,
                se = sqrt(blocked_for_damage.p*(1-blocked_for_damage.p)/n)
            )
        )
    ),
    aes(
        x = bucket,
        y = p,
        group = reason,
        linetype = reason
    )
) + 
theme_bw() +
geom_point() +
geom_errorbar(
    aes(
        ymin = p - se,
        ymax = p + se,
    ),
    width = 0.5
) +
scale_y_continuous("Blocked proportion")
dev.off()
