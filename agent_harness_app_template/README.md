# Application Name Here

Application description here.

# Feature Status Reference

| Status                       | Meaning                                            | Set by        |
| ---------------------------- | -------------------------------------------------- | ------------- |
| `NOT_STARTED`                | Queued for work                                    | Initial state |
| `IN_PROGRESS`                | Being worked on (first attempt)                    | Plan agent    |
| `PENDING_REVIEW`             | Code complete, feature tests pass, awaiting review | Code agent    |
| `REVIEW_FAILED`              | Review failed, will be retried in the next loop    | Review agent  |
| `ADDRESSING_REVIEW_COMMENTS` | Implementing fixes from latest review comments     | Plan agent    |
| `COMPLETE`                   | Review passed                                      | Review agent  |
