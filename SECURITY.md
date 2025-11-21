# Security

RPCs `validate_invite_code` and `complete_signup` include 5-second sleeps to help protect against brute force attacks attempting to guess invite codes.

TODO: add instructions for quickly disabling access to platform during attack

TODO: in the future, add rate limiting at the cloud flare level to protect against DDOS and brute force attacks
