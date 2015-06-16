dbstore = --defaults-file=~/.my.research.cnf --host analytics-store.eqiad.wmnet -u research

################################### Experiment #################################
datasets/experimental_users.tsv: sql/experimental_users.sql
	cat sql/experimental_users.sql | \
	mysql $(dbstore) > \
	datasets/experimental_users.tsv

datasets/experimental_users.loaded: \
		datasets/experimental_users.tsv \
		sql/experimental_users.create.sql
	cat sql/experimental_users.create.sql | \
	mysql $(dbstore) staging && \
	ln -sf experimental_users.tsv datasets/ve2_experimental_users && \
	mysqlimport $(dbstore) --local --ignore-lines=1 staging datasets/ve2_experimental_users; \
	rm -f experimental_users.tsv datasets/ve2_experimental_users; \
	mysql $(dbstore) -e "SELECT NOW(), COUNT(*) FROM staging.ve2_experimental_users" > \
	datasets/experimental_users.loaded

datasets/experimental_user_metrics.tsv: datasets/experimental_users.tsv
	cat datasets/experimental_users.tsv | \
	mwmetrics new_users enwiki $(dbstore) > \
	datasets/experimental_user_metrics.tsv

datasets/experimental_user_blocks.tsv: \
		datasets/experimental_users.loaded \
		sql/experimental_user_blocks.sql
	cat sql/experimental_user_blocks.sql | \
	mysql $(dbstore) > \
	datasets/experimental_user_blocks.tsv

datasets/experimental_user_editing_sessions.tsv: \
		datasets/experimental_users.loaded \
		sql/experimental_user_editing_sessions.sql
	cat sql/experimental_user_editing_sessions.sql | \
	mysql $(dbstore) > \
	datasets/experimental_user_editing_sessions.tsv

datasets/experimental_users.tsv: sql/experimental_users.sql
	cat sql/experimental_users.sql | \
	mysql $(dbstore) > \
	datasets/experimental_users.tsv

datasets/experimental_user_revision_stats.tsv: \
		datasets/experimental_users.loaded \
		sql/experimental_user_revision_stats.sql
	cat sql/experimental_user_revision_stats.sql | \
	mysql $(dbstore) > \
	datasets/experimental_user_revision_stats.tsv

############################ Pilot #############################################
datasets/pilot_users.loaded: \
		datasets/pilot_users.tsv \
		sql/pilot_users.create.sql
	cat sql/pilot_users.create.sql | \
	mysql $(dbstore) staging && \
	ln -sf pilot_users.tsv datasets/ve2_pilot_users && \
	mysqlimport $(dbstore) --local --ignore-lines=1 staging datasets/ve2_pilot_users; \
	rm -f pilot_users.tsv datasets/ve2_pilot_users; \
	mysql $(dbstore) -e "SELECT NOW(), COUNT(*) FROM staging.ve2_pilot_users" > \
	datasets/pilot_users.loaded

datasets/pilot_user_metrics.tsv: datasets/pilot_users.tsv
	cat datasets/pilot_users.tsv | \
	mwmetrics new_users enwiki $(dbstore) > \
	datasets/pilot_user_metrics.tsv

datasets/pilot_user_blocks.tsv: \
		datasets/pilot_users.loaded \
		sql/pilot_user_blocks.sql
	cat sql/pilot_user_blocks.sql | \
	mysql $(dbstore) > \
	datasets/pilot_user_blocks.tsv

datasets/pilot_user_editing_sessions.tsv: \
		datasets/pilot_users.loaded \
		sql/pilot_user_editing_sessions.sql
	cat sql/pilot_user_editing_sessions.sql | \
	mysql $(dbstore) > \
	datasets/pilot_user_editing_sessions.tsv
