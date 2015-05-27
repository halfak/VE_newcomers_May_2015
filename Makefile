dbstore = --defaults-file=~/.my.research.cnf --host analytics-store.eqiad.wmnet -u research

datasets/pilot_users.tsv: sql/pilot_users.sql
	cat sql/pilot_users.sql | \
	mysql $(dbstore) > \
	datasets/pilot_users.tsv

datasets/pilot_user_metrics.tsv: datasets/pilot_users.tsv
	cat datasets/pilot_users.tsv | \
	mwmetrics new_users enwiki $(dbstore) > \
	datasets/pilot_user_metrics.tsv
