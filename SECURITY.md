# Security

## Brute Force Protection

RPCs `validate_invite_code` and `complete_signup` include 5-second sleeps (`pg_sleep(5)`) to help protect against brute force attacks attempting to guess invite codes. This rate limiting makes it impractical to brute force the 2.8 trillion possible alphanumeric invite codes.

Both functions are called separately during the signup flow:

- `validate_invite_code` is called first during step 1 of the onboarding wizard to validate the code before advancing
- `complete_signup` is called again when the user submits the final step, providing defense-in-depth

The PostgreSQL statement timeout for both `authenticated` and `anon` roles is set to 15 seconds to accommodate these sleeps plus query execution time.

## Signup Security

- **Invite-only access**: Only users with valid, unused invite codes can complete signup
- **Atomicity**: Signup operations (user creation, connection establishment, invite marking) occur in a single transaction
- **User profile separation**: Authenticated users without profiles (incomplete signup) are restricted by RLS from creating items, threads, or connections
- **Contact information**: Not created until signup is complete, preventing profile leakage for incomplete signups
- **Auto-generated avatars**: Using dicebear API with user's display name as seed to avoid the need to store/process uploaded avatar images during signup

## Future Improvements

TODO: add instructions for quickly disabling access to platform during attack

TODO: in the future, add rate limiting at the cloud flare level to protect against DDOS and brute force attacks
