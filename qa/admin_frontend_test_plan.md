# Admin Frontend Test Plan

## Scope

This plan covers only the Flutter admin module under
`frontend/lib/features/admin/`. Login, registration, user-facing pet flows and
router ownership remain outside this scope.

## Preconditions

- PostgreSQL, migrations, seed, backend and Flutter web are running.
- The seeded admin account can authenticate.
- `AdminShellPage` is connected to an admin-only route by the application
  integration owner.
- The browser can reach the backend base URL.

## Automated coverage

| Area | Scenario | Expected result |
|---|---|---|
| Dashboard | Statistics load succeeds | All five values enter provider state |
| Dashboard | API returns an error | Backend detail is exposed to the UI |
| Pending pets | Admin approves a listing | Request is sent and card disappears |
| Pending pets | Delete returns `409` | Detail is shown and card remains |
| Applications | Admin chooses a status filter | Selected status is sent to the API |
| Applications | Status update fails | Detail is shown and busy state clears |
| Applications | Pending application is rendered | Only approve and reject actions appear |
| Users | Current admin is identified | Self-demotion control is disabled |
| Users | Role update succeeds | Local role state changes |
| Users | Delete returns `409` | Detail is shown and user remains |

CI runs this suite with:

```bash
flutter test test/features/admin
```

## Manual real-API E2E flow

1. Start the seeded stack and Flutter web client.
2. Sign in with the seeded admin account.
3. Open the admin panel and verify all five dashboard statistics.
4. Open Pending Pets, approve one listing and verify that its card disappears.
5. Reject a listing with linked records and verify the backend `409` detail.
6. Open Applications, filter by `pending`, approve one and then complete it.
7. Verify rejected and completed applications expose no invalid transitions.
8. Open Users and verify the signed-in admin cannot demote or delete themselves.
9. Change another user's role and verify the role chip updates.
10. Attempt to delete a user with linked records and verify the backend detail.
11. Refresh every tab and verify the persisted API state is restored.

## Exit criteria

- The admin Flutter test job is green in CI.
- Every manual real-API step passes on the final integrated application.
- The admin route is inaccessible to a regular user.
- No user-facing Flutter source file is changed by this QA task.
