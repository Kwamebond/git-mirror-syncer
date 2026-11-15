# Code and comment style

Write comments for non-obvious behavior, especially failure cases and Git safety constraints. Avoid explaining self-evident shell statements.

Keep error messages diagnostic and event names greppable. POSIX shell has no stack trace facility, so use small functions and failure-stage logging.

Do not hard-code repository owners, Git providers or schedulers in the engine.