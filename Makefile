dbstore = --defaults-file=~/.my.research.cnf --host analytics-store.eqiad.wmnet -u research

datasets/pilot_users.tsv: sql/pilot_users.sql
	cat sql/pilot_users.sql | \
	mysql $(dbstore) > \
	datasets/pilot_users.tsv

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

datasets/experimental_users.tsv: sql/experimental_users.sql
	cat sql/experimental_users.sql | \
	mysql $(dbstore) > \
	datasets/experimental_users.tsv

