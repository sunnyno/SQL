CREATE OR REPLACE PROCEDURE write_log(dt  SP_LOG.datetime%TYPE, r SP_LOG.res%TYPE,
                                      msg SP_LOG.message%TYPE) IS
  BEGIN
    INSERT INTO SP_LOG (datetime, res, message)
    VALUES (dt, r, msg);
  END;