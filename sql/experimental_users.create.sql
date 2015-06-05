DROP TABLE IF EXISTS ve2_experimental_users;
CREATE TABLE ve2_experimental_users (
  user_id        INT,
  bucket         VARCHAR(50),
  registration   VARBINARY(14),
  via_mobile     BOOL,
  ve_enabled     BOOL,
  PRIMARY KEY(user_id)
);
