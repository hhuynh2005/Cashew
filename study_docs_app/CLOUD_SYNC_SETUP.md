# Firebase sync for Study Docs

The app uses SQLite as the local source of truth. After signing in with the same
Firebase Email/Password account on two app instances, it merges subjects,
document metadata, and `delete_logs` with Firestore. Newer `date_modified`
values win; a deletion wins when its timestamp is at least as new as the record.
Local edits remain available offline and are retried when connectivity returns,
the app resumes, or the user taps the sync button.

Firebase project: `cashew-study-docs-d5b15` (project number `825188339992`).
Android and web apps are registered in this project.

## Firebase Console prerequisites

1. Enable **Authentication > Email/Password**.
2. Create a **Cloud Firestore** database.
3. In Firestore Rules, review and publish `firestore.rules`. The rule file limits
   access to each signed-in user's own documents, subjects, and deletion logs.
4. In **Authentication > Settings > Authorized domains**, ensure `localhost`
   and the domain used for the web demo are allowed.

To deploy only these Firestore rules from this folder:

```powershell
firebase deploy --only firestore:rules --project cashew-study-docs-d5b15
```

Do not enable Firestore test mode or publish unrestricted rules.

## Demonstrating two-way sync

1. Run `flutter run -d chrome` from `study_docs_app`.
2. In the sync panel, create an account with an email and password. On a second
   browser profile/device, log in using the same account.
3. Add/edit a subject or document on one instance. It should appear on the other
   after its automatic sync; the panel shows upload/download counts and the last
   sync time.
4. Disable networking on one instance, edit or delete a document, then restore
   networking. The local change is retained and sync retries; confirm the
   deletion propagates to the other instance.

The web app uses browser-backed SQLite when the browser permits it. The panel
explicitly warns if the app had to fall back to in-memory storage; that state
cannot demonstrate persistent offline cache across reloads. On mobile, SQLite
is stored in the app's local database directory.

Sync currently covers document and subject metadata plus deletion tombstones.
`file_path` is device-local; the app does not upload file bytes to Cloud Storage.
Use `file_url` for documents whose file is already hosted at a shared URL.
